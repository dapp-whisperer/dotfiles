# LazyGit + Delta Integration

**Date:** 2026-02-01
**Status:** Ready for implementation

## What We're Building

Integrate [Delta](https://github.com/dandavison/delta) as the diff pager for both git CLI commands and LazyGit, providing syntax-highlighted, side-by-side diffs that match the existing Tokyo Night theme used in Helix.

### Goals
- Replace the default +/- diff view with precise, syntax-highlighted deltas
- Side-by-side view (familiar from Cursor/VS Code)
- Consistent theming with existing editor setup (Tokyo Night)
- Works everywhere: terminal `git diff`, `git log`, and LazyGit

## Why This Approach

**User preference:** Side-by-side diffs are more readable and familiar from GUI tools like Cursor. The Tokyo Night theme ensures visual consistency across the development environment.

**Global pager:** Setting Delta globally (not just in LazyGit) means all git operations benefit from the improved diff view with zero additional configuration.

**Stow integration:** Creating a new `lazygit/` stow package follows the existing dotfiles architecture pattern.

## Key Decisions

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Diff style | Side-by-side | Familiar from Cursor, easier to compare changes |
| Scope | Global (all git commands) | Consistent experience everywhere |
| Theme | Tokyo Night | Matches Helix editor config |
| Line numbers | Disabled | Cleaner look, more horizontal space |

## Implementation Summary

1. **Brewfile** - Add `brew "git-delta"`
2. **git/.gitconfig** - Add Delta as pager with side-by-side and Tokyo Night theme
3. **lazygit/.config/lazygit/config.yml** - New stow package with Delta pager config
4. **install.sh** - Add `lazygit` to stow packages and mkdir

## Open Questions

None - ready to proceed to planning.

## References

- [Delta GitHub](https://github.com/dandavison/delta)
- [LazyGit + Delta docs](https://github.com/jesseduffield/lazygit/blob/master/docs/Custom_Pagers.md)
