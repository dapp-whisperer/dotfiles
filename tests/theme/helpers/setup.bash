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
    gitui/.config/gitui
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
)

setup() {
    export ORIG_HOME="$HOME"
    export HOME="$BATS_TMPDIR/home-$$"
    # scripts/theme hardcodes DOTFILES="$HOME/dotfiles", so we must
    # place files there for the script and test assertions to agree.
    export DOTFILES="$HOME/dotfiles"
    mkdir -p "$HOME/.config"

    # Copy real repo config dirs + themes into temp DOTFILES.
    # Tests always run against the actual file formats — no fixtures to drift.
    for dir in "${THEME_DIRS[@]}"; do
        [[ -d "$REPO_ROOT/$dir" ]] || { echo "THEME_DIRS entry missing from repo: $dir" >&2; return 1; }
        mkdir -p "$DOTFILES/$dir"
        cp -R "$REPO_ROOT/$dir"/. "$DOTFILES/$dir/"
    done

    # Prepend stubs to PATH so bat/nvim/osascript/pgrep are no-ops
    export PATH="$STUBS_DIR:$PATH"
}

teardown() {
    export HOME="$ORIG_HOME"
    rm -rf "$BATS_TMPDIR/home-$$"
}

# Helper: run the theme script
run_theme() {
    run bash "$SCRIPT" "$@"
}
