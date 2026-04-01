---
title: "Karabiner-Elements File Watcher Doesn't Detect Edits to Stow Symlink Targets"
date: 2026-03-09
category: integration-issues
subcategory: file-watchers

problem:
  type: configuration
  symptoms:
    - Karabiner rules don't take effect after editing the config file
    - Complex modifications appear unchanged despite valid JSON edits
    - Hold/tap and other new rules silently ignored
  error_messages: []

root_cause:
  summary: Karabiner watches the symlink path, not the resolved target — edits to the target don't trigger reload
  details: |
    Karabiner-Elements uses kqueue/FSEvents to watch ~/.config/karabiner/karabiner.json.
    When this path is a GNU Stow symlink, Karabiner monitors the symlink itself, not
    the resolved target file. Editing the target (e.g., ~/dotfiles/karabiner/.config/karabiner/karabiner.json)
    does not fire a change event on the symlink path, so Karabiner never reloads.

solution:
  command: "touch /Users/dev/dotfiles/karabiner/.config/karabiner/karabiner.json"
  verification: "Test the new rule in Karabiner EventViewer"

components:
  - karabiner-elements
  - stow

tags:
  - karabiner
  - file-watchers
  - stow-symlinks
  - kqueue
  - fsevents
  - macos
  - config-reload

related_docs:
  - /Users/dev/dotfiles/docs/solutions/integration-issues/macos-sed-inode-file-watcher-symlink-reload.md
---

# Karabiner-Elements File Watcher Doesn't Detect Edits to Stow Symlink Targets

## Symptom

After editing `karabiner.json` (the real file managed by Stow), new or modified Karabiner rules don't take effect. Existing rules continue working. The config file is valid JSON and passes `karabiner_cli --lint-complex-modifications`.

```
# Edit the file — config is valid, but nothing changes
$ vim ~/dotfiles/karabiner/.config/karabiner/karabiner.json
$ karabiner_cli --lint-complex-modifications ~/.config/karabiner/karabiner.json
karabiner.json: ok
# ... but Karabiner still uses the old rules
```

## Root Cause

Karabiner-Elements watches `~/.config/karabiner/karabiner.json` for changes. When this is a Stow symlink:

```
~/.config/karabiner/karabiner.json -> ../../dotfiles/karabiner/.config/karabiner/karabiner.json
```

Karabiner's file watcher (kqueue/FSEvents) monitors the symlink path. Edits to the target file update the target's inode/mtime but don't generate a change event on the symlink itself, so Karabiner never sees the update.

This applies regardless of how the edit is made (vim, sed, programmatic edit tools) — the issue is the symlink indirection, not the editing method.

## Solution

After editing the config, `touch` the file to update its mtime and trigger the watcher:

```bash
touch /Users/dev/dotfiles/karabiner/.config/karabiner/karabiner.json
```

This should be run after every edit to the Karabiner config when it's stow-managed.

## Verification

1. Open **Karabiner EventViewer** (already installed at `/Applications/Karabiner-EventViewer.app`)
2. Press the key you modified
3. Confirm the new mapping appears in the event log

## Key Insight

This is a sibling issue to the [macOS sed -i inode problem](./macos-sed-inode-file-watcher-symlink-reload.md), but with a different root cause:

| Issue | Root cause | Fix |
|---|---|---|
| sed -i breaks watchers | New inode created, watcher still tracks old inode | Use read-modify-write pattern to preserve inode |
| Symlink target edit invisible | Watcher monitors symlink, not resolved target | `touch` file after edit to trigger watcher |

Both stem from macOS file watcher limitations with Stow symlinks, but require different fixes.

## Prevention

When editing stow-managed configs that are watched by apps:

- Always `touch` the file after editing if the app watches via symlink
- Test that the app picked up changes — don't assume valid config = applied config
- Consider adding `touch` to any scripts that modify stow-managed Karabiner config
