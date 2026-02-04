---
title: "Ubuntu/Linux Support for Dotfiles"
date: 2026-02-01
status: ready-to-plan
---

# Ubuntu/Linux Support for Dotfiles

## What We're Building

Enhance the install script to support Ubuntu VPS machines for server administration. The script should auto-detect the OS and use native apt packages (with PPAs for specialized tools) instead of Linuxbrew.

**Goal:** Run `./install.sh` on a fresh Ubuntu VPS and get the full terminal environment (yazi, zellij, helix, claude, etc.) working quickly.

## Why This Approach

- **Single script**: One install.sh works on both macOS and Ubuntu
- **Native packages**: apt is lighter than Linuxbrew (~1GB+ savings)
- **PPAs for specialized tools**: yazi, helix, zellij aren't in default Ubuntu repos
- **Automatic updates**: PPAs integrate with apt upgrade

## Key Decisions

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Package manager | apt (not Linuxbrew) | Smaller footprint, native to Ubuntu |
| Script structure | Single unified script | Simpler maintenance, consistent UX |
| Specialized tools | PPAs/external repos | apt manages updates automatically |
| Use case | Server administration | Full toolset, not minimal |

## Tool Installation Sources (Ubuntu)

| Tool | Source | Notes |
|------|--------|-------|
| git, stow, curl | apt (default) | Available in Ubuntu repos |
| node, npm | NodeSource PPA | Official Node.js distribution |
| neovim | Neovim PPA | `ppa:neovim-ppa/unstable` for latest |
| helix | Helix PPA or binary | Check for official PPA |
| yazi | Binary download | No official PPA, use GitHub releases |
| zellij | Binary download | No official PPA, use GitHub releases |
| ripgrep, fd, fzf | apt (default) | Available in Ubuntu repos |
| glow | Binary download | Charmbracelet releases |
| gh | GitHub CLI apt repo | Official Microsoft/GitHub repo |
| lazygit | Binary download | GitHub releases |
| claude | Official installer | curl script from claude.ai |

## Implementation Outline

```bash
# In install.sh

if [[ "$OS" == "linux" ]]; then
    # Add PPAs
    sudo add-apt-repository -y ppa:neovim-ppa/unstable
    # Add GitHub CLI repo
    # etc.

    # Install apt packages
    sudo apt update
    sudo apt install -y git stow curl neovim ripgrep fd-find fzf jq

    # Install binaries for tools without PPAs
    install_binary "yazi" "https://github.com/sxyazi/yazi/releases/..."
    install_binary "zellij" "https://github.com/zellij-org/zellij/releases/..."
    install_binary "helix" "https://github.com/helix-editor/helix/releases/..."
fi
```

## Open Questions

1. **Which Ubuntu versions to support?** (22.04 LTS, 24.04 LTS, latest?)
2. **Binary install location?** (`~/.local/bin` vs `/usr/local/bin`)
3. **Font installation on Linux?** (JetBrains Mono Nerd Font for terminal icons)
4. **sudo requirements?** (PPAs need sudo, binaries to ~/.local/bin don't)

## Next Steps

Run `/workflows:plan` to create implementation plan.
