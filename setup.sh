#!/usr/bin/env bash
# setup.sh — One-command restore of this dotfiles repo onto a fresh Linux Mint XFCE install.
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

echo "==============================================="
echo " Linux Mint XFCE dotfiles restore"
echo " repo : $REPO"
echo " user : $(whoami)  home: $HOME_DIR"
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
# 2. Packages (sudo)
# ------------------------------------------------
run_step "Installing packages" bash -c 'sudo apt update && sudo apt install -y rofi flameshot plank picom fastfetch sticky kitty zram-tools'

# Starship prompt (not in apt — official installer, skipped if present)
STEP "Starship prompt engine"
if command -v starship >/dev/null; then
    OK "starship already installed"
else
    if curl -sS https://starship.rs/install.sh | sh -s -- -y; then OK "starship installed"
    else WARN "starship install failed — see mint-setup.md Section 11"; FAILED_STEPS+=("starship install"); fi
fi

# Hook starship into bash (idempotent)
if ! grep -q 'starship init bash' "$HOME_DIR/.bashrc" 2>/dev/null; then
    echo 'eval "$(starship init bash)"' >> "$HOME_DIR/.bashrc"
    OK "starship hook appended to .bashrc"
else
    OK "starship hook already in .bashrc"
fi

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
    OK "toggle-screen-dim.sh created (mint-setup.md Section 12)"
fi

# ------------------------------------------------
# 4. Login screen — slick-greeter (sudo)
# ------------------------------------------------
STEP "Login screen (slick-greeter)"
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

# ------------------------------------------------
# 5. System tweaks (sudo)
# ------------------------------------------------
run_step "Swappiness 100 (zram)" bash -c 'echo "vm.swappiness=100" | sudo tee /etc/sysctl.d/99-swappiness.conf >/dev/null && sudo sysctl --system >/dev/null'

run_step "GRUB timeout 5s" bash -c 'sudo sed -i "s/^GRUB_TIMEOUT=.*/GRUB_TIMEOUT=5/" /etc/default/grub && sudo update-grub >/dev/null'

# ZRAM: zstd + 100% RAM (see mint-setup.md Section 13)
STEP "ZRAM compressed swap (zstd, 100% RAM)"
if grep -q "^ALGO=zstd" /etc/default/zramswap 2>/dev/null && grep -q "^PERCENT=100" /etc/default/zramswap 2>/dev/null; then
    OK "zramswap already configured"
else
    if printf 'ALGO=zstd\nPERCENT=100\n' | sudo tee /etc/default/zramswap >/dev/null && sudo systemctl restart zramswap >/dev/null 2>&1; then
        OK "zramswap configured (zstd, 100%)"
    else
        WARN "zramswap config failed — see mint-setup.md Section 13"; FAILED_STEPS+=("zram config")
    fi
fi

STEP "ext4 reserved blocks 1%"
ROOT_DEV="$(findmnt -n / -o SOURCE)"
if lsblk -no FSTYPE "$ROOT_DEV" 2>/dev/null | grep -q ^ext; then
    if sudo tune2fs -m 1 "$ROOT_DEV" >/dev/null; then OK "reserve set to 1% on $ROOT_DEV"
    else WARN "tune2fs failed on $ROOT_DEV — skipped"; FAILED_STEPS+=("ext4 reserve"); fi
else
    WARN "root ($ROOT_DEV) is not ext4 — skipped"
fi

# ------------------------------------------------
# 6. Acer battery health mode (auto-detected)
# ------------------------------------------------
VENDOR="$(cat /sys/class/dmi/id/sys_vendor 2>/dev/null || echo unknown)"
if grep -qi acer <<<"$VENDOR"; then
    STEP "Acer detected — battery health driver (80% charge limit)"
    if sudo apt install -y build-essential "linux-headers-$(uname -r)" git \
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
        WARN "Acer driver build failed — see mint-setup.md Section 9"; FAILED_STEPS+=("acer battery driver")
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
echo "           kitty + starship prompt, login screen, swappiness, GRUB timeout, ext4 reserve, zram swap (zstd)"
if [ "${#FAILED_STEPS[@]}" -gt 0 ]; then
    echo " FAILED  : ${FAILED_STEPS[*]}  (re-run script or do manually via mint-setup.md)"
fi
echo
echo " manual leftovers (not apt-installable):"
command -v brave-browser >/dev/null && echo "   brave-browser : installed" \
    || echo "   brave-browser : NOT installed (Super+B needs it) — see fresh-install.md"
command -v zed >/dev/null && echo "   zed           : installed" \
    || echo "   zed           : NOT installed — see fresh-install.md"
echo "   GRUB timeout  : applies at next reboot"
echo
read -rp "Restart the login screen now? (logs you out!) [y/N] " ans
[ "${ans:-n}" = y ] && sudo systemctl restart lightdm
exit 0
