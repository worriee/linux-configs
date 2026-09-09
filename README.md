# linux-configs (XFCE-only)

Automated XFCE customizations only — does not work on other desktops. Just a backup of my XFCE setup incase of any worse cases. Most are AI generated for easy setup.

## Contents

| Path                    | Description                                                                                                                                |
| ----------------------- | ------------------------------------------------------------------------------------------------------------------------------------------ |
| `setup.sh`              | One-command restore script for a fresh XFCE install — XFCE-only, supports Mint/Ubuntu (apt) and openSUSE Tumbleweed (zypper) via one script with per-distro branches (see `fresh-install.md`) |
| `fresh-install.md`      | Instructions for the one-command fresh install                                                                                             |
| `setup.md`         | Post-install guide: performance tweaks, storage reclamation, optional hardware drivers (MT7902 Wi-Fi/BT, Acer battery), keybinds, cleanup, autostart, panel styling, login screen, Rofi, screen dim toggle, ZRAM swap |
| `drivers/mt7902/`       | Vendored source for the MediaTek MT7902 Wi-Fi + Bluetooth DKMS drivers (pinned upstream branches + firmware blobs) — installed by `setup.sh` only on machines with the card |
| `background.jpg`        | Login screen wallpaper (used by the slick-greeter config)                                                                                  |
| `.config/`              | Dotfiles for XFCE, rofi, kitty, fastfetch, autostart, gtk-3.0, picom, opencode, Zed, and Starship                                          |
| `.config/xfce4/`        | XFCE keyboard shortcut configuration (Super+B Brave, Super+R Rofi, Super+Return Kitty, and the rest of Section 3)                          |
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
if command -v apt >/dev/null; then sudo apt install -y git; else sudo zypper in -y git; fi && git clone --depth=1 https://github.com/worriee/linux-configs.git && cd linux-configs && bash setup.sh
```

It copies all dotfiles/themes/icons/fonts, applies system tweaks (swappiness, kernel VM tuning, EarlyOOM guard, ModemManager disable, GRUB timeout on Mint/Ubuntu only, ext4 reserve, ZRAM compressed swap, screen dim toggle), configures the slick-greeter login screen, and auto-detects optional hardware — MT7902 Wi-Fi/BT drivers and Acer laptops for the battery health driver. Manual leftovers (Brave, Zed) are listed in `fresh-install.md`.

Prefer doing it manually? Follow `setup.md` section by section.
