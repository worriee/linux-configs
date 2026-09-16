# openSUSE GNOME Post-Install System Optimizations (GNOME-only)

Seven performance, storage and service optimizations for openSUSE Tumbleweed GNOME on laptops with SSDs and 8GB–16GB RAM, tuned for a coding-heavy workflow (Zed, opencode, Node, Kitty). GNOME-only — does not apply to other desktops.

Run in this order after a fresh install.

---

## 0. Support scope (read first)

- GNOME-only: this repo automates GNOME customizations. Other desktops are not supported; `setup.sh` aborts off-GNOME.
- openSUSE Tumbleweed GNOME (zypper): full flow — `zram-generator` (`/etc/systemd/zram-generator.conf`), `/etc/sysconfig/earlyoom`, GDM via `display-manager`, bootloader untouched, btrfs root with snapper `pre-dotfiles` snapshot.
- No Mint/Ubuntu path in this repo. For XFCE/Mint see `xfce-setup/`.
- Fonts are not vendored here (already in `xfce-setup/.local/share/fonts/`). No `~/.local/share/gnome-shell/extensions/*` dirs vendored, no `/home/julry/.config/dconf/user` binary — text `dconf/` dumps only.

---

## 1. System Optimizations (Kernel, Boot, Storage & Services)

Everything the kernel, filesystem and background services need to run fast and lean on this machine — swap strategy, disk space, memory-reclaim behavior, OOM protection and dev-tooling tuning.

### 1A. Swappiness + Swap Readahead (60 → 200 with ZRAM)

#### What This Does

Swappiness controls how aggressively Linux moves idle RAM pages into swap instead of keeping them in physical memory.

- **Default (60):** moderate balance, tuned for slow disk swap.
- **With ZRAM (200):** max aggressive — kernel swaps idle pages eagerly into fast compressed RAM (see Section 11), freeing real RAM for Brave many tabs + Zed/opencode. SSD swapfile touched only after zram fills — SSD wear _down_, not up. `game` alias drops to 10 for gaming.
- **page-cluster (0):** controls swap readahead (pages fetched per I/O = 2^n). With zram, swap I/O is random compressed-RAM access — multi-page readahead just amplifies CPU work decompressing unused pages. `0` = one page per I/O, precise, no overfetch. Default on this kernel is already 0; setting it explicitly keeps the pairing documented.

> Requires Section 11 (ZRAM) to be set up first. Without zram, keep this low (10) to protect the SSD.

#### Step-by-Step

1. Write the drop-in and apply:

```bash
printf "vm.swappiness=200\nvm.page-cluster=0\n" | sudo tee /etc/sysctl.d/99-swappiness.conf
sudo sysctl --system
```

2. Verify:

```bash
cat /proc/sys/vm/swappiness
cat /proc/sys/vm/page-cluster
```

_(Expected output: `200` then `0`)_

Bootloader is untouched by design on openSUSE (no GRUB-timeout step). btrfs root skips any ext4 reserve step (snapper covers rollback).

---

### 1D. Kernel VM Tuning for Coding Workloads (Cache, Writeback, Watermark)

#### What This Does

Four sysctl drop-in files tune how the kernel manages caches and memory reclaim for a coding-heavy workload (Zed, opencode, Node builds, Kitty):

- **`vm.vfs_cache_pressure=125`** — reclaims inode/dentry cache 25% faster than the default (100), freeing RAM for editors and build tools.
- **`vm.dirty_ratio=10` + `vm.dirty_background_ratio=5`** — halves the default writeback thresholds (20/10) so large git operations or builds produce smaller, smoother disk flushes instead of latency spikes.
- **`vm.watermark_boost_factor=0`** — disables the kernel's watermark boost, which on 8GB machines can trigger sudden large reclaim bursts (visible stalls).
- **`vm.watermark_scale_factor=150`** — wakes `kswapd` earlier (default 10 → 150) so reclaim happens gradually in the background instead of all at once when RAM runs low.

#### Step-by-Step

1. Write the four drop-in files and apply them to the running kernel:

```bash
# vfs cache pressure — faster dentry/inode reclaim
echo "vm.vfs_cache_pressure=125" | sudo tee /etc/sysctl.d/70-vfs-cache-pressure.conf

# dirty writeback ratios — smaller, smoother flushes
printf 'vm.dirty_ratio=10\nvm.dirty_background_ratio=5\n' | sudo tee /etc/sysctl.d/80-dirty-ratios.conf

# watermark boost off — no sudden reclaim stalls
echo "vm.watermark_boost_factor=0" | sudo tee /etc/sysctl.d/85-watermark-boost.conf

# earlier background reclaim — gentler under memory pressure
echo "vm.watermark_scale_factor=150" | sudo tee /etc/sysctl.d/86-watermark-scale.conf

# Apply all four immediately
sudo sysctl --system
```

2. Verify the active values:

```bash
sysctl vm.vfs_cache_pressure vm.dirty_ratio vm.dirty_background_ratio vm.watermark_boost_factor vm.watermark_scale_factor
```

_(Expected output: `125`, `10`, `5`, `0`, `150` — files land in `/etc/sysctl.d/` and apply automatically on every boot.)_

### 1E. EarlyOOM Guard (Protect Editors, Prefer Killing Brave)

#### What This Does

`earlyoom` watches free RAM/swap and kills the biggest memory hog **before** the kernel OOM-killer freezes the whole desktop. The config here protects the coding stack (`zed`, `opencode`, `node`, `kitty`, `bash`) via `--avoid` and makes Brave the preferred sacrifice via `--prefer` — a browser tab is recoverable, an editor session is not. `-m 5 -s 5` triggers at 5% RAM/swap free; `-r 3600` logs a status line hourly.

#### Step-by-Step

1. Write the custom process priority rules (openSUSE path) and restart:

```bash
echo 'EARLYOOM_ARGS="-m 5 -s 5 -r 3600 --avoid \"(^|/)(zed|opencode|node|kitty|bash)$\" --prefer \"(^|/)(brave|brave-browser)$\""' | sudo tee /etc/sysconfig/earlyoom && sudo systemctl enable --now earlyoom && sudo systemctl restart earlyoom
```

2. Verify:

```bash
systemctl is-active earlyoom && cat /etc/sysconfig/earlyoom
```

_(Expected: `active` plus the `EARLYOOM_ARGS` line above.)_

### 1F. Disable ModemManager

#### What This Does

Stops the modem-management daemon and prevents it from starting at boot. This laptop has no mobile broadband, so the daemon is pure background overhead. Wi-Fi and Bluetooth are unaffected — those run through NetworkManager.

#### Step-by-Step

```bash
# Stop the service and prevent it from starting on future system boots
sudo systemctl stop ModemManager && sudo systemctl disable ModemManager
```

Verify: `systemctl is-enabled ModemManager` → `disabled`.

### 1G. Node.js Memory Ceiling

#### What This Does

Caps the V8 JavaScript heap at **1536MB** so opencode sessions and npm builds degrade gracefully on the 8GB machine instead of starving zram and triggering the OOM guard. The limit applies to every `node` process started from your shell.

#### Step-by-Step

```bash
# Append the Node.js memory ceiling parameter to your user shell configuration
echo 'export NODE_OPTIONS="--max-old-space-size=1536"' >> ~/.bashrc
```

Verify: `source ~/.bashrc && echo $NODE_OPTIONS` → `--max-old-space-size=1536`.

---

## 2. OPTIONAL — Hardware Notes (Skipped on This Machine)

Both entries below are **laptop-specific extras** — this section documents why `setup.sh` skips them here.

### 2A. MT7902 Wi-Fi + Bluetooth — DEPRECATED (in-kernel driver active)

MediaTek MT7902 (`14c3:7902` at `0000:02:00.0`) previously needed the out-of-tree `mt7902e`/`btusb_mt7902` DKMS drivers (vendored under `xfce-setup/drivers/mt7902/`).

Deprecated on this machine: kernel `7.2.4-1-default` already drives the card via in-kernel `mt7921e` (`lsmod` shows `mt7921e` loaded). `setup.sh` detects the PCI ID but skips the DKMS install and logs the deprecation. Do not install the vendored driver while `mt7921e` is active.

If Wi-Fi ever breaks after a kernel change, check `nmcli device` and `lsmod | grep mt7921` first before touching DKMS.

### 2B. Acer Battery Health Mode — SKIPPED

Vendor is Acer, but the `acer-wmi-battery` 80% charge-limit driver is intentionally skipped on this GNOME install. Charge aliases (`batt80`/`batt100`/`battstat`) from `.bashrc` still work if the module is installed manually later; `setup.sh` logs `Acer detected — battery driver skipped by policy`.

---

## 3. GNOME Shell Extensions (dash-to-panel only)

Kept set (3 IDs, in `extensions/list.txt`):

- `blur-my-shell@aunetx`
- `dash-to-panel@jderose9.github.com`
- `disable-workspace-switcher@jbradaric.me`

Stale ID dropped: `dash-to-dock@micxgx.gmail.com` was in `gsettings enabled-extensions` but is not installed/enabled (`gnome-extensions list --enabled` shows only the 3 above). `setup.sh` overwrites the key with the 3-ID list.

#### Step-by-Step

```bash
gsettings set org.gnome.shell enabled-extensions "['blur-my-shell@aunetx', 'dash-to-panel@jderose9.github.com', 'disable-workspace-switcher@jbradaric.me']"
gsettings get org.gnome.shell enabled-extensions
gnome-extensions list --enabled
```

Panel layout itself restores from text dump:

```bash
dconf load /org/gnome/shell/extensions/dash-to-panel/ < dconf/dash-to-panel.dconf
```

Panel app icon is `~/Documents/jm-icon.png` (repo `assets/jm-icon.png`, auto-copied by `setup.sh`). Same file doubles as fastfetch logo.

---

## 3B. Keybindings (GNOME native, dconf only)

Captured from live TW GNOME 50.4 via `dconf dump` (not `xfce4-keyboard-shortcuts.xml` like XFCE). All four dumps restore with `dconf load` — no GUI steps needed.

### Custom App Shortcuts (media-keys)

| Shortcut | Command | Name |
| -------- | ------- | ---- |
| `Super + Return` | `kitty` | Kitty |
| `Super + e` | `nautilus` | Files |
| `Super + z` | `flatpak run dev.zed.Zed` | Zed |
| `Super + b` | `flatpak run com.brave.Browser` | Brave |
| `Ctrl + Shift + Esc` | `gnome-system-monitor` | System Monitor |

Source dump: `dconf/media-keys.dconf` → path `/org/gnome/settings-daemon/plugins/media-keys/`.

### Window Manager Keybinds (wm)

| Shortcut | Action |
| -------- | ------ |
| `Super + 1..5` | Switch to workspace 1–5 |
| `Super + Alt + 1..5` | Move window to workspace 1–5 |
| `Alt + F4` / `Super + q` | Close window |
| `Super + Up` | Maximize |
| `Super + h` / `Ctrl + Super + f` | Minimize (hide) |
| `Alt + F7` / `Alt + F8` | Begin move / resize |
| `Super + KP_Home/End/Page_Up/Next` | Move to corner (quadrants) |
| `Super + KP_Left/Right/Up/Down` | Tile/move to side |
| `Ctrl + Alt + d` / `Super + d` | Show desktop |
| `Alt + F12` | Toggle above |
| `Alt + F10` / `Super + f` | Toggle maximized |

Source dump: `dconf/wm-keybindings.dconf` → path `/org/gnome/desktop/wm/keybindings/`.

### Mutter + Shell Extras

- `Super + Left/Right` (+ `KP_Left/KP_Right`) — toggle tiled left/right (`dconf/mutter-keybindings.dconf` → `/org/gnome/mutter/keybindings/`).
- `Print` / `Alt+Print` / `Shift+Print` — screenshot / window / UI (`dconf/shell-keybindings.dconf` → `/org/gnome/shell/keybindings/`).

### How to Restore on New Laptop

```bash
REPO=/home/julry/vscodefiles/linux-configs/gnome-setup
dconf load /org/gnome/settings-daemon/plugins/media-keys/ < "$REPO/dconf/media-keys.dconf"
dconf load /org/gnome/desktop/wm/keybindings/ < "$REPO/dconf/wm-keybindings.dconf"
dconf load /org/gnome/shell/keybindings/ < "$REPO/dconf/shell-keybindings.dconf"
dconf load /org/gnome/mutter/keybindings/ < "$REPO/dconf/mutter-keybindings.dconf"
```

Or use `gnome-setup/setup.sh` Section 4 loop — it loads all four automatically.

---

## 4. Blur-my-shell (panel + applications only) + Animations Off

Policy: panel blur ON, applications blur ON, dash-to-dock blur OFF (no dash-to-dock installed).

```bash
# panel + apps stay blurred
dconf write /org/gnome/shell/extensions/blur-my-shell/panel/blur true
dconf write /org/gnome/shell/extensions/blur-my-shell/applications/blur true
# dash-to-dock subtree disabled (stale)
dconf write /org/gnome/shell/extensions/blur-my-shell/dash-to-dock/blur false
# or: dconf reset -f /org/gnome/shell/extensions/blur-my-shell/dash-to-dock/
```

Restore shipped dumps:

```bash
dconf load /org/gnome/shell/extensions/blur-my-shell/panel/ < dconf/blur-my-shell-panel.dconf
dconf load /org/gnome/shell/extensions/blur-my-shell/applications/ < dconf/blur-my-shell-applications.dconf
```

Animations off (less compositor work):

```bash
gsettings set org.gnome.desktop.interface enable-animations false
gsettings get org.gnome.desktop.interface enable-animations  # → false
```

Interface font/theme snapshot lives in `dconf/interface.dconf`; restore with:

```bash
dconf load /org/gnome/desktop/interface/ < dconf/interface.dconf
```

---

## 5. GNOME Indexing + PIM Trim (localsearch, evolution)

`localsearch-3` (file indexer) and Evolution data services are masked per user pick — saves background CPU/IO on a coding machine.

```bash
# Localsearch: mask + stop (ignore missing units)
systemctl --user mask localsearch-3.service localsearch-control-3.service localsearch-writeback-3.service
systemctl --user stop localsearch-3.service localsearch-control-3.service localsearch-writeback-3.service

# Evolution: mask + stop
systemctl --user mask evolution-source-registry.service evolution-calendar-factory.service evolution-addressbook-factory.service evolution-user-prompter.service org.gnome.Evolution-alarm-notify.service
systemctl --user stop evolution-source-registry.service evolution-calendar-factory.service evolution-addressbook-factory.service evolution-user-prompter.service org.gnome.Evolution-alarm-notify.service

# Evolution alarm autostart override (only if system file exists)
mkdir -p ~/.config/autostart
printf '[Desktop Entry]\nHidden=true\n' > ~/.config/autostart/org.gnome.Evolution-alarm-notify.desktop
```

Verify: `systemctl --user is-active localsearch-3.service evolution-source-registry.service` → `inactive`.

GNOME Software background downloads off (manual updates only):

```bash
gsettings set org.gnome.software download-updates false
gsettings get org.gnome.software download-updates  # → false
```

(`allow-updates` stays `true`; if the key is missing the write is ignored.)

---

## 6. Print / Discovery Trim (CUPS + Avahi off, Bluetooth kept)

```bash
sudo systemctl disable --now cups.service cups.socket avahi-daemon.service avahi-daemon.socket
systemctl is-enabled cups.service avahi-daemon.service  # → disabled
systemctl is-enabled bluetooth.service  # → enabled (untouched)
```

Bluetooth stays enabled by policy — `setup.sh` never touches it.

---

## 7. dconf Restore (Fresh Install)

Text dumps only (no `~/.config/dconf/user` binary):

```bash
REPO=/home/julry/vscodefiles/linux-configs/gnome-setup
dconf load /org/gnome/shell/extensions/dash-to-panel/ < "$REPO/dconf/dash-to-panel.dconf"
dconf load /org/gnome/shell/extensions/blur-my-shell/panel/ < "$REPO/dconf/blur-my-shell-panel.dconf"
dconf load /org/gnome/shell/extensions/blur-my-shell/applications/ < "$REPO/dconf/blur-my-shell-applications.dconf"
dconf load /org/gnome/desktop/interface/ < "$REPO/dconf/interface.dconf"
dconf load /org/gnome/settings-daemon/plugins/media-keys/ < "$REPO/dconf/media-keys.dconf"
dconf load /org/gnome/desktop/wm/keybindings/ < "$REPO/dconf/wm-keybindings.dconf"
dconf load /org/gnome/shell/keybindings/ < "$REPO/dconf/shell-keybindings.dconf"
dconf load /org/gnome/mutter/keybindings/ < "$REPO/dconf/mutter-keybindings.dconf"
```

Then re-apply Section 3–4 `gsettings`/`dconf write` trims (loads can revive the stale `dash-to-dock` blur key — the explicit `blur false` after load wins).

Requires `~/Documents/jm-icon.png` present first (`setup.sh` copies it from `assets/jm-icon.png`) — dash-to-panel + fastfetch share it.

Snapper safety net (openSUSE, before dotfiles land):

```bash
sudo snapper create -d "pre-dotfiles $(date +%Y-%m-%d)"
```

---

## 8. Kitty Terminal + Starship Powerline Prompt

Same Kitty/Starship stack as XFCE side. Files ship in repo (`.config/kitty/kitty.conf`, `.config/kitty/current-theme.conf`, `.config/starship.toml`); `setup.sh` copies them with `cp -rb`.

Font note: JetBrains Mono comes from `xfce-setup/.local/share/fonts/` — not duplicated here. Install that set first on a fresh machine, then `fc-cache -f`.

Starship hook + `NODE_OPTIONS` + `fresh` alias land in `~/.bashrc` (idempotent `grep -q` guards in `setup.sh`).

Fastfetch logo is `~/Documents/jm-icon.png` via kitty graphics (`logo.type kitty`, `32x16`) — same file as panel icon, ships in `.config/fastfetch/config.jsonc`.

---

## 9. No-Reboot Reset & fresh Alias (GDM)

GDM restart (logs you out — save work first):

```bash
sudo systemctl restart display-manager
```

Flush zram + restart session (combined):

```bash
sudo systemctl restart dev-zram0.swap && sudo systemctl restart display-manager
```

Shortcut alias — one word: `fresh` (auto-installed by `setup.sh`):

```bash
alias fresh='sudo systemctl restart dev-zram0.swap && sudo systemctl restart display-manager' # distro-fresh-alias
```

Other refreshes:

```bash
sudo sync && echo 3 | sudo tee /proc/sys/vm/drop_caches  # clear RAM cache
sudo systemctl restart NetworkManager                    # Wi-Fi/BT stack
```

---

## 10. Autostart Overrides

Only override shipped here is the Evolution alarm kill (see Section 5). Location: `~/.config/autostart/org.gnome.Evolution-alarm-notify.desktop` with `Hidden=true`. Copy verbatim; log out/in to apply.

---

## 11. ZRAM Compressed Swap (zstd, zram-generator)

Compressed swap in RAM: a virtual block device (`/dev/zram0`) that holds swapped pages compressed in memory instead of writing them to the SSD. Works together with Section 1A (swappiness 180): Linux first compresses idle pages into fast RAM, and only touches the SSD swapfile after zram fills up.

### Step 1: Install the Management Package

```bash
sudo zypper -n in zram-generator
```

### Step 2: Configure Algorithm and Allocation Size

`/etc/systemd/zram-generator.conf`:

```text
[zram0]
zram-size = min(ram)
compression-algorithm = zstd
```

- `zram-size = min(ram)` — zram capacity = 100% of installed RAM. Dynamic limit: only consumes physical memory as data is actively compressed into it.
- `compression-algorithm = zstd` — Zstandard: much tighter ratio (~30–35% of original size) with negligible CPU overhead on modern multi-core processors.

### Step 3: Apply the Configuration

```bash
sudo systemctl daemon-reload
sudo systemctl enable --now systemd-zram-setup@zram0.service
sudo systemctl restart dev-zram0.swap
```

### Step 4: Verification and Priority Check

```bash
zramctl
swapon --show
```

Expected `zramctl` output:

| Field        | Expected Value                            |
| ------------ | ----------------------------------------- |
| `NAME`       | `/dev/zram0`                              |
| `ALGORITHM`  | `zstd`                                    |
| `DISKSIZE`   | 100% of RAM (e.g. `7G` on an 8GB machine) |
| `MOUNTPOINT` | `[SWAP]`                                  |

Expected `swapon --show` priorities:

| Swap Source  | Priority | Role                                     |
| ------------ | -------- | ---------------------------------------- |
| `/dev/zram0` | `100`    | High — Linux writes here first           |
| `/swapfile`  | `-1`     | Low — SSD failsafe only after zram fills |

**Rule**: Linux writes to the highest priority swap first. This guarantees memory overflow goes into high-speed compressed RAM, with the SSD swapfile as a secondary failsafe.

---

## Quick Reference Summary Table

### Performance (Kernel & Services)

| Item | Default | New Value | Benefit |
| -------------------------- | ------------- | ------------------ | -------------------------------------------------------- |
| **vm.swappiness** | `60` | `200` (`game` 10) | Max zram first; SSD failsafe; `game` lowers for gaming |
| **vm.page-cluster** | `0` | `0` | One page per swap I/O — no zram CPU waste |
| **vm.vfs_cache_pressure** | `100` | `125` | Faster cache reclaim — RAM freed for editors/builds |
| **vm.dirty_ratio** | `20` | `10` | Smaller writeback bursts — no save/git stalls |
| **vm.dirty_background_ratio** | `10` | `5` | Earlier background flush — smoother saves |
| **vm.watermark_boost_factor** | `10000` | `0` | Disables sudden reclaim bursts/stalls |
| **vm.watermark_scale_factor** | `10` | `150` | Earlier, gentler background reclaim |
| **EarlyOOM** | _none_ | `active` (`-m 5 -s 5`) | Kills Brave first — protects editor sessions |
| **ModemManager** | `enabled` | `disabled` | Less background overhead |
| **NODE_OPTIONS heap cap** | _unlimited_ | `1536MB` | Node builds can't exhaust 8GB RAM |

### Storage, Boot & Optional Hardware

| Item | Default | New Value | Benefit |
| ---------------------- | ------------ | ------------------- | ---------------------------------------------- |
| **Bootloader** | — | `untouched` | openSUSE GRUB left alone by design |
| **ext4 reserved blocks** | `5%` | `N/A (btrfs)` | Snapper `pre-dotfiles` snapshot instead |
| **ZRAM swap** | SSD swapfile | `zstd`, `min(ram)` via `zram-generator` | Fast compressed swap; less SSD wear |
| **MT7902 Wi-Fi/BT** _(opt)_ | _none_ | `deprecated, in-kernel mt7921e active` | Vendored DKMS driver skipped |
| **Acer battery health** _(opt)_ | `100%` charge | `skipped by policy` | No WMI driver installed here |

### Look & Feel

| Item | Default | New Value | Benefit |
| --------------------- | -------------- | ------------------------------------------------------------ | ---------------------------------- |
| **Shell extensions** | distro defaults | `dash-to-panel + blur-my-shell + disable-workspace-switcher` | Stale dash-to-dock ID dropped |
| **Blur-my-shell** | defaults | `panel blur true, apps blur true, dash-to-dock blur false` | Panel/apps frosted, no stale blur |
| **Animations** | `true` | `false` | Less compositor work |
| **GNOME Software** | auto-download | `download-updates false` | Manual updates only |
| **Indexing (localsearch)** | `active` | `masked` | Less background CPU/IO |
| **Evolution services** | `active` | `masked + autostart Hidden=true` | No PIM background noise |
| **CUPS / Avahi** | `enabled` | `disabled` | Less background overhead; BT kept |
| **Kitty terminal** | stock config | JetBrains Mono 11, 85% opacity, Gruvbox Dark Soft | Gruvbox-consistent GPU terminal |
| **Starship prompt** | plain bash | Gruvbox powerline | Git-aware visual prompt |
| **fresh alias** | _none_ | `restart dev-zram0.swap + display-manager` | One-word session reset |
