# dotfiles

My Termux shell setup: zsh + custom `td` theme, bash fallback, shared aliases.

## Contents

| File | Purpose |
| --- | --- |
| `.zshrc` | Main zsh config (zinit, plugins, completions, PATH) |
| `.zlogin` | Login-shell extras (RVM loader) |
| `.zshenv` | Early env (XDG dirs, editor, PATH seeds) |
| `.zsh/` | Hooks (`ntfy.zsh`) and extra completions |
| `.zsh-themes/td.zsh-theme` | Custom prompt theme (exit-status RPROMPT) |
| `.aliases` | Shared aliases |
| `.shell_common` | Settings shared by bash and zsh |
| `.shell_rc_content` | Extra rc (zoxide, fzf colors, apt wrapper) |
| `.p10k.zsh` | Powerlevel10k config (kept as reference) |
| `.bashrc`, `.bash_profile`, `.profile` | Bash-side config |

## Install on a fresh Termux

```sh
git clone https://github.com/GeneralKaos666/dotfiles ~/dotfiles
cd ~/dotfiles
for f in .zshrc .zlogin .zshenv .aliases .shell_common .shell_rc_content .p10k.zsh .bashrc .bash_profile .profile; do
  cp "$f" ~/
done
cp -r .zsh .zsh-themes ~/
```

Restart Termux afterwards. Plugin manager (zinit) bootstraps itself on first launch.
