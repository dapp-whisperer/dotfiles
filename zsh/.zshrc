# Default editor
export EDITOR="hx"

# Force yazi to use Kitty graphics protocol (for Ghostty)
export YAZI_ADAPTER="kgp"

# fd-find compatibility (Linuxbrew names it fd, but apt names it fdfind)
command -v fd &>/dev/null || alias fd='fdfind'

# Aliases
alias dev='zellij --layout dev'
alias co='opencode'

# eza aliases (https://github.com/eza-community/eza)
alias ls='eza --icons'
alias l='eza -l --icons'
alias la='eza -a --icons'
alias lla='eza -la --icons'
alias lt='eza --tree --level=2 --icons'
alias lsa='eza -la --icons'
alias lta='eza --tree -a --icons'

# fzf: select file and copy absolute path to clipboard
fz() { fzf --bind 'enter:become(realpath {})' | pbcopy; }

# fzf: fuzzy find files with bat preview
ff() { fzf --preview 'bat --color=always --style=numbers {}'; }

# DANGEROUS: These bypass security controls - use only when you trust the context
alias codexr='codex --search --dangerously-bypass-approvals-and-sandbox'
alias clod='claude --dangerously-skip-permissions'
alias cx='claude --dangerously-skip-permissions'

# Load local secrets if they exist (API keys, etc.)
[[ -f "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local"

# OpenCode local override (private, machine-specific)
OPENCODE_LOCAL_CONFIG="$HOME/.config/opencode/opencode.local.json"
[[ -f "$OPENCODE_LOCAL_CONFIG" ]] || OPENCODE_LOCAL_CONFIG="$HOME/dotfiles/.local/opencode/opencode.local.json"
[[ -f "$OPENCODE_LOCAL_CONFIG" ]] && export OPENCODE_CONFIG="$OPENCODE_LOCAL_CONFIG"

# Homebrew
if [[ -f /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -f /home/linuxbrew/.linuxbrew/bin/brew ]]; then
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

# fzf shell integration (Ctrl+R history search, ** tab completion)
command -v fzf &>/dev/null && eval "$(fzf --zsh)"

# Zoxide (smart cd)
command -v zoxide &>/dev/null && eval "$(zoxide init zsh)"

# Local environment
export PATH="$HOME/.local/bin:$PATH"
[[ -f "$HOME/.local/bin/env" ]] && . "$HOME/.local/bin/env"

# opencode
export PATH="$HOME/.opencode/bin:$PATH"
export PATH="$HOME/code/codex/.local/bin:$PATH"

# Theme: fzf colors + BAT_THEME (managed by `theme` command)
[[ -f "$HOME/.config/fzf/theme.sh" ]] && source "$HOME/.config/fzf/theme.sh"

# try: manage experiments in ~/Work/tries
try() { source "$HOME/dotfiles/scripts/try" "$@"; }

# Dotfiles scripts
export PATH="$HOME/dotfiles/scripts:$PATH"
