# =============================================================================
# ZSH Configuration File (.zshrc) - cleaned/sorted 2026-10-01
# Backup: ~/.zshrc.bak-20261001
# Sections: 0 guard | 1 opts+history | 2 PATH/env | 3 zinit | 4 plugins
#           5 completion | 6 compinit | 7 theme | 8 shared sources
#           9 ssh/gpg/java/android | 10 lazy completions | 11 aliases
#           12 opam | 13 ntfy | 14 local
# =============================================================================

# 0. Non-interactive guard (scp/git/CI must not run plugins, ssh-agent, gpg)
[[ $- != *i* ]] && return

# -----------------------------------------------------------------------------
# 1. Options & history
# -----------------------------------------------------------------------------
setopt AUTO_CD
setopt NO_NOMATCH
setopt EXTENDED_GLOB
setopt AUTO_LIST AUTO_MENU

HISTFILE="$HOME/.zsh_history"
HISTSIZE=50000
SAVEHIST=50000
setopt SHARE_HISTORY INC_APPEND_HISTORY
setopt HIST_IGNORE_DUPS HIST_IGNORE_SPACE HIST_REDUCE_BLANKS

bindkey '^Z' undo          # NOTE: shadows suspend (Ctrl-Z job control)
bindkey '^Y' redo
bindkey ' ' magic-space    # NOTE: expands !! on space

# -----------------------------------------------------------------------------
# 2. PATH / env (early, deduped)
# -----------------------------------------------------------------------------
typeset -U path PATH

# User dirs first (i-HakLab wrappers in ~/.local/bin must win)
path=("$HOME/bin" "$HOME/.local/bin" $path)

[[ -d "$HOME/.cargo/bin" ]] && path+=("$HOME/.cargo/bin")
[[ -d "$HOME/.pub-cache/bin" ]] && path+=("$HOME/.pub-cache/bin")
[[ -d "$HOME/.cache/.bun/bin" ]] && path=("$HOME/.cache/.bun/bin" $path)
[[ -d "$HOME/bin" ]] || true  # $HOME/bin already prepended; guard for clarity

export LANG=C.UTF-8
# LC_ALL intentionally unset (overrides everything, breaks per-category)

# -----------------------------------------------------------------------------
# 3. Zinit bootstrap (ZINIT vars BEFORE source so optimize flag applies)
# -----------------------------------------------------------------------------
typeset -gAH ZINIT
ZINIT[HOME_DIR]="$HOME/.local/share/zinit"
ZINIT[BIN_DIR]="$ZINIT[HOME_DIR]/zinit.git"
ZINIT[COMPLETIONS_DIR]="$ZINIT[HOME_DIR]/completions"
ZINIT[SNIPPETS_DIR]="$ZINIT[HOME_DIR]/snippets"
ZINIT[ZCOMPDUMP_PATH]="$ZINIT[HOME_DIR]/zcompdump"
ZINIT[PLUGINS_DIR]="$ZINIT[HOME_DIR]/plugins"
ZINIT[OPTIMIZE_OUT_DISK_ACCESSES]=1

ZI_REPO='zdharma-continuum'

if [[ ! -f "$HOME/.local/share/zinit/zinit.git/zinit.zsh" ]]; then
    if [[ -z "$P9K_INSTANT_PROMPT" ]]; then
        print -P "%F{33}Installing %F{220}ZDHARMA-CONTINUUM%F{220} Initiative Plugin Manager...%f"
        if command mkdir -p "$HOME/.local/share/zinit" && command chmod g-rwX "$HOME/.local/share/zinit"; then
            if command git clone https://github.com/zdharma-continuum/zinit "$HOME/.local/share/zinit/zinit.git"; then
                print -P "%F{33}Installation successful.%f"
            else
                print -P "%F{160}Git clone failed. Please check your internet connection and try again.%f"
                return 1
            fi
        else
            print -P "%F{160}Failed to create zinit directory.%f"
            return 1
        fi
    else
        command mkdir -p "$HOME/.local/share/zinit" && command chmod g-rwX "$HOME/.local/share/zinit"
        command git clone https://github.com/zdharma-continuum/zinit "$HOME/.local/share/zinit/zinit.git" >/dev/null 2>&1
    fi
fi

source "$HOME/.local/share/zinit/zinit.git/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

# -----------------------------------------------------------------------------
# 4. Plugins
# -----------------------------------------------------------------------------
zi for is-snippet \
    OMZL::{compfix,completion,git,key-bindings}.zsh \
    PZT::modules/{history}

# TODO: drop terraform/_terraform if you don't use terraform (saves startup)
zi as'completion' for \
    OMZP::{pip/_pip,terraform/_terraform}

# Annexes only needed for ice:dl/patch/submods. Drop if unused.
zi light-mode for \
    "$ZI_REPO"/zinit-annex-{binary-symlink,patch-dl,submods}

zi light zsh-users/zsh-completions

ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=50
zi light zsh-users/zsh-autosuggestions
bindkey "^_" autosuggest-execute
bindkey "^ " autosuggest-accept

zi light-mode for \
    $ZI_REPO/fast-syntax-highlighting

# -----------------------------------------------------------------------------
# 5. Completion styling + arrow menus
# -----------------------------------------------------------------------------
if [[ "$LS_COLORS" != *ma=45* ]]; then
  export LS_COLORS="${LS_COLORS:-di=1;34:ln=1;36:ex=1;32:so=1;35:pi=33:bd=1;33;40:cd=1;33;40}:ma=45;30"
fi

zmodload zsh/complist
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'

# Down: file menu
zle -C files-menu menu-select _generic
zstyle ':completion:files-menu:*' completer _files
[[ -n "$terminfo[kcud1]" ]] && bindkey "$terminfo[kcud1]" files-menu
bindkey "^[[B" files-menu

# Up: last 20 unique commands (was fc -100 then slice; direct -20 is faster)
_custom_history_completer() {
  local -a h_items
  h_items=(${(u)${(f)"$(fc -ln -20 -1)"}})
  local expl
  _description -V custom-history expl 'recent commands'
  compadd "$expl[@]" -Q -a h_items
}
zle -C history-menu menu-select _generic
zstyle ':completion:history-menu:*' completer _custom_history_completer
zstyle ':completion:*:custom-history' list-colors '=(#b)([^ ]##) (*)=0=1;32=36' '=(#b)([^ ]##)=0=1;32'
[[ -n "$terminfo[kcuu1]" ]] && bindkey "$terminfo[kcuu1]" history-menu
bindkey "^[[A" history-menu

unset ZI_REPO

# -----------------------------------------------------------------------------
# 6. Completion system (cached; restores plugin completions)
# -----------------------------------------------------------------------------
autoload -Uz compinit
compinit -C -d "${ZINIT[ZCOMPDUMP_PATH]:-$HOME/.local/share/zinit/zcompdump}"
zinit cdreplay -q 2>/dev/null

# -----------------------------------------------------------------------------
# 7. Theme (guarded; precmd preserved - NTFY uses add-zsh-hook so vcs_info lives)
# -----------------------------------------------------------------------------
[[ -f "$HOME/.zsh-themes/td.zsh-theme" ]] && source "$HOME/.zsh-themes/td.zsh-theme"

# -----------------------------------------------------------------------------
# 8. Shared sources (aliases/functions live in .aliases; desktop/fzf in rc)
# -----------------------------------------------------------------------------
[[ -f "$HOME/.shell_rc_content" ]] && source "$HOME/.shell_rc_content"
[[ -f "$HOME/.aliases" ]] && source "$HOME/.aliases"

# -----------------------------------------------------------------------------
# 9. SSH / GPG / Java / Android (all guarded, Termux paths via $PREFIX)
# -----------------------------------------------------------------------------
# Single ssh-agent socket (avoids orphan agent per terminal)
export SSH_AUTH_SOCK="$HOME/.ssh/agent.sock"
if ! ssh-add -l >/dev/null 2>&1; then
  mkdir -p "$HOME/.ssh" 2>/dev/null
  if [[ -S "$SSH_AUTH_SOCK" ]]; then
    # Stale socket - start fresh
    rm -f "$SSH_AUTH_SOCK" 2>/dev/null
    eval "$(ssh-agent -s -a "$SSH_AUTH_SOCK")" >/dev/null 2>&1
  else
    # Reuse running agent or start one on fixed socket
    if [[ -z "$SSH_AUTH_SOCK" ]]; then
      eval "$(ssh-agent -s)" >/dev/null 2>&1
    else
      eval "$(ssh-agent -s -a "$SSH_AUTH_SOCK")" >/dev/null 2>&1
    fi
  fi
fi

# GPG: TTY only, never clearsign on startup (was slow + hung non-tty)
if tty -s 2>/dev/null; then
  export GPG_TTY=$(tty)
else
  export GPG_TTY="${TTY:-}"
fi

# Java (only if dir exists; avoids wrong PATH when JDK version changes)
if command -v java >/dev/null 2>&1; then
  [[ -d "$PREFIX/lib/jvm/java-21-openjdk" ]] && export JAVA_HOME="$PREFIX/lib/jvm/java-21-openjdk"
fi
[[ -n "$JAVA_HOME" && -d "$JAVA_HOME/bin" ]] && path=("$JAVA_HOME/bin" $path)

# Guard against stale SDK root from parent envs
unset ANDROID_SDK_ROOT
export ANDROID_HOME="$PREFIX/opt/android-sdk"
export ANDROID_NDK_HOME="$ANDROID_HOME/ndk/29.0.14206865"
export ANDROID_USER_HOME="$HOME/.android"
export GRADLE_USER_HOME="$HOME/.gradle"
[[ -d "$ANDROID_HOME/cmdline-tools/latest/bin" ]] && path=("$ANDROID_HOME/cmdline-tools/latest/bin" "$ANDROID_HOME/platform-tools" $path)
[[ -d "$PREFIX/opt/android-studio/bin" ]] && path+=("$PREFIX/opt/android-studio/bin")
export CHROME_EXECUTABLE=/data/data/com.termux/files/usr/bin/chromium-browser
# -----------------------------------------------------------------------------
# 10. Shell completions (lazy: guarded; each forks - keep list minimal)
# -----------------------------------------------------------------------------
(( $+commands[omp] )) && eval "$(omp completions zsh)"
(( $+commands[gh] )) && eval "$(gh completion -s zsh)"
(( $+commands[rbw] )) && eval "$(rbw gen-completions zsh)"
(( $+commands[dev] )) && eval "$(dev completion zsh)"
(( $+commands[pnpm] )) && eval "$(pnpm completion zsh)"
(( $+commands[mise] )) && eval "$(mise activate zsh)"
# zoxide init lives in ~/.shell_rc_content - guard there if slow:
# (( $+commands[zoxide] )) && eval "$(zoxide init --cmd cd zsh)"

# -----------------------------------------------------------------------------
# 11. Aliases (minimal here; bulk lives in ~/.aliases)
# -----------------------------------------------------------------------------
# NOTE: grep=rg breaks `grep -E` style flags and theme os-release parse.
# Use `command grep` in scripts. Theme should use `command grep`.
alias grep="rg"
alias lsd="eza --icons auto"
alias oc="opencode"
# Removed: duplicate `alias grep="rgu -uuu"` (rgu not installed),
#          duplicate `alias ls` (owned by ~/.aliases),
#          `alias pnpm='pnpm --config.pmOnFail=ignore'` (hid failures, broke completion)

# -----------------------------------------------------------------------------
# 12. opam (lazy, fixed redirect)
# -----------------------------------------------------------------------------
(( $+commands[opam] )) && [[ -r "$HOME/.opam/opam-init/init.zsh" ]] && source "$HOME/.opam/opam-init/init.zsh" >/dev/null 2>&1

# -----------------------------------------------------------------------------
# 13. Termux notify hooks (extracted; uses add-zsh-hook so theme precmd survives)
# -----------------------------------------------------------------------------
[[ -f "$HOME/.zsh/hooks/ntfy.zsh" ]] && source "$HOME/.zsh/hooks/ntfy.zsh"

# -----------------------------------------------------------------------------
# 14. Local overrides (not in git)
# -----------------------------------------------------------------------------
[[ -f "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local" || true
