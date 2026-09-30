#!/usr/bin/env bash
# setup.sh — One-command restore of this dotfiles repo onto a fresh openSUSE GNOME install (GNOME-only).
# Run from inside the cloned repo:  bash gnome-setup/setup.sh
# Full instructions: gnome-setup/setup.md

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
# 0. Distro + DE guards (openSUSE-only, GNOME-only)
# ------------------------------------------------
# shellcheck disable=SC1091
. /etc/os-release
DISTRO=""
case "${ID:-} ${ID_LIKE:-}" in
    *opensuse*|*suse*) DISTRO="opensuse" ;;
    *) echo "Unsupported distro (ID=${ID:-unknown}). Supports openSUSE Tumbleweed (zypper) only." >&2; exit 1 ;;
esac

case "${XDG_CURRENT_DESKTOP:-}" in
    *GNOME*) DE_LABEL="${XDG_CURRENT_DESKTOP}" ;;
    *)
        if pgrep -x gnome-shell >/dev/null 2>&1; then
            DE_LABEL="${XDG_CURRENT_DESKTOP:-gnome-shell (detected via pgrep)}"
        else
            echo "GNOME-only repo: detected desktop '${XDG_CURRENT_DESKTOP:-unknown}'. Aborting." >&2
            exit 1
        fi
        ;;
esac

pkg_in() { # pkg_in <pkgs...> — install packages via zypper
    sudo zypper -n in "$@"
}

echo "==============================================="
echo " GNOME dotfiles restore (GNOME-only, openSUSE)"
echo " repo   : $REPO"
echo " user   : $(whoami)  home: $HOME_DIR"
echo " distro : $DISTRO (ID=${ID:-unknown})  desktop: $DE_LABEL"
echo "==============================================="

# ------------------------------------------------
# 1. Fix hardcoded paths in repo copies
# ------------------------------------------------
STEP "Fixing hardcoded paths (/home/julry -> $HOME_DIR)"
sed -i "s|/home/julry|$HOME_DIR|g" \
    "$REPO/.config/opencode/opencode.jsonc" \
    "$REPO/.bashrc" \
    "$REPO/dconf/dash-to-panel.dconf" 2>/dev/null || true
OK "paths rewritten"

# ------------------------------------------------
# 2. Packages (sudo) — openSUSE only
# ------------------------------------------------
STEP "Checking package availability (zypper dry-check)"
for _pkg in fastfetch kitty earlyoom zram-generator gcc make kernel-default-devel curl gnome-extensions; do
    if sudo zypper se -x --match-exact "$_pkg" >/dev/null 2>&1; then OK "$_pkg found"
    else WARN "$_pkg not found in repos — install still attempted for the rest"; FAILED_STEPS+=("pkg missing: $_pkg"); fi
done
unset _pkg
run_step "Installing packages" bash -c 'sudo zypper -n ref && sudo zypper -n in fastfetch kitty earlyoom zram-generator gcc make kernel-default-devel curl gnome-extensions'

# Starship prompt (not in repos — official installer, skipped if present)
STEP "Starship prompt engine"
if command -v starship >/dev/null; then
    OK "starship already installed"
else
    if curl -sS https://starship.rs/install.sh | sh -s -- -y; then OK "starship installed"
    else WARN "starship install failed — see setup.md Section 8"; FAILED_STEPS+=("starship install"); fi
fi

# Install repo .bashrc (custom aliases: fresh) — idempotent
STEP "Installing .bashrc (alias: fresh)"
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
_FRESH_LINE="alias fresh='sudo systemctl restart dev-zram0.swap && sudo systemctl restart display-manager' # distro-fresh-alias"
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

# Swappiness profile aliases — game low, code max (idempotent)
STEP "Swappiness aliases game/code"
for _AL in "alias game='sudo /usr/sbin/sysctl -w vm.swappiness=10 >/dev/null && echo game: swappiness 10'" "alias code='sudo /usr/sbin/sysctl -w vm.swappiness=200 >/dev/null && echo code: swappiness 200'"; do
    _KEY="${_AL%%=*}"
    if grep -qF "$_AL" "$HOME_DIR/.bashrc" 2>/dev/null; then
        OK "$_KEY already present"
    else
        sed -i "\|^${_KEY}=|d" "$HOME_DIR/.bashrc"
        echo "$_AL" >> "$HOME_DIR/.bashrc"
        OK "$_KEY added"
    fi
done
unset _AL _KEY

# Node.js memory ceiling (idempotent)
STEP "Node.js memory ceiling (1536MB)"
if grep -q 'max-old-space-size=1536' "$HOME_DIR/.bashrc" 2>/dev/null; then
    OK "NODE_OPTIONS already set"
else
    echo 'export NODE_OPTIONS="--max-old-space-size=1536"' >> "$HOME_DIR/.bashrc"
    OK "NODE_OPTIONS appended to .bashrc"
fi

# ------------------------------------------------
# 3. Dotfiles (GNOME-only set)
# ------------------------------------------------
STEP "Copying dotfiles (kitty, starship, fastfetch, opencode)"
mkdir -p "$HOME_DIR/.config"
# -b: back up any pre-existing file as <name>~
if [ -d "$REPO/.config" ]; then
    cp -rb "$REPO/.config/." "$HOME_DIR/.config/"
    OK "dotfiles applied (backups: <file>~)"
else
    WARN "$REPO/.config missing — dotfiles skipped"; FAILED_STEPS+=("dotfiles")
fi
# Fonts live in xfce-setup/.local/share/fonts/ — not duplicated here.
fc-cache -f >/dev/null 2>&1 || true

# Panel app icon referenced by dconf/dash-to-panel.dconf (show-apps-icon-file)
STEP "Panel app icon (jm-icon.png)"
if [ -f "$REPO/assets/jm-icon.png" ]; then
    mkdir -p "$HOME_DIR/Documents"
    if cp -b "$REPO/assets/jm-icon.png" "$HOME_DIR/Documents/jm-icon.png" 2>/dev/null; then
        OK "icon -> $HOME_DIR/Documents/jm-icon.png"
    else
        WARN "icon copy failed"; FAILED_STEPS+=("panel icon")
    fi
else
    WARN "$REPO/assets/jm-icon.png missing — icon skipped"; FAILED_STEPS+=("panel icon missing")
fi

# ------------------------------------------------
# 4. GNOME shell state (extensions + dconf + gsettings)
# ------------------------------------------------
STEP "GNOME extensions (keep 3, drop stale dash-to-dock)"
_WANT="['blur-my-shell@aunetx', 'dash-to-panel@jderose9.github.com', 'disable-workspace-switcher@jbradaric.me']"
if [ "$(gsettings get org.gnome.shell enabled-extensions 2>/dev/null)" = "$_WANT" ]; then
    OK "enabled-extensions already correct"
else
    if gsettings set org.gnome.shell enabled-extensions "$_WANT" 2>/dev/null; then OK "enabled-extensions set (3 IDs)"
    else WARN "gsettings enabled-extensions failed"; FAILED_STEPS+=("enabled-extensions"); fi
fi
unset _WANT

STEP "Restoring dconf dumps (dash-to-panel, blur-my-shell, interface, keybinds)"
for _pair in "dash-to-panel:/org/gnome/shell/extensions/dash-to-panel/" "blur-my-shell-panel:/org/gnome/shell/extensions/blur-my-shell/panel/" "blur-my-shell-applications:/org/gnome/shell/extensions/blur-my-shell/applications/" "interface:/org/gnome/desktop/interface/" "media-keys:/org/gnome/settings-daemon/plugins/media-keys/" "wm-keybindings:/org/gnome/desktop/wm/keybindings/" "shell-keybindings:/org/gnome/shell/keybindings/" "mutter-keybindings:/org/gnome/mutter/keybindings/"; do
    _file="${_pair%%:*}"; _path="${_pair#*:}"
    if [ -f "$REPO/dconf/${_file}.dconf" ]; then
        if dconf load "$_path" < "$REPO/dconf/${_file}.dconf" 2>/dev/null; then OK "dconf load $_file"
        else WARN "dconf load $_file failed"; FAILED_STEPS+=("dconf $_file"); fi
    else
        WARN "$REPO/dconf/${_file}.dconf missing — skipped"
    fi
done
unset _pair _file _path

STEP "Blur-my-shell policy (panel true, apps true, dash-to-dock false)"
dconf write /org/gnome/shell/extensions/blur-my-shell/panel/blur true 2>/dev/null \
    && OK "panel blur true" || { WARN "panel blur write failed"; FAILED_STEPS+=("panel blur"); }
dconf write /org/gnome/shell/extensions/blur-my-shell/applications/blur true 2>/dev/null \
    && OK "applications blur true" || { WARN "applications blur write failed"; FAILED_STEPS+=("apps blur"); }
if dconf write /org/gnome/shell/extensions/blur-my-shell/dash-to-dock/blur false 2>/dev/null; then
    OK "dash-to-dock blur false"
else
    dconf reset -f /org/gnome/shell/extensions/blur-my-shell/dash-to-dock/ 2>/dev/null \
        && OK "dash-to-dock subtree reset" || { WARN "dash-to-dock blur clear failed"; FAILED_STEPS+=("dash-to-dock blur"); }
fi

STEP "GNOME animations off"
if [ "$(gsettings get org.gnome.desktop.interface enable-animations 2>/dev/null)" = "false" ]; then
    OK "animations already off"
else
    if gsettings set org.gnome.desktop.interface enable-animations false 2>/dev/null; then OK "animations disabled"
    else WARN "animations set failed"; FAILED_STEPS+=("animations"); fi
fi

STEP "GNOME Software download-updates false"
if [ "$(gsettings get org.gnome.software download-updates 2>/dev/null)" = "false" ]; then
    OK "download-updates already false"
else
    if gsettings set org.gnome.software download-updates false 2>/dev/null; then OK "download-updates disabled"
    else WARN "download-updates set failed (key may not exist)"; FAILED_STEPS+=("download-updates"); fi
fi

# ------------------------------------------------
# 5. System tweaks (sudo)
# ------------------------------------------------
run_step "Swappiness 200 + page-cluster 0 (zram)" bash -c 'printf "vm.swappiness=200\nvm.page-cluster=0\n" | sudo tee /etc/sysctl.d/99-swappiness.conf >/dev/null && sudo sysctl --system >/dev/null'

OK "bootloader untouched (by design)"
OK "btrfs root — ext4 reserve N/A (snapper covers rollback)"

# ZRAM: zstd + 100% RAM via zram-generator (see setup.md Section 11)
STEP "ZRAM compressed swap (zstd, min(ram))"
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
_EARLYOOM_CONF="/etc/sysconfig/earlyoom"
if grep -qF "brave-browser" "$_EARLYOOM_CONF" 2>/dev/null; then
    OK "earlyoom already configured (our policy present)"
else
    if printf '%s\n' 'EARLYOOM_ARGS="-m 5 -s 5 -r 3600 --avoid \"(^|/)(zed|opencode|node|kitty|bash)$\" --prefer \"(^|/)(brave|brave-browser)$\""' | sudo tee "$_EARLYOOM_CONF" >/dev/null \
        && sudo systemctl enable --now earlyoom >/dev/null 2>&1 \
        && sudo systemctl restart earlyoom >/dev/null 2>&1; then
        OK "earlyoom active (avoid: zed/opencode/node/kitty/bash, prefer: brave)"
    else
        WARN "earlyoom setup failed — see setup.md Section 1E"; FAILED_STEPS+=("earlyoom")
    fi
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

# GNOME service trims: localsearch + evolution (mask + stop, never fatal)
STEP "Mask localsearch indexer (user)"
systemctl --user mask localsearch-3.service localsearch-control-3.service localsearch-writeback-3.service >/dev/null 2>&1 || true
systemctl --user stop localsearch-3.service localsearch-control-3.service localsearch-writeback-3.service >/dev/null 2>&1 || true
OK "localsearch masked + stopped (missing units ignored)"

STEP "Mask Evolution data services (user)"
systemctl --user mask evolution-source-registry.service evolution-calendar-factory.service evolution-addressbook-factory.service evolution-user-prompter.service org.gnome.Evolution-alarm-notify.service >/dev/null 2>&1 || true
systemctl --user stop evolution-source-registry.service evolution-calendar-factory.service evolution-addressbook-factory.service evolution-user-prompter.service org.gnome.Evolution-alarm-notify.service >/dev/null 2>&1 || true
if [ -f /etc/xdg/autostart/org.gnome.Evolution-alarm-notify.desktop ]; then
    mkdir -p "$HOME_DIR/.config/autostart"
    if grep -q "^Hidden=true" "$HOME_DIR/.config/autostart/org.gnome.Evolution-alarm-notify.desktop" 2>/dev/null; then
        OK "evolution alarm override already present"
    else
        printf '[Desktop Entry]\nHidden=true\n' > "$HOME_DIR/.config/autostart/org.gnome.Evolution-alarm-notify.desktop"
        OK "evolution alarm autostart overridden (Hidden=true)"
    fi
else
    OK "no system evolution alarm file — override skipped"
fi

# CUPS + Avahi off, Bluetooth kept (see setup.md Section 6)
STEP "Disable CUPS + Avahi (keep bluetooth)"
if sudo systemctl disable --now cups.service cups.socket avahi-daemon.service avahi-daemon.socket >/dev/null 2>&1; then
    OK "cups + avahi disabled"
else
    WARN "cups/avahi disable had failures — continuing"; FAILED_STEPS+=("cups/avahi")
fi
if systemctl is-enabled bluetooth.service >/dev/null 2>&1; then
    OK "bluetooth still enabled (untouched)"
else
    WARN "bluetooth not enabled — left alone (never touched by policy)"
fi

# openSUSE-only: pre-dotfiles snapper snapshot (best-effort, never fatal)
STEP "Snapper pre-dotfiles snapshot (openSUSE only)"
if command -v snapper >/dev/null 2>&1; then
    if sudo snapper create -d "pre-dotfiles $(date +%Y-%m-%d)" >/dev/null 2>&1; then OK "snapper snapshot pre-dotfiles created"
    else WARN "snapper snapshot failed — continuing"; fi
else
    WARN "snapper not installed — snapshot skipped"
fi

# ------------------------------------------------
# 6. Optional hardware drivers (skipped by policy here)
# ------------------------------------------------

# MT7902 Wi-Fi/BT — DEPRECATED: in-kernel mt7921e is active (see setup.md Section 2A)
STEP "MT7902 Wi-Fi/BT driver (deprecated — skipped)"
_MT7902=0
for _d in /sys/bus/pci/devices/*; do
    [ -r "$_d/vendor" ] && [ -r "$_d/device" ] || continue
    _v="$(cat "$_d/vendor" 2>/dev/null)"; _m="$(cat "$_d/device" 2>/dev/null)"
    if [ "$_v" = "0x14c3" ] && [ "$_m" = "0x7902" ]; then _MT7902=1; break; fi
done
unset _d _v _m
if [ "$_MT7902" -eq 0 ]; then
    OK "MT7902 card not present — skipping"
elif lsmod | grep -q "^mt7921e" 2>/dev/null; then
    OK "MT7902 present but in-kernel mt7921e active — vendored DKMS driver skipped (deprecated)"
else
    OK "MT7902 present, no mt7921e loaded — still skipping per GNOME policy (see setup.md Section 2A)"
fi
unset _MT7902
# ponytail: skip vendored DKMS install entirely; in-kernel driver covers it, less code wins.

# Acer battery health mode — skipped by policy (see setup.md Section 2B)
VENDOR="$(cat /sys/class/dmi/id/sys_vendor 2>/dev/null || echo unknown)"
if grep -qi acer <<<"$VENDOR"; then
    STEP "Vendor: $VENDOR — Acer battery driver skipped by policy"
    OK "battery health mode skipped (see setup.md Section 2B)"
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
echo " applied : dotfiles (kitty, starship, fastfetch, opencode), .bashrc fresh alias,"
echo "           GNOME extensions (3 IDs), dconf dumps + keybinds, blur-my-shell panel+apps,"
echo "           animations off, download-updates off, localsearch+evolution masked,"
echo "           cups/avahi disabled (BT kept), swappiness, VM tuning, earlyoom,"
echo "           zram swap (zstd, zram-generator), ModemManager disabled"
echo "           bootloader untouched (by design); snapper pre-dotfiles snapshot attempted"
if [ "${#FAILED_STEPS[@]}" -gt 0 ]; then
    echo " FAILED  : ${FAILED_STEPS[*]}  (re-run script or do manually via setup.md)"
fi
echo
echo " manual leftovers (not zypper-installable):"
command -v brave-browser >/dev/null && echo "   brave-browser : installed" \
    || echo "   brave-browser : NOT installed — install manually"
command -v zed >/dev/null && echo "   zed           : installed" \
    || echo "   zed           : NOT installed — install manually"
echo "   fonts         : from xfce-setup/.local/share/fonts/ (not vendored here)"
echo "   bootloader    : untouched (by design)"
echo
if [ -t 0 ]; then
    read -rp "Restart the login screen now? (logs you out!) [y/N] " ans
    if [ "${ans:-n}" = y ]; then
        sudo systemctl restart display-manager
    fi
else
    echo "Non-interactive shell — restart skipped (run manually)."
fi
exit 0
