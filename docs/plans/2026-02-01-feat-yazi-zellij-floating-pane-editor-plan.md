---
title: "feat: Add floating pane editor opening from Yazi in Zellij"
type: feat
date: 2026-02-01
---

# Add Floating Pane Editor Opening from Yazi in Zellij

## Overview

Configure Yazi so that pressing Enter opens files in a 90% floating pane in Zellij, keeping Yazi visible underneath. Combined with the existing `e` for glow preview, this gives a clean two-action workflow.

## Current State

Your setup already has the infrastructure:

| Component | File | Current Behavior |
|-----------|------|------------------|
| Yazi keymap | `yazi/.config/yazi/keymap.toml` | Enter opens nvim (blocking) |
| Open script | `~/.config/yazi/scripts/open-editor.sh` | Opens micro in floating pane (not $EDITOR) |
| Zellij config | `~/.config/zellij/config.kdl` | Alt+y opens Yazi floating |

## Proposed Keybindings

Based on common conventions from [NvimTree](https://docs.rockylinux.org/books/nvchad/nvchad_ui/nvimtree/), [yazi.nvim](https://neovimcraft.com/plugin/mikavilpas/yazi.nvim/), and [LazyVim](https://lazyvim-ambitious-devs.phillips.codes/course/chapter-4/):

| Key | Action | Notes |
|-----|--------|-------|
| **Enter** | Open in 90% floating pane | Primary action - edit while keeping Yazi visible |
| **e** | Glow preview | Already configured - quick markdown/text preview |

## Implementation

### 1. Set up Helix with tokyonight theme

**File:** `helix/.config/helix/config.toml`

```toml
theme = "tokyonight"
```

**File:** `zsh/.zshrc` - Add near the top:

```bash
export EDITOR="hx"
```

### 2. Update the open-editor script

**File:** `yazi/.config/yazi/scripts/open-editor.sh`

```bash
#!/bin/bash
# Open file in $EDITOR, with Zellij floating pane support

EDITOR_CMD="${EDITOR:-hx}"

if [ -n "$ZELLIJ" ]; then
    # Inside Zellij: open in 90% floating pane
    zellij run --floating --close-on-exit --x 5% --y 5% --width 90% --height 90% -- $EDITOR_CMD "$@"
else
    # Outside Zellij: open directly
    $EDITOR_CMD "$@"
fi
```

### 3. Update Yazi keymap

**File:** `yazi/.config/yazi/keymap.toml`

```toml
[[mgr.prepend_keymap]]
on   = "<Enter>"
run  = '''shell 'bash ~/.config/yazi/scripts/open-editor.sh "$@"' --block'''
desc = "Open in floating pane (90%)"

[[mgr.prepend_keymap]]
on   = "e"
run  = '''shell 'glow -p "$@"' --block'''
desc = "View with glow"
```

### 4. Stow configs

```bash
cd ~/dotfiles && stow helix yazi
```

## Acceptance Criteria

- [x] `Enter` on a file opens it in a 90% floating pane, Yazi remains visible
- [x] Uses `$EDITOR` (defaults to hx/Helix)
- [x] Script handles files with spaces in names
- [x] Works when Yazi is opened from Zellij's `Alt+y` binding
- [x] Falls back to direct editor open when not in Zellij

## Testing

1. Open Zellij
2. Press `Alt+y` to open Yazi floating
3. Navigate to a file
4. Press `Enter` - should open in large floating pane, Yazi stays visible underneath
5. Close the editor - Yazi should still be there

## Files to Modify

| File | Action |
|------|--------|
| `helix/.config/helix/config.toml` | Create with tokyonight theme |
| `zsh/.zshrc` | Add `export EDITOR="hx"` |
| `yazi/.config/yazi/scripts/open-editor.sh` | Update to use $EDITOR (default hx) |
| `yazi/.config/yazi/keymap.toml` | Update Enter to use floating pane script |

## References

- [Yazi Tips - Zellij Integration](https://yazi-rs.github.io/docs/tips/)
- [Yazelix Project](https://github.com/luccahuguet/yazelix) - Comprehensive Zellij+Yazi+Editor integration
- Current open-editor.sh at `~/.config/yazi/scripts/open-editor.sh`
- Zellij config at `~/.config/zellij/config.kdl`
