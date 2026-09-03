# Codebase Map & File Registry

## 0. Last Synchronized Checkpoint

- **Last AI Analysis Timestamp**: September 03, 2026, 06:32 PM PST

## 1. Visual Codebase Overview

_Draw the entire project directory tree and explain each folder and file in one simple sentence. This is your bird's-eye view of the project._

### Directory Tree

```
linux-configs/
├── AGENTS.md                       _Agent workspace configuration, instruction loading, skill modes_
├── README.md                       _Project readme_
├── background.jpg                  _Desktop wallpaper_
├── fresh-install.md                _Fresh install guide_
├── mint-setup.md                   _Mint setup guide_
├── opencode.json                   _opencode project config_
├── setup.sh                        _Setup script_
├── .config/                        _User app configs (dotfiles)_
│   ├── autostart/                  _Autostart .desktop entries (Plank, updates, etc.)_
│   ├── fastfetch/config.jsonc      _Fastfetch system info config_
│   ├── gtk-3.0/gtk.css             _GTK3 custom CSS overrides_
│   ├── kitty/                      _Kitty terminal configs_
│   │   ├── current-theme.conf      _Kitty active color theme_
│   │   └── kitty.conf              _Kitty terminal settings_
│   ├── opencode/opencode.jsonc     _opencode global config_
│   ├── picom/picom.conf            _picom compositor config_
│   ├── rofi/                       _Rofi application launcher_
│   │   ├── colors/gruvbox.rasi     _Gruvbox color scheme_
│   │   ├── config.rasi             _Rofi main config_
│   │   └── launchers/type-3/       _Launcher theme_
│   ├── starship.toml               _Starship prompt config_
│   ├── xfce4/xfconf/               _Xfce4 settings (xfconf XML)_
│   └── zed/                        _Zed editor configs_
│       ├── keymap.json             _custom keybindings_
│       ├── settings.json           _editor settings_
│       └── themes/                 _custom themes_
├── .icons/                         _Icon themes_
│   ├── WhiteSur-grey/              _WhiteSur grey icons + @2x symlinks_
│   ├── WhiteSur-grey-dark/         _WhiteSur grey-dark variant_
│   └── WhiteSur-grey-light/        _WhiteSur grey-light variant_
├── .themes/                        _GTK themes_
│   ├── Gruvbox-BL-LB-Dark-Soft/    _Gruvbox dark theme (gnome-shell, gtk-2/3/4, xfwm4, plank)_
│   ├── Gruvbox-BL-LB-Dark-Soft-hdpi/ _Gruvbox dark theme hi-DPI variant_
│   └── Gruvbox-BL-LB-Dark-Soft-xhdpi/ _Gruvbox dark theme extra-hi-DPI variant_
├── .local/share/fonts/             _Custom fonts (7 Nerd Font + 2 regular files)_
└── .opencode/                      _Agent memory, rules, skills_
```

### Folder & File Descriptions

| Path | What It Does |
|------|-------------|
| `AGENTS.md` | _Agent workspace configuration — instruction loading, skill modes, memory locations_ |
| `README.md` | _Project readme_ |
| `background.jpg` | _Desktop wallpaper image_ |
| `fresh-install.md` | _Fresh install guide — setup steps for new machine_ |
| `mint-setup.md` | _Mint setup guide — detailed Linux Mint configuration steps_ |
| `opencode.json` | _Project-level opencode configuration_ |
| `setup.sh` | _Setup script — automates config installation_ |
| `.config/` | _Home for all user app configs (dotfiles)_ |
| `.config/autostart/` | _Autostart .desktop entries — auto-launch apps on login (Plank, updates, etc.)_ |
| `.config/fastfetch/config.jsonc` | _Fastfetch config — modern neofetch replacement, system info display_ |
| `.config/gtk-3.0/gtk.css` | _GTK3 custom CSS overrides_ |
| `.config/kitty/` | _Kitty terminal emulator configs_ |
| `.config/kitty/current-theme.conf` | _Kitty active color theme_ |
| `.config/kitty/kitty.conf` | _Kitty terminal settings_ |
| `.config/opencode/opencode.jsonc` | _Global opencode config for user_ |
| `.config/picom/picom.conf` | _Picom compositor config — transparency, shadows, animations_ |
| `.config/rofi/` | _Rofi application launcher configs_ |
| `.config/rofi/colors/gruvbox.rasi` | _Gruvbox color scheme for rofi_ |
| `.config/rofi/config.rasi` | _Rofi main configuration_ |
| `.config/rofi/launchers/type-3/` | _Rofi launcher theme variant_ |
| `.config/starship.toml` | _Starship cross-shell prompt config_ |
| `.config/xfce4/xfconf/` | _Xfce4 settings (xfconf XML channel)_ |
| `.config/zed/keymap.json` | _Custom keybindings for Zed editor_ |
| `.config/zed/settings.json` | _Zed editor settings — theme, UI preferences_ |
| `.config/zed/themes/` | _Custom themes for Zed editor_ |
| `.icons/` | _Icon themes — WhiteSur-grey variants (light, dark, regular)_ |
| `.themes/` | _GTK themes — Gruvbox-BL-LB-Dark-Soft (regular, hdpi, xhdpi)_ |
| `.local/share/fonts/` | _Custom fonts — 5 Nerd Font files (Iosevka, JetBrainsMono) + 2 regular (GrapeNuts, Icomoon)_ |
| `.opencode/` | _Agent memory files, rules, skills — AI workspace state_ |

---

## 2. Frontend Layer

### 1A. Logic, Functions & Code Structures

_Detailed documentation of every frontend logic, function, and code structure used in this project._

#### [FN-FE-001] Function/Logic Name

- **Purpose**: _What does this logic/function do?_
- **Location**: _File path where defined_
- **Input/Output**: _Parameters and return values_
- **Dependencies**: _What other functions/files does it rely on?_
- **Called By**: _Which components or functions invoke this?_
- **Side Effects**: _Any state mutations, API calls, or storage operations_

---

### 1B. File Registry & Connection Mapping

_Every frontend file and how it connects to the logics/functions documented in 1A above._

#### [FILE-FE-001] File Name

- **Path**: _Full relative path from project root_
- **Purpose**: _What does this file do?_
- **Functions Contained**: _References to FN-FE-XXX entries above_
- **Imports From**: _Other files it depends on_
- **Exports To**: _Files/components that import from this_
- **UI Role**: _What component, page, or feature does this file serve?_

---

## 3. Backend Layer

### 2A. Logic, Functions & Code Structures

_Detailed documentation of every backend logic, function, and code structure used in this project._

#### [FN-BE-001] Function/Logic Name

- **Purpose**: _What does this logic/function do?_
- **Location**: _File path where defined_
- **Input/Output**: _Parameters and return values_
- **Dependencies**: _What other functions/files does it rely on?_
- **Called By**: _Which endpoints, jobs, or processes invoke this?_
- **Side Effects**: _Any database mutations, cache operations, or external API calls_

---

### 2B. File Registry & Connection Mapping

_Every backend file and how it connects to the logics/functions documented in 2A above._

#### [FILE-BE-001] File Name

- **Path**: _Full relative path from project root_
- **Purpose**: _What does this file do?_
- **Functions Contained**: _References to FN-BE-XXX entries above_
- **Imports From**: _Other files it depends on_
- **Exports To**: _Files/services that import from this_
- **API Role**: _What endpoint, job, or service does this file serve?_

---

## 4. Data & Platform Layer

### 3A. Database Schema & Data Models

_Documents every database, table/collection, schema design, entity relationships, and ORM/ODM mappings used in this project._

#### [DB-001] Table/Collection Name

- **Database Type**: _[PostgreSQL, MongoDB, SQLite, etc.]_
- **Purpose**: _What this stores and why_
- **Schema Fields**: _Column/field name, type, constraints, defaults_
- **Relationships**: _Foreign keys, references to other tables or collections_
- **Indexes**: _Performance indexes defined_
- **ORM Model**: _File path of the model or schema definition_
- **Used By**: _Which backend functions query this (references to FN-BE-XXX)_

---

### 3B. Storage & File Management

_Documents file storage, asset pipelines, CDN, and cache layers._

#### [STG-001] Storage Service Name

- **Service/Provider**: _[Local disk, AWS S3, Cloudinary, Vercel Blob, etc.]_
- **Purpose**: _What kind of files are stored here_
- **Access Pattern**: _How files are uploaded, retrieved, and served_
- **Security**: _Public vs. private, signed URLs, access control_
- **Integration File**: _File path handling storage operations and configuration_

---

### 3C. Third-Party Services & Integrations

_Documents every external API, auth provider, payment gateway, webhook, and SaaS integration._

#### [SVC-001] Service Name

- **Provider**: _[Auth0, Stripe, Resend, OpenAI, etc.]_
- **Purpose**: _What this service does for the application_
- **Integration File**: _File path where this is configured or called_
- **Auth Method**: _API key, OAuth, JWT, webhook secret_
- **Environment Variables Needed**: _Keys and secrets (list names only, never actual values)_
- **Cost/Rate Limits**: _Any usage constraints or pricing model_

---

### 3D. Hosting & Deployment Environment

_Documents cloud platforms, domains, deployment pipelines, and environment configuration._

#### [DEP-001] Environment / Platform

- **Provider**: _[Vercel, Railway, AWS EC2, Netlify, etc.]_
- **Purpose**: _What runs here (frontend, backend, database, etc.)_
- **Domain**: _Custom domain or subdomain_
- **Deploy Method**: _Git push, CI/CD, Docker, manual_
- **Environment Variables**: _Required env vars (names only, never actual values)_
- **Build Command**: _How the project is built for this platform_
- **Health Check**: _URL or command to verify it is running_

---

### 3E. DevOps & Infrastructure Tooling

_Documents Docker, CI/CD pipelines, monitoring, logging, and orchestration._

#### [OPS-001] Tool / Config Name

- **Tool**: _[Docker, GitHub Actions, Nginx, Sentry, etc.]_
- **Purpose**: _What it automates or monitors_
- **Config File**: _Path to the configuration file_
- **Key Commands**: _Common CLI commands for this tool_

---

## 5. Learning Notes & Dependency Mapping

- **Critical Third-Party Libraries**: None — pure config repo, no application dependencies.
- **Tricky Code Paths**: _[Notes on complex loops, state mutations, or conditional rendering blocks that are hard to grasp at a glance.]_
<!-- c: worrie -->
