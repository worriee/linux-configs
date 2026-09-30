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

## Packages

Pinned live 2026-09-30, openSUSE Tumbleweed:

```bash
sudo zypper in sway waybar wofi mako kitty swayidle swaylock \
  brightnessctl playerctl grim slurp wl-clipboard libnotify-tools \
  NetworkManager bluez pipewire wireplumber \
  xdg-desktop-portal xdg-desktop-portal-gtk xdg-desktop-portal-wlr \
  gnome-system-monitor nautilus
# optional (YaST GUI only): polkit-gnome xorg-x11-server-utils
```

| Package | Version | Used by |
|---|---|---|
| sway | 1.12 | compositor, pixel-4 borders, idle |
| swayidle + swaylock | 1.9 + 1.8.6 | lock 900s |
| waybar | 0.15.0 | pill bar |
| wofi | 1.5.3 | launcher + 4 menus |
| mako + libnotify-tools | 1.11 + 0.8.8 | notifications, shot popup |
| kitty | 0.48.2 | terminal, Gruvbox Dark Soft |
| grim + slurp + wl-clipboard | 1.5 + 1.6 + 2.3 | screenshots + auto-copy |
| brightnessctl | 0.5.1 | backlight, device `amdgpu_bl1` |
| playerctl | 2.4.1 | media keys |
| pipewire + wireplumber | 1.6.9 + 0.5.17 | audio, `wpctl` volume |
| NetworkManager | 1.56.1 | wifi menu via `nmcli` |
| bluez | 5.87 | BT menu via `bluetoothctl` |
| portals + gtk + wlr | 1.22.1 + 1.15.3 + 0.8.4 | dark mode, dialogs (needs `graphical-session.target` line) |
| JetBrainsMonoNL Nerd Font | manual `~/.local/share/fonts`, no rpm | bar, menus, terminal |
| gnome-system-monitor + nautilus | 50 + 50.3.1 | RAM click, files (dark via portal) |

## Notes

- Wallpaper: `/home/julry/wallpapers/bg1.jpg` (same as GNOME, not in repo)
- Bar center: `{:%a | %b %d | %I:%M %p}` → `Wed | Sep 30 | 11:00 PM`
- No rounded corners: vanilla sway limit, skipped by choice
