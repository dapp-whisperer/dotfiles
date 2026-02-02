# Default editor
export EDITOR="hx"

# fd-find compatibility (Linuxbrew names it fd, but apt names it fdfind)
command -v fd &>/dev/null || alias fd='fdfind'

# Aliases
alias dev='zellij --layout dev'

# lsd aliases (https://github.com/lsd-rs/lsd)
alias ls='lsd'
alias l='lsd -l'
alias la='lsd -a'
alias lla='lsd -la'
alias lt='lsd --tree'

# DANGEROUS: These bypass security controls - use only when you trust the context
alias UNSAFE_codex='codex --search --dangerously-bypass-approvals-and-sandbox'
alias UNSAFE_claude='claude --dangerously-skip-permissions'
alias clod='claude --dangerously-skip-permissions'

# Load local secrets if they exist (API keys, etc.)
[[ -f "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local"

# Homebrew
if [[ -f /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -f /home/linuxbrew/.linuxbrew/bin/brew ]]; then
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

# Local environment
export PATH="$HOME/.local/bin:$PATH"
[[ -f "$HOME/.local/bin/env" ]] && . "$HOME/.local/bin/env"
