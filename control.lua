local xray = require("scripts.xray")

local function setupFrequency(frequency)
  storage.current_frequency = math.ceil(60 / frequency)
end

script.on_nth_tick(1, function(event)
  if event.tick % storage.current_frequency == 0 then
    xray.update()
  end
end)

local function init()
  xray.init()
  xray.setup()

  storage.player_xray_toggle = storage.player_xray_toggle or {}
  setupFrequency(settings.global["x-ray-frequency"].value)
end

script.on_init(function()
  init()
end)

script.on_configuration_changed(function()
  init()
end)

script.on_load(
  function()
    xray.setup()
  end
)

script.on_event(defines.events.on_runtime_mod_setting_changed,
  function(event)
    if event.setting == "x-ray-frequency" then
      local newValue = settings.global["x-ray-frequency"].value
      if newValue ~= storage.current_frequency then
        setupFrequency(newValue)
      end
    end
  end
)

--TODO cache players' radius and update when setting is changed

script.on_event(defines.events.on_player_changed_position,
  function(event)
    if storage.player_xray_toggle[event.player_index] then
      xray.check_player(event.player_index)
    end
  end
)

local function toggleXray(event)
  local newValue = not storage.player_xray_toggle[event.player_index]
  local player = game.get_player(event.player_index)
  if not player then return end

  if not newValue then --  put back normal trees for this play
    xray.clear_xray_source(player.index, player)
  else
    xray.check_player(event.player_index)
  end

  storage.player_xray_toggle[event.player_index] = newValue
  player.set_shortcut_toggled("x-ray-toggle", newValue)
end

---@param player_index int
---@return string
local function make_selection_id(player_index) return "selection-" .. tostring(player_index) end

---@param event EventData.on_lua_shortcut
local function deselect_all(event)
  local player = game.get_player(event.player_index)
  if player then
    xray.clear_xray_source(make_selection_id(event.player_index), player)
  end
end

script.on_event(defines.events.on_lua_shortcut,
  function(event)
    if event.prototype_name == "x-ray-toggle" then
      toggleXray(event)
    elseif event.prototype_name == "remove-x-ray-selection" then
      deselect_all(event)
    end
  end
)

script.on_event('toggle-x-ray', toggleXray)
script.on_event('remove-x-ray-selection', deselect_all)

script.on_event(defines.events.on_player_selected_area, function(event)
  if event.item ~= "x-ray-selection" then return end
  for _, tree in pairs(event.entities) do
    local player = game.get_player(event.player_index)
    xray.add_xray_source(tree, make_selection_id(event.player_index), player)
  end
end)

script.on_event({
    defines.events.on_player_alt_selected_area,
    defines.events.on_player_reverse_selected_area,
    defines.events.on_player_alt_reverse_selected_area },
  function(event)
    ---@cast event EventData.on_player_selected_area
    if event.item ~= "x-ray-selection" then return end
    for _, tree in pairs(event.entities) do
      if xray.is_xrayed(tree) then
        local player = game.get_player(event.player_index)
        xray.remove_xray_source(tree, make_selection_id(event.player_index), player)
      end
    end
  end)

script.on_event(defines.events.on_object_destroyed, function(event)
  local id = event.registration_number
  if xray.id_to_tree[id] then
    xray.id_to_tree[id] = nil
    xray.xrayed_trees[id] = nil
  end
end)
