# OpenCode Dotfiles

This package manages your OpenCode setup via GNU Stow.

## Managed Paths

- `opencode/.config/opencode/opencode.json`
- `opencode/.config/opencode/themes/`
- `opencode/.config/opencode/agents/`
- `opencode/.config/opencode/skills/`

When stowed, these map to:

- `~/.config/opencode/opencode.json`
- `~/.config/opencode/themes/`
- `~/.config/opencode/agents/`
- `~/.config/opencode/skills/`

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

`zsh/.zshrc` checks `~/.config/opencode/opencode.local.json` first, then falls back to `~/dotfiles/.local/opencode/opencode.local.json`, and exports `OPENCODE_CONFIG` when one exists.

## Theme Notes

- Default theme is `catppuccin-mocha-glass`
- Glass effect comes from OpenCode using `"none"` backgrounds + terminal opacity settings
