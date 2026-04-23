---
title: Extending the unified theming system with macOS defaults-based tool integrations
date: 2026-04-23
category: docs/solutions/architecture-patterns
module: themes
problem_type: architecture_pattern
component: tooling
severity: medium
applies_when:
  - Adding a new macOS app integration to the unified theming system
  - Authoring a new theme pack that needs a new manifest key
  - Integrating a tool that configures via `defaults write` and has no reload API
  - Extending the manifest schema without retrofitting every existing pack
  - Writing bats tests for app-presence-gated switcher blocks
related_components:
  - development_workflow
  - testing_framework
tags:
  - theming
  - dotfiles
  - macos-defaults
  - manifest-schema
  - bash-switcher
  - bats-testing
  - stow
  - optional-keys
---

# Extending the unified theming system with macOS defaults-based tool integrations

## Context

The unified theming system in this repo previously covered two shapes of tool: stow-managed config files (Ghostty, Helix, Zellij, btop, Neovim, tmux, etc.) where a sed-over-a-symlinked-file pass switches the active theme in-place, and a small set of non-stow XDG copies (delta, fzf, bat, eza) where the whole overlay file is replaced. Both shapes are file-based and let every pack land independently — the filesystem is the only integration surface.

Adding Typora and cmux broke that assumption. Both are macOS GUI apps whose theming lives in `defaults`-managed plist state, not in a file we own. The options on the table were all bad: bolt a one-off `defaults write` into shell startup (out-of-band from the pack manifest, breaking the uniformity-across-tools promise), handle Typora out of band via direct edits to `~/Library/Application Support/abnerworks.Typora/themes/*.css` (a previous ad-hoc approach, [captured for mermaid diagrams in the auto-memory Typora reference](/Users/dev/.claude/projects/-Users-dev-dotfiles/memory/reference_typora_theme_mermaid.md)) (session history), or force every existing pack to ship a new asset and a new manifest key the same day the switcher learned about Typora — a coordination problem that scales badly when the next such tool (Raycast, Alfred, Sublime Text, VS Code) shows up.

The pattern that emerged on `feat/flexoki-dark-theme-pack` is an **optional-manifest-key + env-var-sandboxed-guard** design that lets `defaults`-based integrations land in two independent commits and tests cleanly on any dev machine regardless of which apps are installed. The critical constraint that drove the design: scope-guardian review flagged that making a new manifest key hard-required would break all existing theme switches in the window between "switcher learns new key" and "every pack retrofitted" (session history). Optional keys close that window.

## Guidance

**1. Use a dedicated `manifest_get_optional` helper for new keys.** The strict `manifest_get` dies on missing keys, which is correct for legacy required keys but poison for new ones — it forces simultaneous retrofit of every pack. The helper differs by one behavior:

```bash
manifest_get_optional() {
    local file="$1" key="$2" val
    val=$(grep -F "${key} = " "$file" | head -1 | sed 's/^[^=]*= *"\([^"]*\)"/\1/' || true)
    echo "${val:-}"
}
```

Validate only when present, and guard every downstream use on non-empty:

```bash
TYPORA_NAME=$(manifest_get_optional "$MANIFEST" "typora")
[[ -n "$TYPORA_NAME" ]] && validate_value "$TYPORA_NAME" "typora"
```

**2. Layer three guards on `defaults`-based blocks: OS, manifest opt-in, asset present — plus a real-world app-presence check with env-var overrides.** The Typora block is the canonical shape:

```bash
if [[ "$OSTYPE" == "darwin"* && -n "$TYPORA_NAME" && -f "$THEME_DIR/typora-theme.css" ]]; then
    TYPORA_THEMES="${THEME_TYPORA_THEMES:-$HOME/Library/Application Support/abnerworks.Typora/themes}"
    TYPORA_APP="${THEME_TYPORA_APP:-/Applications/Typora.app}"
    if [[ -d "$TYPORA_THEMES" || -d "$TYPORA_APP" ]]; then
        mkdir -p "$TYPORA_THEMES"
        cp "$THEME_DIR/typora-theme.css" "$TYPORA_THEMES/${TYPORA_NAME}.css"
        defaults write abnerworks.Typora theme "$DISPLAY_NAME" 2>/dev/null || true
        defaults write abnerworks.Typora darkTheme "$DISPLAY_NAME" 2>/dev/null || true
    fi
fi
```

Both env vars are required, not optional. `THEME_TYPORA_THEMES` sandboxes the *write* destination; `THEME_TYPORA_APP` sandboxes the *detection*. They default to real macOS paths so production behavior is unchanged, but tests can redirect both into `$BATS_TMPDIR`. The `|| true` suffix on `defaults write` keeps the switcher atomic when `cfprefsd` is flaky.

**3. Reuse existing manifest keys where the semantics already match.** cmux shipped with zero new manifest keys:

```bash
CMUX_APP="${THEME_CMUX_APP:-/Applications/cmux.app}"
if [[ "$OSTYPE" == "darwin"* && -d "$CMUX_APP" ]]; then
    defaults write com.cmuxterm.app appearanceMode "$VARIANT" 2>/dev/null || true
    defaults write com.cmuxterm.app browserThemeMode "$VARIANT" 2>/dev/null || true
fi
```

Both `appearanceMode` and `browserThemeMode` take `dark` / `light`, which every pack already declares. Zero-retrofit integrations should be the default when the tool's concept space lines up with an existing key. This was discovered during plan review (session history) — not an afterthought.

**4. Use live `defaults read` to verify the real key shape before authoring the integration.** The first draft of this integration plan had two wrong assumptions caught by adversarial review before any code was written (session history):

- Typora themes directory was specified as `~/Library/Themes/` — that directory doesn't exist on macOS. The real path is `~/Library/Application Support/abnerworks.Typora/themes/`, confirmed by `defaults read abnerworks.Typora | grep currentThemeFolder`.
- The `defaults write abnerworks.Typora theme` value was specified as a filesystem slug (`flexoki-dark`) — but live `defaults read` showed Typora stores display names with title-case and spaces (`"Catppuccin Mocha"`). The manifest's existing `name` field is the correct source; no new manifest key was needed for the display name.

Always run `defaults read <domain>` on a working install before writing the integration.

**5. Isolate tests with a `defaults` stub + per-test log file.** The stub at `tests/theme/helpers/stubs/defaults` captures every call:

```bash
#!/usr/bin/env bash
if [[ -n "${DEFAULTS_LOG:-}" ]]; then
    printf '%s\n' "$*" >> "$DEFAULTS_LOG"
fi
exit 0
```

`setup.bash` points `DEFAULTS_LOG` at `$BATS_TMPDIR/defaults-calls-$$.log` and truncates it per test, so assertions like `grep -qF 'write abnerworks.Typora theme Flexoki Dark' "$DEFAULTS_LOG"` stay hermetic. The same setup pre-creates `$THEME_TYPORA_APP` and `$THEME_CMUX_APP` as empty directories, so the presence guards pass without depending on what the developer happens to have installed.

**6. Pin an asset-quality rubric for each new file type.** For Typora the rubric is the 10 semantic roles enumerated in `themes/README.md` → *Tool Integrations → Typora* (body bg/fg, code-block bg, inline code bg, heading, link, selection, blockquote border, accent, error/warning). Ship all ten against the pack palette or don't ship the CSS — a partial CSS silently inherits Typora's default theme for the missing roles and produces a worse result than no CSS.

**7. Write to every semantically equivalent key in one pass.** Typora writes both `theme` and `darkTheme` to the same display name. This sidesteps Typora's `useSeparateDarkTheme` state entirely — the pack renders the same whether macOS is in light or dark mode. Prefer this over branching on variant when the tool exposes parallel keys.

**8. `defaults`-based integrations almost always need an app restart.** Document this in the switcher's closing summary (`Restart needed: ... Typora, cmux`) and in the README troubleshooting section. macOS `cfprefsd` can cache preferences past the `defaults write` call, so even without app restart requirements the guidance is still correct.

**9. For shell-env-variable-based configs (fzf, BAT_THEME), make the sourced file a full reset — not a self-referencing append.** This doc's branch also fixed a latent bug in all six `fzf-theme.sh` files that opened with:

```bash
export FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS \
  --color=bg+:#... \
  ..."
```

The `$FZF_DEFAULT_OPTS` self-reference accumulates color flags on every re-source. After a theme switch, a user running `source ~/.config/fzf/theme.sh` in their current shell got both the old and new pack's flags concatenated. Dropping the prefix makes the file idempotent:

```bash
export FZF_DEFAULT_OPTS="--color=bg+:#... \
  ..."
```

Now the switcher can tell the user `source ~/.config/fzf/theme.sh` to reload in-place — no `exec zsh` needed. This generalizes: any `.sh` file the switcher writes that exports environment variables should be a full reset of those variables, never a self-referencing append, so sourcing is idempotent.

## Why This Matters

The optional-key + env-var-guard combo turns each new integration into two independent, shippable commits instead of one giant breaking change. Commit one adds the switcher block behind an optional manifest key — every existing pack keeps working, the new tool silently no-ops. Commit two retrofits a pack with the asset + key when someone cares. Without this split, integrating Typora would have required updating all N packs in the same PR as the switcher change, which scales as O(packs × tools) in coordination cost and blocks the feature on owners of stale packs.

Test sandboxing via env-var overrides is the critical enabler. Without `THEME_TYPORA_APP` and `THEME_CMUX_APP`, the `defaults`-block guards would check `/Applications/Typora.app` and `/Applications/cmux.app` on whatever machine the tests ran on — present on the author's laptop, absent in CI, flaky everywhere else. The env-var layer makes the bats suite deterministic across environments while leaving production paths untouched.

The live-`defaults read` rule matters because the cost of a wrong assumption compounds. Both Typora wrong-path assumptions in the first plan draft would have shipped as a silently-broken integration (directory created at `~/Library/Themes/`, Typora still on whatever bundled theme), and users would have spent time chasing the discrepancy rather than seeing the bug on first launch.

## When to Apply

- Adding a new macOS `defaults`-based app integration (Raycast, Alfred, Sublime Text, VS Code, Finder, Safari, etc.).
- Adding any optional manifest key where per-pack retrofit will trail the switcher change.
- Writing bats tests that need to answer "is app X installed" deterministically across dev machines and CI.
- Integrating any tool whose configuration is written by an external command (`defaults`, `gsettings`, `osascript`, `launchctl`) rather than a plain file edit.
- Authoring any shell-sourced env-var file that the switcher rewrites — make the file a full reset, not a self-append.

## Examples

Adding Raycast appearance-follows-variant would slot in as roughly 10 lines in `scripts/theme`, with no new manifest key (Raycast's appearance takes `dark`/`light`, same shape as `variant`):

```bash
# Raycast: appearance follows the pack's variant. No new manifest key.
# THEME_RAYCAST_APP env var allows test isolation.
RAYCAST_APP="${THEME_RAYCAST_APP:-/Applications/Raycast.app}"
if [[ "$OSTYPE" == "darwin"* && -d "$RAYCAST_APP" ]]; then
    defaults write com.raycast.macos raycastPreferredAppearance "$VARIANT" 2>/dev/null || true
fi
```

And the matching bats additions in `tests/theme/helpers/setup.bash` and a new test:

```bash
# setup.bash
export THEME_RAYCAST_APP="$HOME/fake-raycast.app"
mkdir -p "$THEME_RAYCAST_APP"

# tests/theme/tests/config_values.bats
@test "raycast appearance follows variant" {
    run_theme catppuccin-mocha
    [ "$status" -eq 0 ]
    grep -qF 'write com.raycast.macos raycastPreferredAppearance dark' "$DEFAULTS_LOG"
}

@test "raycast block skipped when app absent" {
    rmdir "$THEME_RAYCAST_APP"
    run_theme catppuccin-mocha
    [ "$status" -eq 0 ]
    ! grep -qF 'write com.raycast.macos' "$DEFAULTS_LOG"
}
```

If instead the integration needs a per-pack asset (e.g., a Sublime Text `.sublime-color-scheme`), the Typora shape applies wholesale: add a `sublime = "..."` optional manifest key, parse with `manifest_get_optional`, guard on OS + `-n "$SUBLIME_NAME"` + asset file existing + env-var-sandboxed presence check, and copy into the app's user packages dir. The same two-commit cadence follows — switcher change first, per-pack retrofit when someone cares.

## Related

- `docs/solutions/integration-issues/theme-switch-reload-reliability.md` — covers reload-side concerns (AppleScript reliability, process-restart needs) that are complementary to this doc's write-side / integration-shape concerns. Add the new tool to the "Restart needed" output when it can't hot-reload.
- `docs/solutions/integration-issues/macos-sed-inode-file-watcher-symlink-reload.md` — inode-preservation fix for file-based tools. `defaults`-based tools sidestep the symlink/inode class of failures entirely because they go through the preferences daemon, not stow-managed files.
- `themes/README.md` — the developer-facing documentation of the pattern (manifest key schema, tool integrations section, add-a-theme checklist).
- Grounding files on branch `feat/flexoki-dark-theme-pack`:
  - `scripts/theme` — `manifest_get_optional`, Typora block, cmux block, expanded `stow -R`
  - `tests/theme/helpers/setup.bash` — env-var override setup
  - `tests/theme/helpers/stubs/defaults` — the stub
  - `tests/theme/tests/file_copies.bats`, `optional_files.bats`, `config_values.bats` — tests exercising the pattern
  - `themes/flexoki-dark/manifest.toml` + `typora-theme.css` — first pack shipping the optional key
