export const TerminalBellPlugin = async ({ $ }) => {
  const ringBell = async () => {
    await $`sh -lc "printf '\\a' > /dev/tty 2>/dev/null || true"`
  }

  return {
    event: async ({ event }) => {
      if (
        event.type === "session.idle" ||
        event.type === "permission.asked" ||
        event.type === "session.error"
      ) {
        await ringBell()
      }
    },
  }
}
