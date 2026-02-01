# Brewfile - Declarative package management

# Taps
tap "homebrew/bundle"

# Terminal Environment
brew "yazi"           # File manager
brew "zellij"         # Terminal multiplexer
brew "glow"           # Markdown renderer
brew "helix"          # Text editor (default)
brew "neovim"         # Text editor (LazyVim, alternative)
brew "lazygit"        # Git TUI (LazyVim integration)

# CLI Utilities
brew "git"
brew "gh"             # GitHub CLI
brew "ripgrep"        # Fast grep
brew "fd"             # Fast find
brew "fzf"            # Fuzzy finder
brew "jq"             # JSON processor
brew "lsd"            # Modern ls
brew "stow"           # Symlink manager

# Development
brew "node"           # For npm packages
brew "rustup-init"    # Rust toolchain manager

# Fonts (macOS only - casks don't work on Linux)
tap "homebrew/cask-fonts" if OS.mac?
cask "font-jetbrains-mono-nerd-font" if OS.mac?
