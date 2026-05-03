load '../helpers/setup'

# `--check` is the user-facing API surface for drift detection. The
# exit-code contract is tested first; behavior changes that break it
# would silently regress CI/integrations that depend on the result.

@test "--check: exits 0 when live matches dotfiles exactly" {
    # Seed the temp HOME with the tracked content so live == dotfiles.
    while IFS= read -r relpath; do
        live="$(live_path_for "$relpath")"
        mkdir -p "$(dirname "$live")"
        cp "$REPO_ROOT/$relpath" "$live"
    done < <(tracked_files)

    run "$SCRIPT" --check
    [ "$status" -eq 0 ]
    [ -z "$output" ]
}

@test "--check: exits 1 and lists drifted file when live differs" {
    while IFS= read -r relpath; do
        live="$(live_path_for "$relpath")"
        mkdir -p "$(dirname "$live")"
        cp "$REPO_ROOT/$relpath" "$live"
    done < <(tracked_files)

    # Introduce drift in one tracked file
    settings_live="$(live_path_for "pi/.pi/agent/settings.json")"
    printf 'drifted content\n' > "$settings_live"

    run "$SCRIPT" --check
    [ "$status" -eq 1 ]
    [[ "$output" == *"settings.json"* ]]
}

@test "--check: exits 1 when a tracked file is missing from live" {
    # Don't seed extensions; only seed settings.json
    settings_live="$(live_path_for "pi/.pi/agent/settings.json")"
    mkdir -p "$(dirname "$settings_live")"
    cp "$REPO_ROOT/pi/.pi/agent/settings.json" "$settings_live"

    run "$SCRIPT" --check
    [ "$status" -eq 1 ]
    [[ "$output" == *"extensions/resources.ts"* ]]
}

@test "--check: lists every drifted path, not just the first" {
    while IFS= read -r relpath; do
        live="$(live_path_for "$relpath")"
        mkdir -p "$(dirname "$live")"
        cp "$REPO_ROOT/$relpath" "$live"
    done < <(tracked_files)

    # Drift two distinct files
    printf 'a\n' > "$(live_path_for "pi/.pi/agent/settings.json")"
    printf 'b\n' > "$(live_path_for "pi/.pi/agent/settings-extensions.json")"

    run "$SCRIPT" --check
    [ "$status" -eq 1 ]
    [[ "$output" == *"settings.json"* ]]
    [[ "$output" == *"settings-extensions.json"* ]]
}
