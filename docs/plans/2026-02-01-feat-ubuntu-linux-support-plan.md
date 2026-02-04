---
title: "feat: Add Ubuntu/Linux Support via Linuxbrew"
type: feat
date: 2026-02-01
---

# feat: Add Ubuntu/Linux Support via Linuxbrew

## Overview

Enable `install.sh` to work on Ubuntu by using Linuxbrew. The script already has OS detection and Linuxbrew path stubs - we just need to ensure it works.

**Key insight:** Every package in the Brewfile is available via Linuxbrew. Same Brewfile, same script, zero new abstractions.

## Implementation

### 1. Ensure Linuxbrew Prerequisites

Linuxbrew needs `build-essential`, `curl`, and `git` before it can install. Add a prerequisite step for Linux:

**File:** `install.sh` - Add after OS detection (around line 28):

```bash
# ============================================
# STEP 1.5: Linux Prerequisites (before Homebrew)
# ============================================
if [[ "$OS" == "linux" ]]; then
    step "Installing Linux prerequisites..."
    sudo apt update
    sudo apt install -y build-essential curl git
fi
```

### 2. Fix Font Cask for Linux

The Brewfile includes `cask "font-jetbrains-mono-nerd-font"` which only works on macOS. Make it conditional:

**File:** `Brewfile` - Update the font line:

```ruby
# Fonts (macOS only - casks don't work on Linux)
cask "font-jetbrains-mono-nerd-font" if OS.mac?
```

### 3. Add fd Alias for Ubuntu Compatibility

Ubuntu's `fd` package installs as `fdfind`. Add an alias:

**File:** `zsh/.zshrc` - Add near the top:

```bash
# fd-find compatibility (Linuxbrew names it fd, but if using apt it's fdfind)
command -v fd &>/dev/null || alias fd='fdfind'
```

### 4. Update Summary Output

**File:** `install.sh` - Update the "Installed tools" section to not assume macOS:

```bash
echo "Installed tools:"
command -v yazi &>/dev/null && echo "  - yazi (file manager)"
command -v zellij &>/dev/null && echo "  - zellij (terminal multiplexer)"
command -v hx &>/dev/null && echo "  - helix (default editor)"
command -v nvim &>/dev/null && echo "  - neovim (LazyVim)"
# ... rest unchanged
```

## That's It

The existing script already:
- Detects Linux (line 22)
- Has Linuxbrew path in shellenv (line 68)
- Uses universal Homebrew installer that works on Linux (line 61)
- Has `|| true` error handling for package failures (line 77)

## Acceptance Criteria

- [ ] `./install.sh` completes on Ubuntu 22.04 LTS
- [ ] `./install.sh` completes on Ubuntu 24.04 LTS
- [ ] All tools from Brewfile installed via Linuxbrew
- [ ] Dotfiles stowed correctly
- [ ] `dev` command works

## Testing

```bash
# 1. Spin up Ubuntu 22.04 VPS
# 2. Run:
git clone https://github.com/<user>/dotfiles.git
cd dotfiles
./install.sh

# 3. Verify:
source ~/.zshrc
yazi --version && zellij --version && hx --version
```

## Files to Modify

| File | Changes |
|------|---------|
| `install.sh` | Add Linux prerequisites step (~5 lines) |
| `Brewfile` | Make font cask conditional |
| `zsh/.zshrc` | Add fd alias (optional) |

## Why Linuxbrew Over Native apt

| Concern | Answer |
|---------|--------|
| "Linuxbrew is heavy (~1GB)" | Disk is cheap. Maintenance time isn't. |
| "apt is native" | Native means different Brewfile, different code paths, more bugs. |
| "PPAs are better" | PPAs go stale. Homebrew is actively maintained. |
| "Binary downloads are faster" | Binary downloads need version management. Who updates them? |

One package manager. One Brewfile. Zero new abstractions. Ship it.

## References

- Original brainstorm: `docs/brainstorms/2026-02-01-ubuntu-linux-support-brainstorm.md`
  - DHH review: "Homebrew works on Linux. You're solving a problem that doesn't exist."	
