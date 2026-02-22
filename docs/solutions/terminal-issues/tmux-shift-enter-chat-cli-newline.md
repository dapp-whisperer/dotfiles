---
title: Shift+Enter Newline for Codex/Claude Code Inside tmux
date: 2026-02-22
category: terminal-issues
subcategory: tmux-keyboard-reporting

problem:
  type: configuration
  symptoms:
    - Shift+Enter does nothing in Codex and Claude Code when running inside tmux
    - Enter still works, but newline shortcut does not
  error_messages: []

root_cause:
  summary: Modified Enter was not consistently delivered end-to-end in the format chat TUIs expect
  details: |
    Keyboard handling has two hops: terminal -> tmux -> app.
    With negotiated extkeys, some apps do not explicitly request the mode tmux expects,
    so Shift+Enter may not arrive as a distinct key.
    A raw LF fallback (`shift+enter=text:\x0a`) is also unreliable for chat TUIs that
    interpret newline as a modified Enter event, not just a plain byte.

solution:
  tmux:
    - set -g extended-keys always
    - set -g extended-keys-format csi-u
  ghostty:
    - keybind = shift+enter=text:\x1b[13;2u
  verification:
    - Run `cat -v` inside tmux and press Shift+Enter
    - Expect `^[[13;2u` output

components:
  - ghostty
  - tmux
  - codex
  - claude-code

tags:
  - ghostty
  - tmux
  - shift-enter
  - extkeys
  - csi-u
  - codex
  - claude-code

related_docs:
  - /Users/dev/dotfiles/docs/solutions/terminal-issues/ghostty-terminfo-ssh.md
---

# Shift+Enter Newline for Codex/Claude Code Inside tmux

## Symptom

Inside tmux, `Shift+Enter` did not insert a newline in chat CLIs (Codex, Claude Code). `Enter` still submitted as expected.

## Root Cause

The modified key path was inconsistent:
1. Terminal had to emit a distinct modified Enter sequence.
2. tmux had to forward modified keys in a format the app parses.
3. The app had to receive a true modified Enter event (not just a plain LF byte).

The initial raw-byte mapping (`shift+enter=text:\x0a`) was not reliable for these TUIs.

## Changes Applied

### tmux

File:

`/Users/dev/dotfiles/tmux/.config/tmux/tmux.conf`

Set:

```tmux
set -g extended-keys always
set -g extended-keys-format csi-u
set -as terminal-features ",*:extkeys"
```

Why:
- `extended-keys always` avoids relying on app negotiation.
- `csi-u` standardizes modified key encoding (`S-Enter` as `ESC [ 13 ; 2 u`).

### Ghostty

File:

`/Users/dev/dotfiles/ghostty/.config/ghostty/config`

Set:

```ini
keybind = shift+enter=text:\x1b[13;2u
```

Why:
- Forces a real CSI-u `Shift+Enter` sequence even if default terminal behavior is inconsistent.

## Why This Fix Works

Both layers now agree on the same modified-key protocol:
- Ghostty emits CSI-u `Shift+Enter`.
- tmux forwards modified keys in CSI-u format.
- Chat TUIs receive a clear modified Enter event and treat it as newline.

## Rollout Steps

1. Restart Ghostty.
2. Reload tmux config:

```bash
tmux source-file /Users/dev/.config/tmux/tmux.conf
```

3. If behavior is still stale, restart tmux server:

```bash
tmux kill-server
```

## Verification

Inside tmux:

```bash
cat -v
```

Press `Shift+Enter`. Expected output:

```text
^[[13;2u
```

Exit with `Ctrl+C`.

## Rollback

To revert:
1. Remove Ghostty keybind line:
   `keybind = shift+enter=text:\x1b[13;2u`
2. Restore tmux setting:
   `set -g extended-keys on`
3. Remove:
   `set -g extended-keys-format csi-u`

