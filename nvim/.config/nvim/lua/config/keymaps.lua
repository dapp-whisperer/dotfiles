-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Markdown group
local wk = require("which-key")
wk.add({ "<leader>m", group = "Markdown" })

-- Open current Markdown file in Typora (centered, 80% screen)
vim.keymap.set("n", "<leader>mp", function()
  local file = vim.fn.expand("%:p")
  if file == "" then
    vim.notify("No file to open", vim.log.levels.WARN)
    return
  end
  vim.fn.jobstart({ "bash", vim.fn.expand("~/.config/yazi/scripts/open-typora.sh"), file }, { detach = true })
end, { desc = "Preview in Typora" })
