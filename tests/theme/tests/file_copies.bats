load '../helpers/setup'

@test "lazygit config is concatenation of base + theme" {
    run_theme tokyonight-night

    local config="$DOTFILES/lazygit/.config/lazygit/config.yml"
    [ -f "$config" ]
    # Base config values present
    grep -q 'border: hidden' "$config"
    # Theme values present
    grep -q 'theme:' "$config"
}

@test "file copies reach non-stow destinations" {
    run_theme catppuccin-mocha

    [ -f "$HOME/.config/delta/theme.gitconfig" ]
    [ -f "$HOME/.config/fzf/theme.sh" ]
    [ -f "$HOME/.config/bat/themes/bat.tmTheme" ]
    [ -f "$HOME/.config/eza/theme.yml" ]
}

@test "lazydocker config is concatenation of base + theme" {
    run_theme tokyonight-night

    local config="$DOTFILES/lazydocker/.config/lazydocker/config.yml"
    [ -f "$config" ]
    grep -q 'border: hidden' "$config"
    grep -q 'theme:' "$config"
}

@test "zellij colors file copied to themes dir" {
    run_theme catppuccin-mocha
    [ -f "$DOTFILES/zellij/.config/zellij/themes/catppuccin-mocha.kdl" ]
}

@test "btop theme file copied to themes dir" {
    run_theme catppuccin-mocha
    [ -f "$DOTFILES/btop/.config/btop/themes/catppuccin_mocha.theme" ]
}

@test "eza theme.yml content changes with theme" {
    run_theme catppuccin-mocha
    grep -q '#cba6f7' "$HOME/.config/eza/theme.yml"

    run_theme tokyonight-night
    grep -q '#7aa2f7' "$HOME/.config/eza/theme.yml"
}

@test "typora CSS copied to Typora themes dir and both defaults keys written" {
    run_theme flexoki-dark
    [ "$status" -eq 0 ]

    # CSS landed at the configured Typora themes path, named by manifest slug.
    [ -f "$THEME_TYPORA_THEMES/flexoki-dark.css" ]

    # Both `theme` and `darkTheme` defaults were written to the pack's display name.
    grep -qF 'write abnerworks.Typora theme Flexoki Dark' "$DEFAULTS_LOG"
    grep -qF 'write abnerworks.Typora darkTheme Flexoki Dark' "$DEFAULTS_LOG"
}

@test "typora CSS content matches pack asset byte-for-byte" {
    run_theme flexoki-dark
    cmp "$DOTFILES/themes/flexoki-dark/typora-theme.css" \
        "$THEME_TYPORA_THEMES/flexoki-dark.css"
}

@test "typora round-trip: later pack overwrites earlier CSS and defaults" {
    run_theme flexoki-dark
    run_theme catppuccin-mocha
    [ "$status" -eq 0 ]

    # catppuccin's CSS now present at its slug; flexoki's CSS may still exist
    # because each pack writes a distinct slug-named file.
    [ -f "$THEME_TYPORA_THEMES/catppuccin-mocha.css" ]

    # Last write wins for defaults — final line references the last pack.
    local last_theme
    last_theme=$(grep -F 'write abnerworks.Typora theme ' "$DEFAULTS_LOG" | tail -1)
    [[ "$last_theme" == *"Catppuccin Mocha"* ]]
}
