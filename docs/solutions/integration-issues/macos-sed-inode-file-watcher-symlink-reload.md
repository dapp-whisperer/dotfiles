---
title: "macOS sed -i Creates New Inodes, Breaking File Watchers Through Stow Symlinks"
date: 2026-02-14
category: integration-issues
tags:
  - file-watchers
  - kqueue
  - fsevents
  - bsd-sed
  - stow-symlinks
  - theme-management
  - inode-preservation
  - applescript
  - macos
tools_affected:
  - Ghostty
  - Zellij
  - Helix
  - btop
  - Neovim
  - bat
os: macOS (Darwin 23.5.0)
severity: high
resolution_time_estimate: "15 minutes (now documented)"
---

# macOS sed -i Creates New Inodes, Breaking File Watchers Through Stow Symlinks

## Problem Summary

A theme switcher script modifying stow-managed config files ran successfully (printed correct output) but no terminal tools visually changed. Three independent root causes were discovered, each requiring a distinct fix.

## Symptom

```
$ theme tokyonight-night
Switched to: Tokyo Night
# ... but Ghostty, Zellij, Helix, btop all still show old theme
```

## Root Cause Analysis

### 1. macOS `sed -i ''` Creates New Inodes

macOS BSD `sed -i ''` does NOT edit files in-place. It creates a **new file** with a **new inode**, then replaces the old file. File watchers (kqueue/FSEvents) track the original inode and never see updates to the new file.

```bash
$ stat -f '%i' config    # inode: 291816692
$ sed -i '' 's/old/new/' config
$ stat -f '%i' config    # inode: 291817191  ← DIFFERENT!
```

This is a fundamental difference from GNU/Linux `sed -i`, which modifies the file in-place (same inode).

### 2. Ghostty File Watcher Doesn't Trigger Through Stow Symlinks

Even after fixing inode preservation, Ghostty's config watcher on macOS does not detect changes made to stow symlink targets. Writing to `~/dotfiles/ghostty/.config/ghostty/config` (the real file) does not trigger Ghostty's watcher on `~/.config/ghostty/config` (the symlink).

Zellij and Helix DO detect changes through symlinks — each tool implements file watching differently.

### 3. btop `save_config_on_exit` Overwrites External Changes

btop defaults to `save_config_on_exit = true`. When the user quits btop, it writes its in-memory config state back to the file, reverting any external changes:

1. Script writes `tokyonight_night` to btop.conf
2. btop is still running with `catppuccin_mocha` in memory
3. User quits btop → btop writes `catppuccin_mocha` back
4. User restarts btop → old theme persists

## Solution

### Fix 1: Inode-Preserving Writes

Read into memory with sed, write back to the same file (preserves inode):

```bash
sed_inplace() {
    local pattern="$1" file="$2"
    local content
    content="$(sed "$pattern" "$file")"
    printf '%s\n' "$content" > "$file"
}
```

For file copies, `cp` also creates new inodes. Use `cat src > dst` instead:

```bash
copy_over() {
    local src="$1" dst="$2"
    if [[ -f "$dst" ]]; then
        cat "$src" > "$dst"  # preserves dst inode
    else
        cp "$src" "$dst"
    fi
}
```

### Fix 2: Ghostty AppleScript Reload

Trigger "Reload Configuration" from Ghostty's menu bar via AppleScript:

```bash
if pgrep -q ghostty 2>/dev/null; then
    osascript -e '
        tell application "System Events"
            tell process "ghostty"
                click menu item "Reload Configuration" of menu 1 \
                    of menu bar item "Ghostty" of menu bar 1
            end tell
        end tell
    ' 2>/dev/null || true
fi
```

Discovery method — list available menu items:
```bash
osascript -e 'tell application "System Events" to tell process "ghostty" \
    to get name of every menu item of menu 1 of menu bar item "Ghostty" of menu bar 1'
```

### Fix 3: Disable btop `save_config_on_exit`

In `~/.config/btop/btop.conf`:

```
save_config_on_exit = false
```

Move btop to "Restart needed" in script output since it has no config auto-reload.

## Verification

```bash
# Verify inode preservation
before=$(stat -f '%i' "$file")
sed_inplace "s/old/new/" "$file"
after=$(stat -f '%i' "$file")
[[ "$before" == "$after" ]] && echo "PASS" || echo "FAIL"
```

## Key Insight

macOS and Linux have fundamentally different `sed -i` behavior:
- **Linux**: modifies file in-place (same inode)
- **macOS BSD**: creates new file (new inode)

Shell redirections (`printf ... > file`) DO preserve inodes because they open the existing file with O_TRUNC rather than creating a new file. This is the basis of the fix.

Additionally, each macOS app implements file watching differently — some work through symlinks, some don't. Always test with your actual symlink setup rather than assuming.

## Prevention: When Adding New Tools

- [ ] Does it auto-save config on exit? If so, disable that setting.
- [ ] Does its file watcher work through stow symlinks? Test explicitly.
- [ ] Does it have a CLI/signal/menu action for config reload? Use that as fallback.
- [ ] Never use `sed -i` on macOS — always use the read-modify-write pattern.
- [ ] Never use `cp` for files that need inode preservation — use `cat src > dst`.

## Gotchas

- `sed -i ''` (macOS) vs `sed -i` (Linux) — different behavior, both break file watchers on macOS
- `cp` also creates new inodes — use `cat src > dst` for existing files
- `touch` on a symlink updates the target's timestamps but may not trigger all watchers
- GUI apps may need AppleScript/Accessibility triggers instead of file-based reload
- Any tool with "save on exit" will fight external config changes

## Related

- [Theme switcher plan](../../plans/2026-02-13-feat-unified-theme-switcher-plan.md)
- [Theme switcher brainstorm](../../brainstorms/2026-02-13-theme-switcher-brainstorm.md)
- [Ghostty terminfo SSH solution](../terminal-issues/ghostty-terminfo-ssh.md)
