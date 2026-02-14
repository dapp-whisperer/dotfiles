load '../helpers/setup'

@test "A then B then A produces identical config files" {
    run_theme catppuccin-mocha

    # Snapshot all sed-modified configs (SED_FILES from setup.bash)
    local snap="$BATS_TMPDIR/snapshot"
    mkdir -p "$snap"
    for f in "${SED_FILES[@]}"; do
        cp "$DOTFILES/$f" "$snap/$(echo "$f" | tr '/' '_')"
    done

    # Round trip
    run_theme tokyonight-night
    run_theme catppuccin-mocha

    # Compare each file
    for f in "${SED_FILES[@]}"; do
        diff -u "$snap/$(echo "$f" | tr '/' '_')" "$DOTFILES/$f" || \
            fail "Round-trip mismatch in $f"
    done
}

@test "switching to same theme twice is idempotent" {
    run_theme catppuccin-mocha

    local snap="$BATS_TMPDIR/snap"
    mkdir -p "$snap"
    cp "$DOTFILES/ghostty/.config/ghostty/config" "$snap/ghostty"
    cp "$DOTFILES/btop/.config/btop/btop.conf" "$snap/btop"

    run_theme catppuccin-mocha

    diff -u "$snap/ghostty" "$DOTFILES/ghostty/.config/ghostty/config" || \
        fail "Ghostty config changed on idempotent switch"
    diff -u "$snap/btop" "$DOTFILES/btop/.config/btop/btop.conf" || \
        fail "btop config changed on idempotent switch"
}
