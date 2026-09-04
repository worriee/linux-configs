# Fresh Install — One-Command Setup (Linux Mint XFCE)

Applies this entire repo's configs to a freshly installed Linux Mint XFCE system with **one command**. Companion to `mint-setup.md` (which documents every tweak manually).

---

## The One Command

On a fresh Mint XFCE install, open a terminal and run:

```bash
sudo apt install -y git && git clone --depth=1 https://github.com/worriee/linux-configs.git && cd linux-configs && bash setup.sh
```

Type your sudo password when prompted (once). That's it.

---

## What It Applies

| Step | What happens |
| --- | --- |
| 1. Path fix | Rewrites hardcoded `/home/julry` paths in keybinds + opencode config to your `$HOME` |
| 2. Packages | Installs `kitty`, `rofi`, `flameshot`, `plank`, `picom`, `fastfetch`, `sticky`, `zram-tools` via apt + Starship prompt (official installer) |
| 3. Dotfiles | Copies `.config/` (xfce4 keybinds, autostart, gtk-3.0, rofi, kitty, starship.toml, fastfetch, picom, zed, opencode), `.themes/` (Gruvbox), `.icons/` (WhiteSur), fonts → `fc-cache -f` |
| 4. Login screen | Wallpaper → `/usr/share/backgrounds/background.jpg`, writes `/etc/lightdm/slick-greeter.conf` (top-right: battery + full date, 12h clock only) |
| 5. System tweaks | `vm.swappiness=10`, `GRUB_TIMEOUT=5` + `update-grub`, ext4 reserved blocks → 1% (auto-detects root device), ZRAM swap (`zstd`, 100% RAM, idempotent) |
| 6. Acer battery | Only if the machine is an Acer (auto-detected via `/sys/class/dmi/id/sys_vendor`): builds + installs `acer-wmi-battery` with 80% charge limit, autoloading on boot. Non-Acer: silently skipped |

Keybinds included in the dotfiles copy: `Super+B` → Brave, `Super+R` → Rofi launcher, `Super+Return` → Kitty terminal, `Super+Alt+B` → screen dim toggle, plus everything in `mint-setup.md` Section 4.

Safety notes:

- Any pre-existing config file is backed up as `<file>~` before overwriting.
- A failed step is logged and skipped — the script never aborts halfway. Re-run it any time; it is safe to run repeatedly.
- Nothing is deleted from your system.

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

**Reboot once** after the script — the GRUB timeout change applies at boot.

---

## Verify After Install

```bash
# Keybinds active (should print brave-browser / rofi launcher path)
xfconf-query -c xfce4-keyboard-shortcuts -p "/commands/custom/<Super>b"
xfconf-query -c xfce4-keyboard-shortcuts -p "/commands/custom/<Super>r"

# Swappiness (should print 10)
cat /proc/sys/vm/swappiness

# Fonts visible
fc-list | grep -i "jetbrains\|iosevka" | head -3

# Rofi launcher works
~/.config/rofi/launchers/type-3/launcher.sh

# Starship prompt active (should print starship binary path)
starship --version
```

---

## Troubleshooting

| Problem | Fix |
| --- | --- |
| `Super+R` opens nothing | Log out/in once — xfconf reloads keybinds at session start |
| Login screen shows wrong wallpaper | Check `/usr/share/backgrounds/background.jpg` exists; re-run `setup.sh` step 4 |
| Rofi icons missing | Your icon theme name differs — edit `icon-theme` in `~/.config/rofi/launchers/type-3/style-3.rasi` |
| Acer: `modprobe` failed | Reboot — the module autoloads via `/etc/modules-load.d/`; recompiles needed after kernel updates (see `mint-setup.md` Section 9) |
| Script step failed | Re-run `bash setup.sh` — steps are idempotent; or apply manually from `mint-setup.md` |

---

## Keeping the Repo in Sync Later

Changed configs on your machine? Copy them back into the repo and push:

```bash
# example: after changing keybinds
cp ~/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-keyboard-shortcuts.xml .config/xfce4/xfconf/xfce-perchannel-xml/
git add -A && git commit -m "sync keybinds" && git push
```
