load '../helpers/setup'

# Helper: record inode to a temp file
record_inode() {
    stat -f '%i' "$1" > "$BATS_TMPDIR/inode-$(echo "$1" | tr '/' '_')"
}

# Helper: assert inode unchanged
assert_inode_unchanged() {
    local current after_file
    current=$(stat -f '%i' "$1")
    after_file="$BATS_TMPDIR/inode-$(echo "$1" | tr '/' '_')"
    [ "$(cat "$after_file")" = "$current" ] || \
        fail "Inode changed for $1: was $(cat "$after_file"), now $current"
}

@test "sed-modified configs preserve inodes after switch" {
    run_theme catppuccin-mocha

    # Record inodes of all sed-modified files (SED_FILES from setup.bash)
    for f in "${SED_FILES[@]}"; do
        record_inode "$DOTFILES/$f"
    done

    # Switch theme
    run_theme tokyonight-night

    # Verify all inodes preserved
    for f in "${SED_FILES[@]}"; do
        assert_inode_unchanged "$DOTFILES/$f"
    done
}

@test "copy_over targets preserve inodes on re-apply" {
    run_theme catppuccin-mocha

    record_inode "$DOTFILES/zellij/.config/zellij/themes/catppuccin-mocha.kdl"
    record_inode "$DOTFILES/btop/.config/btop/themes/catppuccin_mocha.theme"

    # Re-apply same theme
    run_theme catppuccin-mocha

    assert_inode_unchanged "$DOTFILES/zellij/.config/zellij/themes/catppuccin-mocha.kdl"
    assert_inode_unchanged "$DOTFILES/btop/.config/btop/themes/catppuccin_mocha.theme"
}
