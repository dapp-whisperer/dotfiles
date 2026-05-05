# Loaded by every .bats file via: load '../helpers/setup'
#
# Tests run against the actual dotfiles repo as DOTFILES_DIR (so
# `git ls-files` returns real tracked entries) but with a temp $HOME
# so the live ~/.pi/agent/ on the developer's machine is never touched.

REPO_ROOT="$(cd "$BATS_TEST_DIRNAME/../../.." && pwd)"
SCRIPT="$REPO_ROOT/scripts/pi-sync"

setup() {
    export ORIG_HOME="$HOME"
    export HOME="$BATS_TMPDIR/pi-sync-home-$$-$BATS_TEST_NUMBER"
    rm -rf "$HOME"
    mkdir -p "$HOME"
    # Pin DOTFILES_DIR so the script does not look at $HOME/dotfiles inside
    # the temp home (which would be empty).
    export DOTFILES_DIR="$REPO_ROOT"
    export NO_COLOR=1
}

teardown() {
    rm -rf "$HOME"
    export HOME="$ORIG_HOME"
}

# Map a tracked dotfiles path (pi/.pi/agent/foo) to its live equivalent
# under the temp $HOME ($HOME/.pi/agent/foo).
live_path_for() {
    local rel="${1#pi/.pi/agent/}"
    printf '%s/.pi/agent/%s' "$HOME" "$rel"
}

# Enumerate the tracked file set as the script sees it.
tracked_files() {
    git -C "$REPO_ROOT" ls-files -- pi/.pi/agent
}
