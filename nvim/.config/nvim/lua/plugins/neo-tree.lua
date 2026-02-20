return {
  -- Disable neo-tree in favour of snacks explorer
  {
    "nvim-neo-tree/neo-tree.nvim",
    enabled = false,
  },
  -- Snacks explorer with hidden and gitignored files visible by default
  {
    "folke/snacks.nvim",
    opts = {
      picker = {
        sources = {
          explorer = {
            hidden = true,
            ignored = true,
          },
        },
      },
    },
  },
}
