import { existsSync, readFileSync } from "node:fs";
import { homedir } from "node:os";
import { basename, dirname, join, sep } from "node:path";
import type { ExtensionAPI, ExtensionContext, Theme } from "@mariozechner/pi-coding-agent";

const ANSI_PATTERN = /\x1b\[[0-9;]*m/g;
let activeCtx: ExtensionContext | undefined;
let requestRender: (() => void) | undefined;
let reinstallTimer: ReturnType<typeof setTimeout> | undefined;

function visibleWidth(text: string): number {
  return text.replace(ANSI_PATTERN, "").length;
}

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

function truncateToWidth(text: string, width: number, ellipsis = "…"): string {
  if (width <= 0) return "";
  if (visibleWidth(text) <= width) return text;

  const suffixWidth = visibleWidth(ellipsis);
  const target = Math.max(0, width - suffixWidth);
  const rawEnd = rawOffsetForVisibleIndex(text, target);
  if (rawEnd === undefined) return ellipsis.slice(0, width);
  return text.slice(0, rawEnd) + ellipsis;
}

function shortenPath(path: string, maxWidth = 48): string {
  const home = homedir();
  let display = path;

  if (display === home) display = "~";
  else if (display.startsWith(`${home}${sep}`)) display = `~${sep}${display.slice(home.length + 1)}`;

  if (visibleWidth(display) <= maxWidth) return display;

  const parts = display.split(sep).filter(Boolean);
  if (display.startsWith("~")) {
    const tail = parts.slice(-2).join(sep);
    const folded = `~${sep}…${sep}${tail}`;
    if (visibleWidth(folded) <= maxWidth) return folded;
  }

  const base = basename(display) || display;
  return truncateToWidth(base, maxWidth, "…");
}

function findGitDir(start: string): string | undefined {
  let current = start;

  while (true) {
    const gitPath = join(current, ".git");
    if (existsSync(gitPath)) {
      try {
        const content = readFileSync(gitPath, "utf8").trim();
        if (content.startsWith("gitdir: ")) {
          const gitDir = content.slice("gitdir: ".length).trim();
          return gitDir.startsWith(sep) ? gitDir : join(current, gitDir);
        }
      } catch {
        return gitPath;
      }
      return gitPath;
    }

    const parent = dirname(current);
    if (parent === current) return undefined;
    current = parent;
  }
}

function getGitBranch(cwd: string): string | undefined {
  const gitDir = findGitDir(cwd);
  if (!gitDir) return undefined;

  try {
    const head = readFileSync(join(gitDir, "HEAD"), "utf8").trim();
    if (head.startsWith("ref: refs/heads/")) return head.slice("ref: refs/heads/".length);
    if (head) return head.slice(0, 8);
  } catch {
    return undefined;
  }
}

function renderLine(theme: Theme, width: number): string {
  const ctx = activeCtx;
  if (!ctx) return "";

  const folder = theme.fg("accent", `⌂ ${shortenPath(ctx.cwd)}`);
  const branch = getGitBranch(ctx.cwd);
  const git = branch ? theme.fg("dim", `↳ ${branch}`) : "";
  const line = [folder, git].filter(Boolean).join(theme.fg("dim", " │ "));
  return truncateToWidth(line, width, "…");
}

function installFolderLine(ctx: ExtensionContext): void {
  if (!ctx.hasUI) return;

  ctx.ui.setWidget(
    "powerbar-folder-line",
    (tui: { requestRender: () => void }, theme: Theme) => {
      requestRender = () => tui.requestRender();
      return {
        render(width: number): string[] {
          const line = renderLine(theme, width);
          return line ? [line] : [];
        },
        invalidate(): void {},
      };
    },
    { placement: "belowEditor" },
  );
}

export default function powerbarFolderLine(_pi: ExtensionAPI) {
  const scheduleInstallLast = (ctx = activeCtx) => {
    if (!ctx?.hasUI) return;
    if (reinstallTimer) clearTimeout(reinstallTimer);

    // Powerbar calls setWidget("powerbar", ...) on every segment update, which
    // removes and re-adds its widget at the end of Pi's below-editor widget map.
    // Reinstall this widget on the next tick so folder/git stays on the second
    // line instead of jumping above Powerbar while subscription/context updates
    // settle after /reload.
    reinstallTimer = setTimeout(() => {
      reinstallTimer = undefined;
      if (activeCtx?.hasUI) installFolderLine(activeCtx);
    }, 0);
  };

  const refresh = (ctx: ExtensionContext) => {
    activeCtx = ctx;
    requestRender?.();
  };

  _pi.on("session_start", async (_event, ctx) => {
    activeCtx = ctx;
    scheduleInstallLast(ctx);
  });

  _pi.events.on("powerbar:update", () => scheduleInstallLast());

  _pi.on("tool_result", async (event, ctx) => {
    if (event.toolName === "bash") refresh(ctx);
  });

  _pi.on("turn_start", async (_event, ctx) => refresh(ctx));
  _pi.on("turn_end", async (_event, ctx) => refresh(ctx));
  _pi.on("session_shutdown", async (_event, ctx) => {
    if (reinstallTimer) {
      clearTimeout(reinstallTimer);
      reinstallTimer = undefined;
    }
    if (ctx.hasUI) ctx.ui.setWidget("powerbar-folder-line", undefined, { placement: "belowEditor" });
    activeCtx = undefined;
    requestRender = undefined;
  });
}
