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
}

@test "gitui theme.ron is copied" {
    run_theme catppuccin-mocha
    [ -f "$DOTFILES/gitui/.config/gitui/theme.ron" ]
}

@test "zellij colors file copied to themes dir" {
    run_theme catppuccin-mocha
    [ -f "$DOTFILES/zellij/.config/zellij/themes/catppuccin-mocha.kdl" ]
}

@test "btop theme file copied to themes dir" {
    run_theme catppuccin-mocha
    [ -f "$DOTFILES/btop/.config/btop/themes/catppuccin_mocha.theme" ]
}
