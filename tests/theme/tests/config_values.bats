load '../helpers/setup'

@test "switch to tokyonight-night updates all sed-modified configs" {
    run_theme tokyonight-night
    [ "$status" -eq 0 ]

    grep -q 'theme = "TokyoNight Night"' "$DOTFILES/ghostty/.config/ghostty/config"
    grep -q 'theme = "tokyonight_night"' "$DOTFILES/helix/.config/helix/config.toml"
    grep -q 'color_theme = "tokyonight_night"' "$DOTFILES/btop/.config/btop/btop.conf"
    grep -q 'theme "tokyonight-night"' "$DOTFILES/zellij/.config/zellij/config.kdl"
    grep -q 'colorscheme = "tokyonight-night"' "$DOTFILES/nvim/.config/nvim/lua/plugins/colorscheme.lua"
    grep -q 'features = tokyonight-night' "$DOTFILES/git/.gitconfig"
    grep -q -- '--theme="tokyonight_night"' "$DOTFILES/bat/.config/bat/config"
    grep -q "@catppuccin_flavor 'tokyonight-night'" "$DOTFILES/tmux/.config/tmux/tmux.conf"
    grep -q '"theme": "tokyonight"' "$DOTFILES/opencode/.config/opencode/opencode.json"
}

@test "switch to catppuccin-mocha updates all sed-modified configs" {
    # Start from tokyonight so there's an actual change
    run_theme tokyonight-night
    run_theme catppuccin-mocha
    [ "$status" -eq 0 ]

    grep -q 'theme = "Catppuccin Mocha"' "$DOTFILES/ghostty/.config/ghostty/config"
    grep -q 'theme = "catppuccin_mocha"' "$DOTFILES/helix/.config/helix/config.toml"
    grep -q 'color_theme = "catppuccin_mocha"' "$DOTFILES/btop/.config/btop/btop.conf"
    grep -q "@catppuccin_flavor 'mocha'" "$DOTFILES/tmux/.config/tmux/tmux.conf"
    grep -q '"theme": "catppuccin-mocha-glass"' "$DOTFILES/opencode/.config/opencode/opencode.json"
}

@test "yazi glow flag matches manifest variant" {
    run_theme tokyonight-night
    grep -q '\-s=dark' "$DOTFILES/yazi/.config/yazi/yazi.toml"
}

@test "themes/current updated to new theme" {
    run_theme tokyonight-night
    [ "$(cat "$DOTFILES/themes/current")" = "tokyonight-night" ]
}

# Note: manifest_get() uses grep -F "key = " with strict single-space format.
# Extra whitespace around '=' would break parsing. This is intentional —
# manifests are authored by us, not user input, so strict format is fine.
