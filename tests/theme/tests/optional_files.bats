load '../helpers/setup'

@test "switch succeeds when optional zellij-colors.kdl is missing" {
    rm -f "$DOTFILES/themes/catppuccin-mocha/zellij-colors.kdl"
    run_theme catppuccin-mocha
    [ "$status" -eq 0 ]
}

@test "switch succeeds when optional btop.theme is missing" {
    rm -f "$DOTFILES/themes/catppuccin-mocha/btop.theme"
    run_theme catppuccin-mocha
    [ "$status" -eq 0 ]
}

@test "switch succeeds when optional yazi-theme.toml is missing" {
    rm -f "$DOTFILES/themes/catppuccin-mocha/yazi-theme.toml"
    run_theme catppuccin-mocha
    [ "$status" -eq 0 ]
}
