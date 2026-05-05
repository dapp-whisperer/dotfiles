import type { ExtensionAPI, ExtensionContext } from "@mariozechner/pi-coding-agent";

const PATCHED = Symbol.for("powerline-placement-shim:patched");
const ANSI_PATTERN = /\x1b\[[0-9;]*m/g;

function rawOffsetForVisibleIndex(text: string, visibleIndex: number): number | undefined {
  let rawOffset = 0;
  let currentVisible = 0;

  while (rawOffset < text.length) {
    ANSI_PATTERN.lastIndex = rawOffset;
    const ansiMatch = ANSI_PATTERN.exec(text);
    if (ansiMatch?.index === rawOffset) {
      rawOffset = ANSI_PATTERN.lastIndex;
      continue;
    }

    if (currentVisible === visibleIndex) return rawOffset;
    rawOffset += 1;
    currentVisible += 1;
  }

  return currentVisible === visibleIndex ? rawOffset : undefined;
}

function replaceVisibleText(line: string, target: string, replacement: string): string {
  const visible = line.replace(ANSI_PATTERN, "");
  const visibleStart = visible.indexOf(target);
  if (visibleStart < 0) return line;

  const rawStart = rawOffsetForVisibleIndex(line, visibleStart);
  const rawEnd = rawOffsetForVisibleIndex(line, visibleStart + target.length);
  if (rawStart === undefined || rawEnd === undefined) return line;

  return line.slice(0, rawStart) + replacement + line.slice(rawEnd);
}

function normalizeThinkingRainbow(line: string, theme: { fg: (color: string, text: string) => string }): string {
  let normalized = replaceVisibleText(line, "think:high", theme.fg("thinkingHigh", "think:high"));
  normalized = replaceVisibleText(normalized, "think:xhigh", theme.fg("thinkingXhigh", "think:xhigh"));
  return normalized;
}

function wrapPowerlineComponentFactory(content: unknown): unknown {
  if (typeof content !== "function") return content;

  return (tui: unknown, theme: { fg: (color: string, text: string) => string }, ...rest: unknown[]) => {
    const component = (content as (...args: unknown[]) => any)(tui, theme, ...rest);
    if (!component || typeof component.render !== "function") return component;

    return {
      ...component,
      render(width: number) {
        return component.render(width).map((line: string) => normalizeThinkingRainbow(line, theme));
      },
    };
  };
}

/**
 * Move pi-powerline-footer's primary status row below the editor and normalize
 * its high-thinking segment to one color.
 *
 * pi-powerline-footer currently hard-codes the `powerline-top` widget to
 * `{ placement: "aboveEditor" }` and renders high/xhigh thinking levels as a
 * rainbow gradient. This shim patches the session UI before package extensions
 * run and rewrites only that widget's placement/rendering. Keeping this as a
 * local extension makes the change survive npm package updates.
 */
export default function powerlinePlacementShim(pi: ExtensionAPI) {
  pi.on("session_start", async (_event, ctx: ExtensionContext) => {
    if (!ctx.hasUI) return;

    const ui = ctx.ui as any;
    if (ui[PATCHED]) return;

    const originalSetWidget = ui.setWidget.bind(ui);
    ui.setWidget = (key: string, content: unknown, options?: { placement?: string }) => {
      if (key === "powerline-top" && content !== undefined) {
        return originalSetWidget(key, wrapPowerlineComponentFactory(content), {
          ...(options ?? {}),
          placement: "belowEditor",
        });
      }

      if (key === "powerline-secondary" && content !== undefined) {
        return originalSetWidget(key, wrapPowerlineComponentFactory(content), options);
      }

      return originalSetWidget(key, content, options);
    };

    ui[PATCHED] = true;
  });
}
