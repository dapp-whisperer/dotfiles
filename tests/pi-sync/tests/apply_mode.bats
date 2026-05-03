load '../helpers/setup'

# `apply` is the reapply step that runs after every LazyPi rewrite and
# during bootstrap. Overwrite semantics: dotfiles wins.

@test "apply: stale live file is restored to dotfiles content" {
    settings_live="$(live_path_for "pi/.pi/agent/settings.json")"
    mkdir -p "$(dirname "$settings_live")"
    printf 'lazypi rewrote this\n' > "$settings_live"

    run "$SCRIPT" apply
    [ "$status" -eq 0 ]
    cmp -s "$REPO_ROOT/pi/.pi/agent/settings.json" "$settings_live"
}

@test "apply: default mode (no argument) behaves like apply" {
    settings_live="$(live_path_for "pi/.pi/agent/settings.json")"
    mkdir -p "$(dirname "$settings_live")"
    printf 'stale\n' > "$settings_live"

    run "$SCRIPT"
    [ "$status" -eq 0 ]
    cmp -s "$REPO_ROOT/pi/.pi/agent/settings.json" "$settings_live"
}

@test "apply: idempotent — second run produces zero changes" {
    run "$SCRIPT" apply
    [ "$status" -eq 0 ]

    # Capture mtimes after first apply, sleep briefly, run again, compare.
    snapshot_before="$(find "$HOME/.pi/agent" -type f -exec stat -f '%m %N' {} \; | sort)"
    sleep 1
    run "$SCRIPT" apply
    [ "$status" -eq 0 ]
    snapshot_after="$(find "$HOME/.pi/agent" -type f -exec stat -f '%m %N' {} \; | sort)"

    # Content should be byte-identical, regardless of mtime.
    run "$SCRIPT" --check
    [ "$status" -eq 0 ]
}

@test "apply: fresh machine — creates ~/.pi/agent/extensions and writes files" {
    # No ~/.pi at all
    [ ! -d "$HOME/.pi" ]

    run "$SCRIPT" apply
    [ "$status" -eq 0 ]

    [ -d "$HOME/.pi/agent/extensions" ]
    [ -f "$(live_path_for "pi/.pi/agent/settings.json")" ]
    [ -f "$(live_path_for "pi/.pi/agent/extensions/resources.ts")" ]
    [ -f "$(live_path_for "pi/.pi/agent/extensions/powerbar-folder-line.ts")" ]
}

@test "apply: replaces a symlink at the live path with a regular file" {
    settings_live="$(live_path_for "pi/.pi/agent/settings.json")"
    mkdir -p "$(dirname "$settings_live")"
    # Simulate a prior `stow pi` symlink
    ln -s /nonexistent/source "$settings_live"
    [ -L "$settings_live" ]

    run "$SCRIPT" apply
    [ "$status" -eq 0 ]

    [ ! -L "$settings_live" ]
    [ -f "$settings_live" ]
    cmp -s "$REPO_ROOT/pi/.pi/agent/settings.json" "$settings_live"
}

@test "apply: does not touch excluded paths (sessions/, cache/, auth.json)" {
    sessions_dir="$HOME/.pi/agent/sessions"
    auth_file="$HOME/.pi/agent/auth.json"
    cache_file="$HOME/.pi/agent/cache/sub-core/state"
    mkdir -p "$sessions_dir/abc" "$(dirname "$cache_file")"
    printf 'private session\n' > "$sessions_dir/abc/data.json"
    printf 'secret\n' > "$auth_file"
    printf 'cached\n' > "$cache_file"

    run "$SCRIPT" apply
    [ "$status" -eq 0 ]

    [ "$(cat "$sessions_dir/abc/data.json")" = "private session" ]
    [ "$(cat "$auth_file")" = "secret" ]
    [ "$(cat "$cache_file")" = "cached" ]
}

@test "apply: errors with a clear DOTFILES_DIR message when path is wrong" {
    DOTFILES_DIR="$BATS_TMPDIR/no-such-dotfiles-$$" run "$SCRIPT" apply
    [ "$status" -ne 0 ]
    [[ "$output" == *"DOTFILES_DIR"* ]]
}

@test "apply: errors when --check is given an unknown subcommand" {
    run "$SCRIPT" wibble
    [ "$status" -ne 0 ]
    [[ "$output" == *"unknown"* ]] || [[ "$output" == *"wibble"* ]]
}
