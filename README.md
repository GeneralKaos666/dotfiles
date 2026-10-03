# Termux SilkCircuit Dotfiles

![Termux](https://img.shields.io/badge/Termux-000000?style=flat&logo=android&logoColor=white)
![zsh](https://img.shields.io/badge/shell-zsh-blue)
![MIT](https://img.shields.io/badge/license-MIT-green)

Neon-on-near-black Termux setup: zsh + custom `td` theme (bash fallback), tmux,
fastfetch, Neovim snapshot, and the SilkCircuit color family — wired up by a
backup-safe `install.sh`.

## Screenshots

> screenshots pending — drop phone captures here

| Shell | tmux |
| --- | --- |
| ![shell](screenshots/shell.png) | ![tmux](screenshots/tmux.png) |

| fastfetch | Palette |
| --- | --- |
| ![fastfetch](screenshots/fastfetch.png) | ![palette](screenshots/palette.png) |

## SilkCircuit Palette (vibrant)

| Name | Hex |
| --- | --- |
| `background` | `#0f0c1a` |
| `foreground` | `#d0a8f0` |
| `cursor` | `#ff00ff` |
| `color0` | `#0f0c1a` |
| `color1` | `#ff66ff` |
| `color2` | `#00ff66` |
| `color3` | `#ffcc00` |
| `color4` | `#ff00ff` |
| `color5` | `#ff00cc` |
| `color6` | `#00ffcc` |
| `color7` | `#b890e0` |
| `color8` | `#637777` |
| `color9` | `#ff3366` |
| `color10` | `#66ff99` |
| `color11` | `#ffff66` |
| `color12` | `#88aaff` |
| `color13` | `#ff66ff` |
| `color14` | `#00ffff` |
| `color15` | `#e0c0ff` |

Exact values (from `termux/colors/silkcircuit-vibrant.properties`):

```properties
background=#0f0c1a
foreground=#d0a8f0
cursor=#ff00ff
color0=#0f0c1a
color1=#ff66ff
color2=#00ff66
color3=#ffcc00
color4=#ff00ff
color5=#ff00cc
color6=#00ffcc
color7=#b890e0
color8=#637777
color9=#ff3366
color10=#66ff99
color11=#ffff66
color12=#88aaff
color13=#ff66ff
color14=#00ffff
color15=#e0c0ff
```

Five variants ship under `termux/colors/`: vibrant (default), neon, glow, soft, dawn.

## Features

- zsh first (zinit, plugins, completions), bash fallback, shared aliases
- Custom `td` prompt theme with exit-status RPROMPT
- tmux config tuned for Termux touch keyboards
- fastfetch config in SilkCircuit colors
- Neovim config snapshot (lazy.nvim, LSP, snippets)
- Backup-safe installer — existing files are moved aside, never overwritten

## Contents

| Path | Purpose |
| --- | --- |
| `shell/zsh` | Main zsh config (zinit, plugins, completions, PATH) + `td` theme |
| `shell/bash` | Bash-side config (`.bashrc`, `.bash_profile`, `.profile`) |
| `shell/shared` | Settings shared by bash and zsh (aliases, common rc) |
| `termux` | `termux.properties`, `font.ttf`, SilkCircuit color variants |
| `tmux` | tmux config (`.tmux.conf`) |
| `nvim` | Neovim config snapshot (`init.lua`, `lua/`, `snippets/`) |
| `fastfetch` | fastfetch config (`config.jsonc`) |

## Install

```sh
git clone https://github.com/GeneralKaos666/dotfiles ~/dotfiles && ~/dotfiles/install.sh
```

Restart Termux afterwards. Plugin manager (zinit) bootstraps itself on first launch.

## Termux Notes

- The installer copies `termux/font.ttf` to `~/.termux/font.ttf` and the
  vibrant variant to `~/.termux/colors.properties` (never symlinked, so theme
  switchers keep working).
- Apply colors/font immediately without restarting:
  `termux-reload-settings`.
- Other variants (`neon`, `glow`, `soft`, `dawn`) live in
  `~/dotfiles/termux/colors/` — copy one over `~/.termux/colors.properties`
  and run `termux-reload-settings` to preview.

## Restore

Every `install.sh` run moves pre-existing files into a timestamped backup
directory (`~/.dotfiles.bak-*`). To undo, copy the files back from the newest
backup, e.g. `cp ~/.dotfiles.bak-*/.zshrc ~/`.

## Credits

Built by GeneralKaos666. SilkCircuit palette, `termux/colors/silkcircuit-*` files, and `fastfetch/config.jsonc` derive from [SilkCircuit](https://github.com/hyperb1iss/silkcircuit) by hyperb1iss (MIT), including the hyperb1iss/silkcircuit generator noted in the fastfetch config header. Released under the MIT License — see [LICENSE](LICENSE).
