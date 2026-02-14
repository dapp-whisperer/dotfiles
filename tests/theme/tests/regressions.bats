load '../helpers/setup'

@test "REGRESSION: btop save_config_on_exit is false" {
    grep -q 'save_config_on_exit = false' "$DOTFILES/btop/.config/btop/btop.conf"
}

@test "REGRESSION: no sed -i in executable code" {
    # Strip comment lines first — the script documents sed -i in comments,
    # which is fine. Only executable sed -i usage breaks file watchers.
    ! sed '/^[[:space:]]*#/d' "$SCRIPT" | grep -q 'sed -i' || \
        fail "scripts/theme uses 'sed -i' in executable code (breaks file watchers on macOS)"
}

@test "REGRESSION: stow-managed files use copy_over not cp" {
    # Only $HOME/.config/* destinations should use raw cp
    # Count cp lines that DON'T target $HOME/.config
    local bad_cp
    bad_cp=$(grep -n '^cp ' "$SCRIPT" | grep -v 'HOME/\.config' || true)
    [ -z "$bad_cp" ] || fail "Found raw cp for non-HOME paths: $bad_cp"
}
