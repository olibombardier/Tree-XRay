require("blacklist")

local function suffixed(str, ending) -- Taken from bulk-teleport
	return ending == "" or str:sub(-#ending) == ending
end

local function swapTree(name, old, surface)
  local newTree = surface.create_entity({
    name = name, 
    position = old.position,
    force = old.force,
    raise_built = false,
    create_build_effect_smoke = false,
    spawn_decorations = false
  })

  if old.to_be_deconstructed() then
    newTree.order_deconstruction(player.force, player)
  end

  if newTree.tree_color_index_max > 0 then
    newTree.tree_color_index = old.tree_color_index
    newTree.tree_stage_index = old.tree_stage_index
  end

  if newTree.tree_gray_stage_index_max > 0 then
    newTree.tree_gray_stage_index = old.tree_gray_stage_index
  end

  return newTree
end

local function updatePlayerXray(playerIndex)
  local player = game.get_player(playerIndex)
  local radius = player.mod_settings["x-ray-tile-radius"].value
  local radiusSqr = radius * radius
  local surface = player.surface

  local trees = surface.find_entities_filtered{position = player.position, radius = radius, type="tree"}

  for _, tree in ipairs(trees) do
    if not suffixed(tree.name, "-xray") and not xrayTreeBlacklist[tree.name] then
      local newTree = swapTree(tree.name .. "-xray", tree, surface)

      tree.destroy({raise_destroy = false})

      if not global.players_xray[playerIndex] then
        global.players_xray[playerIndex] = {}
      end
      table.insert(global.players_xray[playerIndex], newTree)
    end
  end

  -- check already 'xrayed' trees
  if global.players_xray[playerIndex] then
    for index, tree in pairs(global.players_xray[playerIndex]) do

      if tree.valid then
        local dx = tree.position.x - player.position.x
        local dy = tree.position.y - player.position.y

        if (dx * dx) + (dy * dy) > radiusSqr or surface ~= tree.surface then
          swapTree(tree.name:sub(1, -6), tree, tree.surface)

          tree.destroy({raise_destroy = false})

          global.players_xray[playerIndex][index] = nil
        end
      else
        global.players_xray[playerIndex][index] = nil
      end
    end
  end
end

local function setupFrequency(frequency) 
  if global.current_frequency then 
    script.on_nth_tick(math.ceil(60 / global.current_frequency), nil)
  end

  script.on_nth_tick(math.ceil(60 / frequency),
    function()
      for playerIndex, moved in pairs(global.moving_player) do
        if moved and global.player_xray_toggle[playerIndex] then
          updatePlayerXray(playerIndex)
          global.moving_player[playerIndex] = false
        end
      end
    end
  )

  global.current_frequency = frequency
end

local function init()
    global.players_xray = global.players_xray or {}
    global.moving_player = global.moving_player or {}
    global.player_xray_toggle = global.player_xray_toggle or {}
    setupFrequency(settings.global["x-ray-frequency"].value)
end

script.on_init(
  function()
    init()
  end
)

script.on_load(
  function()
    init()
  end
)

script.on_event(defines.events.on_runtime_mod_setting_changed, 
  function(event)
    if event.setting == "x-ray-frequency" then
      local newValue = settings.global["x-ray-frequency"].value
      if newValue ~= global.current_frequency then
        setupFrequency(newValue)
      end
    end
  end
)

--TODO cache players' radius and update when setting is changed

script.on_event(defines.events.on_player_changed_position,
  function(event)
    global.moving_player[event.player_index] = true
  end
)

local function toggleXray(event)
  local newValue = not global.player_xray_toggle[event.player_index]
  local player = game.get_player(event.player_index)

  if not newValue and global.players_xray[event.player_index] then -- We put back normal trees for this player
    for index, tree in pairs(global.players_xray[event.player_index]) do
      if tree.valid then
        swapTree(tree.name:sub(1, -6), tree, tree.surface)

        tree.destroy({raise_destroy= false})
      end
      global.players_xray[event.player_index][index] = nil
    end
  else 
    updatePlayerXray(event.player_index)
  end

  global.player_xray_toggle[event.player_index] = newValue
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