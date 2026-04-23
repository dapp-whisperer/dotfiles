# Loaded by every .bats file via: load '../helpers/setup'

# Resolve the real repo root (tests/theme/helpers -> ../../..)
REPO_ROOT="$(cd "$BATS_TEST_DIRNAME/../../.." && pwd)"
STUBS_DIR="$BATS_TEST_DIRNAME/../helpers/stubs"
SCRIPT="$REPO_ROOT/scripts/theme"

# Directories within the repo that the theme script reads/writes.
# Only these are copied to the temp dir — not the entire repo.
THEME_DIRS=(
    ghostty/.config/ghostty
    helix/.config/helix
    btop/.config/btop
    zellij/.config/zellij
    nvim/.config/nvim/lua/plugins
    git
    bat/.config/bat
    yazi/.config/yazi
    lazygit
    lazydocker
    tmux/.config/tmux
    opencode/.config/opencode
    wezterm/.config/wezterm
    themes
)

# Files modified by sed_inplace / replace_quoted in the script.
# Defined once here so tests can iterate without repeating the list.
SED_FILES=(
    ghostty/.config/ghostty/config
    helix/.config/helix/config.toml
    btop/.config/btop/btop.conf
    zellij/.config/zellij/config.kdl
    nvim/.config/nvim/lua/plugins/colorscheme.lua
    git/.gitconfig
    bat/.config/bat/config
    yazi/.config/yazi/yazi.toml
    tmux/.config/tmux/tmux.conf
    opencode/.config/opencode/opencode.json
)

setup() {
    export ORIG_HOME="$HOME"
    export HOME="$BATS_TMPDIR/home-$$"
    # scripts/theme hardcodes DOTFILES="$HOME/dotfiles", so we must
    # place files there for the script and test assertions to agree.
    export DOTFILES="$HOME/dotfiles"
    # Real machines have ~/.config/tmux created by first tmux launch; mirror it here
    # so scripts/theme's outer-status-bar cp doesn't die in test isolation.
    mkdir -p "$HOME/.config/tmux"

    # Copy real repo config dirs + themes into temp DOTFILES.
    # Tests always run against the actual file formats — no fixtures to drift.
    for dir in "${THEME_DIRS[@]}"; do
        [[ -d "$REPO_ROOT/$dir" ]] || { echo "THEME_DIRS entry missing from repo: $dir" >&2; return 1; }
        mkdir -p "$DOTFILES/$dir"
        cp -R "$REPO_ROOT/$dir"/. "$DOTFILES/$dir/"
    done

    # Sandbox Typora + cmux app path checks into temp so tests are
    # deterministic across dev machines (Typora may or may not be installed)
    # and CI (neither app exists).
    export THEME_TYPORA_THEMES="$HOME/typora-themes"
    export THEME_TYPORA_APP="$HOME/fake-typora.app"
    export THEME_CMUX_APP="$HOME/fake-cmux.app"
    mkdir -p "$THEME_TYPORA_APP" "$THEME_CMUX_APP"

    # Fresh defaults stub log per test
    export DEFAULTS_LOG="$BATS_TMPDIR/defaults-calls-$$.log"
    : > "$DEFAULTS_LOG"

    # Prepend stubs to PATH so bat/nvim/osascript/pgrep/defaults are no-ops
    export PATH="$STUBS_DIR:$PATH"
}

teardown() {
    export HOME="$ORIG_HOME"
    rm -rf "$BATS_TMPDIR/home-$$"
    rm -f "$DEFAULTS_LOG"
}

# Helper: run the theme script
run_theme() {
    run bash "$SCRIPT" "$@"
}
