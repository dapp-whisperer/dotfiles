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

@test "switch succeeds when optional tmux-theme.conf is missing" {
    rm -f "$DOTFILES/themes/catppuccin-mocha/tmux-theme.conf"
    run_theme catppuccin-mocha
    [ "$status" -eq 0 ]
}

@test "switch succeeds when optional typora key is missing from manifest" {
    # Strip the typora key from the manifest so the parser returns empty.
    sed -i.bak '/^typora = /d' "$DOTFILES/themes/catppuccin-mocha/manifest.toml"
    run_theme catppuccin-mocha
    [ "$status" -eq 0 ]

    # No CSS should have been copied since the key is absent.
    [ ! -f "$THEME_TYPORA_THEMES/catppuccin-mocha.css" ]

    # Typora defaults-writes should not have happened.
    ! grep -qF 'write abnerworks.Typora theme' "$DEFAULTS_LOG"
}

@test "switch succeeds when typora-theme.css asset is missing" {
    rm -f "$DOTFILES/themes/catppuccin-mocha/typora-theme.css"
    run_theme catppuccin-mocha
    [ "$status" -eq 0 ]

    # Without the asset file, the guard blocks the copy and defaults-writes.
    [ ! -f "$THEME_TYPORA_THEMES/catppuccin-mocha.css" ]
    ! grep -qF 'write abnerworks.Typora theme' "$DEFAULTS_LOG"
}

@test "switch succeeds when Typora.app and themes dir are both absent" {
    rmdir "$THEME_TYPORA_APP"
    # $THEME_TYPORA_THEMES was never created — both guards fail, block is skipped.
    run_theme flexoki-dark
    [ "$status" -eq 0 ]

    ! grep -qF 'write abnerworks.Typora' "$DEFAULTS_LOG"
}

@test "switch succeeds when cmux.app is absent" {
    rmdir "$THEME_CMUX_APP"
    run_theme catppuccin-mocha
    [ "$status" -eq 0 ]

    ! grep -qF 'write com.cmuxterm.app' "$DEFAULTS_LOG"
}
