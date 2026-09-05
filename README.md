# linux-configs

Just a backup of my mint xfce setup incase of any worse cases. Most are AI generated for easy setup.

## Contents

| Path                    | Description                                                                                                                                |
| ----------------------- | ------------------------------------------------------------------------------------------------------------------------------------------ |
| `setup.sh`              | One-command restore script for a fresh Mint XFCE install (see `fresh-install.md`)                                                          |
| `fresh-install.md`      | Instructions for the one-command fresh install                                                                                             |
| `mint-setup.md`         | Post-install guide: performance tweaks, storage reclamation, keybinds, cleanup, autostart, panel styling, login screen, Acer battery, Rofi, screen dim toggle, ZRAM swap |
| `background.jpg`        | Login screen wallpaper (used by the slick-greeter config)                                                                                  |
| `.config/`              | Dotfiles for XFCE, rofi, kitty, fastfetch, autostart, gtk-3.0, picom, opencode, Zed, and Starship                                          |
| `.config/xfce4/`        | XFCE keyboard shortcut configuration (Super+B Brave, Super+R Rofi, Super+Return Kitty, and the rest of Section 4)                          |
| `.config/rofi/`         | Rofi Type-3 launcher (Gruvbox palette, WhiteSur icons) + config                                                                            |
| `.config/kitty/`        | Kitty terminal config (JetBrains Mono, picom blur opacity, audio bell muted) + Gruvbox Dark Soft theme                                     |
| `.config/starship.toml` | Starship prompt config (single-line Gruvbox Powerline arrows)                                                                              |
| `.config/autostart/`    | XFCE autostart entries (picom, blueman, sticky, etc.)                                                                                     |
| `.config/gtk-3.0/`      | GTK 3 panel styling CSS                                                                                                                    |
| `.config/zed/`          | Zed editor settings, keymap, and themes                                                                                                    |
| `.config/fastfetch/`    | Fastfetch dotfiles layout                                                                                                                  |
| `.config/picom/`        | Picom compositor configuration                                                                                                             |
| `.config/opencode/`     | OpenCode global configuration                                                                                                              |
| `.themes/`              | Gruvbox XFCE window themes (BL-LB-Dark-Soft + hdpi/xhdpi variants)                                                                         |
| `.icons/`               | WhiteSur-grey icon themes                                                                                                                  |
| `.local/share/fonts/`   | Rofi/Nerd fonts (Iosevka, JetBrains Mono, etc.)                                                                                            |
| `opencode.json`         | OpenCode project configuration                                                                                                             |
| `AGENTS.md`             | Agent workspace instructions                                                                                                               |
| `.opencode/`            | Agent rules, memory, and skills                                                                                                            |

## Getting Started on a New Machine

One command (details in `fresh-install.md`):

```bash
sudo apt install -y git && git clone --depth=1 https://github.com/worriee/linux-configs.git && cd linux-configs && bash setup.sh
```

It copies all dotfiles/themes/icons/fonts, applies system tweaks (swappiness, GRUB timeout, ext4 reserve, ZRAM compressed swap, screen dim toggle), configures the slick-greeter login screen, and auto-detects Acer laptops for the battery health driver. Manual leftovers (Brave, Zed) are listed in `fresh-install.md`.

Prefer doing it manually? Follow `mint-setup.md` section by section.
