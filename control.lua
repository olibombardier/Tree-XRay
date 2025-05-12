local xray = require("scripts.xray")

local function setupFrequency(frequency)
  if storage.current_frequency then
    script.on_nth_tick(math.ceil(60 / storage.current_frequency), nil)
  end

  script.on_nth_tick(math.ceil(60 / frequency),
    function()
      xray.update()
    end
  )

  storage.current_frequency = frequency
end

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

script.on_event(defines.events.on_lua_shortcut,
  function(event)
    if event.prototype_name == "x-ray-toggle" then
      toggleXray(event)
    end
  end
)

script.on_event('toggle-x-ray', toggleXray)

---@param player_index int
---@return string
local function make_selection_id(player_index) return "selection-" .. tostring(player_index) end

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
