# Dotfiles

Personal terminal environment configuration.

## Quick Install

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/dapp-whisperer/dotfiles/main/install.sh)"
```

The script will prompt for your GitHub username.

## What's Included

| Tool | Purpose |
|------|---------|
| **yazi** | Terminal file manager |
| **zellij** | Terminal multiplexer |
| **neovim** | Text editor (LazyVim) |
| **glow** | Markdown renderer |
| **claude** | Claude Code CLI |
| **codex** | OpenAI Codex CLI |
| **rust** | Rust toolchain with rust-analyzer |

## Directory Structure

```
~/dotfiles/
├── install.sh          # Bootstrap script
├── Brewfile            # Homebrew packages
├── zsh/.zshrc          # Shell config
├── git/.gitconfig      # Git config
├── yazi/.config/yazi/  # Yazi file manager
├── zellij/.config/zellij/  # Zellij multiplexer
└── nvim/.config/nvim/  # Neovim (LazyVim)
```

## Key Features

- `dev` - Opens Yazi + Claude split layout in Zellij
- `Enter` in Yazi - Edit file in Neovim (returns to Yazi on quit)
- `e` in Yazi - View markdown with glow
- `Alt+m` in Zellij - Toggle fullscreen pane
- `Space` in Neovim - Leader key for commands

## LazyVim Quick Reference

| Key | Action |
|-----|--------|
| `Space f f` | Find files |
| `Space s g` | Search in files (grep) |
| `Space e` | File explorer |
| `g d` | Go to definition |
| `g r` | Go to references |
| `K` | Hover documentation |
| `Space c a` | Code actions |

**First run note:** On first launch, Neovim downloads plugins (~30-60 seconds). Subsequent launches are instant.

## Secrets

API keys go in `~/.zshrc.local` (not tracked):

```bash
export GEMINI_API_KEY="your-key-here"
```

## Manual Update

```bash
cd ~/dotfiles && git pull && stow --restow */
```

## Testing on Ubuntu

Test the install script on a fresh Ubuntu environment using Docker:

```bash
# Start container (auto-builds if needed)
./test-ubuntu.sh run

# Connect to container
./test-ubuntu.sh shell

# Inside container, run install
cd ~/dotfiles && bash install.sh
```

**Commands:**
| Command | Action |
|---------|--------|
| `./test-ubuntu.sh run` | Start test container |
| `./test-ubuntu.sh shell` | Connect to container |
| `./test-ubuntu.sh stop` | Stop container |
| `./test-ubuntu.sh clean` | Remove container and image |
