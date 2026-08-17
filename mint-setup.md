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

*(Adjust `linux-configs/` to wherever this repo lives on the new laptop)*

2. Log out and back in (or restart) for the shortcuts to load.

Alternatively, re-add them manually via **Settings → Keyboard → Application Shortcuts** using the tables above.

### Dualboot with Windows Notes

- The Windows key (`Super`) works fine as the main modifier in XFCE under dualboot — no conflicts.
- If you ever switch the default browser/editor, update the `Super + b` / `Super + z` commands in Settings → Keyboard.
- Flameshot saves to `/home/julry/Pictures` — change the username in the command if your new laptop uses a different user.

---
