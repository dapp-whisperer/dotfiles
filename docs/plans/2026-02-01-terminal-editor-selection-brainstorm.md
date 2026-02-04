# Terminal Editor Selection for Agentic Dev Environment
**Date:** 2026-02-01
**Status:** Reconsidering - Helix vs LazyVim
**Participants:** User, Claude

## What We're Building

A terminal-based development environment that integrates:
- **File navigation** (Yazi)
- **Agentic coding** (Claude Code)
- **Manual editing** (upgraded from Micro)
- **Window management** (Zellij)

The goal is a VSCode-replacement workflow that runs entirely in the terminal.

## Why This Approach

### User Context
- Coming from VSCode/Cursor background (no Vim experience)
- Full replacement for GUI editor, not just occasional use
- Fuzzy file finder is essential
- Open to deep learning investment
- Prefers minimal configuration / works out of the box
- Already using Zellij + Yazi + Claude Code workflow

### Decision: Architecture B - Hybrid Approach

```
┌─────────────────────────────────────────────────────┐
│                    Zellij                           │
│  ┌─────────────────┐  ┌─────────────────────────┐  │
│  │   Yazi          │  │   Claude Code           │  │
│  │  (navigation)   │  │   (agent)               │  │
│  │                 │  │                         │  │
│  │  Enter → opens  │  │                         │  │
│  │  editor float   │  │                         │  │
│  └─────────────────┘  └─────────────────────────┘  │
│                                                     │
│  Tab 2: Editor (fullscreen when needed)            │
└─────────────────────────────────────────────────────┘
```

**Rationale:**
- Each tool does what it's best at (separation of concerns)
- If one tool crashes, others keep running (resilience)
- Can work in Claude-only mode OR editor mode (flexibility)
- Minimal changes to existing dotfiles setup

## Key Decisions

### Editor Choice: Helix vs LazyVim (Reconsidering)

**Previous Decision:** LazyVim
**Current Consideration:** Helix may be better fit for VSCode user

#### Head-to-Head Comparison

| Factor | Helix | LazyVim |
|--------|-------|---------|
| **Editing model** | Selection → Action | Action → Motion (Vim) |
| **Example: delete word** | `w` (select) → `d` (delete) | `dw` (delete word) |
| **Learning curve** | ~1 week | ~1-3 months |
| **Configuration** | Single TOML file | Lua files, many options |
| **Out-of-box experience** | Excellent | Excellent (with distro) |
| **Plugin ecosystem** | None (by design) | Massive |
| **LSP setup** | Zero-config | Pre-configured in LazyVim |
| **Fuzzy finder** | Built-in | Telescope (plugin) |
| **Tree-sitter** | Built-in | Built-in |
| **Multiple cursors** | Native | Plugin required |
| **Customizability** | Limited, opinionated | Infinite |
| **Debugger (DAP)** | ❌ Not yet | ✅ nvim-dap |
| **Community size** | Growing | Huge |

#### For a VSCode User (Key Insight)

| Factor | Helix | LazyVim |
|--------|-------|---------|
| **Familiar feel** | Closer (selection model) | Further (must rewire brain) |
| **Time to productivity** | Days | Weeks to months |
| **Ceiling** | High | Unlimited |
| **Transferable skills** | Helix-specific | Industry standard (Vim everywhere) |
| **"I want to tweak X"** | Often can't | Always can |
| **Frustration early on** | Lower | Higher |

#### Rust Development

| Feature | Helix | LazyVim |
|---------|-------|---------|
| rust-analyzer | ✅ Auto-detected | ✅ Via rustaceanvim |
| Inline diagnostics | ✅ | ✅ |
| Code actions | ✅ | ✅ |
| Inlay hints | ✅ | ✅ |
| Debugging | ❌ No DAP yet | ✅ nvim-dap |
| Cargo integration | Basic | Better (plugins) |

#### Tradeoffs Summary

**Choose Helix if:**
- Faster path to productivity matters
- Prefer "it just works" over customization
- Selection-first model appeals (see what you're affecting before acting)
- Don't need debugger integration
- Okay with smaller community

**Choose LazyVim if:**
- Willing to invest in longer learning curve
- Want Vim skills (useful everywhere: servers, IDEs, etc.)
- Customization matters
- Need debugging support
- Want the largest ecosystem of solutions

**Current Leaning:** Helix - the selection-first model is more intuitive for VSCode users, and zero-config LSP matches the "minimal configuration" preference.

### Integration Points

1. **Yazi → Editor**: Update `open-editor.sh` to use chosen editor
2. **Zellij floating pane**: Editor opens in 90% floating pane (current behavior)
3. **Keybinding harmony**: Zellij uses Ctrl+, editor uses Space leader (no conflict)

### Rejected Alternatives

- **Architecture A (LazyVim-centric)**: Running Claude in Neovim terminal is awkward; neo-tree is weaker than Yazi
- **Architecture C (Editor-optional)**: Limits manual editing capability too much
- **Micro**: Most VSCode-like keybindings (Ctrl+S, Ctrl+C/V), but no built-in LSP and limited plugin ecosystem. Good for light edits, insufficient for full VSCode replacement.
- **Zed**: GUI editor, not terminal-native. Has VSCode-like keybindings but requires display server.
- **Lapce/Lite XL**: GUI-only, not terminal-native
- **Kakoune**: Helix is essentially "Kakoune done right" with batteries included

## Open Questions

1. **LazyVim vs Helix**: Reconsidering - leaning Helix (see comparison above)

2. ~~**Dedicated editor tab**~~: No - spawn on demand when needed

3. ~~**Yazi editor integration**~~: Option 4 - Replace Yazi with editor in same pane

### Yazi → Editor Integration Decision

**Choice:** Yazi and editor share the left pane slot, swapping as needed.

```
Before (browsing):               After (editing):
┌─────────────┐ ┌────────────┐   ┌─────────────┐ ┌────────────┐
│   Yazi      │ │   Claude   │   │   Helix     │ │   Claude   │
│             │ │            │   │             │ │            │
└─────────────┘ └────────────┘   └─────────────┘ └────────────┘
```

**Rationale:**
- Matches agentic workflow (browse OR edit, not both)
- Maximizes editor space (full 50%)
- Simple mental model (left = file work, right = agent)
- When `:q` editor, Yazi returns

## Implementation Checklist

### If Helix (Current Leaning)

- [ ] Add `helix` to Brewfile
- [ ] Run `hx --tutor` to complete built-in tutorial
- [ ] Update Yazi keymap: Enter opens `hx`, returns to Yazi on quit
- [ ] Remove `open-editor.sh` script (no longer needed)
- [ ] Test Rust LSP (rust-analyzer auto-detected)
- [ ] Learn core Helix keybindings:
  - `Space` = leader menu (like VSCode Ctrl+Shift+P)
  - `w` = select word, `x` = select line
  - `d` = delete, `y` = yank, `p` = paste
  - `gd` = go to definition, `gr` = references
  - `Space+f` = fuzzy file finder

### If LazyVim (Alternative)

- [ ] Add `neovim` to Brewfile
- [ ] Clone LazyVim starter config to ~/.config/nvim
- [ ] Install Nerd Font for icons (uncomment in Brewfile)
- [ ] Update Yazi keymap: Enter opens nvim, returns to Yazi on quit
- [ ] Remove `open-editor.sh` script (no longer needed)
- [ ] Test Rust LSP (rust-analyzer) integration
- [ ] Learn core LazyVim keybindings (Space as leader)

## Sources

### Helix Resources (Beginner)
- [Helix Official Docs](https://docs.helix-editor.com/)
- [Helix Built-in Tutor](https://docs.helix-editor.com/usage.html) - run `hx --tutor`
- [Unofficial Beginner-Friendly Docs](https://helix-editor.vercel.app/start-here/basics/)
- [Helix Editor Tutorials](https://helix-editor-tutorials.com/tutorials/)
- [GitHub Wiki - Getting Started](https://github.com/helix-editor/helix/wiki/1.-Tutorial:-Getting-Started)

### Comparison Articles
- [Notes on switching to Helix from vim - Julia Evans](https://jvns.ca/blog/2025/10/10/notes-on-switching-to-helix-from-vim/)
- [Helix vs Neovim comparison](https://tqwewe.com/blog/helix-vs-neovim/)
- [From Helix to Neovim](https://pawelgrzybek.com/from-helix-to-neovim/)

### Other Editors
- [LazyVim documentation](https://www.lazyvim.org/)
- [Micro editor](https://micro-editor.github.io/)
- [Amp editor](https://amp.rs/)
- [Lapce editor](https://lapce.dev/)
