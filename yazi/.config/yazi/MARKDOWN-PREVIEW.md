# Markdown Preview Modes

Three options for previewing `.md` files in Yazi. Switch by replacing the
`prepend_previewers` / `prepend_preloaders` blocks at the top of `yazi.toml`.

Restart Yazi after switching.

---

## Mode 1: Default (no custom preview)

Remove the `[[plugin.prepend_previewers]]` and `[[plugin.prepend_preloaders]]`
blocks for `*.md` from `yazi.toml`. Yazi falls back to its built-in plain-text
preview.

## Mode 2: Lowdown + piper

Fast, lightweight rendered markdown. No syntax highlighting in code blocks.
Uses `scripts/preview-markdown.sh`.

```toml
[[plugin.prepend_previewers]]
url = "*.md"
run = 'piper -- bash ~/.config/yazi/scripts/preview-markdown.sh "$1" $w'
```

## Mode 3: Glow + faster-piper (current)

Syntax-highlighted code blocks, polished tables, cached rendering.
Glow runs once per file; scrolling is O(1).

```toml
[[plugin.prepend_previewers]]
url = "*.md"
run = 'faster-piper --rely-on-preloader'

[[plugin.prepend_preloaders]]
url = "*.md"
run = 'faster-piper -- CLICOLOR_FORCE=1 glow -w=$w -s=dark "$1"'
```

---

## Notes

- `package.toml` keeps both `piper` and `faster-piper` deps regardless of
  active mode.
- `preview-markdown.sh` stays in the repo for the lowdown fallback.
- `Brewfile` keeps both `glow` and `lowdown` installed.
