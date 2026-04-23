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

@test "cmux appearance and browser mode follow variant" {
    run_theme catppuccin-mocha
    [ "$status" -eq 0 ]

    # Both cmux defaults were written with the pack's variant value.
    grep -qF 'write com.cmuxterm.app appearanceMode dark' "$DEFAULTS_LOG"
    grep -qF 'write com.cmuxterm.app browserThemeMode dark' "$DEFAULTS_LOG"
}

@test "brave manifest.json contains RGB tuples derived from palette.toml" {
    run_theme flexoki-dark
    [ "$status" -eq 0 ]

    local manifest="$THEME_BRAVE_EXT/manifest.json"

    # flexoki-dark palette.toml:
    #   background   = "#100F0F"  → 16, 15, 15     (frame)
    #   foreground   = "#CECDC3"  → 206, 205, 195  (toolbar_text, tab_text, ...)
    #   surface      = "#282726"  → 40, 39, 38     (toolbar)
    #   surface_dark = "#1C1B1A"  → 28, 27, 26     (frame_inactive, background_tab)
    #   comment      = "#878580"  → 135, 133, 128  (tab_background_text)
    grep -qF '"frame":               [16, 15, 15]' "$manifest"
    grep -qF '"toolbar":             [40, 39, 38]' "$manifest"
    grep -qF '"toolbar_text":        [206, 205, 195]' "$manifest"
    grep -qF '"frame_inactive":      [28, 27, 26]' "$manifest"
    grep -qF '"tab_background_text": [135, 133, 128]' "$manifest"
}

@test "brave manifest.json RGB values change with theme" {
    run_theme flexoki-dark
    grep -qF '"frame":               [16, 15, 15]' "$THEME_BRAVE_EXT/manifest.json"

    # tokyonight-night palette.toml: background = #1a1b26 → 26, 27, 38
    run_theme tokyonight-night
    grep -qF '"frame":               [26, 27, 38]' "$THEME_BRAVE_EXT/manifest.json"
}

@test "brave Preferences edit skipped when Brave is running" {
    # pgrep stub always exits 0 → script treats Brave as running. Verify the
    # warning path fires and the Preferences file (if present) isn't touched.
    mkdir -p "$(dirname "$THEME_BRAVE_PREFS")"
    printf '%s\n' '{"brave":{"new_tab_page":{}}}' > "$THEME_BRAVE_PREFS"
    local checksum_before
    checksum_before=$(shasum "$THEME_BRAVE_PREFS")

    run_theme flexoki-dark
    [ "$status" -eq 0 ]

    [[ "$output" == *"Brave is running"* ]]
    [ "$(shasum "$THEME_BRAVE_PREFS")" = "$checksum_before" ]
}

# Note: manifest_get() uses grep -F "key = " with strict single-space format.
# Extra whitespace around '=' would break parsing. This is intentional —
# manifests are authored by us, not user input, so strict format is fine.
