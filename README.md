# linux-configs (XFCE + GNOME)

Split-layout backup of my Linux setups incase of any worse cases. Most are AI generated for easy setup. Pick your desktop — scripts abort off-DE.

- `xfce-setup/` — Mint/Ubuntu (apt), XFCE-only
- `gnome-setup/` — openSUSE Tumbleweed (zypper), GNOME-only

## Contents

| Path                                    | Description                                                                                                                                                                                        |
| --------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `xfce-setup/setup.sh`                   | One-command restore for fresh XFCE install — per-distro branches (see `xfce-setup/fresh-install.md`)                                                                                               |
| `xfce-setup/setup.md`                   | Post-install guide: performance tweaks, storage reclamation, MT7902 Wi-Fi/BT + Acer battery drivers, keybinds, cleanup, autostart, panel styling, login screen, Rofi, screen dim toggle, ZRAM swap |
| `xfce-setup/drivers/mt7902/`            | Vendored MediaTek MT7902 Wi-Fi + Bluetooth DKMS sources + firmware — installed only on machines with the card                                                                                      |
| `xfce-setup/.config/`                   | Dotfiles for XFCE, rofi, kitty, fastfetch, autostart, gtk-3.0, picom, opencode, Zed, Starship                                                                                                      |
| `xfce-setup/.config/xfce4/`             | XFCE keyboard shortcuts (Super+B Brave, Super+R Rofi, Super+Return Kitty, rest of Section 3)                                                                                                       |
| `xfce-setup/.config/rofi/`              | Rofi Type-3 launcher (Gruvbox palette, WhiteSur icons) + config                                                                                                                                    |
| `xfce-setup/.config/kitty/`             | Kitty config (JetBrains Mono, picom blur opacity, audio bell muted) + Gruvbox Dark Soft theme                                                                                                      |
| `xfce-setup/.config/starship.toml`      | Starship prompt (single-line Gruvbox Powerline arrows)                                                                                                                                             |
| `xfce-setup/.config/autostart/`         | XFCE autostart overrides (`Hidden=true` disables Mint welcome/reports etc.)                                                                                                                        |
| `xfce-setup/.config/gtk-3.0/`           | GTK 3 panel styling CSS                                                                                                                                                                            |
| `xfce-setup/.config/zed/`               | Zed editor settings, keymap, themes                                                                                                                                                                |
| `xfce-setup/.config/fastfetch/`         | Fastfetch layout                                                                                                                                                                                   |
| `xfce-setup/.config/picom/`             | Picom compositor config                                                                                                                                                                            |
| `xfce-setup/.config/opencode/`          | OpenCode global config (`opencode.jsonc` only)                                                                                                                                                     |
| `xfce-setup/.themes/`                   | Gruvbox XFCE window themes (BL-LB-Dark-Soft + hdpi/xhdpi)                                                                                                                                          |
| `xfce-setup/.icons/`                    | WhiteSur-grey icon themes                                                                                                                                                                          |
| `xfce-setup/.local/share/fonts/`        | Shared Nerd fonts (JetBrains Mono etc.) — reused by GNOME, not duplicated                                                                                                                          |
| `xfce-setup/.bashrc`                    | Shell aliases (`fresh` Mint/TW branches, batt80/100/stat), starship hook, `NODE_OPTIONS=1536`                                                                                                      |
| `gnome-setup/setup.sh`                  | One-command restore for fresh openSUSE TW GNOME install — GNOME-only, zypper only, GDM restart                                                                                                     |
| `gnome-setup/setup.md`                  | Post-install guide: same kernel/ZRAM/EarlyOOM/ModemManager/Node tunings, plus extensions, dconf, search/index mask, software updates, autostart masks                                              |
| `gnome-setup/.bashrc`                   | TW `fresh` alias (`dev-zram0.swap` + `display-manager`), starship hook, `NODE_OPTIONS=1536`                                                                                                        |
| `gnome-setup/.config/kitty/`            | Kitty config + theme (mirrors live)                                                                                                                                                                |
| `gnome-setup/.config/starship.toml`     | Starship prompt (same single-line Powerline)                                                                                                                                                       |
| `gnome-setup/.config/fastfetch/`        | Fastfetch layout (`config.jsonc` only)                                                                                                                                                             |
| `gnome-setup/.config/opencode/`         | OpenCode global config (`opencode.jsonc` only)                                                                                                                                                     |
| `gnome-setup/dconf/`                    | Text dumps only: `dash-to-panel.dconf`, `blur-my-shell-panel.dconf`, `blur-my-shell-applications.dconf`, `interface.dconf` (never the binary `~/.config/dconf/user`)                               |
| `gnome-setup/extensions/list.txt`       | Enabled extensions (blur-my-shell, dash-to-panel, disable-workspace-switcher) — dirs reinstall via Extension Manager, then `dconf load`                                                            |
| `gnome-setup/assets/opensuse-icon.webp` | Custom dash-to-panel app icon referenced by the dconf dump                                                                                                                                         |
| `xfce-setup/fresh-install.md`           | XFCE one-command guide (Mint/TW XFCE). No standalone GNOME fresh-install guide yet — use `gnome-setup/setup.md`                                                                                    |
| `opencode.json`                         | OpenCode project configuration                                                                                                                                                                     |
| `AGENTS.md`                             | Agent workspace instructions                                                                                                                                                                       |
| `.opencode/`                            | Agent rules, memory, skills                                                                                                                                                                        |

Hardened: XFCE wallpaper step warns + skips if `background.jpg` absent; GNOME icon auto-installs to `~/Documents/`; GNOME path rewrite covers `opencode.jsonc` + `.bashrc` + dconf dump; both scripts skip restart prompt when non-interactive.

## Getting Started on a New Machine

XFCE (Mint/Ubuntu or openSUSE TW XFCE, details in `xfce-setup/fresh-install.md`):

```bash
if command -v apt >/dev/null; then sudo apt install -y git; else sudo zypper in -y git; fi && git clone --depth=1 https://github.com/worriee/linux-configs.git && cd linux-configs && bash xfce-setup/setup.sh
```

GNOME (openSUSE Tumbleweed GNOME only, details in `gnome-setup/setup.md`):

```bash
sudo zypper in -y git && git clone --depth=1 https://github.com/worriee/linux-configs.git && cd linux-configs && bash gnome-setup/setup.sh
```

What XFCE applies: dotfiles/themes/icons/fonts copy, swappiness 180 + page-cluster 0 (zram pairing), kernel VM tuning (vfs 125, dirty 10/5, watermark 0/150), EarlyOOM guard (protect zed/opencode/kitty, prefer Brave), ModemManager disable, GRUB timeout 5s (Mint only), ext4 reserve 1% (btrfs auto-skips), ZRAM zstd 100% RAM, slick-greeter login screen, screen dim toggle, optional MT7902 + Acer battery drivers. Manual leftovers (Brave, Zed) in fresh-install guide.

What GNOME applies: same swappiness/VM/ZRAM/EarlyOOM/ModemManager/Node tunings via `zram-generator` + `/etc/sysconfig/earlyoom`, dotfiles + `dconf load` (dash-to-panel, blur-my-shell panel+apps only, interface), extensions reinstall list, animations off, localsearch-3 + evolution masks, software download-updates off, cups/avahi disable (bluetooth kept), bootloader untouched, btrfs snapper pre-dotfiles snapshot. MT7902 skipped by design (in-kernel `mt7921e` on kernel 7.2); Acer cap skipped.

Prefer doing it manually? Follow `xfce-setup/setup.md` or `gnome-setup/setup.md` section by section.
