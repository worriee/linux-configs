#!/usr/bin/env bash
# setup.sh — One-command restore of this dotfiles repo onto a fresh XFCE install (XFCE-only).
# Run from inside the cloned repo:  bash setup.sh
# Full instructions: fresh-install.md

set -u

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOME_DIR="${HOME}"
OK()   { printf '  \033[32m[ok]\033[0m %s\n' "$*"; }
WARN() { printf '  \033[33m[!!]\033[0m %s\n' "$*"; }
STEP() { printf '\n\033[1m==> %s\033[0m\n' "$*"; }

FAILED_STEPS=()
run_step() { # run_step <label> <command...>  — a failed step is logged, not fatal
    local label="$1"; shift
    STEP "$label"
    if "$@"; then OK "$label"
    else WARN "$label failed — continuing"; FAILED_STEPS+=("$label"); fi
}

# ------------------------------------------------
# 0. Distro + DE guards (XFCE-only; Mint/Ubuntu-apt vs openSUSE-zypper)
# ------------------------------------------------
# shellcheck disable=SC1091
. /etc/os-release
DISTRO=""
case "${ID:-} ${ID_LIKE:-}" in
    *opensuse*|*suse*) DISTRO="opensuse" ;;
    *mint*|*ubuntu*|*debian*) DISTRO="ubuntu" ;;
    *) echo "Unsupported distro (ID=${ID:-unknown}). Supports Linux Mint/Ubuntu (apt) and openSUSE (zypper) only." >&2; exit 1 ;;
esac

case "${XDG_CURRENT_DESKTOP:-}" in
    *XFCE*) DE_LABEL="${XDG_CURRENT_DESKTOP}" ;;
    *)
        if pgrep -x xfce4-session >/dev/null 2>&1; then
            DE_LABEL="${XDG_CURRENT_DESKTOP:-xfce4-session (detected via pgrep)}"
        else
            echo "XFCE-only repo: detected desktop '${XDG_CURRENT_DESKTOP:-unknown}'. Aborting." >&2
            exit 1
        fi
        ;;
esac

pkg_in() { # pkg_in <pkgs...> — install packages for the detected distro
    if [ "$DISTRO" = "opensuse" ]; then sudo zypper -n in "$@"
    else sudo apt install -y "$@"; fi
}

echo "==============================================="
echo " XFCE dotfiles restore (XFCE-only)"
echo " repo   : $REPO"
echo " user   : $(whoami)  home: $HOME_DIR"
echo " distro : $DISTRO (ID=${ID:-unknown})  desktop: $DE_LABEL"
echo "==============================================="

# ------------------------------------------------
# 1. Fix hardcoded paths in repo copies
# ------------------------------------------------
STEP "Fixing hardcoded paths (/home/julry -> $HOME_DIR)"
sed -i "s|/home/julry|$HOME_DIR|g" \
    "$REPO/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-keyboard-shortcuts.xml" \
    "$REPO/.config/opencode/opencode.jsonc"
OK "paths rewritten"

# ------------------------------------------------
# 2. Packages (sudo) — per-distro list, installed via pkg helpers
# ------------------------------------------------
if [ "$DISTRO" = "opensuse" ]; then
    STEP "Checking package availability (zypper dry-check)"
    for _pkg in rofi flameshot picom fastfetch kitty earlyoom lightdm-slick-greeter zram-generator gcc make kernel-default-devel curl xrandr; do
        if sudo zypper se -x --match-exact "$_pkg" >/dev/null 2>&1; then OK "$_pkg found"
        else WARN "$_pkg not found in repos — install still attempted for the rest"; FAILED_STEPS+=("pkg missing: $_pkg"); fi
    done
    unset _pkg
    run_step "Installing packages" bash -c 'sudo zypper -n ref && sudo zypper -n in rofi flameshot picom fastfetch kitty earlyoom lightdm-slick-greeter zram-generator gcc make kernel-default-devel curl xrandr'
else
    run_step "Installing packages" bash -c 'sudo apt update && sudo apt install -y rofi flameshot picom fastfetch sticky kitty zram-tools curl'
fi

# Starship prompt (not in apt — official installer, skipped if present)
STEP "Starship prompt engine"
if command -v starship >/dev/null; then
    OK "starship already installed"
else
    if curl -sS https://starship.rs/install.sh | sh -s -- -y; then OK "starship installed"
    else WARN "starship install failed — see setup.md Section 9"; FAILED_STEPS+=("starship install"); fi
fi

# Install repo .bashrc (custom aliases: fresh, batt80/100/stat) — idempotent
STEP "Installing .bashrc (aliases: fresh, batt80/100/stat)"
if grep -q '^alias fresh=' "$HOME_DIR/.bashrc" 2>/dev/null; then
    OK ".bashrc aliases already present"
elif [ -f "$REPO/.bashrc" ]; then
    cp -b "$REPO/.bashrc" "$HOME_DIR/.bashrc"
    OK ".bashrc installed (backup: .bashrc~)"
else
    WARN "$REPO/.bashrc missing — aliases skipped"
fi

# Hook starship into bash (idempotent)
if ! grep -q 'starship init bash' "$HOME_DIR/.bashrc" 2>/dev/null; then
    echo 'eval "$(starship init bash)"' >> "$HOME_DIR/.bashrc"
    OK "starship hook appended to .bashrc"
else
    OK "starship hook already in .bashrc"
fi

# Distro-specific `fresh` alias — rewrite the alias line in place (idempotent)
STEP "Setting distro-specific fresh alias ($DISTRO)"
if [ "$DISTRO" = "opensuse" ]; then
    _FRESH_LINE="alias fresh='sudo systemctl restart dev-zram0.swap && sudo systemctl restart display-manager' # distro-fresh-alias"
else
    _FRESH_LINE="alias fresh='(sudo systemctl restart zramswap 2>/dev/null || sudo systemctl restart zram-config) && sudo systemctl restart lightdm' # distro-fresh-alias"
fi
if [ -f "$HOME_DIR/.bashrc" ]; then
    if grep -qF "$_FRESH_LINE" "$HOME_DIR/.bashrc" 2>/dev/null; then
        OK "fresh alias already correct for $DISTRO"
    else
        sed -i '/# distro-fresh-alias/d; /^alias fresh=/d' "$HOME_DIR/.bashrc"
        echo "$_FRESH_LINE" >> "$HOME_DIR/.bashrc"
        OK "fresh alias set for $DISTRO"
    fi
else
    WARN "$HOME_DIR/.bashrc missing — fresh alias skipped"
fi
unset _FRESH_LINE

# ------------------------------------------------
# 3. Dotfiles, themes, icons, fonts
# ------------------------------------------------
STEP "Copying dotfiles, themes, icons, fonts"
mkdir -p "$HOME_DIR/.config" "$HOME_DIR/.local/share/fonts" "$HOME_DIR/.themes" "$HOME_DIR/.icons"
# -b: back up any pre-existing file as <name>~
cp -rb "$REPO/.config/." "$HOME_DIR/.config/"
cp -rb "$REPO/.themes/." "$HOME_DIR/.themes/"
cp -rb "$REPO/.icons/." "$HOME_DIR/.icons/"
cp -rb "$REPO/.local/share/fonts/." "$HOME_DIR/.local/share/fonts/"
fc-cache -f >/dev/null 2>&1
OK "dotfiles + fonts applied (backups: <file>~)"

# Screen dim toggle script (keybind restores from the xfconf XML above)
STEP "Screen dim toggle script (Super+Alt+B)"
if [ -f "$HOME_DIR/.local/bin/toggle-screen-dim.sh" ]; then
    OK "toggle-screen-dim.sh already exists"
else
    mkdir -p "$HOME_DIR/.local/bin"
    tee "$HOME_DIR/.local/bin/toggle-screen-dim.sh" >/dev/null <<'EOF'
#!/usr/bin/env bash

# 1. Dynamically grab the first connected display identifier
DISPLAY_NAME=$(xrandr --current | grep " connected" | awk '{print $1}' | head -n 1)

# 2. File used to track whether dimming is currently active
STATE_FILE="/tmp/.screen_dim_toggle_state"

# 3. Toggle brightness between 1.0 (default) and 0.6 (ultra-dim)
if [ -f "$STATE_FILE" ]; then
    xrandr --output "$DISPLAY_NAME" --brightness 1.0
    rm -f "$STATE_FILE"
else
    xrandr --output "$DISPLAY_NAME" --brightness 0.6
    touch "$STATE_FILE"
fi
EOF
    chmod +x "$HOME_DIR/.local/bin/toggle-screen-dim.sh"
    OK "toggle-screen-dim.sh created (setup.md Section 10)"
fi

# ------------------------------------------------
# 4. Login screen — slick-greeter (sudo)
# ------------------------------------------------
STEP "Login screen (slick-greeter)"
sudo mkdir -p /usr/share/backgrounds
sudo cp "$REPO/background.jpg" /usr/share/backgrounds/background.jpg && OK "wallpaper -> /usr/share/backgrounds/background.jpg"
sudo tee /etc/lightdm/slick-greeter.conf >/dev/null <<'EOF'
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
OK "slick-greeter.conf written (top-right: battery + full date, 12h)"

if [ "$DISTRO" = "opensuse" ]; then
    STEP "Selecting slick-greeter as default greeter (openSUSE)"
    _GREETER=""
    if [ -f /usr/share/xgreeters/slick-greeter.desktop ]; then
        _GREETER="/usr/share/xgreeters/slick-greeter.desktop"
    else
        _SLICK="$(ls /usr/share/xgreeters/slick*.desktop 2>/dev/null | head -n 1)"
        [ -n "${_SLICK:-}" ] && _GREETER="$_SLICK"
        unset _SLICK
    fi
    if [ -z "${_GREETER:-}" ]; then
        WARN "no slick*.desktop in /usr/share/xgreeters/ — greeter selection skipped"; FAILED_STEPS+=("greeter selection")
    elif sudo update-alternatives --set lightdm-default-greeter.desktop "$_GREETER" >/dev/null 2>&1; then
        OK "default greeter -> $_GREETER"
    else
        WARN "update-alternatives failed for $_GREETER — see setup.md Section 7"; FAILED_STEPS+=("greeter selection")
    fi
    unset _GREETER
fi

# ------------------------------------------------
# 5. System tweaks (sudo)
# ------------------------------------------------
run_step "Swappiness 180 + page-cluster 0 (zram)" bash -c 'printf "vm.swappiness=180\nvm.page-cluster=0\n" | sudo tee /etc/sysctl.d/99-swappiness.conf >/dev/null && sudo sysctl --system >/dev/null'

if [ "$DISTRO" = "opensuse" ]; then
    OK "bootloader untouched (by design)"
else
    run_step "GRUB timeout 5s" bash -c 'sudo sed -i "s/^GRUB_TIMEOUT=.*/GRUB_TIMEOUT=5/" /etc/default/grub && sudo update-grub >/dev/null'
fi

# ZRAM: zstd + 100% RAM (see setup.md Section 11)
STEP "ZRAM compressed swap (zstd, 100% RAM)"
if [ "$DISTRO" = "opensuse" ]; then
    # openSUSE uses zram-generator (units: dev-zram0.swap + systemd-zram-setup@zram0).
    # Post-state is asserted via zramctl — never assumed.
    if grep -q "zram-size = min(ram)" /etc/systemd/zram-generator.conf 2>/dev/null \
        && grep -q "compression-algorithm = zstd" /etc/systemd/zram-generator.conf 2>/dev/null \
        && zramctl --noheadings --output ALGORITHM 2>/dev/null | grep -qi zstd; then
        OK "zram already configured (zstd, 100% RAM, active)"
    else
        # Park the legacy script-based service if present (avoids double zram devices)
        sudo systemctl disable --now zramswap >/dev/null 2>&1 || true
        if printf '[zram0]\nzram-size = min(ram)\ncompression-algorithm = zstd\n' | sudo tee /etc/systemd/zram-generator.conf >/dev/null \
            && sudo systemctl daemon-reload >/dev/null 2>&1 \
            && sudo systemctl enable --now systemd-zram-setup@zram0.service >/dev/null 2>&1 \
            && sudo systemctl restart dev-zram0.swap >/dev/null 2>&1; then
            if zramctl --noheadings --output ALGORITHM 2>/dev/null | grep -qi zstd; then
                OK "zram configured + active (zstd, 100% RAM, verified via zramctl)"
            else
                WARN "zram config written but zstd not active — reboot, then check zramctl"; FAILED_STEPS+=("zram verify")
            fi
        else
            WARN "zram config failed — see setup.md Section 11"; FAILED_STEPS+=("zram config")
        fi
    fi
elif grep -q "^ALGO=zstd" /etc/default/zramswap 2>/dev/null && grep -q "^PERCENT=100" /etc/default/zramswap 2>/dev/null; then
    OK "zramswap already configured"
else
    if printf 'ALGO=zstd\nPERCENT=100\n' | sudo tee /etc/default/zramswap >/dev/null && sudo systemctl restart zramswap >/dev/null 2>&1; then
        OK "zramswap configured (zstd, 100%)"
    else
        WARN "zramswap config failed — see setup.md Section 11"; FAILED_STEPS+=("zram config")
    fi
fi

STEP "Root reserve (ext4 only — btrfs auto-skips)"
ROOT_DEV="$(findmnt -n / -o SOURCE)"
ROOT_DEV="${ROOT_DEV%%\[*}" # strip btrfs subvolume suffix like [/ @]
ROOT_FSTYPE="$(lsblk -no FSTYPE "$ROOT_DEV" 2>/dev/null)"
if [ "$ROOT_FSTYPE" = "btrfs" ]; then
    OK "btrfs root — reserve step N/A (snapper covers rollback)"
elif [[ "$ROOT_FSTYPE" == ext* ]]; then
    if sudo tune2fs -m 1 "$ROOT_DEV" >/dev/null; then OK "reserve set to 1% on $ROOT_DEV"
    else WARN "tune2fs failed on $ROOT_DEV — skipped"; FAILED_STEPS+=("ext4 reserve"); fi
else
    WARN "root ($ROOT_DEV, fstype: ${ROOT_FSTYPE:-unknown}) is not ext4/btrfs — skipped"
fi
unset ROOT_FSTYPE

# Kernel VM tuning: cache pressure, writeback, watermark (see setup.md Section 1D)
STEP "Kernel VM tuning (vfs cache, dirty ratios, watermark)"
if grep -q "^vm.vfs_cache_pressure=125" /etc/sysctl.d/70-vfs-cache-pressure.conf 2>/dev/null \
    && grep -q "^vm.watermark_scale_factor=150" /etc/sysctl.d/86-watermark-scale.conf 2>/dev/null; then
    OK "VM tuning already configured"
else
    if printf 'vm.vfs_cache_pressure=125\n' | sudo tee /etc/sysctl.d/70-vfs-cache-pressure.conf >/dev/null \
        && printf 'vm.dirty_ratio=10\nvm.dirty_background_ratio=5\n' | sudo tee /etc/sysctl.d/80-dirty-ratios.conf >/dev/null \
        && printf 'vm.watermark_boost_factor=0\n' | sudo tee /etc/sysctl.d/85-watermark-boost.conf >/dev/null \
        && printf 'vm.watermark_scale_factor=150\n' | sudo tee /etc/sysctl.d/86-watermark-scale.conf >/dev/null \
        && sudo sysctl --system >/dev/null 2>&1; then
        OK "VM tuning applied (vfs 125, dirty 10/5, watermark 0/150)"
    else
        WARN "VM tuning failed — see setup.md Section 1D"; FAILED_STEPS+=("VM tuning")
    fi
fi

# EarlyOOM: guard daemon — protects the coding stack, prefers killing Brave (see setup.md Section 1E)
STEP "EarlyOOM guard (protect zed/opencode/kitty, prefer killing Brave)"
if [ "$DISTRO" = "opensuse" ]; then
    _EARLYOOM_CONF="/etc/sysconfig/earlyoom"
else
    _EARLYOOM_CONF="/etc/default/earlyoom"
fi
if grep -qF "brave-browser" "$_EARLYOOM_CONF" 2>/dev/null; then
    OK "earlyoom already configured (our policy present)"
else
    if [ "$DISTRO" = "opensuse" ]; then
        _EARLYOOM_INSTALL=true
    else
        pkg_in earlyoom >/dev/null 2>&1 && _EARLYOOM_INSTALL=true || _EARLYOOM_INSTALL=false
    fi
    if [ "$_EARLYOOM_INSTALL" = true ] \
        && printf '%s\n' 'EARLYOOM_ARGS="-m 5 -s 5 -r 3600 --avoid \"(^|/)(zed|opencode|node|kitty|bash)$\" --prefer \"(^|/)(brave|brave-browser)$\""' | sudo tee "$_EARLYOOM_CONF" >/dev/null \
        && sudo systemctl enable --now earlyoom >/dev/null 2>&1 \
        && sudo systemctl restart earlyoom >/dev/null 2>&1; then
        OK "earlyoom active (avoid: zed/opencode/node/kitty/bash, prefer: brave)"
    else
        WARN "earlyoom setup failed — see setup.md Section 1E"; FAILED_STEPS+=("earlyoom")
    fi
    unset _EARLYOOM_INSTALL
fi
unset _EARLYOOM_CONF

# ModemManager: unneeded on a laptop without mobile broadband (see setup.md Section 1F)
STEP "Disable ModemManager"
if ! systemctl is-enabled ModemManager >/dev/null 2>&1; then
    OK "ModemManager already disabled (or not installed)"
else
    if sudo systemctl disable --now ModemManager >/dev/null 2>&1; then
        OK "ModemManager disabled"
    else
        WARN "Could not disable ModemManager — see setup.md Section 1F"; FAILED_STEPS+=("ModemManager")
    fi
fi

# TW-only: pre-dotfiles snapper snapshot (best-effort, never fatal)
if [ "$DISTRO" = "opensuse" ]; then
    STEP "Snapper pre-dotfiles snapshot (openSUSE only)"
    if command -v snapper >/dev/null 2>&1; then
        if sudo snapper create -d "pre-dotfiles $(date +%Y-%m-%d)" >/dev/null 2>&1; then OK "snapper snapshot pre-dotfiles created"
        else WARN "snapper snapshot failed — continuing"; fi
    else
        WARN "snapper not installed — snapshot skipped"
    fi
fi

# ------------------------------------------------
# 6. Optional hardware drivers (auto-detected)
# ------------------------------------------------

# MT7902 Wi-Fi/BT — only if the card is present (see setup.md Section 2A)
# Dependency-free PCI scan (no lspci needed): match vendor 0x14c3 + device 0x7902
STEP "MT7902 Wi-Fi/BT driver (optional, device-dependent)"
_MT7902=0
for _d in /sys/bus/pci/devices/*; do
    [ -r "$_d/vendor" ] && [ -r "$_d/device" ] || continue
    _v="$(cat "$_d/vendor" 2>/dev/null)"; _m="$(cat "$_d/device" 2>/dev/null)"
    if [ "$_v" = "0x14c3" ] && [ "$_m" = "0x7902" ]; then _MT7902=1; break; fi
done
unset _d _v _m
if [ "$_MT7902" -eq 0 ]; then
    OK "MT7902 card not present — skipping"
elif dkms status 2>/dev/null | grep -q "^mt7902-wifi/"; then
    OK "MT7902 drivers already registered in DKMS"
else
    if { if [ "$DISTRO" = "opensuse" ]; then pkg_in gcc make kernel-default-devel dkms >/dev/null 2>&1; \
        else pkg_in build-essential "linux-headers-$(uname -r)" dkms >/dev/null 2>&1; fi; } \
        && sudo cp -r "$REPO/drivers/mt7902/mt7902-wifi" /usr/src/mt7902-wifi-1.0 \
        && sudo cp -r "$REPO/drivers/mt7902/mt7902-bt" /usr/src/mt7902-bt-1.0 \
        && sudo dkms install -m mt7902-wifi -v 1.0 >/dev/null 2>&1 \
        && sudo dkms install -m mt7902-bt -v 1.0 >/dev/null 2>&1 \
        && sudo make -C /usr/src/mt7902-wifi-1.0 install_fw >/dev/null 2>&1 \
        && sudo make -C /usr/src/mt7902-bt-1.0 install_fw >/dev/null 2>&1; then
        OK "MT7902 drivers installed (Wi-Fi + BT, firmware + DKMS auto-rebuild)"
    else
        WARN "MT7902 setup failed — see setup.md Section 2A"; FAILED_STEPS+=("MT7902 driver")
    fi
fi
unset _MT7902

# Acer battery health mode — only on Acer laptops (see setup.md Section 2B)
VENDOR="$(cat /sys/class/dmi/id/sys_vendor 2>/dev/null || echo unknown)"
if grep -qi acer <<<"$VENDOR"; then
    STEP "Acer detected — battery health driver (80% charge limit)"
    if { if [ "$DISTRO" = "opensuse" ]; then pkg_in gcc make kernel-default-devel git; \
        else pkg_in build-essential "linux-headers-$(uname -r)" git; fi; } \
       && git clone --depth=1 https://github.com/frederik-h/acer-wmi-battery.git /tmp/acer-wmi-battery \
       && make -C /tmp/acer-wmi-battery; then
        KDIR="/lib/modules/$(uname -r)/kernel/drivers/platform/x86"
        sudo mkdir -p "$KDIR"
        sudo cp /tmp/acer-wmi-battery/acer-wmi-battery.ko "$KDIR/"
        sudo depmod -a
        echo "acer-wmi-battery" | sudo tee /etc/modules-load.d/acer-wmi-battery.conf >/dev/null
        echo "options acer-wmi-battery enable_health_mode=1" | sudo tee /etc/modprobe.d/acer-wmi-battery.conf >/dev/null
        sudo modprobe acer-wmi-battery || WARN "modprobe failed — will load after reboot"
        rm -rf /tmp/acer-wmi-battery
        OK "battery health mode installed (limit 80%)"
    else
        WARN "Acer driver build failed — see setup.md Section 2B"; FAILED_STEPS+=("acer battery driver")
    fi
else
    STEP "Vendor: $VENDOR — not an Acer, skipping battery driver"
fi

# ------------------------------------------------
# 7. Summary
# ------------------------------------------------
echo
echo "==============================================="
echo " DONE — summary"
echo "==============================================="
echo " applied : dotfiles, themes, icons, fonts, keybinds (Super+B brave, Super+R rofi, Super+Return kitty, Super+Alt+B dim toggle),"
if [ "$DISTRO" = "opensuse" ]; then
    echo "           kitty + starship prompt, login screen, swappiness, ext4 reserve, zram swap (zstd, zram-generator)"
    echo "           bootloader untouched (by design); snapper pre-dotfiles snapshot attempted"
else
    echo "           kitty + starship prompt, login screen, swappiness, GRUB timeout, ext4 reserve, zram swap (zstd)"
fi
if [ "${#FAILED_STEPS[@]}" -gt 0 ]; then
    echo " FAILED  : ${FAILED_STEPS[*]}  (re-run script or do manually via setup.md)"
fi
echo
echo " manual leftovers (not apt-installable):"
command -v brave-browser >/dev/null && echo "   brave-browser : installed" \
    || echo "   brave-browser : NOT installed (Super+B needs it) — see fresh-install.md"
command -v zed >/dev/null && echo "   zed           : installed" \
    || echo "   zed           : NOT installed — see fresh-install.md"
if [ "$DISTRO" = "opensuse" ]; then
    echo "   bootloader    : untouched (by design, GRUB step skipped on openSUSE)"
else
    echo "   GRUB timeout  : applies at next reboot"
fi
echo
read -rp "Restart the login screen now? (logs you out!) [y/N] " ans
if [ "${ans:-n}" = y ]; then
    if [ "$DISTRO" = "opensuse" ]; then sudo systemctl restart display-manager
    else sudo systemctl restart lightdm; fi
fi
exit 0
