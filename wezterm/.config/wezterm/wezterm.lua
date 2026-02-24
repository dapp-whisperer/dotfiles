local wezterm = require 'wezterm'
local config = wezterm.config_builder()

-- Theme
config.color_scheme = 'Catppuccin Mocha'

-- Font
config.font = wezterm.font 'JetBrains Mono'
config.font_size = 13.5
config.line_height = 1.08

config.background = {
  {
    source = { File = wezterm.home_dir .. '/.config/wezterm/background.jpg' },
    hsb = { brightness = 0.32, saturation = 1.0, hue = 1.0 },
    opacity = 1.0,
    width = '100%',
    height = '100%',
  },
  {
    source = { Color = '#1e1e2e' }, -- Catppuccin Mocha base
    opacity = 0.84,
    width = '100%',
    height = '100%',
  },
}
config.macos_window_background_blur = 28

-- Window
config.window_padding = { left = 10, right = 10, top = 10, bottom = 10 }
config.window_decorations = 'RESIZE'
config.hide_tab_bar_if_only_one_tab = true
config.window_close_confirmation = 'NeverPrompt'

return config
