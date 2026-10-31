# td.zsh-theme - fast two-line prompt for Termux and proot-distro.
#
# vcs_info costs ~37 ms per prompt on this device, so git state is not read on
# the prompt path. It lives in a per-directory cache that a background job
# refreshes; `cd` seeds the branch synchronously (~10 ms) so the first prompt
# inside a repo is never blank.

zmodload zsh/datetime 2>/dev/null
autoload -Uz add-zsh-hook
setopt PROMPT_SUBST

# ---------------------------------------------------------------- platform ---
typeset -g TD_DISTRO_ICON TD_DISTRO_NAME

_td_detect_platform() {
  emulate -L zsh
  local id='' line=''

  # Termux has no /etc/os-release, and Android reports the app uid as user.
  if [[ -n $PREFIX && $PREFIX == */com.termux/* ]]; then
    TD_DISTRO_NAME=termux
    TD_DISTRO_ICON=$'\U000f0032'          # android
    return
  fi

  if [[ -r /etc/os-release ]]; then
    for line in "${(@f)$(</etc/os-release)}"; do
      [[ $line == ID=* ]] || continue
      id=${line#ID=}
      id=${id//\"/}
      break
    done
  fi

  TD_DISTRO_NAME=${id:-linux}
  case $id in
    kali)           TD_DISTRO_ICON=$'\uf327' ;;
    arch*|manjaro)  TD_DISTRO_ICON=$'\ue732' ;;
    ubuntu)         TD_DISTRO_ICON=$'\uf31b' ;;
    debian)         TD_DISTRO_ICON=$'\uf306' ;;
    fedora)         TD_DISTRO_ICON=$'\uf30a' ;;
    alpine)         TD_DISTRO_ICON=$'\uf300' ;;
    void)           TD_DISTRO_ICON=$'\uf32e' ;;
    opensuse*|sles) TD_DISTRO_ICON=$'\uf314' ;;
    gentoo)         TD_DISTRO_ICON=$'\uf30d' ;;
    nixos)          TD_DISTRO_ICON=$'\uf313' ;;
    *)              TD_DISTRO_ICON=$'\uf31a' ;;   # tux
  esac
}
_td_detect_platform

# Android reports u0_a1391, not the person, so Termux keeps the configured
# name; everywhere else the real login name is correct. TD_USER overrides both.
if [[ $TD_DISTRO_NAME == termux ]]; then
  typeset -g TD_USER=${TD_USER:-kaos666}
else
  typeset -g TD_USER=${TD_USER:-%n}
fi

typeset -g TD_USERHOST="%F{cyan}${TD_USER}%f"
[[ -n $SSH_CONNECTION ]] && TD_USERHOST+="%F{yellow}@%F{cyan}%m%f"

# --------------------------------------------------------------------- git ---
: ${XDG_CACHE_HOME:=$HOME/.cache}
typeset -g TD_GIT_CACHE_DIR="$XDG_CACHE_HOME/zsh/git"
[[ -d $TD_GIT_CACHE_DIR ]] || command mkdir -p -- "$TD_GIT_CACHE_DIR" 2>/dev/null

typeset -g TD_GIT_SEG='' TD_GIT_KEY='' TD_GIT_REPO=0 TD_GIT_PID='' TD_GIT_LAST=0
typeset -g TD_BRANCH_ICON=$'\ue0a0'
typeset -g TD_TIMER_ICON=$'\U000f051b'

# Cache file: line 1 = rendered git segment, line 2 = "1" when this is a repo.
_td_git_worker() {
  emulate -L zsh
  local dir=$1 out=$2 tmp="$2.tmp.$$" line='' branch='' oid='' ab='' seg=''
  local -a lines
  lines=( "${(@f)$(command git -C "$dir" --no-optional-locks status --porcelain=v2 --branch 2>/dev/null)}" )

  if (( ${#lines} )); then
    local ahead=0 behind=0 dirty=0 untracked=0 conflict=0
    for line in "${lines[@]}"; do
      case $line in
        '# branch.head '*) branch=${line#'# branch.head '} ;;
        '# branch.oid '*)  oid=${line#'# branch.oid '} ;;
        '# branch.ab '*)
          ab=${line#'# branch.ab '}
          ahead=${${ab%% *}#+}
          behind=${${ab##* }#-}
          ;;
        '1 '*|'2 '*) dirty=1 ;;
        'u '*)       conflict=1 ;;
        '? '*)       untracked=1 ;;
      esac
    done

    [[ $branch == '(detached)' ]] && branch="@${oid[1,7]}"
    [[ -n $branch ]] && branch=${branch//\%/%%}

    if [[ -n $branch ]]; then
      seg=" %F{magenta}${TD_BRANCH_ICON} ${branch}%f"
      (( conflict ))  && seg+="%F{red}✘%f"
      (( dirty ))     && seg+="%F{red}●%f"
      (( untracked )) && seg+="%F{yellow}?%f"
      (( ahead ))     && seg+="%F{yellow}⇡${ahead}%f"
      (( behind ))    && seg+="%F{yellow}⇣${behind}%f"
      [[ -s $dir/.git/logs/refs/stash ]] && seg+="%F{cyan}⚑%f"
    fi
  fi

  {
    print -r -- "$seg"
    print -r -- "$(( ${#lines} ? 1 : 0 ))"
  } >| "$tmp" && command mv -f -- "$tmp" "$out" 2>/dev/null
}

_td_git_spawn() {
  local file=$1
  # One worker at a time: never queue git processes while the user types.
  if [[ -n $TD_GIT_PID ]] && kill -0 "$TD_GIT_PID" 2>/dev/null; then
    return
  fi
  TD_GIT_LAST=$EPOCHSECONDS
  ( _td_git_worker "$PWD" "$file" ) &!
  TD_GIT_PID=$!
}

_td_git_update() {
  emulate -L zsh
  local key=${PWD//\//%}
  key=${key#%}
  local file="$TD_GIT_CACHE_DIR/${key:-_root}"
  local -a c

  if [[ $PWD != $TD_GIT_KEY ]]; then
    TD_GIT_KEY=$PWD
    TD_GIT_SEG='' TD_GIT_REPO=0
    if [[ -r $file ]]; then
      c=( "${(@f)$(<$file)}" )
      TD_GIT_SEG=${c[1]}
      TD_GIT_REPO=${c[2]:-0}
    else
      local branch
      branch=$(command git -C "$PWD" symbolic-ref --short -q HEAD 2>/dev/null)
      if [[ -z $branch ]]; then
        branch=$(command git -C "$PWD" rev-parse --short HEAD 2>/dev/null)
        [[ -n $branch ]] && branch="@$branch"
      fi
      if [[ -n $branch ]]; then
        TD_GIT_REPO=1
        TD_GIT_SEG=" %F{magenta}${TD_BRANCH_ICON} ${branch//\%/%%}%f"
      fi
    fi
    _td_git_spawn "$file"
  elif (( EPOCHSECONDS - TD_GIT_LAST >= (TD_GIT_REPO ? 1 : 2) )); then
    _td_git_spawn "$file"
  fi
}

# ------------------------------------------------------------------ prompt ---
typeset -g TD_EXIT=0 TD_SYMBOL='' TD_RPROMPT='' TD_DUR='' TD_VENV='' TD_JOBS=''
typeset -g TD_CMD_START=0

_td_preexec() {
  TD_CMD_START=$EPOCHSECONDS
}

_td_precmd() {
  TD_EXIT=$?          # must stay first: every command below would clobber it
  emulate -L zsh
  _td_git_update

  TD_DUR=''
  if (( TD_CMD_START > 0 )); then
    local dur=$(( EPOCHSECONDS - TD_CMD_START ))
    (( dur >= 2 )) && TD_DUR=" %F{242}${TD_TIMER_ICON} ${dur}s%f"
    TD_CMD_START=0
  fi

  TD_VENV=''
  if [[ -n $VIRTUAL_ENV ]]; then
    TD_VENV=" %F{blue}${VIRTUAL_ENV:t}%f"
  elif [[ -n $CONDA_DEFAULT_ENV ]]; then
    TD_VENV=" %F{blue}${CONDA_DEFAULT_ENV}%f"
  fi

  # %j / %(1j...) render empty outside a real prompt, so count jobs directly.
  TD_JOBS=''
  (( ${#jobstates} )) && TD_JOBS=" %F{blue}${#jobstates}⚙%f"

  if (( TD_EXIT )); then
    TD_SYMBOL='%F{red}❯%f'
    TD_RPROMPT="%F{red}✘ ${TD_EXIT}%f"
  else
    TD_SYMBOL='%F{green}❯%f'
    TD_RPROMPT=''
  fi
}

_td_chpwd() {
  TD_GIT_KEY=''
  _td_git_update
}

add-zsh-hook preexec _td_preexec
add-zsh-hook precmd  _td_precmd
add-zsh-hook chpwd   _td_chpwd

PROMPT='
%B%F{green}╭─%b%f %F{blue}[%f${TD_USERHOST} %F{yellow}${TD_DISTRO_ICON}%f%F{blue}]%f %F{blue}[%f%F{yellow}%~%f%F{blue}]%f${TD_GIT_SEG}${TD_DUR}${TD_VENV}${TD_JOBS}
%B%F{green}╰─%b%f${TD_SYMBOL} '

RPROMPT='${TD_RPROMPT}'
