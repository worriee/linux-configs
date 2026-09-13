# Fresh Install — One-Command Setup (Mint XFCE + openSUSE TW XFCE)

XFCE-only: this repo automates XFCE customizations and does not work on other desktops. Applies this entire repo's configs to a freshly installed Mint XFCE **or** openSUSE Tumbleweed XFCE system with **one command**. Companion to `setup.md` (which documents every tweak manually).

---

## The One Command

On a fresh Mint XFCE or openSUSE TW XFCE install, open a terminal and run:

```bash
if command -v apt >/dev/null; then sudo apt install -y git; else sudo zypper in -y git; fi && git clone --depth=1 https://github.com/worriee/linux-configs.git && cd linux-configs && bash setup.sh
```

Type your sudo password when prompted (once). That's it.

---

## What It Applies

| Step | What happens |
| --- | --- |
| 1. Path fix | Rewrites hardcoded `/home/julry` paths in keybinds + opencode config to your `$HOME` |
| 2. Packages | Per-distro list (see below) + Starship prompt (official installer) |
| 3. Dotfiles | Copies `.config/` (xfce4 keybinds, autostart, gtk-3.0, rofi, kitty, starship.toml, fastfetch, picom, zed, opencode), `.bashrc` (aliases: `fresh`, batt80/100/stat), `.themes/` (Gruvbox), `.icons/` (WhiteSur), fonts → `fc-cache -f` |
| 4. Login screen | Wallpaper → `/usr/share/backgrounds/background.jpg`, writes `/etc/lightdm/slick-greeter.conf` (top-right: battery + full date, 12h clock only) |
| 5. System tweaks | `vm.swappiness=180` + `vm.page-cluster=0` (zram pairing), kernel VM tuning (`vfs_cache_pressure=125`, dirty ratios 10/5, watermark 0/150), EarlyOOM guard (protects zed/opencode/kitty, prefers killing Brave), ModemManager disabled, `GRUB_TIMEOUT=5` + `update-grub` (Mint/Ubuntu only — skipped on openSUSE), ext4 reserved blocks → 1% (auto-detects root device, btrfs auto-skips), ZRAM swap (`zstd`, 100% RAM, idempotent) |
| 6. Optional drivers | Auto-detected extras: **MT7902 Wi-Fi/BT** (only if the `14c3:7902` PCIe card is present — restores vendored sources from `drivers/mt7902/`, builds via DKMS, installs firmware) and **Acer battery** (only if `/sys/class/dmi/id/sys_vendor` is Acer — builds `acer-wmi-battery` with 80% charge limit, autoloading on boot). Anything else: skipped |

Keybinds included in the dotfiles copy: `Super+B` → Brave, `Super+R` → Rofi launcher, `Super+Return` → Kitty terminal, `Super+Alt+B` → screen dim toggle, plus everything in `setup.md` Section 3.

Safety notes:

- Any pre-existing config file is backed up as `<file>~` before overwriting.
- A failed step is logged and skipped — the script never aborts halfway. Re-run it any time; it is safe to run repeatedly.
- Nothing is deleted from your system.

---

## What Differs on openSUSE

| Area | Mint/Ubuntu (apt) | openSUSE TW (zypper) |
| --- | --- | --- |
| Packages | `rofi flameshot picom fastfetch sticky kitty zram-tools curl` via apt | `rofi flameshot picom fastfetch kitty earlyoom lightdm-slick-greeter zram-generator gcc make kernel-default-devel curl xrandr` via zypper (no `sticky`, no `zram-tools`) |
| Login screen | wallpaper + `slick-greeter.conf` | same wallpaper + `slick-greeter.conf`, plus slick-greeter set via `update-alternatives --set lightdm-default-greeter.desktop` (verified against `/usr/share/xgreeters/slick*.desktop`) |
| EarlyOOM | `EARLYOOM_ARGS` in `/etc/default/earlyoom` | `EARLYOOM_ARGS` in `/etc/sysconfig/earlyoom` |
| ZRAM | `zram-tools`, `ALGO=zstd` + `PERCENT=100` in `/etc/default/zramswap` | `zram-generator` (`[zram0] zram-size = min(ram)` + `compression-algorithm = zstd` in `/etc/systemd/zram-generator.conf`, units `dev-zram0.swap` + `systemd-zram-setup@zram0`; post-state asserted via `zramctl`, legacy `zramswap` service parked) |
| Bootloader | `GRUB_TIMEOUT=5` + `update-grub` | GRUB step skipped — bootloader untouched (by design) |
| Root reserve | ext4 reserve → 1% | same step; btrfs root auto-skips (fstype guard) |
| Snapshot | none | `snapper create -d pre-dotfiles` (best-effort) |
| Session restart | `sudo systemctl restart lightdm` | `sudo systemctl restart display-manager` |
| `fresh` alias | `(sudo systemctl restart zramswap 2>/dev/null \|\| sudo systemctl restart zram-config) && sudo systemctl restart lightdm` | `sudo systemctl restart dev-zram0.swap && sudo systemctl restart display-manager` |

---

## Manual Leftovers (2 min)

Two apps are not apt-installable:

**Brave browser** (needed by `Super+B` keybind):

```bash
curl -fsS https://dl.brave.com/install.sh | sh
```

**Zed editor:**

```bash
curl -f https://zed.dev/install.sh | sh
```

**Reboot once** after the script — the GRUB timeout change (Mint only) applies at boot. On openSUSE the bootloader is untouched.

---

## Verify After Install

```bash
# Keybinds active (should print brave-browser / rofi launcher path)
xfconf-query -c xfce4-keyboard-shortcuts -p "/commands/custom/<Super>b"
xfconf-query -c xfce4-keyboard-shortcuts -p "/commands/custom/<Super>r"

# Swappiness + swap readahead (should print 180 then 0)
cat /proc/sys/vm/swappiness
cat /proc/sys/vm/page-cluster

# Fonts visible
fc-list | grep -i "jetbrains\|iosevka" | head -3

# .bashrc aliases (should print the fresh/combined flush command)
type fresh

# Rofi launcher works
~/.config/rofi/launchers/type-3/launcher.sh

# Starship prompt active (should print starship binary path)
starship --version
```

TW-only checks:

```bash
zramctl
snapper list
update-alternatives --display lightdm-default-greeter.desktop
```

---

## Troubleshooting

| Problem | Fix |
| --- | --- |
| `Super+R` opens nothing | Log out/in once — xfconf reloads keybinds at session start |
| Login screen shows wrong wallpaper | Check `/usr/share/backgrounds/background.jpg` exists; re-run `setup.sh` step 4 |
| Rofi icons missing | Your icon theme name differs — edit `icon-theme` in `~/.config/rofi/launchers/type-3/style-3.rasi` |
| Acer: `modprobe` failed | Reboot — the module autoloads via `/etc/modules-load.d/`; recompiles needed after kernel updates (see `setup.md` Section 2B) |
| MT7902 machine: Wi-Fi/BT dead | Only for MediaTek 7902 cards — driver needs kernel headers + DKMS rebuild; check `dkms status` and `lsmod | grep 7902` (see `setup.md` Section 2A) |
| Script step failed | Re-run `bash setup.sh` — steps are idempotent; or apply manually from `setup.md` |

---

## Keeping the Repo in Sync Later

Changed configs on your machine? Copy them back into the repo and push:

```bash
# example: after changing keybinds
cp ~/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-keyboard-shortcuts.xml .config/xfce4/xfconf/xfce-perchannel-xml/
git add -A && git commit -m "sync keybinds" && git push
```
