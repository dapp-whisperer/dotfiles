# Default editor
export EDITOR="hx"

# Force yazi to use Kitty graphics protocol (for Ghostty)
export YAZI_ADAPTER="kgp"

# fd-find compatibility (Linuxbrew names it fd, but apt names it fdfind)
command -v fd &>/dev/null || alias fd='fdfind'

# Aliases
alias dev='zellij --layout dev'
alias co='opencode'

# OpenCode startup mode wrappers
OPENCODE_DOTFILES_ROOT="${OPENCODE_DOTFILES_ROOT:-}"
if [[ -z "$OPENCODE_DOTFILES_ROOT" && -d "$HOME/dotfiles" ]]; then
    OPENCODE_DOTFILES_ROOT="$HOME/dotfiles"
fi

OPENCODE_ALL_AGENTS_DIR="$HOME/.config/opencode-profiles/all-agents"
if [[ ! -d "$OPENCODE_ALL_AGENTS_DIR" && -n "$OPENCODE_DOTFILES_ROOT" ]]; then
    OPENCODE_ALL_AGENTS_DIR="$OPENCODE_DOTFILES_ROOT/opencode/.config/opencode-profiles/all-agents"
fi

_oc_run_mode() {
    local mode="$1"
    shift

    local clean=false
    local parse_wrapper_flags=true
    local -a passthrough=()

    while (( $# )); do
        if [[ "$parse_wrapper_flags" == true && "$1" == "--" ]]; then
            parse_wrapper_flags=false
            passthrough+=("$1")
            shift
            continue
        fi

        if [[ "$parse_wrapper_flags" == true && "$1" == "--clean" ]]; then
            clean=true
            shift
            continue
        fi

        passthrough+=("$1")
        shift
    done

    local -a cmd=(opencode)
    if [[ "$mode" == "all" ]]; then
        if [[ ! -d "$OPENCODE_ALL_AGENTS_DIR" ]]; then
            echo "oca: all-agents profile not found at $OPENCODE_ALL_AGENTS_DIR" >&2
            return 1
        fi

        if [[ "$clean" == true ]]; then
            env -u OPENCODE_CONFIG_DIR OPENCODE_DISABLE_PROJECT_CONFIG=true OPENCODE_CONFIG_DIR="$OPENCODE_ALL_AGENTS_DIR" "${cmd[@]}" "${passthrough[@]}"
        else
            env -u OPENCODE_CONFIG_DIR -u OPENCODE_DISABLE_PROJECT_CONFIG OPENCODE_CONFIG_DIR="$OPENCODE_ALL_AGENTS_DIR" "${cmd[@]}" "${passthrough[@]}"
        fi
        return $?
    fi

    if [[ "$clean" == true ]]; then
        env -u OPENCODE_CONFIG_DIR OPENCODE_DISABLE_PROJECT_CONFIG=true "${cmd[@]}" "${passthrough[@]}"
    else
        env -u OPENCODE_CONFIG_DIR -u OPENCODE_DISABLE_PROJECT_CONFIG "${cmd[@]}" "${passthrough[@]}"
    fi
}

oc() {
    _oc_run_mode standard "$@"
}

oca() {
    _oc_run_mode all "$@"
}

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
alias lgit='lazygit'
alias ldock='lazydocker'

# Load local secrets if they exist (API keys, etc.)
[[ -f "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local"

# OpenCode local override (private, machine-specific)
OPENCODE_LOCAL_CONFIG="$HOME/.config/opencode/opencode.local.json"
if [[ ! -f "$OPENCODE_LOCAL_CONFIG" && -n "$OPENCODE_DOTFILES_ROOT" ]]; then
    OPENCODE_LOCAL_CONFIG="$OPENCODE_DOTFILES_ROOT/.local/opencode/opencode.local.json"
fi
[[ -f "$OPENCODE_LOCAL_CONFIG" ]] && export OPENCODE_CONFIG="$OPENCODE_LOCAL_CONFIG"

# Homebrew
if [[ -f /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -f /home/linuxbrew/.linuxbrew/bin/brew ]]; then
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

# fzf shell integration (Ctrl+R history search, ** tab completion)
if [[ -o interactive && -t 0 ]] && command -v fzf &>/dev/null; then
    eval "$(fzf --zsh)"
fi

# Zoxide (smart cd)
if [[ -o interactive && -t 0 ]] && command -v zoxide &>/dev/null; then
    eval "$(zoxide init zsh)"
fi

# Local environment
export PATH="$HOME/.local/bin:$PATH"
[[ -f "$HOME/.local/bin/env" ]] && . "$HOME/.local/bin/env"

# opencode
export PATH="$HOME/.opencode/bin:$PATH"
export PATH="$HOME/code/codex/.local/bin:$PATH"

# Theme: fzf colors + BAT_THEME (managed by `theme` command)
[[ -f "$HOME/.config/fzf/theme.sh" ]] && source "$HOME/.config/fzf/theme.sh"

# Launch tabbed sub-session inside current tmux pane
tmux2() {
  if [ -n "$TMUX_INNER" ]; then
    echo "Already in an inner tmux session"
    return 1
  fi
  if [ -z "$TMUX" ]; then
    echo "Not inside tmux"
    return 1
  fi
  tmux -L inner -f ~/.config/tmux/inner.conf new-session -A -s "tabs-$(tmux display-message -p '#{pane_id}' | tr '%' '_')" -c "$(pwd)"
}

# try: manage experiments in ~/Work/tries
try() { source "$HOME/dotfiles/scripts/try" "$@"; }

# Dotfiles scripts
export PATH="$HOME/dotfiles/scripts:$PATH"
