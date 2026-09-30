# sway session backup (mirror-exact)

Live paths mirrored 1:1 under this folder. Restore: copy back to `$HOME`
preserving exec bit on `.local/bin/`:

```bash
cp -r sway/.config sway/.local ~/
chmod +x ~/.local/bin/*.sh
```

## Layout

- `.config/sway/config` — compositor: gaps, steel-blue `#4e6f90CC` border pixel 4,
  keybinds, portal env, idle lock 900s, grim screenshot binds
- `.config/waybar/` — pill bar: BT/wifi always-show, white text, blue glass
- `.config/wofi/` — launcher + menus theme
- `.config/mako/` — notifications
- `.config/gtk-3.0+4.0/settings.ini` — Adwaita + prefer-dark fallback
- `.local/bin/` — wifi/bluetooth/notif/power/shot/launcher/mako-bell/battery/countdown

## Requires

```bash
sudo zypper in brightnessctl playerctl grim slurp wl-clipboard \
  libnotify-tools xdg-desktop-portal xdg-desktop-portal-gtk xdg-desktop-portal-wlr
# optional: polkit-gnome xorg-x11-server-utils (YaST GUI)
```

## Notes

- Wallpaper: `/home/julry/wallpapers/bg1.jpg` (same as GNOME, not in repo)
- Bar center: `{:%a | %b %d | %I:%M %p}` → `Wed | Sep 30 | 11:00 PM`
- No rounded corners: vanilla sway limit, skipped by choice
