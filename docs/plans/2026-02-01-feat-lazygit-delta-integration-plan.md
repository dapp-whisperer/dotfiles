---
title: "feat: LazyGit Delta Integration"
type: feat
date: 2026-02-01
---

# feat: LazyGit Delta Integration

## Overview

Integrate [Delta](https://github.com/dandavison/delta) as the global git pager and LazyGit diff viewer, providing syntax-highlighted side-by-side diffs with Tokyo Night theming to match the existing Helix editor configuration.

## Problem Statement / Motivation

The default git diff output uses `+/-` prefixes without syntax highlighting, making it difficult to quickly understand code changes. Delta provides a familiar diff experience similar to Cursor/VS Code with:

- Syntax highlighting for changed code
- Side-by-side view for easier comparison
- Word-level diff highlighting (not just line-level)
- Theme consistency with the rest of the development environment

## Proposed Solution

1. Install Delta via Brewfile
2. Install Tokyo Night theme for bat/delta
3. Configure Delta as global git pager in `.gitconfig`
4. Create new `lazygit/` stow package with Delta pager configuration
5. Update `install.sh` to handle the new package and theme installation

## Technical Considerations

### Theme Installation

Tokyo Night is **not a built-in theme** for Delta/bat. It must be installed from [folke/tokyonight.nvim](https://github.com/folke/tokyonight.nvim/tree/main/extras/sublime) extras.

**Installation steps:**
1. Create bat themes directory: `~/.config/bat/themes/`
2. Download `tokyonight_night.tmTheme` from the tokyonight.nvim repo
3. Run `bat cache --build` to register the theme

### LazyGit Pager Configuration

LazyGit requires specific pager settings:
- `--paging=never` - LazyGit handles its own scrolling
- `--side-by-side` - Enable side-by-side view
- `--syntax-theme` - Explicit theme reference

### Terminal Width Consideration

Side-by-side mode works best in terminals >= 100 columns. In narrow terminals (split panes), the output may be cramped. This is an accepted trade-off for the better experience in full-width scenarios.

## Acceptance Criteria

- [x] `git diff` shows syntax-highlighted side-by-side output with Tokyo Night colors
- [x] `git log -p` shows syntax-highlighted diffs
- [x] LazyGit diff preview uses Delta formatting
- [x] `install.sh` successfully sets up Delta and theme on fresh machine
- [x] Configuration works on both macOS and Linux (Linuxbrew)

## Files to Modify

### Brewfile

Add Delta to CLI Utilities section (after line 18):

```ruby
# Brewfile (line ~19)
brew "git-delta"      # Syntax-highlighted diffs
brew "bat"            # Cat with syntax highlighting (needed for delta themes)
```

### git/.gitconfig

Add Delta pager and configuration:

```ini
# git/.gitconfig

[init]
	defaultBranch = main

[core]
	editor = nvim
	pager = delta

[interactive]
	diffFilter = delta --color-only

[delta]
	side-by-side = true
	line-numbers = false
	syntax-theme = tokyonight_night
	dark = true
	navigate = true

[merge]
	conflictStyle = zdiff3

[alias]
	st = status
	co = checkout
	br = branch
	ci = commit

[pull]
	rebase = true

[user]
	name = dapp-whisperer
	email = dapp-whisperer@pm.me
```

### lazygit/.config/lazygit/config.yml (NEW FILE)

Create new stow package:

```yaml
# lazygit/.config/lazygit/config.yml
git:
  paging:
    colorArg: always
    pager: delta --paging=never --side-by-side --syntax-theme=tokyonight_night
```

### install.sh

**Add mkdir for lazygit and bat config directories (after line 135):**

```bash
mkdir -p "$HOME/.config/lazygit"
mkdir -p "$HOME/.config/bat/themes"
```

**Add lazygit to stow loop (line 147):**

```bash
for package in zsh git yazi zellij helix nvim lazygit; do
```

**Add new step for Tokyo Night theme installation (new STEP between 6 and 7):**

```bash
# ============================================
# STEP 6.5: Install Delta theme
# ============================================
step "Installing Delta syntax theme..."

TOKYONIGHT_THEME="$HOME/.config/bat/themes/tokyonight_night.tmTheme"
if [[ ! -f "$TOKYONIGHT_THEME" ]]; then
    info "Downloading Tokyo Night theme for Delta..."
    curl -fsSL "https://raw.githubusercontent.com/folke/tokyonight.nvim/main/extras/sublime/tokyonight_night.tmTheme" \
        -o "$TOKYONIGHT_THEME" || warn "Could not download Tokyo Night theme"

    if command -v bat &>/dev/null; then
        bat cache --build || warn "Could not rebuild bat cache"
        info "Tokyo Night theme installed"
    fi
else
    info "Tokyo Night theme already installed"
fi
```

**Add delta to installed tools output (after line 235):**

```bash
command -v delta &>/dev/null && echo "  - delta (syntax-highlighted diffs)"
```

## Directory Structure After Implementation

```
dotfiles/
├── Brewfile                           # +2 lines (git-delta, bat)
├── git/.gitconfig                     # +delta config sections
├── lazygit/                           # NEW
│   └── .config/
│       └── lazygit/
│           └── config.yml             # NEW
└── install.sh                         # +theme installation step
```

## References & Research

### Internal References
- Brainstorm: `docs/brainstorms/2026-02-01-lazygit-delta-integration-brainstorm.md`
- Current git config: `git/.gitconfig`
- Stow pattern reference: `helix/.config/helix/config.toml`

### External References
- [Delta GitHub](https://github.com/dandavison/delta)
- [Delta Configuration](https://dandavison.github.io/delta/configuration.html)
- [LazyGit Custom Pagers](https://github.com/jesseduffield/lazygit/blob/master/docs/Custom_Pagers.md)
- [Tokyo Night bat theme](https://github.com/0xTadash1/bat-into-tokyonight)
- [tokyonight.nvim extras](https://github.com/folke/tokyonight.nvim/tree/main/extras/sublime)
