local wezterm = require("wezterm")

local M = {}
local initialized = false

local STATE_PRIORITY = {
  ["off"] = 0,
  ["running"] = 1,
  ["done"] = 2,
  ["needs-input"] = 3,
}

local STATE_STYLE = {
  ["running"] = {
    badge = "[..]",
    color = "#89b4fa",
  },
  ["done"] = {
    badge = "[ok]",
    color = "#a6e3a1",
  },
  ["needs-input"] = {
    badge = "[!]",
    color = "#f9e2af",
  },
}

local function normalize_state(value)
  if STATE_PRIORITY[value] ~= nil then
    return value
  end

  return "off"
end

local function tab_title(tab)
  if tab.tab_title and #tab.tab_title > 0 then
    return tab.tab_title
  end

  if tab.active_pane and tab.active_pane.title and #tab.active_pane.title > 0 then
    return tab.active_pane.title
  end

  return "shell"
end

local function aggregated_tab_state(tab)
  local best_state = "off"
  local best_priority = STATE_PRIORITY[best_state]

  for _, pane in ipairs(tab.panes or {}) do
    local state = normalize_state((pane.user_vars or {}).agent_state)
    local priority = STATE_PRIORITY[state]

    if priority > best_priority then
      best_state = state
      best_priority = priority
    end
  end

  if best_priority == 0 and tab.active_pane then
    local active_state = normalize_state((tab.active_pane.user_vars or {}).agent_state)
    if STATE_PRIORITY[active_state] > best_priority then
      best_state = active_state
    end
  end

  return best_state
end

local function truncate_title(text, max_width)
  if not max_width or max_width <= 0 then
    return text
  end

  return wezterm.truncate_right(text, max_width)
end

function M.setup()
  if initialized then
    return M
  end

  wezterm.on("format-tab-title", function(tab, _, _, _, _, max_width)
    local state = aggregated_tab_state(tab)
    local title = tab_title(tab)
    local style = STATE_STYLE[state]

    if not style then
      return " " .. truncate_title(title, math.max(max_width - 2, 1)) .. " "
    end

    local text = string.format(" %s %s ", style.badge, title)
    return {
      { Foreground = { Color = style.color } },
      { Text = truncate_title(text, max_width) },
    }
  end)

  wezterm.on("user-var-changed", function(window, _, name, value)
    if name == "agent_state" and (value == "done" or value == "needs-input") then
      window:toast_notification("agent-notify", "Agent " .. value, nil, 5000)
    end
  end)

  initialized = true
  return M
end

function M.apply_to_config(_)
  return M.setup()
end

return M
