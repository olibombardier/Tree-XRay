local blacklist = require("blacklist")
local sprites = require("xray-sprites")

local xray = {}

---@type table<LuaEntity, table<(int|string), int>>
xray.xrayed_trees = {}

---@type table<int|string, table<LuaEntity, int>>
xray.xray_sources = {}

---@type table<int, true>
xray.players_to_check = {}

---Setups local references to storage
function xray.init()
  storage.xrayed_trees = storage.xrayed_trees or {}
  storage.xray_sources = storage.xray_sources or {}
end

function xray.setup()
  xray.xrayed_trees = storage.xrayed_trees
  xray.xray_sources = storage.xray_sources
end

---register a player to be checked at the next update
---@param player_index int
function xray.check_player(player_index)
  xray.players_to_check[player_index] = true
end

---turn xrayed trees around the player back to normal
---@param source int|string
---@param player LuaPlayer
function xray.clear_xray_source(source, player)
  if type(source) == "number" then
    xray.players_to_check[source] = nil
  end

  local sources = xray.xray_sources[source]
  if sources then
    for tree in pairs(sources) do
      xray.remove_xray_source(tree, source, player)
    end
  end
end

---Turn a treee into a new one, keeping its values the same where possible
---@param tree LuaEntity
---@param new_tree_name string
---@return LuaEntity
function xray.swap_tree(tree, new_tree_name, player)
  local new_tree = tree.surface.create_entity({
    name = new_tree_name,
    position = tree.position,
    force = tree.force,
    raise_built = false,
    create_build_effect_smoke = false,
    spawn_decorations = false
  })

  if not new_tree then error("Tree could not be made") end

  if tree.to_be_deconstructed() then
    new_tree.order_deconstruction(player.force, player)
  end

  if new_tree.tree_color_index_max > 0 then
    new_tree.tree_color_index = tree.tree_color_index
    new_tree.tree_stage_index = tree.tree_stage_index
  end

  if new_tree.tree_gray_stage_index_max > 0 then
    new_tree.tree_gray_stage_index = tree.tree_gray_stage_index
  end

  tree.destroy({ raise_destroy = false })
  return new_tree
end

---@param tree LuaEntity
---@return boolean
function xray.is_xrayed(tree)
  return tree.name:sub(-5) == "-xray"
end

---Adds an xray source to a tree, turning it into its xrayed form if necessary
---@param tree LuaEntity
---@param source (int|string)
---@param player LuaPlayer
function xray.add_xray_source(tree, source, player)
  local sources = xray.xrayed_trees[tree] or {}

  if not xray.is_xrayed(tree) then
    if not sprites[tree.name] or blacklist[tree.name] then return end
    tree = xray.swap_tree(tree, tree.name .. "-xray", player)
  end

  local tick = game.tick
  sources[source] = tick

  xray.xrayed_trees[tree] = sources
  xray.xray_sources[source] = xray.xray_sources[source] or {}
  xray.xray_sources[source][tree] = tick
end

---Removes an xray source to a xrayed tree, turning it back to normal if no sources remain
---@param tree LuaEntity
---@param source (int|string)
---@param player LuaPlayer
function xray.remove_xray_source(tree, source, player)
  if not tree.valid then
    xray.xrayed_trees[tree] = nil
    return
  end
  local sources = xray.xrayed_trees[tree]
  if not sources or not xray.is_xrayed(tree) then return end

  sources[source] = nil

  if table_size(sources) == 0 then
    --turn the tree back to normal
    xray.xrayed_trees[tree] = nil
    xray.swap_tree(tree, tree.name:sub(1, -6), player)
  end

  if xray.xray_sources[source] then
    xray.xray_sources[source][tree] = nil
  end
end

function xray.update()
  for player_id in pairs(xray.players_to_check) do
    local player = game.get_player(player_id)

    if not player then
      xray.players_to_check[player_id] = nil
    else
      local position = player.position
      local radius = player.mod_settings["x-ray-tile-radius"].value
      local radius_sqr = radius * radius
      ---@cast radius number

      local trees = player.surface.find_entities_filtered { position = position, radius = radius, type = "tree" }

      for _, tree in pairs(trees) do
        xray.add_xray_source(tree, player_id, player)
      end

      local tick = game.tick
      local sources = xray.xray_sources[player_id] or {}
      for tree, tree_tick in pairs(sources) do
        if not tree.valid then
          sources[tree] = nil
        elseif tree_tick < tick then
          local tree_position = tree.position
          local dx = tree_position.x - position.x
          local dy = tree_position.y - position.y

          if dx * dx + dy * dy > radius_sqr then
            xray.remove_xray_source(tree, player_id, player)
          end
        end
      end
    end
  end
end

return xray
