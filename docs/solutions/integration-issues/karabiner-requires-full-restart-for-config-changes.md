---
title: "Karabiner-Elements Requires Full Application Restart for Config Changes"
date: 2026-03-11
category: integration-issues
tags:
  - karabiner
  - macos
  - config-reload
  - hot-reload
severity: low
tools_affected:
  - Karabiner-Elements
root_cause: Karabiner-Elements has no hot-reload mechanism; config is only read at launch
---

# Karabiner-Elements Requires Full Application Restart for Config Changes

## Problem Summary

Editing `karabiner.json` (whether manually or via a script like `scripts/karabiner restore`) has no effect on the running application. Karabiner-Elements only reads its configuration at launch — there is no file watcher, CLI reload command, or menu action to trigger a re-read.

## Symptom

```bash
$ scripts/karabiner restore
Restored: ~/dotfiles/karabiner/karabiner.json → ~/.config/karabiner/karabiner.json
# ... but key remappings haven't changed
```

The config file is correct on disk, but the running Karabiner process still uses the old mappings.

## Root Cause

Karabiner-Elements loads `~/.config/karabiner/karabiner.json` once at startup and does not monitor it for changes. Unlike tools such as Ghostty (which has "Reload Configuration") or Zellij/Helix (which use file watchers), Karabiner has no reload mechanism at all.

## Solution

Quit and relaunch the application:

```bash
osascript -e 'quit app "Karabiner-Elements"'
sleep 1
open -a "Karabiner-Elements"
```

Or manually: click the Karabiner menu bar icon → **Quit Karabiner-Elements**, then relaunch from Applications.

## Prevention

- If Karabiner config management is added to the theme switcher, list it under **"Restart needed"** — never under "Auto-reloaded".
- The `scripts/karabiner restore` command could be extended to automatically restart the app after restoring config.

## Related

- [Theme switch reload reliability](./theme-switch-reload-reliability.md) — broader doc on tools that don't reliably reload
- [`scripts/karabiner`](../../scripts/karabiner) — save/restore utility for Karabiner config
