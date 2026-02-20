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
| **neovim**   | Text editor (LazyVim, [details](nvim/README.md)) |
| **tmux**     | Terminal multiplexer ([details](tmux/README.md)) |
| **zellij**   | Terminal multiplexer (alternative) |
| **yazi**     | Terminal file manager              |
| **lazygit**  | Git TUI                            |
| **lazydocker** | Docker TUI                       |
| **ghostty**  | Terminal emulator                  |
| **gitui**    | Git TUI (alternative)              |
| **btop**     | System monitor                     |
| **delta**    | Syntax-highlighted diffs           |
| **bat**      | Cat with syntax highlighting       |
| **eza**      | Modern ls with icons               |
| **fzf**      | Fuzzy finder + shell integration   |
| **zoxide**   | Smart cd with frecency             |
| **glow**     | Markdown renderer                  |
| **claude**   | Claude Code CLI                    |
| **codex**    | OpenAI Codex CLI                   |
| **opencode** | OpenCode CLI + custom theme        |
| **karabiner** | Keyboard remapping (macOS, [details](#karabiner)) |
| **rust**     | Rust toolchain with rust-analyzer  |

## Directory Structure

Tool details: see [nvim/README.md](nvim/README.md), [tmux/README.md](tmux/README.md), [opencode/README.md](opencode/README.md), [themes/README.md](themes/README.md).

```
~/dotfiles/
├── install.sh              # Bootstrap script
├── Brewfile                # Homebrew packages
├── zsh/.zshrc              # Shell config
├── git/.gitconfig          # Git config
├── bat/.config/bat/        # bat syntax highlighter
├── delta/.config/delta/    # delta diff highlighter
├── yazi/.config/yazi/      # Yazi file manager
├── zellij/.config/zellij/  # Zellij multiplexer
├── nvim/.config/nvim/      # Neovim (LazyVim)
├── helix/.config/helix/    # Helix editor
├── tmux/.config/tmux/      # Tmux multiplexer
├── lazygit/.config/lazygit/ # LazyGit
├── lazydocker/.config/lazydocker/ # LazyDocker
├── ghostty/.config/ghostty/ # Ghostty terminal
├── gitui/.config/gitui/    # GitUI
├── btop/.config/btop/      # btop system monitor
├── opencode/.config/opencode/ # OpenCode config, themes, agents, skills
├── karabiner/              # Karabiner-Elements (copy-managed, macOS only)
├── scripts/                # Theme switcher, utilities
├── themes/                 # Theme packs + current tracker
└── tests/                  # BATS test suite
```

## Key Features

- **Unified theming** across 15 tools — see [Theme Quickstart](#theme-quickstart)
- **OpenCode setup:** `catppuccin-mocha-glass` theme + versioned `agents/` and `skills/`
- `dev` — Opens Yazi + Claude split layout in Zellij
- `devt` — Same layout using tmux
- `Enter` in Yazi — Edit file in Helix (returns to Yazi on quit)
- `e` in Yazi — View markdown with glow
- `Ctrl+b o` in Zellij — Session mode (detach, session manager, config, plugins)
- `Ctrl+b s` in Zellij — Session manager (direct shortcut)
- `Ctrl+b g` in Zellij — Locked mode (pass all keys through)
- `Alt+m` in Zellij — Toggle fullscreen pane
- `Space` in Neovim — Leader key for commands

## Theme Quickstart

```bash
# Show current + available themes
theme

# Switch theme
theme catppuccin-mocha
theme tokyonight-night
```

See [themes/README.md](themes/README.md) for internals, maintenance, and agent instructions.

## Karabiner

Provides personal key overrides for MacOS. Karabiner-Elements config is copy-managed (not stowed) since its GUI writes to the config file directly.

```bash
# Save live config to repo
scripts/karabiner save

# Restore repo config to live
scripts/karabiner restore

# Show diff between live and repo
scripts/karabiner diff
```

## Neovim

LazyVim with added plugins (markview.nvim, diffview.nvim), Rust extras, and markdown-focused keybindings. See [nvim/README.md](nvim/README.md) for full details.

**First run note:** On first launch, Neovim downloads plugins (~30-60 seconds). Subsequent launches are instant.

## Secrets

API keys go in `~/.zshrc.local` (not tracked):

```bash
export GEMINI_API_KEY="your-key-here"
```

## Manual Update

```bash
cd ~/dotfiles && git pull && stow --restow --target="$HOME" \
  zsh git yazi zellij helix nvim lazygit lazydocker delta tmux ghostty gitui btop bat opencode
```

## Updating an Existing Machine

If the machine already has most tools installed, prefer this safe update flow:

```bash
# 1) Update repo
cd ~/dotfiles
git fetch
git status
git pull --rebase

# 2) Preview symlink changes
stow --simulate --verbose=1 --target="$HOME" --restow \
  zsh git yazi zellij helix nvim lazygit lazydocker delta tmux ghostty gitui btop bat opencode

# 3) Apply if preview looks correct
stow --target="$HOME" --restow \
  zsh git yazi zellij helix nvim lazygit lazydocker delta tmux ghostty gitui btop bat opencode

# 4) Reload shell
source ~/.zshrc
```

### Should You Run `install.sh` for Updates?

You can, but it is a full bootstrap script and more invasive than the flow above.

### What Update Operations Can Override

- Managed config files under stowed paths (for example `~/.config/tmux/tmux.conf`, `~/.zshrc`)
- Existing files at managed paths when using `stow --adopt` (used by `install.sh`)
- macOS LazyGit config at `~/Library/Application Support/lazygit/config.yml` (relinked by `install.sh`)
- macOS LazyDocker config at `~/Library/Application Support/jesseduffield/lazydocker/config.yml` (relinked by `install.sh`)

### What Usually Stays Intact

- `~/.zshrc.local` (created only if missing)
- `~/.gitconfig.local` (created only if missing; existing values reused)
- Unmanaged files outside stowed paths
- Extra packages not listed in Brewfile (not automatically removed)

### Dirty Working Tree Warning

If `~/dotfiles` has uncommitted changes, `install.sh` skips `git pull` and also skips its restore checkout step.  
That can leave adopted local content in your dotfiles tree. Commit or stash first.

## Testing

### Theme Switcher Tests

```bash
bats tests/theme/tests/
```

### Ubuntu Docker Test

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
