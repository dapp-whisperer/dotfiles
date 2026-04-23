# Unified Theming System

This directory is the source of truth for cross-tool theming in this dotfiles repo.

The `theme` command (`scripts/theme`) applies one named theme across terminal apps, editors, CLIs, and OpenCode.

## How It Works

- Theme packs live at `themes/<theme-name>/`
- Active theme name is stored in `themes/current`
- Each pack has `manifest.toml` with per-tool theme mappings
- `scripts/theme` reads the manifest, updates stowed config files, and copies overlay files where needed
- Some apps auto-reload; others require restart (reported by the script after switching)

## Directory Contract

Each `themes/<theme-name>/` directory should contain:

- `manifest.toml` - required key mapping for all integrated tools
- `delta.gitconfig`
- `fzf-theme.sh`
- `eza-theme.yml`
- `lazygit-theme.yml`
- `lazydocker-theme.yml`
- `gitui-theme.ron`
- `btop.theme`
- `yazi-theme.toml`
- `bat.tmTheme`
- `tmux-theme.conf` — catppuccin `@thm_*` palette variables + outer status bar colors, pane borders, and copy-mode highlight
- Optional: `zellij-colors.kdl` for custom Zellij theme definitions. In practice, every non-catppuccin pack needs this (see gruvbox-dark, monokai, flexoki-dark precedent).
- Optional: `typora-theme.css` — required only if the pack wants custom Typora theming. Must define all 10 semantic roles listed under *Tool Integrations → Typora*.

## Manifest Keys

`manifest.toml` must define these keys:

- `name`
- `variant` (`dark` or `light`)
- `font` (Ghostty `font-family`, e.g. `"JetBrains Mono"` or `"IBM Plex Mono"`)
- `ghostty`
- `helix`
- `zellij`
- `btop`
- `neovim`
- `delta`
- `bat`
- `tmux`
- `opencode`
- `wezterm` (WezTerm built-in color scheme name, or the slug of a local scheme file under `wezterm/.config/wezterm/colors/`)
- `wezterm_font` (full Lua `wezterm.font` expression, e.g. `"wezterm.font 'JetBrainsMono Nerd Font Mono'"`)
- `wezterm_bg` (6-digit hex background overlay color, no `#` prefix)

Optional:

- `typora` — CSS filename slug for Typora theme. If absent, `scripts/theme` skips the Typora copy block entirely. The corresponding `typora-theme.css` must define the 10 semantic roles listed under *Tool Integrations → Typora*.

Example:

```toml
name = "Catppuccin Mocha"
variant = "dark"
font = "JetBrains Mono"
ghostty = "Catppuccin Mocha"
helix = "catppuccin_mocha"
zellij = "catppuccin-mocha"
btop = "catppuccin_mocha"
neovim = "catppuccin-mocha"
delta = "catppuccin-mocha"
bat = "Catppuccin Mocha"
tmux = "mocha"
opencode = "catppuccin-mocha-glass"
wezterm = "Catppuccin Mocha"
wezterm_font = "wezterm.font 'JetBrainsMono Nerd Font Mono'"
wezterm_bg = "1e1e2e"
```

## Commands

```bash
# Show current + available themes
theme

# Switch theme
theme catppuccin-mocha
theme tokyonight-night
```

## OpenCode Integration

- OpenCode theme is set by `manifest.toml` key `opencode`
- `scripts/theme` writes that value into `opencode/.config/opencode/opencode.json` (`"theme"` field)
- Custom OpenCode theme definitions live in `opencode/.config/opencode/themes/`
- Current custom glass preset: `catppuccin-mocha-glass.json`

When adding a new OpenCode theme:

1. Add the JSON theme file under `opencode/.config/opencode/themes/`
2. Reference its theme ID in each relevant `themes/<theme>/manifest.toml` via `opencode = "..."`
3. Run `theme <name>` and verify OpenCode picks it up after restart

## Tool Integrations

### Typora (macOS)

- `scripts/theme` copies each pack's `typora-theme.css` into `~/Library/Application Support/abnerworks.Typora/themes/` named by the pack's `typora` manifest slug (e.g., `flexoki-dark.css`).
- It then writes **both** `theme` and `darkTheme` defaults keys to the pack's display `name` (e.g., `"Flexoki Dark"`) so the active pack renders regardless of macOS appearance mode / Typora's `useSeparateDarkTheme` state.
- The block is guarded on macOS, the pack having a `typora` manifest key, the CSS asset existing, and either Typora's themes dir already existing or `/Applications/Typora.app` being installed. Missing any guard → silent skip.
- Typora reads themes at startup — **restart Typora** to see changes.
- `typora-theme.css` must define these 10 semantic roles against the pack's palette:
  1. body background
  2. body foreground
  3. code-block background (`.md-fences` / `.CodeMirror`)
  4. inline code background (`code`)
  5. heading color (`h1..h6`)
  6. link color (`a`)
  7. selection background (`::selection`)
  8. blockquote border (`blockquote` `border-left`)
  9. accent / emphasis (`mark`, `.md-search-hit`)
  10. error / warning (`.md-error`, `.md-warning`, `.cm-error`)

### cmux (macOS)

- `scripts/theme` writes the pack's `variant` (`dark` or `light`) into `com.cmuxterm.app` as both `appearanceMode` and `browserThemeMode`, so cmux's app chrome and its built-in browser follow the theme.
- No new manifest keys — reuses the existing `variant` key, so every pack works with zero retrofit.
- cmux sidebar background auto-derives from the terminal background because `sidebarMatchTerminalBackground = 1` in cmux defaults.
- **Restart cmux** to pick up defaults changes; macOS `cfprefsd` can delay propagation otherwise.

### WezTerm (local color schemes)

- Packs can ship a custom scheme at `wezterm/.config/wezterm/colors/<slug>.toml` and reference it via the `wezterm` manifest key.
- The scheme file should include `[metadata] name = "<slug>"` — this takes precedence over filename parsing across WezTerm versions and makes scheme resolution stable.
- `scripts/theme` restows `wezterm` so new scheme files get symlinked into `~/.config/wezterm/` on fresh clones.

## For Coding Agents (Important)

If you modify `scripts/theme` or theme assets, follow these rules.

- Do not use `sed -i` for watched stow-managed files on macOS.
- Preserve inode for existing destination files when editing/copying watched configs.
- Prefer read-modify-write (`content="$(sed ...)"; printf ... > file`) over tools that replace files.
- For existing watched destination files, prefer `cat src > dst` over `cp src dst`.
- Keep `manifest.toml` schema expectations aligned with parser logic in `scripts/theme`.
- Validate inputs; keep theme names restricted to safe characters.
- Preserve best-effort reload behavior (`|| true`) to avoid partial failure during theme switch.

Background: macOS file watchers and stow symlinks can miss updates when inode changes. See `docs/solutions/integration-issues/macos-sed-inode-file-watcher-symlink-reload.md`.

## Add a New Theme Checklist

1. Copy an existing pack (for example `themes/catppuccin-mocha`) to a new directory.
2. Update `manifest.toml` mappings for every required key.
3. Replace theme asset files (`delta.gitconfig`, `fzf-theme.sh`, etc.) with matching values.
4. Verify the installed font family name via `fc-list | grep <font>` or `system_profiler SPFontsDataType | grep -A2 <font>` **before** filling in the `font` manifest value. Some Nerd Font casks install family strings that don't match the base font name (e.g., `Monaspace Xenon NF` vs `Monaspace Xenon`, `Maple Mono NF` vs `Maple Mono`). Wrong string → silent Ghostty fallback.
5. Confirm `bat.tmTheme`'s internal `<key>name</key><string>...</string>` matches the manifest `bat` value **exactly** — `bat cache --build` indexes themes by the plist's internal name, not the filename.
6. If shipping a custom WezTerm scheme, include `[metadata] name = "<slug>"` matching the manifest `wezterm` value.
7. If shipping a Typora CSS, ensure all 10 semantic roles are defined against the pack's palette (see *Tool Integrations → Typora*).
8. Run `theme <new-theme>`.
9. Verify:
   - `themes/current` changed
   - config values were updated in stowed sources
   - apps that should auto-reload do so
   - restart-required apps (btop, lazygit, lazydocker, yazi, opencode, Typora, cmux) reflect the new theme after restart

## Troubleshooting

- Theme appears unchanged in Ghostty: run `theme <name>` again and ensure Ghostty accessibility/menu reload is allowed.
- btop reverts theme: ensure `save_config_on_exit = false` in `btop/.config/btop/btop.conf`.
- OpenCode theme not visible: confirm theme JSON exists and `opencode` manifest value matches its ID.
- fzf colors unchanged: open a new shell session (theme script reports this).
- Typora theme not applied: restart Typora — themes are read once at startup, not via file watcher.
- cmux appearance mode not changed: restart cmux — macOS defaults caching (`cfprefsd`) can delay propagation until next launch.
