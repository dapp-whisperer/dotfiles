local wezterm = require 'wezterm'
local config = wezterm.config_builder()
local act = wezterm.action

local function split_and_zoom(command)
  return wezterm.action_callback(function(window, pane)
    local ok, new_pane = pcall(function()
      return pane:split {
        direction = 'Right',
        size = { Percent = 40 },
        top_level = true,
        command = {
          args = {
            os.getenv('SHELL') or '/bin/zsh',
            '-lc',
            command,
          },
        },
      }
    end)

    if ok and new_pane then
      window:perform_action(act.TogglePaneZoomState, new_pane)
    end
  end)
end

-- Theme
config.color_scheme = 'Catppuccin Mocha'

-- Font
config.font = wezterm.font 'JetBrainsMono Nerd Font Mono'
config.font_size = 13.5
config.line_height = 1.08

config.background = {
  {
    source = { File = wezterm.home_dir .. '/.config/wezterm/background.jpg' },
    hsb = { brightness = 0.25, saturation = 1.0, hue = 1.0 },
    opacity = 1.0,
    width = '100%',
    height = '100%',
  },
  {
    source = { Color = '#1e1e2e' }, -- theme background overlay
    opacity = 1.0,
    width = '100%',
    height = '100%',
  },
}
config.macos_window_background_blur = 28

-- Leader key (matches tmux C-Space muscle memory)
config.leader = { key = 'Space', mods = 'CTRL', timeout_milliseconds = 1000 }

-- Keys
config.keys = {
  -- Alt+Arrow: word navigation (match Ghostty)
  { key = 'LeftArrow', mods = 'OPT', action = act.SendKey { key = 'b', mods = 'ALT' } },
  { key = 'RightArrow', mods = 'OPT', action = act.SendKey { key = 'f', mods = 'ALT' } },

  -- Window management (match Ghostty)
  { key = 'r', mods = 'SUPER', action = act.SplitHorizontal { domain = 'CurrentPaneDomain' } },
  { key = 'd', mods = 'SUPER', action = act.SplitVertical { domain = 'CurrentPaneDomain' } },
  { key = 'Enter', mods = 'SUPER', action = act.TogglePaneZoomState },
  { key = 'w', mods = 'SUPER', action = act.CloseCurrentPane { confirm = false } },
  { key = 'Enter', mods = 'SUPER|SHIFT', action = act.ToggleFullScreen },
  -- Split navigation (match Ghostty)
  { key = ']', mods = 'SUPER', action = act.ActivatePaneDirection 'Next' },
  { key = '[', mods = 'SUPER', action = act.ActivatePaneDirection 'Prev' },
  { key = 'UpArrow', mods = 'SUPER|OPT', action = act.ActivatePaneDirection 'Up' },
  { key = 'DownArrow', mods = 'SUPER|OPT', action = act.ActivatePaneDirection 'Down' },
  { key = 'LeftArrow', mods = 'SUPER|OPT', action = act.ActivatePaneDirection 'Left' },
  { key = 'RightArrow', mods = 'SUPER|OPT', action = act.ActivatePaneDirection 'Right' },
  -- Split resize (match Ghostty)
  { key = 'UpArrow', mods = 'SUPER|CTRL', action = act.AdjustPaneSize { 'Up', 10 } },
  { key = 'DownArrow', mods = 'SUPER|CTRL', action = act.AdjustPaneSize { 'Down', 10 } },
  { key = 'LeftArrow', mods = 'SUPER|CTRL', action = act.AdjustPaneSize { 'Left', 10 } },
  { key = 'RightArrow', mods = 'SUPER|CTRL', action = act.AdjustPaneSize { 'Right', 10 } },

  -- Leader: splits
  { key = 'r', mods = 'LEADER', action = act.SplitHorizontal { domain = 'CurrentPaneDomain' } },
  { key = 'd', mods = 'LEADER', action = act.SplitVertical { domain = 'CurrentPaneDomain' } },

  -- Leader: pane navigation
  { key = 'h', mods = 'LEADER', action = act.ActivatePaneDirection 'Left' },
  { key = 'j', mods = 'LEADER', action = act.ActivatePaneDirection 'Down' },
  { key = 'k', mods = 'LEADER', action = act.ActivatePaneDirection 'Up' },
  { key = 'l', mods = 'LEADER', action = act.ActivatePaneDirection 'Right' },

  -- Leader: pane management
  { key = 'x', mods = 'LEADER', action = act.CloseCurrentPane { confirm = false } },
  { key = 'z', mods = 'LEADER', action = act.TogglePaneZoomState },
  { key = 'm', mods = 'LEADER', action = act.TogglePaneZoomState },
  { key = 'f', mods = 'LEADER', action = act.TogglePaneZoomState },

  -- Leader: tab rename
  {
    key = ',',
    mods = 'LEADER',
    action = act.PromptInputLine {
      description = 'Rename tab',
      action = wezterm.action_callback(function(window, pane, line)
        if line then
          window:active_tab():set_title(line)
        end
      end),
    },
  },

  -- Leader: split-and-zoom apps
  { key = 'g', mods = 'LEADER', action = split_and_zoom('lazygit') },
  { key = 'y', mods = 'LEADER', action = split_and_zoom('yazi') },

  -- Leader: utilities
  { key = 'Space', mods = 'LEADER', action = act.QuickSelect },
  { key = 'o', mods = 'LEADER', action = act.ShowLauncherArgs { flags = 'FUZZY|WORKSPACES' } },
  { key = 'R', mods = 'LEADER|SHIFT', action = act.ReloadConfiguration },
  { key = 'D', mods = 'LEADER|SHIFT', action = act.CloseCurrentTab { confirm = false } },

  -- Leader: key tables
  { key = 'a', mods = 'LEADER', action = act.ActivateKeyTable { name = 'activate_pane', timeout_milliseconds = 1000 } },
  { key = 'p', mods = 'LEADER', action = act.ActivateKeyTable { name = 'resize_pane', one_shot = false } },
}

-- Key tables
config.key_tables = {
  activate_pane = {
    { key = 'h', action = act.ActivatePaneDirection 'Left' },
    { key = 'j', action = act.ActivatePaneDirection 'Down' },
    { key = 'k', action = act.ActivatePaneDirection 'Up' },
    { key = 'l', action = act.ActivatePaneDirection 'Right' },
  },
  resize_pane = {
    { key = 'h', action = act.AdjustPaneSize { 'Left', 1 } },
    { key = 'j', action = act.AdjustPaneSize { 'Down', 1 } },
    { key = 'k', action = act.AdjustPaneSize { 'Up', 1 } },
    { key = 'l', action = act.AdjustPaneSize { 'Right', 1 } },
    { key = 'Escape', action = 'PopKeyTable' },
  },
}

-- Keyboard protocol (enables Shift+Enter in Claude Code, etc.)
config.enable_kitty_keyboard = true

-- Window
config.window_padding = { left = 10, right = 10, top = 10, bottom = 10 }
config.window_decorations = 'RESIZE'
config.hide_tab_bar_if_only_one_tab = true
config.window_close_confirmation = 'NeverPrompt'

return config
