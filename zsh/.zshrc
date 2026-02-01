# Default editor
export EDITOR="hx"

# Aliases
alias dev='zellij --layout dev'

# DANGEROUS: These bypass security controls - use only when you trust the context
alias UNSAFE_codex='codex --search --dangerously-bypass-approvals-and-sandbox'
alias UNSAFE_claude='claude --dangerously-skip-permissions'

# Load local secrets if they exist (API keys, etc.)
[[ -f "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local"

# Homebrew
if [[ -f /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -f /home/linuxbrew/.linuxbrew/bin/brew ]]; then
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

# Local environment
[[ -f "$HOME/.local/bin/env" ]] && . "$HOME/.local/bin/env"
