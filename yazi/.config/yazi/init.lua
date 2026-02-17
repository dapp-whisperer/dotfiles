-- Disable mouse click actions in Yazi.
--
-- Using `reveal` here can change the current directory when the clicked item
-- is outside the active folder (for example, parent pane items), which feels
-- like random directory jumps.
function Entity:click(event, up)
  return
end
