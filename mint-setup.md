# Linux Mint XFCE Post-Install System Optimizations

Three essential performance and storage tweaks for Linux Mint on laptops with SSDs and 8GB–16GB RAM. Applies to any edition (Cinnamon, XFCE, MATE) — none of these are desktop-environment specific.

Run in this order after a fresh install.

---

## 1. Lower Swappiness (60 → 10)

### What This Does

Swappiness controls how aggressively Linux moves idle RAM pages onto your slower SSD storage.

- **Default (60):** Linux starts paging data to disk even when you have 40% RAM free.
- **Optimized (10):** Linux relies on fast physical RAM first and only swaps when RAM is near capacity.

### Step-by-Step

1. Open the sysctl configuration file:

```bash
sudo nano /etc/sysctl.conf
```

2. Scroll to the very bottom and add these two lines:

```text
# Prioritize physical RAM over disk swap
vm.swappiness=10
```

3. Press `Ctrl + O`, then `Enter` to save, and `Ctrl + X` to exit.
4. Apply immediately without rebooting:

```bash
sudo sysctl -p
```

5. Verify the active value:

```bash
cat /proc/sys/vm/swappiness
```

_(Expected output: `10`)_

---

## 2. Reduce GRUB Boot Menu Timeout (10s → 5s)

### What This Does

When dual-booting or restarting, the GRUB menu waits 10 seconds before automatically booting your OS. Reducing this to 5 seconds saves boot time while still leaving enough time to select recovery options if needed.

### Step-by-Step

1. Open the GRUB configuration file:

```bash
sudo nano /etc/default/grub
```

2. Find the line:

```text
GRUB_TIMEOUT=10
```

Change it to:

```text
GRUB_TIMEOUT=5
```

3. Press `Ctrl + O`, then `Enter` to save, and `Ctrl + X` to exit.
4. Update the GRUB bootloader to apply changes:

```bash
sudo update-grub
```

---

## 3. Reclaim Reserved Root Space (5% → 1%)

### What This Does

By default, the `ext4` filesystem reserves **5% of your total drive space** exclusively for the `root` user.

- On old small drives, 5% was necessary so system daemons wouldn't crash if normal users filled the drive.
- On modern SSDs (like 512GB drives), 5% reserves **~25GB of wasted space**.
- Reducing it to **1%** retains a safe ~5GB buffer for system logs while instantly freeing ~20GB of usable disk storage.

### Step-by-Step

1. Find your main root partition identifier:

```bash
df -h /
```

_(Look under the `Filesystem` column, e.g., `/dev/nvme0n1p2` or `/dev/sda2`)_

2. Reduce the reserved block percentage to 1%:

```bash
sudo tune2fs -m 1 /dev/nvme0n1p2
```

_(Replace `/dev/nvme0n1p2` with the partition found in step 1)_

3. Verify your newly reclaimed space:

```bash
df -h /
```

## Quick Reference Summary Table

| Optimization            | Default | New Value | Benefit                                                    |
| ----------------------- | ------- | --------- | ---------------------------------------------------------- |
| **vm.swappiness**       | `60`    | `10`      | Keeps apps in RAM, reduces SSD wear and stuttering.        |
| **GRUB_TIMEOUT**        | `10s`   | `5s`      | Shaves 5 seconds off system startup time.                  |
| **ext4 Reserved Space** | `5%`    | `1%`      | Reclaims ~20GB of SSD storage while maintaining stability. |

---

## 4. Keyboard Shortcuts & Window Manager Keybinds

Custom shortcuts captured from current Mint XFCE setup (stored in `~/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-keyboard-shortcuts.xml`). Recreate these on the new laptop.

### Application Shortcuts

| Shortcut             | Action                                           |
| -------------------- | ------------------------------------------------ |
| `Super + Return`     | Open terminal (`x-terminal-emulator`)            |
| `Super + e`          | Open Thunar file manager                         |
| `Super + z`          | Open Zed editor                                  |
| `Super + b`          | Open Microsoft Edge                              |
| `Super + Esc`        | Popup Whisker menu                               |
| `Alt + F3`           | Appfinder (launcher)                             |
| `Ctrl + Shift + Esc` | Task manager                                     |
| `Print`              | Flameshot full screen (`-c` copies to clipboard) |
| `Shift + Print`      | Flameshot GUI selection mode                     |

### Window Manager Keybinds

| Shortcut                           | Action                                     |
| ---------------------------------- | ------------------------------------------ |
| `Super + 1..5`                     | Switch to workspace 1–5                    |
| `Ctrl + Alt + 1..5`                | Move window to workspace 1–5               |
| `Alt + Tab` / `Alt + Shift + Tab`  | Cycle windows forward / reverse            |
| `Super + Tab`                      | Switch windows                             |
| `Super + w`                        | Close window                               |
| `Super + f`                        | Maximize window                            |
| `Ctrl + Super + f`                 | Hide window                                |
| `Alt + F11`                        | Toggle fullscreen                          |
| `Alt + F12`                        | Toggle window above others                 |
| `Alt + F6`                         | Stick window (all workspaces)              |
| `Alt + F7` / `Alt + F8`            | Move / resize window                       |
| `Alt + space`                      | Window menu                                |
| `Ctrl + Alt + d`                   | Show desktop                               |
| `Left` / `Right` / `Up` / `Down`   | Move between workspaces                    |
| `Super + KP_Left/Right/Up/Down`    | Tile window to left/right/top/bottom half  |
| `Super + KP_Home/End/Page_Up/Next` | Tile window to corners (quadrants)         |
| `Primary + Shift + Alt + Arrows`   | Move window to workspace in that direction |

### How to Restore on New Laptop

1. Copy the saved config file from this repo into place (all shortcuts applied at once):

```bash
mkdir -p ~/.config/xfce4/xfconf/xfce-perchannel-xml
cp linux-configs/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-keyboard-shortcuts.xml ~/.config/xfce4/xfconf/xfce-perchannel-xml/
```

_(Adjust `linux-configs/` to wherever this repo lives on the new laptop)_

2. Log out and back in (or restart) for the shortcuts to load.

Alternatively, re-add them manually via **Settings → Keyboard → Application Shortcuts** using the tables above.

### Dualboot with Windows Notes

- The Windows key (`Super`) works fine as the main modifier in XFCE under dualboot — no conflicts.
- If you ever switch the default browser/editor, update the `Super + b` / `Super + z` commands in Settings → Keyboard.
- Flameshot saves to `/home/julry/Pictures` — change the username in the command if your new laptop uses a different user.

---

## 5. No-Reboot Reset & System Cleanup

### 5A. Restart the Entire Desktop Session (Closest to a Full Reboot)

Kills the graphical session, logs you out, restarts the display manager, and clears loaded desktop memory — without touching the kernel or power state.

```bash
sudo systemctl restart lightdm
```

**Warning: Save your work first.** Restarting LightDM terminates your current session, so unsaved work in editors or browsers will be lost.

### 5B. Restart Only the XFCE Desktop & Panel (Keeps Apps Open)

Reloads the interface without losing open browser tabs or terminal windows. Fixes frozen panel, glitchy UI, or stale theme.

```bash
xfce4-panel -r && xfwm4 --replace &
```

- `xfce4-panel -r` reloads the taskbar, tray icons, and widgets.
- `xfwm4 --replace` restarts the window manager to fix stutters, borders, or compositor lag.

### 5C. Clear RAM & Buffer Cache (Memory Refresh)

Gets a fresh-boot-like memory state after closing heavy applications.

```bash
sudo sync && echo 3 | sudo tee /proc/sys/vm/drop_caches
```

Writes pending data to disk (`sync`), then flushes pagecache, dentries, and inodes to free memory immediately.

### 5D. Restart the Network Stack (Wi-Fi & Bluetooth)

Fixes Wi-Fi or Bluetooth that stopped responding, without rebooting.

```bash
sudo systemctl restart NetworkManager
```

### 5E. Remove Unused Packages & Their Config Files (One Command)

Removes orphaned dependencies, packages with leftover config files (`rc` status), clears the apt cache, and drops unused Flatpak runtimes:

```bash
sudo apt autoremove --purge -y && sudo apt purge -y $(dpkg -l | grep '^rc' | awk '{print $2}') 2>/dev/null; sudo apt clean && flatpak uninstall --unused -y
```

What each part does:

- `apt autoremove --purge -y` — removes packages no longer needed, including their config files.
- `apt purge -y $(dpkg -l | grep '^rc' | ...)` — finds packages marked `rc` (removed but config left behind) and purges them. `2>/dev/null` suppresses the error when there are none.
- `apt clean` — deletes downloaded `.deb` files from the apt cache.
- `flatpak uninstall --unused -y` — removes Flatpak runtimes and extensions no app uses.

---

## 6. Application Autostart Configuration

Location in system: **Settings** → **Session and Startup** → **Application Autostart**

### Checked (Active on Login)

- [x] **im-launch**
- [x] **NetworkManager Applet** _(Manage your network connections)_
- [x] **picom** _(An X compositor)_
- [x] **Plank**
- [x] **PolicyKit Authentication Agent** _(PolicyKit Authentication Agent)_
- [x] **Power Manager** _(Power management for the Xfce desktop)_
- [x] **PulseAudio Sound System** _(Start the PulseAudio Sound System)_
- [x] **Screen Locker** _(Launch screen locker program)_
- [x] **Update Manager** _(Linux Mint Update Manager)_
- [x] **User folders update** _(Update common folders names to match current locale)_
- [x] **User folders update**
- [x] **Warpinator** _(Transfer files from one computer to another on the local network)_
- [x] **xapp-sn-watcher** _(A service that provides the org.kde.StatusNotifierWatcher interface for XApps)_
- [x] **Xfce Notification Daemon**
- [x] **Xfce Settings Daemon** _(The Xfce Settings Daemon)_

### Unchecked (Disabled on Login)

- [ ] **AT-SPI D-Bus Bus**
- [ ] **Blueman Applet** _(Blueman Bluetooth Manager)_
- [ ] **Events and Tasks Reminders** _(Event and task notifications)_
- [ ] **Geoclue Demo agent**
- [ ] **mintwelcome** _(Linux Mint Welcome Screen)_
- [ ] **Print Queue Applet** _(System tray icon for managing print jobs)_
- [ ] **Sticky Notes** _(Create and manage sticky notes on your desktop)_
- [ ] **Support for NVIDIA Prime** _(Shows a tray icon when a compatible NVIDIA Optimus graphics card is detected)_
- [ ] **System Reports** _(Troubleshoot problems)_
- [ ] **xiccd** _(Applies color management profiles to your session)_
- [ ] **Certificate and Key Storage** _(GNOME Keyring: PKCS#11 Component)_
- [ ] **gnome-disk-utility notification plugin for GNOME Settings Daemon**
- [ ] **Onboard** _(Flexible onscreen keyboard)_
- [ ] **Orca Screen Reader**
- [ ] **Secret Storage Service** _(GNOME Keyring: Secret Service)_
- [ ] **SSH Key Agent** _(GNOME Keyring: SSH Agent)_

### Commands for Checked Autostart Apps

The command each checked app actually runs at login (captured from `/etc/xdg/autostart/` and `~/.config/autostart/`). Verified on this system: `picom` and `plank` both resolve to `/usr/bin/picom` and `/usr/bin/plank`.

| App                            | Command                                                                                                                            |
| ------------------------------ | ---------------------------------------------------------------------------------------------------------------------------------- |
| im-launch                      | `sh -c 'IM_CONFIG_CHECK_ENV=1 im-launch true'`                                                                                     |
| NetworkManager Applet          | `nm-applet`                                                                                                                        |
| picom                          | `picom`                                                                                                                            |
| Plank                          | `plank`                                                                                                                            |
| PolicyKit Authentication Agent | `/usr/lib/policykit-1-gnome/polkit-gnome-authentication-agent-1`                                                                   |
| Power Manager                  | `xfce4-power-manager`                                                                                                              |
| PulseAudio Sound System        | `start-pulseaudio-x11`                                                                                                             |
| Screen Locker                  | `light-locker`                                                                                                                     |
| Update Manager                 | `mintupdate-launcher`                                                                                                              |
| User folders update            | `xdg-user-dirs-gtk-update`                                                                                                         |
| User folders update (2nd)      | `xdg-user-dirs-update`                                                                                                             |
| Warpinator                     | `warpinator --autostart`                                                                                                           |
| xapp-sn-watcher                | `/usr/lib/x86_64-linux-gnu/xapps/xapp-sn-watcher`                                                                                  |
| Xfce Notification Daemon       | `sh -c "systemctl --user start xfce4-notifyd.service 2>/dev/null \|\| exec /usr/lib/x86_64-linux-gnu/xfce4/notifyd/xfce4-notifyd"` |
| Xfce Settings Daemon           | `xfsettingsd`                                                                                                                      |

### How to Restore on New Laptop

All checked apps above are **system defaults** — on a fresh Mint XFCE install they are active automatically, so no action is needed for them. Only **Plank** is a user-added autostart entry.

1. Copy the saved autostart files from this repo into place (restores the disabled state + enables Plank):

```bash
mkdir -p ~/.config/autostart
cp linux-configs/.config/autostart/*.desktop ~/.config/autostart/
```

_(Adjust `linux-configs/` to wherever this repo lives on the new laptop)_

2. Log out and back in for the changes to take effect.

**Beginner note:** The `Hidden=true` files are just as important as the enabled one. They override the system defaults in `/etc/xdg/autostart/` — for example, the disabled `mintwelcome.desktop` and `mintreport.desktop` files are what stop the Mint Welcome Screen and System Reports from popping up at every login. Copy them all, exactly as saved, to keep the same behavior.

### Alternative: Set Them in the GUI

**Settings → Session and Startup → Application Autostart** — tick or untick each app there. Same result, done visually.

---

## 7. XFCE Panel Styling (Rounded Corners & Transparent Buttons)

### Edit the GTK User Stylesheet

Open or create `~/.config/gtk-3.0/gtk.css` and paste the following rules:

```css
.xfce4-panel {
  border-radius: 16px !important;
}

.xfce4-panel button,
.xfce4-panel button:hover,
.xfce4-panel button:checked,
.xfce4-panel .flat,
.xfce4-panel .flat:hover {
  background-color: transparent !important;
  background-image: none !important;
  border: none !important;
  box-shadow: none !important;
  margin: 0 !important;
  padding: 0 4px !important;
}
```

**What each rule does:**

- `.xfce4-panel` — targets the outer panel container, curves all four corners with a 16px radius.
- `.xfce4-panel button, .flat` — targets workspace switchers, app launchers, and applet buttons.
- `background-color: transparent !important;` — strips background box colors and fills.
- `border: none !important;` & `box-shadow: none !important;` — removes outlines, borders, and drop shadows.
- `padding: 0 4px !important;` & `margin: 0 !important;` — normalizes button spacing so items fit evenly without gaps.

### Reload the Panel

```bash
xfce4-panel -r
```

Restarts the panel process and applies the updated CSS stylesheet immediately without logging out.

### How to Restore on New Laptop

The GTK CSS file is already saved in this repo at `.config/gtk-3.0/gtk.css`. Copy it into place:

```bash
mkdir -p ~/.config/gtk-3.0
cp linux-configs/.config/gtk-3.0/gtk.css ~/.config/gtk-3.0/
```

_(Adjust `linux-configs/` to wherever this repo lives on the new laptop)_

Then reload the panel:

```bash
xfce4-panel -r
```

---

## 8. Login Screen UI (Slick-Greeter Top-Right Minimal)

Configures the default Mint login screen (slick-greeter) to show **only** the battery percentage and a full date + 12-hour clock, both in the top-right corner (order: battery → date → time). Everything else in the top panel is hidden.

### Apply the Config

The greeter reads `/etc/lightdm/slick-greeter.conf`. Replace it with:

```bash
sudo tee /etc/lightdm/slick-greeter.conf > /dev/null <<'EOF'
[Greeter]
background=/usr/share/backgrounds/background.jpg
content-align=center
draw-user-backgrounds=true
show-clock=true
clock-format=%A, %B %d  %I:%M %p
show-power=true
show-quit=false
show-keyboard=false
show-a11y=false
show-hostname=false
EOF
```

### What Each Option Does

| Option                  | Value                                   | Meaning                                                      |
| ----------------------- | --------------------------------------- | ------------------------------------------------------------ |
| `background`            | `/usr/share/backgrounds/background.jpg` | Wallpaper shown on the login screen                          |
| `content-align`         | `center`                                | Center the login box vertically/horizontally                 |
| `draw-user-backgrounds` | `true`                                  | Use the logged-in user's wallpaper behind the login box      |
| `show-clock`            | `true`                                  | Show the clock (top-right)                                   |
| `clock-format`          | `%A, %B %d  %I:%M %p`                   | Full date + 12-hour time, e.g. `Sunday, August 30  08:05 PM` |
| `show-power`            | `true`                                  | Show battery icon + percentage (top-right, left of clock)    |
| `show-quit`             | `false`                                 | Hide the shutdown/suspend/quit menu                          |
| `show-keyboard`         | `false`                                 | Hide the keyboard layout indicator                           |
| `show-a11y`             | `false`                                 | Hide the accessibility menu                                  |
| `show-hostname`         | `false`                                 | Hide the hostname label                                      |

### Result

Top-right corner, left to right: **battery icon + percentage** → **full date and 12-hour time**. Nothing else in the top panel.

### Notes

- **Battery only appears when on battery power** — while plugged into AC it is hidden by the greeter.
- `show-quit=false` removes the shutdown/suspend/quit menu from the login screen. Re-enable it with `show-quit=true`.
- The bottom-left session selector (e.g. `Xfce Session`) is a separate widget and is not affected.
- The config applies after a display manager restart:

```bash
sudo systemctl restart lightdm
```

_(This logs you out — save your work first.)_

---

## 9. Acer Battery Health Mode (80% Charge Limit) — ACER LAPTOPS ONLY

Replicates the **80% Battery Charge Limit** from Acer Care Center on Windows using the open-source `acer-wmi-battery` driver. **Skip this section entirely on non-Acer laptops** — the WMI interface does not exist on other brands.

> Source: https://github.com/frederik-h/acer-wmi-battery

### Prerequisites

```bash
sudo apt update
sudo apt install -y build-essential linux-headers-$(uname -r) git
```

- `build-essential` — gcc, make, and system libraries for compiling kernel modules.
- `linux-headers-$(uname -r)` — header files matching the running kernel so the module compiles cleanly.

### Build and Install the Module

```bash
cd ~
git clone https://github.com/frederik-h/acer-wmi-battery.git
cd acer-wmi-battery
make

sudo mkdir -p /lib/modules/$(uname -r)/kernel/drivers/platform/x86/
sudo cp acer-wmi-battery.ko /lib/modules/$(uname -r)/kernel/drivers/platform/x86/
sudo depmod -a
sudo modprobe acer-wmi-battery
```

- `make` — compiles `acer-wmi-battery.c` into `acer-wmi-battery.ko`.
- `depmod -a` — updates module dependencies so modprobe finds the driver by name.
- `modprobe acer-wmi-battery` — loads the driver into the running kernel.

### Load Automatically on Boot

```bash
echo "acer-wmi-battery" | sudo tee /etc/modules-load.d/acer-wmi-battery.conf
echo "options acer-wmi-battery enable_health_mode=1" | sudo tee /etc/modprobe.d/acer-wmi-battery.conf
```

- `modules-load.d` — systemd loads the driver at every boot.
- `modprobe.d` — passes `enable_health_mode=1`, so the 80% limit is applied automatically at startup.

### Manual Control and Status

```bash
# Check current mode (1 = 80% limit active, 0 = full 100%)
cat /sys/bus/wmi/drivers/acer-wmi-battery/health_mode

# Enable 80% charge limit
echo 1 | sudo tee /sys/bus/wmi/drivers/acer-wmi-battery/health_mode

# Allow full 100% charge
echo 0 | sudo tee /sys/bus/wmi/drivers/acer-wmi-battery/health_mode
```

### Add them in .bashrc file for shortcut commands (Optional)

```bash
# Acer Battery Control Aliases
# Limit charging threshold to 80%
alias batt80='echo 1 | sudo tee /sys/bus/wmi/drivers/acer-wmi-battery/health_mode'

# Allow charging threshold up to 100%
alias batt100='echo 0 | sudo tee /sys/bus/wmi/drivers/acer-wmi-battery/health_mode'

# Check active charging mode
alias battstat='cat /sys/bus/wmi/drivers/acer-wmi-battery/health_mode'
```

- `batt80` — cap charging at 80%.
- `batt100` — allow full 100% charge.
- `battstatus` — show current mode (`1` or `0`).

### Kernel Update Maintenance

The module is compiled against the active kernel, so after a major kernel update you must recompile:

```bash
cd ~/acer-wmi-battery
make clean
make
sudo cp acer-wmi-battery.ko /lib/modules/$(uname -r)/kernel/drivers/platform/x86/
sudo depmod -a
sudo modprobe acer-wmi-battery
```
