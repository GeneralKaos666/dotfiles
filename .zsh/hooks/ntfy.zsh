# NTFY Termux auto-notify hook (extracted from .zshrc)
# Discord-style: mute when watching this tab, banner in another tab, loud when away.
# Uses ~/bin/notify-decide + termux-notification. Safe to source, no output.

# Tuning (seconds)
export LONG_NOTIFY_SECS=${LONG_NOTIFY_SECS:-60}
export NTFY_IDLE_SECS=${NTFY_IDLE_SECS:-300}
# How long a keystroke keeps this tab marked "watched":
# 0=never mute, 180=safest default, 900=quiet 15min
export NTFY_FOCUS_SECS=${NTFY_FOCUS_SECS:-180}

typeset -g __ntfy_start=0
typeset -g __ntfy_cmd=""
typeset -g __ntfy_tty_cached=""

# Cache TTY once (avoids ps fork on every prompt).
# Normalised to "pts-N" to match `ps -o tty=` + notify-decide's pts-* filter.
# (tty(1) returns /dev/pts/N -> strip /dev/ or markers become "-dev-pts-N"
#  which notify-decide ignores, so mute never fires.)
if [[ -z "$__ntfy_tty_cached" ]]; then
  __ntfy_tty_cached=$(tty 2>/dev/null | sed 's|^/dev/||' | tr '/' '-' | tr -d ' ')
  if [[ "$__ntfy_tty_cached" == "notatty" || "$__ntfy_tty_cached" == *"not a tty"* ]]; then
    __ntfy_tty_cached=""
  fi
  # Fallback to ps when tty gives nothing (e.g. /dev/pts/N)
  if [[ -z "$__ntfy_tty_cached" ]]; then
    __ntfy_tty_cached=$(ps -o tty= -p $$ 2>/dev/null | tr -d ' ' | tr '/' '-')
  fi
  # ps reports "?" when there is no tty (background/subshell) - not a marker
  if [[ "$__ntfy_tty_cached" == "?" ]]; then
    __ntfy_tty_cached=""
  fi
fi

# ms timestamp with fallback (Toybox date lacks %3N)
__ntfy_now_ms() {
  local ms
  ms=$(date +%s%3N 2>/dev/null)
  if [[ "$ms" == *[!0-9]* ]]; then
    ms=$(date +%s 2>/dev/null)
    ms="${ms}000"
  fi
  printf '%s' "$ms"
}

_ntfy_preexec() {
  __ntfy_start=$EPOCHSECONDS
  __ntfy_cmd="$1"
  # Claim "human is here" - agents must never write .ntfy_user, only .ntfy_tty liveness.
  # Only pts-* names are valid (notify-decide ignores anything else).
  if [[ "$__ntfy_tty_cached" == pts-* ]]; then
    mkdir -p "$HOME/.ntfy_user" "$HOME/.ntfy_tty" 2>/dev/null
    local now_ms
    now_ms=$(__ntfy_now_ms)
    printf '%s' "$now_ms" > "$HOME/.ntfy_user/$__ntfy_tty_cached" 2>/dev/null
    printf '%s' "$now_ms" > "$HOME/.ntfy_tty/$__ntfy_tty_cached" 2>/dev/null
  fi
  date +%s > ~/.ntfy_last_active 2>/dev/null
}

_ntfy_precmd() {
  local rc=$?
  [[ -n "$__ntfy_start" && "$__ntfy_start" -gt 0 ]] || return 0
  local __ntfy_began=$__ntfy_start
  local elapsed=$(( EPOCHSECONDS - __ntfy_began ))
  __ntfy_start=0
  [[ $rc -eq 130 || $rc -eq 143 || $rc -eq 137 ]] && return 0
  # Skip full-screen TUIs you live in - opencode already notifies
  # per-turn via its plugin, so the shell must not re-ping on exit.
  local __ntfy_trimmed=${__ntfy_cmd#"${__ntfy_cmd%%[![:space:]]*}"}
  case "$__ntfy_trimmed" in opencode*|claude*|codex*|gemini*|nvim*|ssh*) return 0 ;; esac
  if (( elapsed >= LONG_NOTIFY_SECS )); then
    (( $+commands[termux-notification] )) || return 0
    [[ -x "$HOME/bin/notify-decide" ]] || return 0
    local nid
    nid=$(printf '%s' "$__ntfy_cmd" | tr -c 'a-zA-Z0-9' '-' | cut -c1-40)
    local title content
    if (( rc == 0 )); then title="DONE (${elapsed}s): ${__ntfy_cmd:0:60}"; content="Exit 0"
    else title="FAILED (${elapsed}s, code $rc): ${__ntfy_cmd:0:60}"; content="Check session"; fi
    # Refresh liveness only (never .ntfy_user): long jobs must not alert while watched
    if [[ "$__ntfy_tty_cached" == pts-* ]]; then
      mkdir -p "$HOME/.ntfy_tty" 2>/dev/null
      __ntfy_now_ms > "$HOME/.ntfy_tty/$__ntfy_tty_cached" 2>/dev/null
    fi
    local decision
    decision=$("$HOME/bin/notify-decide" "$__ntfy_tty_cached" 2>/dev/null)
    case "$decision" in
      banner)
        termux-notification --id "ntfy-$nid" --channel ntfy-silent --priority min --alert-once --title "$title" --content "$content" 2>/dev/null
        command -v termux-vibrate >/dev/null 2>&1 && termux-vibrate -d 400 2>/dev/null
        ;;
      mute) : ;;
      *)
        termux-notification --id "ntfy-$nid" --alert-once --title "$title" --content "$content" --sound 2>/dev/null
        command -v termux-vibrate >/dev/null 2>&1 && termux-vibrate -d 400 2>/dev/null
        ;;
    esac
  fi
}

# Use hooks (not direct preexec/precmd) so theme vcs_info keeps working
autoload -Uz add-zsh-hook 2>/dev/null && {
  add-zsh-hook preexec _ntfy_preexec
  add-zsh-hook precmd _ntfy_precmd
}

# Background job with buzz on finish. Spec name is nohup() so
# `nohup longjob &` auto-buzzes; buzz-bg kept as explicit alias.
nohup() {
  command nohup "$@" &
  local pid=$!
  ( while kill -0 $pid 2>/dev/null; do sleep 30; done
    ~/bin/buzz "DONE (bg): $1" "background job finished" ) >/dev/null 2>&1 &
  echo "bg pid $pid (buzz armed)"
}
buzz-bg() {
  nohup "$@"
}
