# Code Review Log Memory

## 0. Last Synchronized Checkpoint

- **Last AI Analysis Timestamp**: September 09, 2026, 04:02 PM PST

## 1. Active & Open Review Findings

_All eight reviews REVIEW-019–026 (split-layout audit, September 13, 2026) fixed the same day — migrated to Section 2._

_All six reviews from the September 05, 2026 full-repo audit are resolved — migrated to Section 2._

_Reviews REVIEW-012–018 (TW-readiness audit, September 09, 2026) all fixed the same day — migrated to Section 2._

## 2. Historical & Resolved Reviews

_Move reviews to this section once they are completely verified as resolved. This serves as historical memory to prevent the AI from re-introducing the same issues._

> STRICT RULE: When a review finding in Section 1 is remediated, the AI MUST migrate it to this section within the SAME response using `### [RESOLVED] Short Review Description (REVIEW-XXX)`. All headers in this file are IMMUTABLE. Existing resolved entries MUST NOT be deleted, truncated, or rewritten. New resolved entries are prepended (LIFO) directly under the Section 2 header. The original REVIEW-XXX tracking number MUST be preserved in the resolved header. Failure to migrate immediately is a CRITICAL VIOLATION.

### [RESOLVED] Stale duplicate docs (REVIEW-026)

- **The Issue**: Map listed old root `background.jpg`, `fresh-install.md`, `mint-setup.md`; no GNOME entrypoint pointer.
- **The Resolution**: `codebase_map.md` tree + table rewritten to split layout (`xfce-setup/` + `gnome-setup/` with dconf/extensions/assets rows); timestamp September 13, 2026, 08:53 AM PST. Verified via read-back.
- **Prevention Strategy**: Refresh map on every repo restructure; grep for moved filenames before closing.

---

### [RESOLVED] Scripts block automation, weak guards (REVIEW-025)

- **The Issue**: Both scripts ended with blocking `read -rp`; XFCE bulk `cp -rb` unchecked. Breaks non-interactive runs.
- **The Resolution**: Both tails gated on `[ -t 0 ]` with non-interactive skip note; XFCE copies split into per-dir `[ -d ]` guarded lines (September 13, 2026, 08:54 AM PST). Verified `bash -n` ok both.
- **Prevention Strategy**: Gate every `read` on TTY; guard every bulk copy on `[ -d ]`.

---

### [RESOLVED] Hardcoded path rewrite incomplete (REVIEW-024)

- **The Issue**: GNOME path fix covered only `opencode.jsonc`; `/home/julry` remained in `.bashrc` + dconf dump.
- **The Resolution**: `gnome-setup/setup.sh` sed extended to `.bashrc` + `dconf/dash-to-panel.dconf` (September 13, 2026, 08:54 AM PST). Verified via grep.
- **Prevention Strategy**: Grep repo for `/home/julry` before closing portability reviews.

---

### [RESOLVED] Dconf icon path mismatch assets (REVIEW-023)

- **The Issue**: Dump pointed at `~/Documents/opensuse-icon.webp`; script never installed the asset.
- **The Resolution**: New `Panel app icon` step copies `assets/opensuse-icon.webp` to `$HOME/Documents/` with `cp -b`, warns + logs `FAILED_STEPS` when missing (September 13, 2026, 08:54 AM PST). Verified `bash -n` ok.
- **Prevention Strategy**: Every dconf-referenced absolute path needs an install step or rewrite.

---

### [RESOLVED] Background.jpg missing, cp unguarded (REVIEW-022)

- **The Issue**: XFCE login step ran unconditional `sudo cp "$REPO/background.jpg"`; file absent on fresh clone.
- **The Resolution**: Wrapped in `[ -f ]` guard — copies when present, else `WARN` + `FAILED_STEPS+=("wallpaper missing")` (September 13, 2026, 08:54 AM PST). Verified `bash -n` ok.
- **Prevention Strategy**: Guard every asset `cp` on `[ -f ]`; never assume vendored media.

---

### [RESOLVED] Fresh-install.md misplaced (REVIEW-021)

- **The Issue**: Guide lived in `.opencode/` tool dir; refs assumed sibling file.
- **The Resolution**: Confirmed already at `xfce-setup/fresh-install.md` (move predated audit); fixed stale `bash setup.sh` refs inside to `bash xfce-setup/setup.sh` + corrected both `setup.sh` header lines to per-DE paths (September 13, 2026, 08:54 AM PST).
- **Prevention Strategy**: Keep guides next to their scripts; fix internal command paths on move.

---

### [RESOLVED] One-command target missing (REVIEW-020)

- **The Issue**: `bash setup.sh` at root fails post-split.
- **The Resolution**: `xfce-setup/fresh-install.md:12,119` now `bash xfce-setup/setup.sh`; both `setup.sh` headers show per-DE commands; README shows both per-DE commands (September 13, 2026, 08:54 AM PST). Verified via grep.
- **Prevention Strategy**: Grep for bare `bash setup.sh` after any layout split.

---

### [RESOLVED] README stale root layout (REVIEW-019)

- **The Issue**: Table listed root-level scripts/assets; real layout is split `gnome-setup/` + `xfce-setup/`.
- **The Resolution**: README rewritten — split scope note, per-DE table rows, two clone commands, hardened-notes paragraph; refs updated to `xfce-setup/fresh-install.md` (September 13, 2026, 08:54 AM PST). Verified all linked paths exist.
- **Prevention Strategy**: Rewrite README table on every top-level move; verify each linked path exists.

### [RESOLVED] snapper snapshot per re-run (REVIEW-018)

- **The Issue**: Every re-run minted a `pre-dotfiles` snapshot, littering `snapper list`.
- **The Resolution**: Description date-tagged: `snapper create -d "pre-dotfiles $(date +%Y-%m-%d)"` (September 09, 2026, 04:02 PM PST).
- **Prevention Strategy**: Snapshot descriptions must carry dates.

---

### [RESOLVED] btrfs root printed misleading ext4 WARN (REVIEW-017)

- **The Issue**: On btrfs, findmnt SOURCE carries `[/@]`, lsblk failed, every TW run printed a scary "not ext4 — skipped" warning.
- **The Resolution**: Step rewritten — strips `[...]` suffix, explicit btrfs branch prints OK "reserve step N/A (snapper covers rollback)", ext4 branch unchanged (September 09, 2026, 04:02 PM PST).
- **Prevention Strategy**: Fstype checks must name btrfs explicitly; never infer from lsblk failure.

---

### [RESOLVED] pkg_sync() dead code removed (REVIEW-016)

- **The Issue**: `pkg_sync()` defined but step 2 inlined sync inside the run_step subshell; never called.
- **The Resolution**: Function deleted; `pkg_in()` retained and used (September 09, 2026, 04:02 PM PST).
- **Prevention Strategy**: Grep for callers before adding shell helpers.

---

### [RESOLVED] xrandr dep declared on TW (REVIEW-015)

- **The Issue**: Dim-toggle script needs xrandr at keypress time; TW XFCE pattern might not ship it.
- **The Resolution**: `xrandr` added to TW zypper pkg list + dry-check loop (September 09, 2026, 04:02 PM PST).
- **Prevention Strategy**: Runtime deps of generated scripts must be install-time packages.

---

### [RESOLVED] curl installed on both distros (REVIEW-014)

- **The Issue**: Starship/Brave/Zed steps pipe `curl`; Mint pre-installs it, TW XFCE might not.
- **The Resolution**: `curl` added to apt list and TW zypper list + dry-check loop (September 09, 2026, 04:02 PM PST).
- **Prevention Strategy**: Never assume fetch tools; declare them.

---

### [RESOLVED] ZRAM moved to verified zram-generator flow (REVIEW-013)

- **The Issue**: Config targeted /etc/systemd/zram-generator.conf with no guarantee the mechanism existed; fallbacks enabled unknown defaults silently.
- **The Resolution**: Web-verified (upstream systemd/zram-generator + TW forum Jan 2026 + SLES docs): TW pkg list now installs `zram-generator` (replacing `systemd-zram-service`), writes `[zram0] zram-size = min(ram)` + `compression-algorithm = zstd`, parks legacy `zramswap`, daemon-reload + enable `systemd-zram-setup@zram0` + start `dev-zram0.swap`, and ASSERTS post-state via `zramctl` (zstd active → OK; else FAILED_STEPS "zram verify"). TW `fresh` alias + fresh-install/docs updated to `dev-zram0.swap` (September 09, 2026, 04:02 PM PST).
- **Prevention Strategy**: Swap setup must assert via zramctl/swapon, never assume from config files.

---

### [RESOLVED] EarlyOOM guard uses policy signature (REVIEW-012)

- **The Issue**: `grep -q EARLYOOM_ARGS` matched vendor templates (TW fillup sysconfig VERIFIED to ship uncommented SUSE-default EARLYOOM_ARGS via OBS), so our avoid-zed/prefer-brave policy would silently never apply.
- **The Resolution**: Guard changed to `grep -qF "brave-browser"` — matches only our policy, both distros (September 09, 2026, 04:02 PM PST).
- **Prevention Strategy**: Idempotency guards must match our signature, never generic variable names.

---

### [RESOLVED] Kitty doc heredoc synced with live config (REVIEW-011)

- **The Issue**: S11B heredoc listed 7 kitty settings; live + repo kitty.conf have 4 more: `cursor_shape block`, `remember_window_size no`, `initial_window_width 900`, `initial_window_height 800`.
- **The Resolution**: Added the 4 lines (with comment markers) + explainer bullets to S11B, matching live kitty.conf byte-for-byte.
- **Prevention Strategy**: Doc heredocs should be diffed against live config during `-codebase` sync.

---

### [RESOLVED] Zed settings.json mirrored to live (REVIEW-010)

- **The Issue**: Repo `settings.json` had `"line_ending": "enforce_crlf"`; live uses `"detect"`.
- **The Resolution**: Copied live `~/.config/zed/settings.json` into repo (verified identical).
- **Prevention Strategy**: Mirror dotfiles to the repo after any manual settings change.

---

### [RESOLVED] opencode.jsonc mirrored to live (REVIEW-009)

- **The Issue**: Repo opencode.jsonc still carried the removed obsidian MCP block + `/home/julry` path; live version dropped it and fixed a trailing comma.
- **The Resolution**: Copied live `~/.config/opencode/opencode.jsonc` into repo (verified identical; setup.sh `/home/julry` sed still applies on install).
- **Prevention Strategy**: Keep `.config/opencode` in sync with live; treat doc mentions of MCP as historical.

---

### [RESOLVED] picom.conf mirrored to live, Plank artifacts removed (REVIEW-008)

- **The Issue**: Repo picom.conf had dormant Plank `opacity-rule` + old `fade-delta 8`/`steps 0.04`; live is clean (`opacity-rule=[]`, fade-delta 2, steps 0.02, `use-damage`, `no-fading-openclose`).
- **The Resolution**: Copied live `~/.config/picom/picom.conf` into repo (verified identical) — consistent with plank removal.
- **Prevention Strategy**: picom.conf should be mirrored from live; run a Plank-class grep on commit.

---

### [RESOLVED] Plank.desktop deletion staged for commit (REVIEW-007)

- **The Issue**: `Plank.desktop` deleted in worktree but still tracked in HEAD — a fresh clone would reinstall plank autostart.
- **The Resolution**: Deletion is in the worktree and staged with the review-fix batch; user commits it themselves.
- **Prevention Strategy**: Verify `git ls-files` for removed autostart entries before considering a removal done.

---

### [RESOLVED] .bashrc added to git tracking (REVIEW-006)

- **The Issue**: `.bashrc` backup was untracked — fresh clone would lose aliases (`fresh`, batt80/100/stat, starship hook) and setup.sh would WARN-skip.
- **The Resolution**: `.bashrc` is staged for commit with this fix batch; user commits it.
- **Prevention Strategy**: New repo backup files must be `git add`ed in the same session they are created.

---

### [RESOLVED] Rofi palette switched to gruvbox (REVIEW-003)

- **The Issue**: Doc + setup.sh claimed Gruvbox palette, but live AND repo `shared/colors.rasi` imported `onedark.rasi`.
- **The Resolution**: `colors.rasi` line 18 updated to `@import "~/.config/rofi/colors/gruvbox.rasi"` in both live `~/.config/rofi/` and repo copy. Doc S10A/10B + setup.sh already consistent.
- **Prevention Strategy**: Keep file state and docs in sync during a commit; re-audit `colors.rasi` import on future theme changes.

---

### [RESOLVED] Acer battery doc clarified to current 100% state (REVIEW-002)

- **The Issue**: Doc described driver installed with 80% limit active, but live `health_mode` = `0` (100% charge).
- **The Resolution**: User confirmed driver is installed and working; 100% limit is intentional for now. Added a "Current state (this machine)" note to S9 explaining limit is off by choice and how to re-enable via the `batt80` alias. Guide left intact.
- **Prevention Strategy**: Doc must separate "setup guide" from "current machine state" — annotate runtime state explicitly.

---

### [RESOLVED] Autostart section corrected — Plank removed, disabled apps fixed (REVIEW-001)

- **The Issue**: Doc listed Plank as checked/enabled (user had deleted plank); Update Manager + Warpinator listed checked but were `Hidden=true` disabled; undocumented Bitwarden entry present.
- **The Resolution**: Dropped `plank` from setup.sh packages, fresh-install.md, README autostart line; deleted repo `.config/autostart/Plank.desktop`; removed Plank from S6 checked list, command table, and restore prose (all checked apps are now system defaults); moved Update Manager + Warpinator to the Unchecked list to mirror live. Left dormant plank assets (.themes plank dock.theme, picom `class_g = 'Plank'` rules) untouched by design. Bitwarden autostart not documented (manual-app leftover).
- **Prevention Strategy**: Verify live planted state, then recount autostart checked/unchecked against `~/.config/autostart/` + `/etc/xdg/autostart/` before documenting.

---

### [RESOLVED] Keyboard shortcut table synced to live binds (REVIEW-004)

- **The Issue**: 4 stale rows: `Super+Return`→kitty (doc said x-terminal-emulator), close = `Super+q` (doc said `Super+w`), workspaces only 1–4 (doc said 1–5), plain arrows are cursor keys not workspace nav.
- **The Resolution**: S4 tables updated: `Super + Return` → "Open Kitty terminal (`kitty`)", `Super + 1..4`, `Super + q`, removed the `Left/Right/Up/Down` "Move between workspaces" row. Repo keybind XML already matched live — no XML change.
- **Prevention Strategy**: Generate keybind tables from the repo `xfce4-keyboard-shortcuts.xml` (single source of truth) instead of hand-writing.

---

### [RESOLVED] ext4 reserved space verified at 1% (REVIEW-005)

- **The Issue**: `tune2fs -l` needs root — reserve % unconfirmed; `df` math estimated ~1.2%.
- **The Resolution**: User confirmed root reserve is 1% on `/dev/nvme0n1p5`. No doc change needed.
- **Prevention Strategy**: Confirm root-reserve value during `-context` scans with `sudo tune2fs -l` when possible.

---

## 3. Review Summary Metrics

- **Total Reviews Conducted**: 3
- **Critical Findings**: 0
- **High Findings**: 6
- **Medium Findings**: 4
- **Low Findings**: 8
- **Last Review Date**: `September 09, 2026, 04:02 PM PST`

---

## 4. ARCHIVE STATUS

- **Archive File**: `.opencode/archives/review_archive.md`
- **Threshold**: 10 active entries per section
- **Total Archived**: 0
- **Last Archive Check**: `Not yet performed`

| Entries Archived | Archived At (PST) |
| ---------------- | ----------------- |
| 0                | —                 |

<!-- c: worrie -->
