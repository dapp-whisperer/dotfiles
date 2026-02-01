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

DOTFILES_DIR="${HOME}/dotfiles"

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
    sudo apt update
    sudo apt install -y build-essential curl git
fi

# ============================================
# STEP 1: Clone or update dotfiles
# ============================================
step "Setting up dotfiles repository..."

if [[ -d "$DOTFILES_DIR" ]]; then
    info "Dotfiles exist, pulling latest..."
    git -C "$DOTFILES_DIR" pull --rebase || warn "Could not pull (maybe no remote set)"
else
    echo ""
    read -p "Enter your GitHub username: " github_username
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
    info "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Add Homebrew to PATH for this session
if [[ "$OS" == "macos" ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)" 2>/dev/null || eval "$(/usr/local/bin/brew shellenv)" 2>/dev/null || true
else
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)" 2>/dev/null || true
fi

# ============================================
# STEP 3: Install packages from Brewfile
# ============================================
step "Installing packages from Brewfile..."

if [[ -f "$DOTFILES_DIR/Brewfile" ]]; then
    brew bundle install --file="$DOTFILES_DIR/Brewfile" || true
else
    warn "No Brewfile found, skipping..."
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
mkdir -p "$HOME/.config/helix"
mkdir -p "$HOME/.config/nvim"

# Backup existing nvim config if it exists and is not a symlink
if [ -d "$HOME/.config/nvim" ] && [ ! -L "$HOME/.config/nvim" ]; then
    if [ "$(ls -A "$HOME/.config/nvim" 2>/dev/null)" ]; then
        info "Backing up existing nvim config..."
        mv "$HOME/.config/nvim" "$HOME/.config/nvim.backup.$(date +%Y%m%d%H%M%S)"
        mkdir -p "$HOME/.config/nvim"
    fi
fi

# Stow each package
for package in zsh git yazi zellij helix nvim; do
    if [[ -d "$package" ]]; then
        info "Stowing $package..."
        # Use --adopt to take ownership of existing files, then restore from git
        stow --verbose=1 --target="$HOME" --adopt --restow "$package" 2>&1 | grep -v "^BUG" || true
    fi
done

# Restore any adopted files to dotfiles version
info "Restoring dotfiles versions..."
git -C "$DOTFILES_DIR" checkout -- . 2>/dev/null || true

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
# STEP 9: Setup Git identity (interactive)
# ============================================
step "Checking Git configuration..."

if ! git config --global user.name &>/dev/null; then
    echo ""
    read -p "Enter your Git name: " git_name
    read -p "Enter your Git email: " git_email
    git config --global user.name "$git_name"
    git config --global user.email "$git_email"
    info "Git identity configured"
else
    info "Git identity already configured: $(git config --global user.name)"
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
command -v rustup &>/dev/null && echo "  - rust (via rustup with rust-analyzer)"
echo ""
echo "Next steps:"
echo "  1. Restart your terminal or run: source ~/.zshrc"
echo "  2. Add API keys to ~/.zshrc.local"
echo "  3. Run 'dev' to launch Yazi + Claude split view"
echo "  4. Press Enter on any file to edit in Helix (floating pane)"
echo "  5. Use 'nvim' directly for LazyVim (first launch downloads plugins)"
echo ""
