#!/usr/bin/env bash
# install.sh — backup-safe installer for the Termux SilkCircuit dotfiles.
# Usage: bash install.sh (no args). Idempotent: every run backs up again.
# Never overwrites without backup; never symlinks colors.properties.
set -u
shopt -s dotglob nullglob # globs must match dotfiles (shell/bash/* etc.)

DOTFILES="$(cd "$(dirname "$0")" && pwd)"
BACKUP="$HOME/.dotfiles.bak-$(date +%F-%H%M%S)-$$"

# Non-Termux fallback: no $PREFIX and no termux-reload-settings on PATH.
# Print manual cp instructions, change nothing, exit 0.
if [ -z "${PREFIX:-}" ] && ! command -v termux-reload-settings >/dev/null 2>&1; then
	cat <<EOF
Not on Termux (no \$PREFIX and no termux-reload-settings on PATH).
Manual install with cp from "$DOTFILES":
  cp "$DOTFILES/shell/zsh/.zshrc" "$DOTFILES/shell/zsh/.zlogin" "$DOTFILES/shell/zsh/.zshenv" "$DOTFILES/shell/zsh/.p10k.zsh" "\$HOME/"
  cp -r "$DOTFILES/shell/zsh/.zsh" "$DOTFILES/shell/zsh/.zsh-themes" "\$HOME/"
  cp "$DOTFILES/shell/bash/"* "\$HOME/"
  cp "$DOTFILES/shell/shared/"* "\$HOME/"
  cp "$DOTFILES/tmux/.tmux.conf" "\$HOME/.tmux.conf"
  mkdir -p "\$HOME/.termux/colors" "\$HOME/.config/fastfetch" "\$HOME/.config/nvim"
  cp "$DOTFILES/termux/termux.properties" "\$HOME/.termux/"
  cp "$DOTFILES/termux/colors/"*.properties "\$HOME/.termux/colors/"
  cp "$DOTFILES/termux/colors/silkcircuit-vibrant.properties" "\$HOME/.termux/colors.properties"
  cp "$DOTFILES/termux/font.ttf" "\$HOME/.termux/font.ttf"
  cp "$DOTFILES/fastfetch/config.jsonc" "\$HOME/.config/fastfetch/"
  cp -r "$DOTFILES/nvim/"* "\$HOME/.config/nvim/"
EOF
	exit 0
fi

mkdir -p "$BACKUP" "$HOME/.termux" "$HOME/.termux/colors" "$HOME/.config/fastfetch" "$HOME/.config/nvim"

# backup_copy SRC DST: move existing DST aside into $BACKUP, then copy.
# Directories copy with cp -r; missing sources warn and skip.
backup_copy() {
	local src="$1"
	local dst="$2"
	if [ ! -e "$src" ]; then
		echo "warn: missing source, skipping: $src" >&2
		return 0
	fi
	if [ -e "$dst" ] || [ -L "$dst" ]; then
		mv "$dst" "$BACKUP/"
	fi
	if [ -d "$src" ]; then
		cp -r "$src" "$dst"
	else
		cp "$src" "$dst"
	fi
}

# Shell: zsh core files, zsh dirs, bash + shared dotfiles.
backup_copy "$DOTFILES/shell/zsh/.zshrc" "$HOME/.zshrc"
backup_copy "$DOTFILES/shell/zsh/.zlogin" "$HOME/.zlogin"
backup_copy "$DOTFILES/shell/zsh/.zshenv" "$HOME/.zshenv"
backup_copy "$DOTFILES/shell/zsh/.p10k.zsh" "$HOME/.p10k.zsh"
backup_copy "$DOTFILES/shell/zsh/.zsh" "$HOME/.zsh"
backup_copy "$DOTFILES/shell/zsh/.zsh-themes" "$HOME/.zsh-themes"
for f in "$DOTFILES"/shell/bash/*; do
	[ -e "$f" ] || continue
	backup_copy "$f" "$HOME/$(basename "$f")"
done
for f in "$DOTFILES"/shell/shared/*; do
	[ -e "$f" ] || continue
	backup_copy "$f" "$HOME/$(basename "$f")"
done

# tmux.
backup_copy "$DOTFILES/tmux/.tmux.conf" "$HOME/.tmux.conf"

# Termux app config.
backup_copy "$DOTFILES/termux/termux.properties" "$HOME/.termux/termux.properties"
for f in "$DOTFILES"/termux/colors/*; do
	[ -e "$f" ] || continue
	backup_copy "$f" "$HOME/.termux/colors/$(basename "$f")"
done
# Vibrant palette as the active colors.properties — plain cp via backup_copy,
# so any pre-existing symlink is moved aside and the result is a regular file.
backup_copy "$DOTFILES/termux/colors/silkcircuit-vibrant.properties" "$HOME/.termux/colors.properties"
backup_copy "$DOTFILES/termux/font.ttf" "$HOME/.termux/font.ttf"

# fastfetch.
backup_copy "$DOTFILES/fastfetch/config.jsonc" "$HOME/.config/fastfetch/config.jsonc"

# nvim snapshot (files and dirs; repo copy holds no .git/.superpowers/docs).
for f in "$DOTFILES"/nvim/*; do
	[ -e "$f" ] || continue
	backup_copy "$f" "$HOME/.config/nvim/$(basename "$f")"
done

if command -v termux-reload-settings >/dev/null 2>&1; then
	termux-reload-settings
fi

echo "Installed from $DOTFILES."
echo "Previous files (if any) were moved to: $BACKUP"
echo "To restore: copy files back from $BACKUP, then restart Termux."
