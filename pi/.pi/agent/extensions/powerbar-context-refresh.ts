import type { ExtensionAPI, ExtensionContext } from "@mariozechner/pi-coding-agent";

const CHUNK_SIZE = 100_000;
let lastCtx: ExtensionContext | undefined;
let timers: Array<ReturnType<typeof setTimeout>> = [];

function colorForPercent(percent: number): string {
  if (percent > 80) return "error";
  if (percent > 60) return "warning";
  return "muted";
}

function emitContext(pi: ExtensionAPI, ctx: ExtensionContext): void {
  const usage = ctx.getContextUsage();

  if (!usage) {
    pi.events.emit("powerbar:update", {
      id: "context-usage",
      text: "ctx",
      suffix: "?",
      color: "dim",
    });
    return;
  }

  if (usage.tokens == null || usage.percent == null) {
    const contextWindow = usage.contextWindow ? `${Math.round(usage.contextWindow / 1000)}k` : "";
    pi.events.emit("powerbar:update", {
      id: "context-usage",
      text: "ctx",
      suffix: contextWindow ? `?/${contextWindow}` : "?",
      color: "dim",
    });
    return;
  }

  const pct = Math.round(usage.percent);
  pi.events.emit("powerbar:update", {
    id: "context-usage",
    text: "ctx",
    suffix: `${pct}%`,
    bar: pct,
    barSegments: Math.ceil(usage.contextWindow / CHUNK_SIZE),
    color: colorForPercent(pct),
  });
}

export default function powerbarContextRefresh(pi: ExtensionAPI): void {
  pi.events.emit("powerbar:register-segment", { id: "context-usage", label: "Context Usage" });

  const clearTimers = () => {
    for (const timer of timers) clearTimeout(timer);
    timers = [];
  };

  const scheduleContext = (ctx = lastCtx) => {
    if (!ctx) return;
    lastCtx = ctx;
    clearTimers();

    // This local extension is loaded before @juanibiapina/pi-powerbar's built-in
    // context producer. On session_start that producer resets context-usage after
    // our handler runs. Re-emit on the next ticks so the visible segment settles
    // immediately instead of waiting for a later turn/subscription refresh.
    for (const delay of [0, 50, 250]) {
      timers.push(
        setTimeout(() => {
          if (lastCtx) emitContext(pi, lastCtx);
        }, delay),
      );
    }
  };

  pi.events.on("powerbar:update", (payload: unknown) => {
    const update = payload as { id?: string; text?: string; bar?: number } | undefined;
    if (update?.id === "context-usage" && !update.text && update.bar === undefined) {
      scheduleContext();
    }
  });

  pi.on("session_start", async (_event, ctx) => scheduleContext(ctx));
  pi.on("session_compact", async (_event, ctx) => scheduleContext(ctx));
  pi.on("turn_start", async (_event, ctx) => emitContext(pi, ctx));
  pi.on("tool_result", async (_event, ctx) => emitContext(pi, ctx));
  pi.on("turn_end", async (_event, ctx) => emitContext(pi, ctx));
  pi.on("session_shutdown", async () => {
    clearTimers();
    lastCtx = undefined;
  });
}
