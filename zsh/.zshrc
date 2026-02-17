# Default editor
export EDITOR="hx"

# Force yazi to use Kitty graphics protocol (for Ghostty)
export YAZI_ADAPTER="kgp"

# fd-find compatibility (Linuxbrew names it fd, but apt names it fdfind)
command -v fd &>/dev/null || alias fd='fdfind'

# Aliases
alias dev='zellij --layout dev'
alias devt='tmux has-session -t devt 2>/dev/null && tmux attach-session -t devt || tmux new-session -d -s devt "yazi" \; split-window -h -l 45% "claude --dangerously-skip-permissions" \; attach-session -t devt'

# lsd aliases (https://github.com/lsd-rs/lsd)
alias ls='lsd'
alias l='lsd -l'
alias la='lsd -a'
alias lla='lsd -la'
alias lt='lsd --tree'

# fzf: select file and copy absolute path to clipboard
fz() { fzf --bind 'enter:become(realpath {})' | pbcopy; }

# DANGEROUS: These bypass security controls - use only when you trust the context
alias codexr='codex --search --dangerously-bypass-approvals-and-sandbox'
alias clod='claude --dangerously-skip-permissions'
alias cx='claude --dangerously-skip-permissions'

# Always use inline mode for Codex so output remains in terminal scrollback.
codex() {
    command codex --no-alt-screen "$@"
}

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

# Zoxide (smart cd)
command -v zoxide &>/dev/null && eval "$(zoxide init zsh)"

# Local environment
export PATH="$HOME/.local/bin:$PATH"
[[ -f "$HOME/.local/bin/env" ]] && . "$HOME/.local/bin/env"

# opencode
export PATH="$HOME/.opencode/bin:$PATH"
export PATH="$HOME/code/codex/.local/bin:$PATH"
