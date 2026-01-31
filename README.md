# Dotfiles

Personal terminal environment configuration.

## Quick Install

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/YOUR_USERNAME/dotfiles/main/install.sh)"
```

The script will prompt for your GitHub username.

## What's Included

| Tool | Purpose |
|------|---------|
| **yazi** | Terminal file manager |
| **zellij** | Terminal multiplexer |
| **glow** | Markdown renderer |
| **micro** | Text editor |
| **claude** | Claude Code CLI |
| **codex** | OpenAI Codex CLI |

## Directory Structure

```
~/dotfiles/
├── install.sh          # Bootstrap script
├── Brewfile            # Homebrew packages
├── zsh/.zshrc          # Shell config
├── git/.gitconfig      # Git config
├── yazi/.config/yazi/  # Yazi file manager
└── zellij/.config/zellij/  # Zellij multiplexer
```

## Key Features

- `dev` - Opens Yazi + Claude split layout in Zellij
- `e` in Yazi - View markdown with glow
- `Alt+m` in Zellij - Toggle fullscreen pane

## Secrets

API keys go in `~/.zshrc.local` (not tracked):

```bash
export GEMINI_API_KEY="your-key-here"
```

## Manual Update

```bash
cd ~/dotfiles && git pull && stow --restow */
```
