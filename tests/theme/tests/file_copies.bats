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
