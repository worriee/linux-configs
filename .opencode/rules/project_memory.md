# Project Memory & Context Tracker

## 0. Last Checkpoint

- **Last Sync**: September 05, 2026, 07:57 AM PST

## 1. Recent Changes (Git)

- **Vault Path**: [set after first `-obsidian`]
- **Last Scan**: September 05, 2026, 07:57 AM PST

> `-context` scan: `git status` + `git diff` + `git log @{u}..HEAD`. LIFO, newest on top.

| File | Status | Δ Lines | What Changed |
|---|---|---|---|
| `mint-setup.md` + `setup.sh` + `README.md` + `fresh-install.md` | M | — | swappiness reworked 10 → 100 → 180 (zram-first rationale), ZRAM section added (Section 13, zstd 100% RAM, priority tables), zram-tools added to package list + idempotent config step, screen dim toggle Section 12 + keybind XML synced; docs updated to match — commits `ff3c5a3b`, `fa2f0972`, `86bd8088` |
| `.config/fastfetch/` | A | — | fastfetch replaced neofetch — custom Catnap-style config: all rows iconed, aligned, 12h month-word dates, since/age rows; `config.old.jsonc` backup kept (commit `68e7cf44`) |
| `.config/kitty/kitty.conf` | M | — | cursor_shape=block fixed (commit `68e7cf44`) |
| repo sync | C | — | rofi configs + fonts, keybinds (Super+B=brave, Super+R=rofi, Super+Return=kitty), mint-setup.md Section 10 Rofi + Section 11 Kitty/Starship, setup.sh + fresh-install.md + README.md, Acer battery Section 9 — all committed; working tree clean |
| `mint-setup.md` | M | +58 | Section 8 added (Slick-Greeter login screen config: top-right minimal — battery + full date + 12h clock only; show-quit/keyboard/a11y/hostname disabled) |
| `.opencode/rules/.clinerules` | M | — | Template v5.0 update from upstream |
| `.opencode/rules/system_instructions.md` | M | — | Template v5.0 update from upstream |
| `.opencode/skills/*/SKILL.md` | M | — | All 8 skill files updated |
| `.opencode/workspace.json` | M | — | template_version 4.5 → 5.0 |
| `mint-setup.md` | M | +107 | Sections 7–8 added (panel styling, web-greeter) |
| `.themes/WhiteSur-Dark/*` | D | ~17,000+ | Full WhiteSur-Dark theme removed |
| `.themes/Gruvbox-BL-LB-Dark-Soft/` | A (untracked) | — | Gruvbox theme added (cinnamon, gnome-shell, gtk-2.0/3.0/4.0, xfwm4, metacity, plank) |
| `.themes/Gruvbox-BL-LB-Dark-Soft-hdpi/` | A (untracked) | — | Gruvbox hdpi variant (xfwm4 only) |
| `.themes/Gruvbox-BL-LB-Dark-Soft-xhdpi/` | A (untracked) | — | Gruvbox xhdpi variant (xfwm4 only) |
| `.config/gtk-3.0/gtk.css` | A (untracked) | — | GTK3 panel styling (rounded corners, transparent buttons) |

_New files visual:_
```
.config/gtk-3.0/           (new)
.themes/Gruvbox-BL-LB-Dark-Soft/
  ├── cinnamon/
  ├── gnome-shell/
  ├── gtk-2.0/
  ├── gtk-3.0/
  ├── gtk-4.0/
  ├── metacity-1/
  ├── plank/
  └── xfwm4/
.themes/Gruvbox-BL-LB-Dark-Soft-hdpi/xfwm4/
.themes/Gruvbox-BL-LB-Dark-Soft-xhdpi/xfwm4/
```

- **Unpushed**: 0 | **Staged**: 0 | **Unstaged**: 0 | **Untracked**: 0 (clean tree)
- **Total Δ**: +514 / −17,574 lines (massive theme swap WhiteSur-Dark → Gruvbox)

---

## 2. Objective

- **Purpose**: Centralize and version-control user's Linux desktop dotfiles; provide post-install setup guide for future Mint XFCE machines
- **Goal**: One-repo backup of all theming, keybinds, panel, autostart, GTK config for consistent setup across fresh installs
- **Users**: Single user (julry) — personal dev machine dotfiles

---

## 3. Important Details

- Login screen reverted to stock slick-greeter: web-greeter removed from system AND from mint-setup.md Section 8 → replaced with slick-greeter config as new Section 8
- Theme swap: WhiteSur-Dark deleted, Gruvbox-BL-LB-Dark-Soft added (with hdpi/xhdpi xfwm4 variants)
- mint-setup.md: expanded with keybinds, autostart, panel styling, web-greeter content
- `.config/gtk-3.0/` tracked for GTK3 settings
- All .opencode/ rule files modified in this session (template v5.0 update)

---

## 4. Completed

### [DONE] Login screen reverted to stock slick-greeter + minimal top-right config — August 30, 2026

### [DONE] Initial -context sync — August 30, 2026

- First context scan complete; project_memory.md populated with repo state

---

## 5. Blocked

---

## 6. Next Move

1. Pull/push repo to GitHub remote (local commits exist; ensure remote synced)
2. Future: copy repo configs to new laptop via setup guide

---

## 7. Relevant Files

| Path | Why Relevant |
|---|---|
| `mint-setup.md` | Post-install guide — keybinds, autostart, panel, web-greeter |
| `.themes/Gruvbox-BL-LB-Dark-Soft/` | Active theme (all variants) |
| `.themes/Gruvbox-BL-LB-Dark-Soft-hdpi/` | HDPI xfwm4 assets |
| `.themes/Gruvbox-BL-LB-Dark-Soft-xhdpi/` | XHDPI xfwm4 assets |
| `.config/gtk-3.0/` | GTK3 user settings |
| `.icons/WhiteSur-grey/` | Active icon theme (unchanged) |
| `README.md` | Repo readme |

<!-- c: worrie -->
