# Termux Dotfiles

![Termux](https://img.shields.io/badge/Termux-000000?style=flat&logo=android&logoColor=white)
![zsh](https://img.shields.io/badge/shell-zsh-blue)
![MIT](https://img.shields.io/badge/license-MIT-green)

Neon-on-near-black Termux setup: zsh with custom `td` theme
(bash fallback), tmux, fastfetch, Neovim snapshot, Violet Overdrive colors
(SilkCircuit variants included). `install.sh` wires it up.

## Screenshots

| shell | tmux |
| --- | --- |
| ![shell](screenshots/shell.jpg) | ![tmux](screenshots/tmux.jpg) |

| fastfetch | nvim |
| --- | --- |
| ![fastfetch](screenshots/fastfetch.jpg) | ![nvim](screenshots/nvim.jpg) |

| palette |
| --- |
| ![palette](screenshots/palette.jpg) |

## Violet Overdrive Palette (default)

True black base, full-chroma neon pop layer, one purple in the highlight half.

| Name | Hex |
| --- | --- |
| `background` | `#000000` |
| `foreground` | `#ede6ff` |
| `cursor` | `#a855f7` |
| `color0` | `#0d0714` |
| `color1` | `#ff2e63` |
| `color2` | `#00ff9c` |
| `color3` | `#ffe600` |
| `color4` | `#2e9bff` |
| `color5` | `#ff2ed1` |
| `color6` | `#00f0ff` |
| `color7` | `#d8ccf0` |
| `color8` | `#8a8f9e` |
| `color9` | `#ff6fae` |
| `color10` | `#5cffc0` |
| `color11` | `#fff566` |
| `color12` | `#7ab8ff` |
| `color13` | `#c77dff` |
| `color14` | `#7affff` |
| `color15` | `#ffffff` |

Exact values (from `termux/colors/violet-overdrive.properties`):

```properties
background=#000000
foreground=#EDE6FF
cursor=#A855F7
color0=#0D0714
color1=#FF2E63
color2=#00FF9C
color3=#FFE600
color4=#2E9BFF
color5=#FF2ED1
color6=#00F0FF
color7=#D8CCF0
color8=#8A8F9E
color9=#FF6FAE
color10=#5CFFC0
color11=#FFF566
color12=#7AB8FF
color13=#C77DFF
color14=#7AFFFF
color15=#FFFFFF
```

## SilkCircuit Palette (alternative)

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

`termux/colors/` holds six palettes: violet-overdrive (default), plus the
SilkCircuit variants — vibrant, neon, glow, soft, dawn.

## Features

- zsh first (zinit, plugins, completions), bash fallback, shared aliases
- Custom `td` prompt theme, exit status in RPROMPT
- tmux config for Termux touch keyboards
- fastfetch in SilkCircuit colors
- Neovim snapshot (lazy.nvim, LSP, snippets)
- Installer moves old files aside, overwrites nothing

## Contents

| Path | Purpose |
| --- | --- |
| `shell/zsh` | Main zsh config (zinit, plugins, completions, PATH) + `td` theme |
| `shell/bash` | Bash-side config (`.bashrc`, `.bash_profile`, `.profile`) |
| `shell/shared` | Settings shared by bash and zsh (aliases, common rc) |
| `termux` | `termux.properties`, `font.ttf`, color palettes (Violet Overdrive default) |
| `tmux` | tmux config (`.tmux.conf`) |
| `nvim` | Neovim config snapshot (`init.lua`, `lua/`, `snippets/`) |
| `fastfetch` | fastfetch config (`config.jsonc`) |

## Install

```sh
git clone https://github.com/GeneralKaos666/dotfiles ~/dotfiles && ~/dotfiles/install.sh
```

Restart Termux. Zinit pulls plugins on first launch.

## Termux Notes

- The installer copies `termux/font.ttf` to `~/.termux/font.ttf` and the
  violet-overdrive palette to `~/.termux/colors.properties`. Plain copies,
  no symlinks, so theme switchers keep control.
- Apply colors/font with no restart:
  `termux-reload-settings`.
- Other palettes (`silkcircuit-vibrant`, `neon`, `glow`, `soft`, `dawn`) sit
  in `~/dotfiles/termux/colors/`. Preview: copy one to
  `~/.termux/colors.properties`, then run `termux-reload-settings`.

## Restore

`install.sh` moves old files to a timestamped backup
directory (`~/.dotfiles.bak-*`). To undo, copy files back from the newest
backup, e.g. `cp ~/.dotfiles.bak-*/.zshrc ~/`.

## Credits

GeneralKaos666 built this. The SilkCircuit palette, `termux/colors/silkcircuit-*` files, and `fastfetch/config.jsonc` come from [SilkCircuit](https://github.com/hyperb1iss/silkcircuit) by hyperb1iss (MIT). The Violet Overdrive palette is original to this repo. Generator credit sits in the fastfetch config header. MIT License covers this repo. See [LICENSE](LICENSE).
