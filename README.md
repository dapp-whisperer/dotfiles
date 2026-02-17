# Dotfiles

Personal terminal environment configuration.

## Quick Install

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/dapp-whisperer/dotfiles/main/install.sh)"
```

The script will prompt for your GitHub username.

## What's Included

| Tool         | Purpose                            |
| ------------ | ---------------------------------- |
| **git**      | Version control with delta diffs   |
| **helix**    | Text editor (default)              |
| **neovim**   | Text editor (LazyVim)              |
| **tmux**     | Terminal multiplexer ([details](tmux/README.md)) |
| **zellij**   | Terminal multiplexer (alternative) |
| **yazi**     | Terminal file manager              |
| **lazygit**  | Git TUI                            |
| **ghostty**  | Terminal emulator                  |
| **gitui**    | Git TUI (alternative)              |
| **btop**     | System monitor                     |
| **delta**    | Syntax-highlighted diffs           |
| **bat**      | Cat with syntax highlighting       |
| **glow**     | Markdown renderer                  |
| **claude**   | Claude Code CLI                    |
| **codex**    | OpenAI Codex CLI                   |
| **opencode** | OpenCode CLI + custom theme        |
| **rust**     | Rust toolchain with rust-analyzer  |

## Directory Structure

Tool details: see [tmux/README.md](tmux/README.md), [opencode/README.md](opencode/README.md).

```
~/dotfiles/
├── install.sh              # Bootstrap script
├── Brewfile                # Homebrew packages
├── zsh/.zshrc              # Shell config
├── git/.gitconfig          # Git config
├── yazi/.config/yazi/      # Yazi file manager
├── zellij/.config/zellij/  # Zellij multiplexer
├── nvim/.config/nvim/      # Neovim (LazyVim)
├── helix/.config/helix/    # Helix editor
├── tmux/.config/tmux/      # Tmux multiplexer
├── lazygit/.config/lazygit/ # LazyGit
├── ghostty/.config/ghostty/ # Ghostty terminal
├── gitui/.config/gitui/    # GitUI
├── btop/.config/btop/      # btop system monitor
└── opencode/.config/opencode/ # OpenCode config, themes, agents, skills
```

## Key Features

- **Theme:** Catppuccin Mocha across all tools
- **OpenCode setup:** `catppuccin-mocha-glass` theme + versioned `agents/` and `skills/`
- `dev` - Opens Yazi + Claude split layout in Zellij
- `Enter` in Yazi - Edit file in Neovim (returns to Yazi on quit)
- `e` in Yazi - View markdown with glow
- `Alt+m` in Zellij - Toggle fullscreen pane
- `Space` in Neovim - Leader key for commands

## LazyVim Quick Reference

| Key         | Action                 |
| ----------- | ---------------------- |
| `Space f f` | Find files             |
| `Space s g` | Search in files (grep) |
| `Space e`   | File explorer          |
| `g d`       | Go to definition       |
| `g r`       | Go to references       |
| `K`         | Hover documentation    |
| `Space c a` | Code actions           |

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

Non-interactive mode (CI/Docker):

```bash
GITHUB_USERNAME=yourname GIT_NAME="Your Name" GIT_EMAIL="you@example.com" ./install.sh --non-interactive
```

Linux PATH notes:
If Homebrew was installed, add it to your shell:
`eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"`
If Claude Code was installed, ensure `~/.local/bin` is on your PATH.

**Commands:**
| Command | Action |
|---------|--------|
| `./test-ubuntu.sh run` | Start test container |
| `./test-ubuntu.sh shell` | Connect to container |
| `./test-ubuntu.sh stop` | Stop container |
| `./test-ubuntu.sh clean` | Remove container and image |
