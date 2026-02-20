# Neovim

LazyVim-based configuration with customizations for markdown authoring, Rust development, and terminal integration.

## Added Plugins

These plugins are added on top of LazyVim's defaults:

| Plugin | Purpose | Lazy-loaded |
| ------ | ------- | ----------- |
| [markview.nvim](https://github.com/OXY2DEV/markview.nvim) | In-buffer markdown rendering with hybrid edit mode | No (self-manages) |
| [diffview.nvim](https://github.com/sindrets/diffview.nvim) | Git diff viewer and file history browser (auto-refreshes on index changes) | On `:DiffviewOpen` / `:DiffviewFileHistory` |
| [catppuccin](https://github.com/catppuccin/nvim) | Color scheme (default: `catppuccin-mocha`) | Yes |
| [tokyonight](https://github.com/folke/tokyonight.nvim) | Color scheme (alternative) | Yes |

The **Rust language extra** (`lazyvim.plugins.extras.lang.rust`) is also enabled, which pulls in rustaceanvim, crates.nvim, and related tooling.

## Extra Treesitter Parsers

The following parsers are ensured beyond LazyVim's defaults:

`markdown`, `markdown_inline`, `html`, `latex`, `yaml`

## Custom Keybindings

All LazyVim default keybindings are preserved. These are added:

| Key | Mode | Action |
| --- | ---- | ------ |
| `<leader>mp` | Normal | Open current markdown file in Typora (centered, 80% screen) |
| `<leader>mm` | Normal | Toggle Markview rendering |
| `<leader>mh` | Normal | Toggle Markview hybrid mode |
| `<leader>ms` | Normal | Toggle Markview split preview |

All markdown bindings live under the `<leader>m` which-key group.

## Changed Options

Defined in `lua/config/options.lua`. These override LazyVim defaults:

| Option | Value | Why |
| ------ | ----- | --- |
| `wrap` | `true` | Soft-wrap long lines (LazyVim default: off) |
| `linebreak` | `true` | Break at word boundaries, not mid-word |
| `breakindent` | `true` | Preserve indentation on wrapped lines |
| `fillchars` (diff) | `" "` (space) | Cleaner diff view — blank fill instead of default dashes |

`showbreak = "↪ "` is available but commented out.

## Changed Autocmds

Defined in `lua/config/autocmds.lua`:

- **Removed `lazyvim_wrap_spell`** — disables LazyVim's automatic spell checking in text/markdown buffers.

## RPC Server

An RPC socket is started at `$XDG_RUNTIME_DIR/nvim-server.sock` (falls back to `/tmp/nvim-server.sock`). This lets external tools like tmux-fingers open files directly in the running Neovim instance.

## Disabled Built-in Plugins

For startup performance, these Vim built-in plugins are disabled:

`gzip`, `tarPlugin`, `tohtml`, `tutor`, `zipPlugin`

## File Structure

```
nvim/.config/nvim/
├── init.lua                     # Entry point (loads config.lazy)
├── lazy-lock.json               # Plugin version lock
├── lazyvim.json                 # LazyVim extras tracking
├── stylua.toml                  # Lua formatter config
├── spell/                       # Spell files
└── lua/
    ├── config/
    │   ├── lazy.lua             # Plugin spec + lazy.nvim setup
    │   ├── keymaps.lua          # Custom keybindings
    │   ├── options.lua          # Custom vim options + RPC server
    │   └── autocmds.lua         # Removed: wrap_spell group
    └── plugins/
        ├── colorscheme.lua      # catppuccin (default) + tokyonight
        ├── markdown.lua         # markview.nvim + treesitter parsers
        ├── diffview.lua         # diffview.nvim
        └── rust.lua             # Placeholder (extras handle it)
```
