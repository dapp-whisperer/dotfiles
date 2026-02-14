load '../helpers/setup'

@test "rejects theme name with slashes (path traversal)" {
    run_theme "../etc/passwd"
    [ "$status" -ne 0 ]
    [[ "$output" == *"Invalid theme name"* ]]
}

@test "rejects theme name with spaces" {
    run_theme "my theme"
    [ "$status" -ne 0 ]
}

@test "rejects theme name with shell metacharacters" {
    run_theme '$(whoami)'
    [ "$status" -ne 0 ]
}

@test "rejects nonexistent theme" {
    run_theme "nonexistent"
    [ "$status" -ne 0 ]
    [[ "$output" == *"not found"* ]]
}

@test "rejects theme missing manifest.toml" {
    mkdir -p "$DOTFILES/themes/broken-theme"
    run_theme "broken-theme"
    [ "$status" -ne 0 ]
    [[ "$output" == *"missing manifest.toml"* ]]
}

@test "no args shows current theme and list" {
    run_theme
    [ "$status" -eq 0 ]
    [[ "$output" == *"Current theme:"* ]]
    [[ "$output" == *"Available themes:"* ]]
    [[ "$output" == *"catppuccin-mocha"* ]]
    [[ "$output" == *"tokyonight-night"* ]]
}

@test "no args marks current theme with asterisk" {
    echo "catppuccin-mocha" > "$DOTFILES/themes/current"
    run_theme
    [[ "$output" == *"* catppuccin-mocha"* ]]
}

@test "rejects manifest with unsafe characters in values" {
    # validate_value() rejects shell metacharacters — verify it catches them
    cat > "$DOTFILES/themes/catppuccin-mocha/manifest.toml" <<'TOML'
name = "$(rm -rf /)"
variant = "dark"
ghostty = "test"
helix = "test"
zellij = "test"
btop = "test"
neovim = "test"
delta = "test"
bat = "test"
TOML
    run_theme catppuccin-mocha
    [ "$status" -ne 0 ]
    [[ "$output" == *"Invalid manifest value"* ]]
}
