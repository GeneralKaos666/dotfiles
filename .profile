. "$HOME/.cargo/env"

# Add RVM to PATH for scripting. Make sure this is the last PATH variable change.
export PATH="$PATH:$HOME/.rvm/bin"


. "$HOME/.local/share/../bin/env"

# Cross-shell compatibility (added by aidevops setup)
# Shared profile - edit ~/.shell_common for settings in both shells
[ -f "$HOME/.shell_common" ] && . "$HOME/.shell_common"
export PATH="/data/data/com.termux/files/home/.dsh-mini/bin:$PATH"
