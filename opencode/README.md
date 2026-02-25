# OpenCode Dotfiles

This package manages your OpenCode setup via GNU Stow.

## Managed Paths

- `opencode/.config/opencode/opencode.json`
- `opencode/.config/opencode/themes/`
- `opencode/.config/opencode/agents/`
- `opencode/.config/opencode/skills/`
- `opencode/.config/opencode/plugins/`
- `opencode/.config/opencode-profiles/all-agents/`

When stowed, these map to:

- `~/.config/opencode/opencode.json`
- `~/.config/opencode/themes/`
- `~/.config/opencode/agents/`
- `~/.config/opencode/skills/`
- `~/.config/opencode/plugins/`
- `~/.config/opencode-profiles/all-agents/`

## Startup Modes

Use these shell wrappers from `zsh/.zshrc`:

- `oc`: standard mode (built-ins baseline)
- `oca`: all-agents mode (loads repo custom agents from `~/.config/opencode-profiles/all-agents/`)
- `--clean`: wrapper-level flag that sets `OPENCODE_DISABLE_PROJECT_CONFIG=true`

Examples:

```bash
oc agent list
oca agent list
oc --clean agent list
oca --clean agent list
```

Notes:

- `--clean` is implemented by wrapper logic, not a native top-level OpenCode CLI flag.
- `oca` relies on `OPENCODE_CONFIG_DIR` pointing at the all-agents profile directory.
- `oc` unsets inherited `OPENCODE_CONFIG_DIR` to keep standard mode stable.
- Wrapper behavior supports `OPENCODE_DOTFILES_ROOT` for non-default dotfiles locations.
- Baseline `opencode/.config/opencode/agents/` is intentionally placeholder-only (`.gitkeep`); repo custom agents live under `opencode/.config/opencode-profiles/all-agents/agents/`.
- Terminal bell notifications are handled by `opencode/.config/opencode/plugins/terminal-bell.js` on `session.idle`, `permission.asked`, and `session.error`.

## Rollback

If mode wrappers cause issues, rollback to baseline invocation quickly:

1. In a current shell session, run `opencode` directly instead of `oc`/`oca`.
2. Restore previous alias behavior in `zsh/.zshrc` (`alias oc='opencode'`) if needed.
3. Re-run `zsh -ic 'type oc && type oca'` and `zsh -ic 'oc agent list'` to confirm recovery.

## Common Operations

Restow after changes:

```bash
cd ~/dotfiles
stow --restow opencode
```

Preview stow changes:

```bash
cd ~/dotfiles
stow --simulate --verbose=1 opencode
```

## Editing Workflow

- Prefer editing files under `~/dotfiles/opencode/.config/opencode/...`
- Home paths are symlinks, so edits in either location affect the same content
- Keep machine-local artifacts out of this package (for example `node_modules/`)

## Local-Only Overrides

Keep personal MCP servers out of git by creating a local override file:

```json
{
  "mcp": {
    "linear": {
      "type": "remote",
      "url": "https://mcp.linear.app/mcp",
      "enabled": true
    }
  }
}
```

Write this file at either path:

- `~/.config/opencode/opencode.local.json`
- `~/dotfiles/.local/opencode/opencode.local.json`

`zsh/.zshrc` checks `~/.config/opencode/opencode.local.json` first, then falls back to `$OPENCODE_DOTFILES_ROOT/.local/opencode/opencode.local.json` (defaulting to `~/dotfiles` when present), and exports `OPENCODE_CONFIG` when one exists.

## Theme Notes

- Default theme is `catppuccin-mocha-glass`
- Glass effect comes from OpenCode using `"none"` backgrounds + terminal opacity settings
- Global theming architecture and maintenance guide: [themes/README.md](../themes/README.md)
