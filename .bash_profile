
[[ -s "$HOME/.profile" ]] && source "$HOME/.profile" # Load the default .profile

[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*

. "$HOME/.local/share/../bin/env"

# GitHub Copilot CLI - keytar bypass for Termux
export NODE_OPTIONS="${NODE_OPTIONS:+$NODE_OPTIONS }--require $HOME/.copilot-hooks/keytar-bypass.js"
. "$HOME/.cargo/env"

# Cross-shell compatibility (added by aidevops setup)
# Shared profile - edit ~/.shell_common for settings in both shells
[ -f "$HOME/.shell_common" ] && . "$HOME/.shell_common"
