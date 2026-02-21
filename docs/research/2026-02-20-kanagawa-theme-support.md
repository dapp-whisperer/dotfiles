# Kanagawa Theme Support Across Dotfiles Stack

**Date:** 2026-02-20
**Status:** Initial research

---

## Executive Summary

Kanagawa has strong ecosystem coverage — better than most themes outside of Catppuccin and Tokyo Night. Of the 14 tools in the dotfiles theme switcher, **7 have ready-to-use official/community themes**, **5 have community sources that need adaptation** to the dotfiles format, and only **2 need manual creation** from the palette. The kanagawa-paper.nvim project (a Kanagawa remix) is a particularly rich source, providing extras for fzf, lazygit, and zellij that the original kanagawa.nvim doesn't cover.

## Tool-by-Tool Coverage

### Ready to Use (Official / Built-in)

| # | Tool | Source | Theme Name | Notes |
|---|------|--------|------------|-------|
| 1 | **Neovim** | [rebelot/kanagawa.nvim](https://github.com/rebelot/kanagawa.nvim) | `kanagawa-wave` | LazyVim extra. Origin of the theme. Variants: wave (dark), dragon (darker), lotus (light) |
| 2 | **Ghostty** | [kanagawa.nvim extras/Ghostty](https://github.com/rebelot/kanagawa.nvim) | `kanagawa_wave` | In kanagawa.nvim extras directory. Also likely built into Ghostty (`ghostty +list-themes` to verify) |
| 3 | **Helix** | [helix built-in](https://github.com/helix-editor/helix/blob/master/runtime/themes/kanagawa.toml) | `kanagawa` | Ships with Helix. In `runtime/themes/kanagawa.toml` |
| 4 | **btop** | [btop PR #1034](https://github.com/aristocratos/btop/pull/1034/files) | `kanagawa-wave` | Merged Feb 2025. `kanagawa-wave.theme` with full color definitions. Also has `kanagawa-lotus` light variant |
| 5 | **bat** | [kanagawa.nvim extras/tmTheme](https://github.com/rebelot/kanagawa.nvim) | Internal name TBD | `.tmTheme` file in kanagawa.nvim extras. Need to verify internal `<key>name</key>` value |
| 6 | **Yazi** | [dangooddd/kanagawa.yazi](https://github.com/dangooddd/kanagawa.yazi) | `kanagawa` | Official Yazi flavor with `flavor.toml` + `tmtheme.xml`. MIT licensed |
| 7 | **OpenCode** | [Built-in](https://opencode.ai/docs/themes/) | `kanagawa` | Listed as built-in theme. No custom JSON needed |

### Available — Needs Adaptation to Dotfiles Format

| # | Tool | Source | Work Needed |
|---|------|--------|-------------|
| 8 | **fzf** | [kanagawa-paper.nvim extras/fzf](https://github.com/thesimonho/kanagawa-paper.nvim) | Extract `FZF_DEFAULT_OPTS` color string + set `BAT_THEME`. kanagawa-paper uses slightly muted colors vs original |
| 9 | **LazyGit** | [kanagawa-paper.nvim extras/lazygit](https://github.com/thesimonho/kanagawa-paper.nvim) | Extract theme YAML section. Need to add `git.pagers` delta integration |
| 10 | **Zellij** | [kanagawa-paper.nvim extras/zellij](https://github.com/thesimonho/kanagawa-paper.nvim) | Extract KDL color definitions. Map to 11-color palette format |
| 11 | **tmux** | Derive from palette | Create catppuccin-compatible flavor file (same pattern as `tokyonight-night/tmux-theme.conf` — set `@thm_*` variables). Two community projects exist but use different plugin architectures: [Nybkox/tmux-kanagawa](https://github.com/Nybkox/tmux-kanagawa) (dracula fork), [AntonReborn/kanagawa-tmux](https://github.com/AntonReborn/kanagawa-tmux) (catppuccin fork, useful for color reference) |
| 12 | **Delta** | Derive from palette + tmTheme | Create `.gitconfig` with delta color settings. Use tmTheme for `syntax-theme`. Reference the tokyonight delta.gitconfig format |

### Needs Manual Creation

| # | Tool | Effort | Notes |
|---|------|--------|-------|
| 13 | **eza** | Medium | No kanagawa in [eza-community/eza-themes](https://github.com/eza-community/eza-themes). Create from palette — map file types, permissions, git status, sizes to Kanagawa colors |
| 14 | **LazyDocker** | Low | Same YAML theme format as LazyGit. Derive from LazyGit theme |
| 15 | **gitui** | Low (dead code) | No gitui stow package currently exists. A [community gist](https://gist.github.com/zetashift/292f5b07318a48d843cf67d60edfae5f) exists but is a Helix toml, not gitui ron |

## Kanagawa Wave Color Palette Reference

From [kanagawa.nvim colors.lua](https://github.com/rebelot/kanagawa.nvim/blob/master/lua/kanagawa/colors.lua):

| Role | Name | Hex | Usage |
|------|------|-----|-------|
| bg | sumiInk1 | `#1F1F28` | Main background |
| bg dark | sumiInk0 | `#16161D` | Darker background |
| bg darker | sumiInk2 | `#2A2A37` | Float/popup bg |
| fg | fujiWhite | `#DCD7BA` | Main foreground |
| fg dim | oldWhite | `#C8C093` | Dimmed text |
| red | autumnRed | `#C34043` | Errors, deletions |
| green | autumnGreen | `#76946A` | Success, additions (muted) |
| green bright | springGreen | `#98BB6C` | Strings, insertions |
| blue | crystalBlue | `#7E9CD8` | Functions |
| yellow | carpYellow | `#E6C384` | Identifiers |
| yellow dark | autumnYellow | `#DCA561` | Operators, warnings |
| magenta | oniViolet | `#957FB8` | Keywords, statements |
| orange | surimiOrange | `#FFA066` | Numbers, parameters |
| cyan | springBlue | `#7FB4CA` | Special identifiers |
| cyan bright | waveAqua2 | `#7AA89F` | Types |
| pink | sakuraPink | `#D27E99` | Brackets, punctuation |
| comment | fujiGray | `#727169` | Comments, inactive |
| selection | waveBlue2 | `#2D4F67` | Visual selection |
| surface | sumiInk4 | `#54546D` | Borders, separators |

## Variant Comparison

| Property | Wave (default) | Dragon (darker) | Lotus (light) |
|----------|---------------|-----------------|----------------|
| Background | `#1F1F28` | `#181616` | `#F2ECBC` |
| Foreground | `#DCD7BA` | `#C5C9C5` | `#545464` |
| Mood | Calm, oceanic dark | Deeper, warmer dark | Soft, warm light |
| Best for | General use | Maximum darkness | Daytime use |

**Recommendation:** Wave is the standard variant and has the broadest community support.

## Key Sources

### Primary
- **kanagawa.nvim** ([rebelot/kanagawa.nvim](https://github.com/rebelot/kanagawa.nvim)) — Origin. Provides: Ghostty, bat tmTheme, and 15+ terminal emulator configs
- **kanagawa-paper.nvim** ([thesimonho/kanagawa-paper.nvim](https://github.com/thesimonho/kanagawa-paper.nvim)) — Remix with extras for: fzf, lazygit, zellij, plus all the terminals

### Community Ports
- **Yazi** — [dangooddd/kanagawa.yazi](https://github.com/dangooddd/kanagawa.yazi)
- **btop** — [PR #1034](https://github.com/aristocratos/btop/pull/1034/files) (merged)
- **tmux** — [AntonReborn/kanagawa-tmux](https://github.com/AntonReborn/kanagawa-tmux) (catppuccin fork, good color reference)
- **tmux** — [Nybkox/tmux-kanagawa](https://github.com/Nybkox/tmux-kanagawa) (dracula fork, active development)
- **eza-themes** — No kanagawa yet ([eza-community/eza-themes](https://github.com/eza-community/eza-themes))
- **zellij-themes** — No kanagawa yet ([witjem/zellij-themes](https://github.com/witjem/zellij-themes))

### Reference
- **OpenCode themes** — [opencode.ai/docs/themes](https://opencode.ai/docs/themes/) (kanagawa built-in)
- **Helix themes** — [helix-editor themes](https://docs.helix-editor.com/themes.html) (kanagawa built-in)
- **fzf color schemes** — [fzf wiki](https://github.com/junegunn/fzf/wiki/Color-schemes)

## Effort Estimate

Building a complete `themes/kanagawa-wave/` theme pack:

- **Direct downloads** (bat tmTheme, Ghostty, btop): Copy from upstream sources
- **Light adaptation** (fzf, lazygit, zellij): Extract from kanagawa-paper extras, convert to dotfiles format
- **Medium creation** (tmux, delta, eza): Build from palette using existing tokyonight files as structural templates
- **Trivial derivation** (lazydocker, gitui): Clone from lazygit theme / skip (gitui unused)

Total: ~5-8 files to create from scratch, ~5-6 files to adapt from community sources, ~2-3 direct downloads.

## Caveats

- **kanagawa-paper vs kanagawa**: kanagawa-paper.nvim is a _remix_ with slightly muted/adjusted colors. Its extras may not perfectly match the original kanagawa.nvim palette. For consistency, prefer extracting color values from the original palette and using kanagawa-paper extras as structural templates only.
- **bat tmTheme internal name**: Must verify the exact `<key>name</key>` value in the kanagawa tmTheme before setting the manifest `bat` key (learned from the Tokyo Night bug).
- **btop theme**: The PR added `kanagawa-wave.theme` — if using btop >= Feb 2025, it may ship built-in. Otherwise the theme file from the PR can be used directly.
