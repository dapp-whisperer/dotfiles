#!/usr/bin/env bash
set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'

info()  { echo -e "${GREEN}[INFO]${NC} $1"; }
warn()  { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }
step()  { echo -e "${BLUE}[STEP]${NC} $1"; }
usage() {
    cat << 'EOF'
Usage: ./install.sh [--non-interactive] [--help]

Options:
  --non-interactive   Disable prompts. Requires env vars for missing inputs.
  --help              Show this help and exit.

Environment variables (non-interactive):
  GITHUB_USERNAME  Used when cloning dotfiles.
  GIT_NAME         Used for git identity setup.
  GIT_EMAIL        Used for git identity setup.
EOF
}

DOTFILES_DIR="${HOME}/dotfiles"
BREW_FAILED="false"
NONINTERACTIVE="false"
if [[ "${DOTFILES_NON_INTERACTIVE:-}" == "1" ]]; then
    NONINTERACTIVE="true"
fi

for arg in "$@"; do
    case "$arg" in
        --non-interactive)
            NONINTERACTIVE="true"
            ;;
        -h|--help)
            usage
            exit 0
            ;;
    esac
done

if [[ ! -t 0 ]]; then
    NONINTERACTIVE="true"
fi

# Detect OS
detect_os() {
    case "$(uname -s)" in
        Darwin*) echo "macos" ;;
        Linux*)  echo "linux" ;;
        *)       error "Unsupported OS" ;;
    esac
}

OS=$(detect_os)
info "Detected OS: $OS"

# ============================================
# STEP 0: Linux Prerequisites (before Homebrew)
# ============================================
if [[ "$OS" == "linux" ]]; then
    step "Installing Linux prerequisites..."
    if command -v apt-get &>/dev/null; then
        sudo apt-get update
        sudo apt-get install -y build-essential procps curl git file
    else
        warn "Non-Debian/Ubuntu system detected. Please install manually: build-essential (or gcc/make), curl, git, file"
        warn "Then re-run this script."
    fi
fi

# ============================================
# STEP 1: Clone or update dotfiles
# ============================================
step "Setting up dotfiles repository..."

if [[ -d "$DOTFILES_DIR" ]]; then
    info "Dotfiles exist, pulling latest..."
    if git -C "$DOTFILES_DIR" diff --quiet && git -C "$DOTFILES_DIR" diff --cached --quiet; then
        git -C "$DOTFILES_DIR" pull --rebase || warn "Could not pull (maybe no remote set)"
    else
        warn "Local changes detected; skipping git pull"
    fi
else
    echo ""
    github_username="${GITHUB_USERNAME:-}"
    if [[ -z "$github_username" && "$NONINTERACTIVE" == "true" ]]; then
        error "GitHub username required in non-interactive mode. Set GITHUB_USERNAME and re-run."
    fi
    if [[ -z "$github_username" ]]; then
        read -p "Enter your GitHub username: " github_username
    fi
    if [[ -z "$github_username" ]]; then
        error "GitHub username is required"
    fi
    if [[ ! "$github_username" =~ ^[a-zA-Z0-9_-]+$ ]]; then
        error "Invalid GitHub username format (only letters, numbers, hyphens, underscores allowed)"
    fi
    DOTFILES_REPO="https://github.com/${github_username}/dotfiles.git"
    info "Cloning dotfiles from $DOTFILES_REPO..."
    git clone "$DOTFILES_REPO" "$DOTFILES_DIR"
fi

# ============================================
# STEP 2: Install Homebrew
# ============================================
step "Checking Homebrew..."

if command -v brew &>/dev/null; then
    info "Homebrew already installed"
else
    if [[ "$OS" == "linux" && -x /home/linuxbrew/.linuxbrew/bin/brew ]]; then
        info "Homebrew already installed (linuxbrew path detected)"
    else
        info "Installing Homebrew..."
        if GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; then
            info "Homebrew installed"
        else
            warn "Homebrew install failed"
            BREW_FAILED="true"
        fi
    fi
fi

# Add Homebrew to PATH for this session
if [[ "$OS" == "macos" ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)" 2>/dev/null || eval "$(/usr/local/bin/brew shellenv)" 2>/dev/null || true
else
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)" 2>/dev/null || true
fi

if ! command -v brew &>/dev/null; then
    BREW_FAILED="true"
fi

# ============================================
# STEP 3: Install packages from Brewfile
# ============================================
step "Installing packages from Brewfile..."

if [[ -f "$DOTFILES_DIR/Brewfile" ]]; then
    if command -v brew &>/dev/null; then
        if ! GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null brew bundle --file="$DOTFILES_DIR/Brewfile"; then
            warn "Brew bundle failed"
            BREW_FAILED="true"
        fi
    else
        warn "brew command not found"
        BREW_FAILED="true"
    fi
else
    warn "No Brewfile found, skipping..."
fi

# ============================================
# STEP 3.5: Linux fallback to APT if brew failed
# ============================================
if [[ "$OS" == "linux" && "$BREW_FAILED" == "true" ]]; then
    step "Homebrew failed; falling back to APT..."
    if command -v apt-get &>/dev/null; then
        sudo apt-get update

        # Install packages individually to avoid aborting on missing packages
        APT_PACKAGES=(
            git
            gh
            ripgrep
            fd-find
            fzf
            git-delta
            bat
            jq
            eza
            stow
            nodejs
            npm
            neovim
            helix
            lazygit
            zellij
            yazi
            glow
            rustup
        )

        for pkg in "${APT_PACKAGES[@]}"; do
            if apt-cache show "$pkg" >/dev/null 2>&1; then
                if sudo apt-get install -y "$pkg"; then
                    info "Installed $pkg"
                else
                    warn "Could not install $pkg via APT"
                fi
            else
                warn "Package not available in APT: $pkg"
            fi
        done

        # Common Ubuntu binary name compatibility
        sudo mkdir -p /usr/local/bin
        if command -v batcat &>/dev/null && ! command -v bat &>/dev/null; then
            sudo ln -sf "$(command -v batcat)" /usr/local/bin/bat || true
        fi
        if command -v fdfind &>/dev/null && ! command -v fd &>/dev/null; then
            sudo ln -sf "$(command -v fdfind)" /usr/local/bin/fd || true
        fi
    else
        warn "APT not available. Please install packages manually."
    fi
fi

# ============================================
# STEP 4: Install Claude Code
# ============================================
step "Checking Claude Code..."

if command -v claude &>/dev/null; then
    info "Claude Code already installed"
else
    info "Installing Claude Code..."
    curl -fsSL https://claude.ai/install.sh | bash || warn "Could not install Claude Code"
fi

# ============================================
# STEP 5: Install Codex CLI
# ============================================
step "Checking Codex CLI..."

if command -v codex &>/dev/null; then
    info "Codex CLI already installed"
else
    if command -v npm &>/dev/null; then
        info "Installing Codex CLI..."
        npm install -g @openai/codex || warn "Could not install Codex CLI"
    else
        warn "npm not available, skipping Codex CLI"
    fi
fi

# ============================================
# STEP 6: Create symlinks with stow
# ============================================
step "Creating symlinks..."

cd "$DOTFILES_DIR"

# Create necessary directories first
mkdir -p "$HOME/.config/yazi"
mkdir -p "$HOME/.config/zellij/layouts"
mkdir -p "$HOME/.config/zellij/themes"
mkdir -p "$HOME/.config/helix"
mkdir -p "$HOME/.config/nvim"
mkdir -p "$HOME/.config/lazygit"
mkdir -p "$HOME/.config/bat/themes"
mkdir -p "$HOME/.config/delta"
mkdir -p "$HOME/.config/fzf"
mkdir -p "$HOME/.config/tmux"
mkdir -p "$HOME/.config/ghostty"
mkdir -p "$HOME/.config/gitui"
mkdir -p "$HOME/.config/btop/themes"
mkdir -p "$HOME/Work/tries"
mkdir -p "$HOME/.config/opencode/themes"
mkdir -p "$HOME/.config/eza"

# Backup existing nvim config if it exists and is not a symlink
if [ -d "$HOME/.config/nvim" ] && [ ! -L "$HOME/.config/nvim" ]; then
    if [ "$(ls -A "$HOME/.config/nvim" 2>/dev/null)" ]; then
        info "Backing up existing nvim config..."
        mv "$HOME/.config/nvim" "$HOME/.config/nvim.backup.$(date +%Y%m%d%H%M%S)"
        mkdir -p "$HOME/.config/nvim"
    fi
fi

# Generate theme-managed files before stow (so symlink targets exist)
SAVED_THEME="catppuccin-mocha"
[[ -f "$DOTFILES_DIR/themes/current" ]] && SAVED_THEME="$(tr -d '[:space:]' < "$DOTFILES_DIR/themes/current")"
SAVED_THEME_DIR="$DOTFILES_DIR/themes/$SAVED_THEME"
if [[ -d "$SAVED_THEME_DIR" ]]; then
    cat "$DOTFILES_DIR/lazygit/base-config.yml" "$SAVED_THEME_DIR/lazygit-theme.yml" \
        > "$DOTFILES_DIR/lazygit/.config/lazygit/config.yml" 2>/dev/null || true
fi

# Stow each package
for package in zsh git yazi zellij helix nvim lazygit delta tmux ghostty gitui btop bat opencode; do
    if [[ -d "$package" ]]; then
        info "Stowing $package..."
        # Use --adopt to take ownership of existing files, then restore from git
        stow --verbose=1 --target="$HOME" --adopt --restow "$package" 2>&1 | grep -v "^BUG" || true
    fi
done

# Restore any adopted files to dotfiles version
info "Restoring dotfiles versions..."
if git -C "$DOTFILES_DIR" diff --quiet && git -C "$DOTFILES_DIR" diff --cached --quiet; then
    git -C "$DOTFILES_DIR" checkout -- . 2>/dev/null || true
else
    warn "Local changes detected; skipping git checkout"
fi

# ============================================
# STEP 6.5: Install Bat/Delta theme (Catppuccin Mocha)
# ============================================
step "Installing Catppuccin Mocha syntax theme..."

CATPPUCCIN_THEME="$HOME/.config/bat/themes/Catppuccin Mocha.tmTheme"
if [[ ! -f "$CATPPUCCIN_THEME" ]]; then
    info "Downloading Catppuccin Mocha theme for Bat/Delta..."
    curl -fsSL "https://github.com/catppuccin/bat/raw/main/themes/Catppuccin%20Mocha.tmTheme" \
        -o "$CATPPUCCIN_THEME" || warn "Could not download Catppuccin Mocha theme"

    if command -v bat &>/dev/null; then
        bat cache --build || warn "Could not rebuild bat cache"
        info "Catppuccin Mocha theme installed"
    fi
else
    info "Catppuccin Mocha theme already installed"
fi


# macOS: LazyGit uses ~/Library/Application Support/lazygit instead of ~/.config/lazygit
if [[ "$OS" == "macos" ]]; then
    LAZYGIT_MACOS_DIR="$HOME/Library/Application Support/lazygit"
    mkdir -p "$LAZYGIT_MACOS_DIR"
    if [[ ! -L "$LAZYGIT_MACOS_DIR/config.yml" ]]; then
        rm -f "$LAZYGIT_MACOS_DIR/config.yml"
        ln -s "$DOTFILES_DIR/lazygit/.config/lazygit/config.yml" "$LAZYGIT_MACOS_DIR/config.yml"
        info "Linked LazyGit config for macOS"
    fi
fi

# ============================================
# STEP 7: Install Yazi plugins
# ============================================
step "Installing Yazi plugins..."

if command -v ya &>/dev/null; then
    ya pack -i 2>/dev/null || info "Yazi plugins already installed"
else
    warn "ya command not found, skipping plugin installation"
fi

# ============================================
# STEP 8: Initialize Rust toolchain
# ============================================
step "Checking Rust toolchain..."

if command -v rustup &>/dev/null; then
    info "Rust toolchain already installed"
elif command -v rustup-init &>/dev/null; then
    info "Installing Rust toolchain..."
    rustup-init -y --no-modify-path
    source "$HOME/.cargo/env"
    rustup component add rust-analyzer
    info "Rust toolchain installed with rust-analyzer"
else
    warn "rustup-init not found, skipping Rust installation"
fi

# ============================================
# STEP 9: Setup local Git config (~/.gitconfig.local)
# ============================================
step "Checking local Git config..."

GITCONFIG_LOCAL="$HOME/.gitconfig.local"
if [[ ! -f "$GITCONFIG_LOCAL" ]]; then
    cat > "$GITCONFIG_LOCAL" << 'EOF'
# Machine-specific git config - DO NOT COMMIT
EOF
    info "Created ~/.gitconfig.local"
fi

# --- Git identity ---
local_git_name="$(git config --file "$GITCONFIG_LOCAL" --get user.name || true)"
local_git_email="$(git config --file "$GITCONFIG_LOCAL" --get user.email || true)"

if [[ -n "$local_git_name" && -n "$local_git_email" ]]; then
    info "Git identity already configured in ~/.gitconfig.local"
else
    git_name="${GIT_NAME:-$local_git_name}"
    git_email="${GIT_EMAIL:-$local_git_email}"

    if [[ -z "$git_name" || -z "$git_email" ]]; then
        if [[ "$NONINTERACTIVE" == "true" ]]; then
            warn "Non-interactive mode: set GIT_NAME and GIT_EMAIL to configure git identity"
        else
            echo ""
            if [[ -z "$git_name" ]]; then
                read -p "Enter your Git name: " git_name
            fi
            if [[ -z "$git_email" ]]; then
                read -p "Enter your Git email: " git_email
            fi
        fi
    fi

    if [[ -n "$git_name" && -n "$git_email" ]]; then
        git config --file "$GITCONFIG_LOCAL" user.name "$git_name"
        git config --file "$GITCONFIG_LOCAL" user.email "$git_email"
        info "Configured git identity in ~/.gitconfig.local"
    fi
fi

# --- Commit signing ---
local_signing_key="$(git config --file "$GITCONFIG_LOCAL" --get user.signingkey || true)"
local_signing_pref="$(git config --file "$GITCONFIG_LOCAL" --get commit.gpgsign || true)"

if [[ -n "$local_signing_key" ]]; then
    info "Git commit signing key already configured in ~/.gitconfig.local"
elif [[ -n "$local_signing_pref" ]]; then
    info "Git commit signing preference already set in ~/.gitconfig.local"
else
    effective_signing_key="$(git config --get user.signingkey || true)"
    if [[ -n "$effective_signing_key" ]]; then
        info "Git signing key already configured"
    else
        ssh_signing_key=""
        for candidate in "$HOME"/.ssh/*.pub; do
            if [[ ! -e "$candidate" ]]; then
                continue
            fi
            case "$(basename "$candidate")" in
                known_hosts*|authorized_keys|*.cert.pub)
                    continue
                    ;;
            esac
            if [[ -f "$candidate" ]]; then
                ssh_signing_key="$candidate"
                break
            fi
        done

        if [[ -n "$ssh_signing_key" ]]; then
            git config --file "$GITCONFIG_LOCAL" gpg.format ssh
            git config --file "$GITCONFIG_LOCAL" user.signingkey "$ssh_signing_key"
            info "Configured Git commit signing with SSH key: $ssh_signing_key"
        elif command -v gpg >/dev/null 2>&1 && gpg --list-secret-keys --with-colons 2>/dev/null | grep -q '^sec'; then
            info "Detected existing GPG secret key; leaving commit signing enabled"
        else
            git config --file "$GITCONFIG_LOCAL" commit.gpgsign false
            warn "No Git signing key detected; set commit.gpgsign=false in ~/.gitconfig.local"
            warn "Configure user.signingkey later and remove the local commit.gpgsign override to re-enable signing"
        fi
    fi
fi

# ============================================
# STEP 10: Create local secrets file if needed
# ============================================
step "Checking local secrets file..."

if [[ ! -f "$HOME/.zshrc.local" ]]; then
    cat > "$HOME/.zshrc.local" << 'EOF'
# Machine-specific secrets - DO NOT COMMIT
# Add your API keys here:
# export GEMINI_API_KEY="your-key-here"
EOF
    info "Created ~/.zshrc.local - add your API keys there"
else
    info "~/.zshrc.local already exists"
fi

# ============================================
# STEP 10.5: Restore active theme
# ============================================
step "Restoring theme..."

if [[ -f "$DOTFILES_DIR/themes/current" ]]; then
    ACTIVE_THEME="$(tr -d '[:space:]' < "$DOTFILES_DIR/themes/current")"
    if [[ -n "$ACTIVE_THEME" && -d "$DOTFILES_DIR/themes/$ACTIVE_THEME" ]]; then
        "$DOTFILES_DIR/scripts/theme" "$ACTIVE_THEME" || warn "Could not restore theme '$ACTIVE_THEME'"
    fi
else
    info "No saved theme found, skipping"
fi

# ============================================
# Done!
# ============================================
echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  Dotfiles installation complete!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo "Installed tools:"
command -v yazi &>/dev/null && echo "  - yazi (file manager)"
command -v zellij &>/dev/null && echo "  - zellij (terminal multiplexer)"
command -v hx &>/dev/null && echo "  - helix (default editor)"
command -v nvim &>/dev/null && echo "  - neovim (LazyVim, use 'nvim' to launch)"
command -v claude &>/dev/null && echo "  - claude (Claude Code CLI)"
command -v codex &>/dev/null && echo "  - codex (OpenAI Codex CLI)"
command -v glow &>/dev/null && echo "  - glow (markdown renderer)"
command -v delta &>/dev/null && echo "  - delta (syntax-highlighted diffs)"
command -v eza &>/dev/null && echo "  - eza (modern ls with icons)"
command -v fzf &>/dev/null && echo "  - fzf (fuzzy finder)"
command -v zoxide &>/dev/null && echo "  - zoxide (smart cd)"
command -v rg &>/dev/null && echo "  - ripgrep (fast grep)"
command -v fd &>/dev/null && echo "  - fd (fast find)"
command -v rustup &>/dev/null && echo "  - rust (via rustup with rust-analyzer)"

if [[ "$OS" == "linux" ]]; then
    echo ""
    echo "Note: Nerd Fonts not auto-installed on Linux."
    echo "For proper icons in LazyVim/eza, install manually:"
    echo "  https://www.nerdfonts.com/font-downloads"
fi

echo ""
echo "Next steps:"
echo "  1. Restart your terminal or run: source ~/.zshrc"
echo "  2. Add API keys to ~/.zshrc.local"
echo "  3. Run 'dev' to launch Yazi + Claude split view"
echo "  4. Press Enter on any file to edit in Helix (floating pane)"
echo "  5. Use 'nvim' directly for LazyVim (first launch downloads plugins)"
echo ""
