# Tmux Dotfiles

Terminal multiplexer config with Catppuccin Mocha theme, session management, and vim-style navigation.

## Managed Paths

- `tmux/.config/tmux/tmux.conf`

When stowed, maps to `~/.config/tmux/tmux.conf`.

## Plugins (11)

Managed by [TPM](https://github.com/tmux-plugins/tpm). Install with `prefix+I` inside tmux.

| Plugin | Purpose |
|--------|---------|
| [tpm](https://github.com/tmux-plugins/tpm) | Plugin manager |
| [tmux-sensible](https://github.com/tmux-plugins/tmux-sensible) | Sensible defaults |
| [vim-tmux-navigator](https://github.com/christoomey/vim-tmux-navigator) | Seamless vim/tmux pane switching |
| [catppuccin/tmux](https://github.com/catppuccin/tmux) | Catppuccin Mocha theme (v2) |
| [tmux-yank](https://github.com/tmux-plugins/tmux-yank) | System clipboard integration |
| [tmux-thumbs](https://github.com/fcsonline/tmux-thumbs) | Text hint overlay (copy text with keyboard) |
| [tmux-sessionx](https://github.com/omerxx/tmux-sessionx) | Fuzzy session manager with zoxide |
| [tmux-floax](https://github.com/omerxx/tmux-floax) | Floating terminal pane |
| [tmux-fzf-url](https://github.com/wfxr/tmux-fzf-url) | Open URLs from buffer via fzf |
| [tmux-resurrect](https://github.com/tmux-plugins/tmux-resurrect) | Save/restore sessions |
| [tmux-continuum](https://github.com/tmux-plugins/tmux-continuum) | Auto-save sessions, auto-restore on start |

## Keybindings

Prefix is `Ctrl+B` (default).

### Navigation

| Key | Action |
|-----|--------|
| `Alt+h/j/k/l` | Switch panes (no prefix needed) |
| `Ctrl+h/j/k/l` | Switch panes (vim-tmux-navigator, works inside Neovim) |
| `Shift+Left/Right` | Previous/next window (no prefix needed) |

### Prefix Commands

| Key | Action |
|-----|--------|
| `prefix+h` | Split pane right (horizontal layout) |
| `prefix+v` | Split pane below (vertical layout) |
| `prefix+r` | Reload config |
| `prefix+D` | Detach tmux client |
| `prefix+x` | Kill pane (no confirmation prompt) |
| `prefix+z` | Toggle pane zoom |
| `prefix+[` | Enter copy mode (vi keys: `h/j/k/l`, `v` select, `y` yank) |
| `prefix+Space` | Tmux-thumbs: text hint overlay for copying |
| `prefix+o` | SessionX: fuzzy session picker (zoxide-powered) |
| `prefix+f` | Floax: toggle floating terminal pane |
| `prefix+u` | FZF-URL: pick and open URLs from buffer |
| `prefix+Ctrl+s` | Resurrect: save session |
| `prefix+Ctrl+r` | Resurrect: restore session |
| `prefix+I` | TPM: install plugins |
| `prefix+U` | TPM: update plugins |

## Theme

Catppuccin Mocha (v2) with:
- Session name on the left
- Current directory on the right
- Zoom indicator `()` on zoomed windows
- Themed pane borders (lavender active, surface inactive)

### Catppuccin v2 Load Order

The v2 plugin requires a specific ordering in `tmux.conf`:

1. Declare `@plugin 'catppuccin/tmux'` with other plugins
2. Set catppuccin options (`@catppuccin_flavor`, window text, etc.)
3. `run` catppuccin.tmux manually (before status line)
4. Set `status-left` and `status-right` using `#{E:@catppuccin_status_*}` format strings
5. `run` TPM last

This is because the `#{E:}` format strings reference variables that catppuccin defines at `run` time.

## Terminal Features

- True color (`Tc` override)
- Passthrough for image rendering (Claude Code)
- OSC 8 hyperlinks (clickable file paths)
- OSC 52 clipboard
- Extended keys (Shift+Enter, Ctrl+J passthrough)

## General Behavior

- Mouse enabled (scroll, select panes, resize)
- Scrollback buffer: 1,000,000 lines
- Windows and panes numbered from 1 (not 0)
- Windows auto-renumber on close
- Activity monitoring with visual alerts
- Floax scratch session pre-warmed on startup for instant toggle
- Mouse drag selection copies to clipboard

## First Run

```bash
# 1. Clone TPM (if not already installed)
git clone https://github.com/tmux-plugins/tpm ~/.config/tmux/plugins/tpm

# 2. Start tmux (status bar will be unstyled until plugins install)
tmux

# 3. Install plugins
# Press prefix+I (Ctrl+B then Shift+I)

# 4. Reload config to ensure clean state
# Press prefix+r

# 5. First prefix+Space triggers tmux-thumbs Rust compilation (~30s)
```

## Dependencies

- `fzf` (tmux-fzf-url, sessionx) — Brewfile
- `zoxide` (sessionx zoxide mode) — Brewfile
- `rust` (tmux-thumbs compilation) — Brewfile via `rustup-init`, initialized by install.sh
