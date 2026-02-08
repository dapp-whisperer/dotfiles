---
title: Ghostty Terminal SSH "missing or unsuitable terminal" Error
date: 2026-02-07
category: terminal-issues
subcategory: ssh-compatibility

problem:
  type: configuration
  symptoms:
    - tmux fails to start on remote server
    - "missing or unsuitable terminal: xterm-ghostty" error
    - tput commands fail with unknown terminal
  error_messages:
    - "missing or unsuitable terminal: xterm-ghostty"
    - "tput: unknown terminal 'xterm-ghostty'"

root_cause:
  summary: Remote server lacks terminfo entry for xterm-ghostty
  details: |
    Ghostty terminal sets TERM=xterm-ghostty to identify itself.
    Remote servers don't have this terminfo entry in their database,
    causing terminal capability lookups to fail.

solution:
  command: "infocmp -x xterm-ghostty | ssh USER@SERVER -- tic -x -"
  verification: "ssh USER@SERVER 'infocmp xterm-ghostty'"

components:
  - ghostty
  - tmux
  - ssh
  - terminfo

tags:
  - ghostty
  - tmux
  - ssh
  - terminfo
  - terminal
  - remote-server
  - xterm-ghostty

related_docs: []
---

# Ghostty Terminal SSH "missing or unsuitable terminal" Error

## Symptom

When SSHing from a machine using Ghostty terminal to a remote server, tmux (and other terminal apps) fail with:

```
missing or unsuitable terminal: xterm-ghostty
```

## Root Cause

Ghostty sets `TERM=xterm-ghostty` to identify itself. Remote servers don't have this terminfo entry in their database, so terminal capability lookups fail.

## Solution

### One-Liner Fix (Recommended)

Transfer your local terminfo to the remote server:

```bash
infocmp -x xterm-ghostty | ssh USER@SERVER -- tic -x -
```

This:
1. Exports your local Ghostty terminfo entry
2. Pipes it to the remote server
3. Compiles and installs it in `~/.terminfo/`

### Quick Workaround (Temporary)

If you can't install terminfo, override TERM:

```bash
TERM=xterm-256color ssh user@server
```

Or add to `~/.ssh/config`:

```
Host server
    SetEnv TERM=xterm-256color
```

**Caveat:** This disables Ghostty-specific features (styled underlines, etc.)

## Prevention

### Option 1: Ghostty Shell Integration (v1.2.0+)

Add to `~/.config/ghostty/config`:

```ini
shell-integration-features = ssh-terminfo,ssh-env
```

This automatically installs terminfo on first SSH to new servers.

### Option 2: Dotfiles Bootstrap Script

Add to your dotfiles installation script to run on new servers:

```bash
#!/bin/bash
# Install ghostty terminfo from bundled file or fetch from repo

if infocmp xterm-ghostty &>/dev/null; then
    echo "xterm-ghostty terminfo already installed"
    exit 0
fi

# Try fetching from Ghostty repo
curl -sL "https://raw.githubusercontent.com/ghostty-org/ghostty/main/src/terminfo/ghostty.terminfo" | tic -x -

if infocmp xterm-ghostty &>/dev/null; then
    echo "Successfully installed xterm-ghostty terminfo"
else
    echo "Warning: Failed to install. Use TERM=xterm-256color as fallback"
fi
```

### Option 3: Bundle Terminfo in Dotfiles

Export and store the terminfo file:

```bash
# On your local machine
infocmp -x xterm-ghostty > ~/dotfiles/terminal/xterm-ghostty.terminfo
```

Then install on remote servers:

```bash
tic -x ~/dotfiles/terminal/xterm-ghostty.terminfo
```

## Verification

```bash
# Check if terminfo is installed
infocmp xterm-ghostty

# Check current TERM
echo $TERM

# Test tmux
tmux new-session -d -s test && tmux kill-session -t test && echo "tmux works!"
```

## Notes

- ncurses 6.5-20241228+ includes xterm-ghostty by default
- As distros update, this issue will resolve itself
- macOS pre-Sonoma may need Homebrew ncurses for `infocmp`

## References

- [Ghostty Terminfo Documentation](https://ghostty.org/docs/help/terminfo)
- [GitHub Issue #896](https://github.com/ghostty-org/ghostty/issues/896)
