require("blacklist")
require("xray-sprites")

---@param str string
---@param ending string
---@return boolean
local function suffixed(str, ending) -- Taken from bulk-teleport
	return ending == "" or str:sub(-#ending) == ending
end

---Swaps a tree for a new one
---@param name string
---@param old LuaEntity
---@param player LuaPlayer
---@return LuaEntity?
local function swapTree(name, old, player)
  local newTree = old.surface.create_entity({
    name = name, 
    position = old.position,
    force = old.force,
    raise_built = false,
    create_build_effect_smoke = false,
    spawn_decorations = false
  })

  if not newTree then return nil end

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

---Turn a tree in its xray version
---@param tree LuaEntity
---@param player LuaPlayer
---@return LuaEntity?
local function xray_tree(tree, player)
  if not suffixed(tree.name, "-xray") and not xrayTreeBlacklist[tree.name] and xraySprites[tree.name] then
    local newTree = swapTree(tree.name .. "-xray", tree, player)
    if not newTree then return nil end

    tree.destroy({raise_destroy= false})

    if not storage.players_xray[player.index] then
      storage.players_xray[player.index] = {}
    end
    table.insert(storage.players_xray[player.index], newTree)

    return newTree
  end
end

--TODO Remove index -> table with entity as keys

---Turn an xrayed tree in its normal version
---@param tree LuaEntity
---@param player LuaPlayer
---@return LuaEntity?
local function unxray_tree(tree, player, index)
  local new_tree = swapTree(tree.name:sub(1, -6), tree, player)
  if not new_tree then return nil end

  tree.destroy({raise_destroy= false})

  storage.players_xray[player.index][index] = nil

  return new_tree
end

local function updatePlayerXray(playerIndex)
  local player = game.get_player(playerIndex)
  local radius = player.mod_settings["x-ray-tile-radius"].value
  local surface = player.surface

  local trees = surface.find_entities_filtered{position = player.position, radius = radius, type="tree"}
  for _, tree in ipairs(trees) do
    xray_tree(tree, player)
  end

  -- check already 'xrayed' trees
  if storage.players_xray[playerIndex] then
    local player = game.get_player(playerIndex)
    for index, tree in pairs(storage.players_xray[playerIndex]) do

      if tree.valid then
        local dx = tree.position.x - player.position.x
        local dy = tree.position.y - player.position.y

        if dx * dx + dy * dy > radius * radius then
          unxray_tree(tree, player, index)
        end
      else
        storage.players_xray[playerIndex][index] = nil
      end
    end
  end
end

local function setupFrequency(frequency)
  if storage.current_frequency then 
    script.on_nth_tick(math.ceil(60 / storage.current_frequency), nil)
  end

  script.on_nth_tick(math.ceil(60 / frequency),
    function()
      for playerIndex, moved in pairs(storage.moving_player) do
        if moved and storage.player_xray_toggle[playerIndex] then
          updatePlayerXray(playerIndex)
          storage.moving_player[playerIndex] = false
        end
      end
    end
  )

  storage.current_frequency = frequency
end

local function init()
    storage.players_xray = storage.players_xray or {}
    storage.moving_player = storage.moving_player or {}
    storage.player_xray_toggle = storage.player_xray_toggle or {}
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
      if newValue ~= storage.current_frequency then
        setupFrequency(newValue)
      end
    end
  end
)

--TODO cache players' radius and update when setting is changed

script.on_event(defines.events.on_player_changed_position,
  function(event)
    storage.moving_player[event.player_index] = true
  end
)

local function toggleXray(event)
  local newValue = not storage.player_xray_toggle[event.player_index]
  local player = game.get_player(event.player_index)

  if not newValue and storage.players_xray[event.player_index] then -- We put back normal trees for this player
    for index, tree in pairs(storage.players_xray[event.player_index]) do
      if tree.valid then
        swapTree(tree.name:sub(1, -6), tree, player.surface, player)

        tree.destroy({raise_destroy= false})
      end
      storage.players_xray[event.player_index][index] = nil
    end
  else 
    updatePlayerXray(event.player_index)
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

script.on_event(defines.events.on_player_selected_area, function (event)
  if event.item ~= "x-ray-selection" then return end
  for _, tree in pairs(event.entities) do
    local player = game.get_player(event.player_index)
    xray_tree(tree, player)
  end
end)

script.on_event({
      defines.events.on_player_alt_selected_area,
      defines.events.on_player_reverse_selected_area,
      defines.events.on_player_alt_reverse_selected_area},
      function (event)
  ---@cast event EventData.on_player_selected_area
  if event.item ~= "x-ray-selection" then return end
  for _, tree in pairs(event.entities) do
    if suffixed(tree.name, "-xray") then
      local player = game.get_player(event.player_index)
      local index = 0
      for i, xtree in pairs(storage.players_xray[player.index]) do
        if xtree == tree then index = i end
      end
      unxray_tree(tree, player, index)
    end
  end
end)