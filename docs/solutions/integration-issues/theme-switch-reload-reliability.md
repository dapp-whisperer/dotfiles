---
title: "Theme Switch Reports Success but Tools Don't Actually Reload"
date: 2026-03-11
category: integration-issues
tags:
  - theme-switching
  - ghostty
  - karabiner
  - applescript
  - stow-symlinks
  - macos
  - auto-reload
severity: medium
tools_affected:
  - Ghostty
  - Karabiner-Elements
root_cause: AppleScript menu automation can silently fail; some tools require full restart
---

# Theme Switch Reports Success but Tools Don't Actually Reload

## Problem Summary

The theme switcher script (`scripts/theme`) reports "Auto-reloaded: Ghostty" but the terminal still shows the old theme. The config file is correct, the AppleScript reload ran without error, but Ghostty didn't pick up the change.

Separately, Karabiner-Elements requires a **full application restart** to pick up config changes — there is no hot-reload mechanism.

## Symptom

```
$ theme tokyonight-night
Switched to: Tokyo Night (JetBrains Mono)

Auto-reloaded: Ghostty, Zellij, Helix, Neovim, tmux, bat
# ... but Ghostty still shows Monokai Pro colors
```

The script exits 0, the config file contains the correct theme, and no errors are printed.

## Root Cause

### Ghostty: AppleScript Reload is Intermittently Unreliable

The theme switcher triggers Ghostty's "Reload Configuration" menu item via AppleScript:

```bash
osascript -e 'tell application "System Events" to tell process "ghostty" \
    to click menu item "Reload Configuration" of menu 1 \
    of menu bar item "Ghostty" of menu bar 1'
```

This can silently fail when:
- macOS Accessibility permissions have been revoked or need re-granting
- Ghostty doesn't have focus or its menu bar isn't active
- A race condition between the config write and the reload trigger
- macOS System Events is busy or unresponsive

The `2>/dev/null || true` in the script swallows all errors, so the script always reports success.

### Karabiner: No Hot-Reload for External Config Changes

Karabiner-Elements requires a **true application restart** to pick up configuration changes. Unlike Ghostty (which has a menu-based reload), Karabiner has no reload mechanism — you must quit and relaunch the app entirely.

## Solution

### Ghostty: Manual AppleScript Retry

Run the AppleScript reload command directly:

```bash
osascript -e 'tell application "System Events" to tell process "ghostty" \
    to click menu item "Reload Configuration" of menu 1 \
    of menu bar item "Ghostty" of menu bar 1'
```

Or use Ghostty's menu: **Ghostty → Reload Configuration**.

### Karabiner: Restart the Application

```bash
# Quit and relaunch Karabiner
osascript -e 'quit app "Karabiner-Elements"'
sleep 1
open -a "Karabiner-Elements"
```

Or manually quit from the menu bar icon and relaunch from Applications.

## Prevention

### For the Theme Switcher Script

1. **Don't swallow errors silently** — capture stderr and report failures:
   ```bash
   if ! osascript -e '...' 2>/tmp/ghostty-reload-err; then
       echo "⚠ Ghostty reload may have failed: $(cat /tmp/ghostty-reload-err)"
   fi
   ```

2. **Add Karabiner to "Restart needed" list** if/when Karabiner theming is added to the switcher.

3. **Consider a retry** — a second AppleScript attempt after a brief delay catches most transient failures.

### When Adding New Tools to the Switcher

- [ ] Does the tool support hot-reload? (file watcher, signal, CLI command)
- [ ] Does hot-reload work through stow symlinks? Test explicitly.
- [ ] If using AppleScript: does it fail silently? Capture and report errors.
- [ ] If no hot-reload: add to the "Restart needed" output list.
- [ ] Does the tool require a **full restart** (not just reload)? Document this.

## Key Insight

The theme switcher has two reliability gaps:

1. **False positives**: AppleScript-based reloads can exit 0 without actually triggering the reload. The script should verify or at minimum not swallow stderr.

2. **Missing tools**: Some tools (like Karabiner) have no reload mechanism at all and need to be explicitly listed as requiring restart.

The script's output should distinguish between "confirmed reloaded", "attempted reload (unverified)", and "restart required".

## Related

- [macOS sed inode + file watcher + symlink reload](./macos-sed-inode-file-watcher-symlink-reload.md) — the original root cause analysis for theme switch failures
- [`scripts/theme`](../../scripts/theme) — the theme switcher implementation
- [`scripts/karabiner`](../../scripts/karabiner) — Karabiner config save/restore utility
