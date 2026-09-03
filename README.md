# linux-configs

Just a backup of my mint xfce setup incase of any worse cases. Most are AI generated for easy setup.

## Contents

| Path                | Description                                                                                                |
| ------------------- | ---------------------------------------------------------------------------------------------------------- |
| `mint-setup.md`     | Post-install guide: performance tweaks, storage reclamation, keyboard shortcut restoration, dualboot notes |
| `.config/`          | Dotfiles for neofetch, picom, opencode, Zed, and XFCE                                                      |
| `.config/xfce4/`    | XFCE keyboard shortcut configuration (restorable in one command)                                           |
| `.config/zed/`      | Zed editor settings, keymap, and themes                                                                    |
| `.config/neofetch/` | Neofetch system info display config                                                                        |
| `.config/picom/`    | Picom compositor configuration                                                                             |
| `.config/opencode/` | OpenCode global configuration                                                                              |
| `opencode.json`     | OpenCode project configuration                                                                             |
| `AGENTS.md`         | Agent workspace instructions                                                                               |
| `.opencode/`        | Agent rules, memory, and skills                                                                            |

## Getting Started on a New Machine

1. Clone this repository.
2. Follow `mint-setup.md` to apply system optimizations (swappiness, GRUB timeout, reserved disk space).
3. Restore keyboard shortcuts with the one-command copy step in Section 4.
4. Optionally copy individual configs from `.config/` to `~/.config/`.
