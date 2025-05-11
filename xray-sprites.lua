xraySprites = {}

function add_tree_sprite(name, shift, width, height, options)
  options = options or {}
  xraySprites[name] = {
    filename = "__Tree_XRay__/graphics/trees/" .. (options.sprite_name or name) .. ".png",
    width = width,
    height = height,
    shift = shift,
  }
  if options.scale then
    xraySprites[name].scale = options.scale
  end
  if options.others then
    for _, other in pairs(options.others) do
      xraySprites[other] = xraySprites[name]
    end
  end
end

add_tree_sprite("tree-01", {0, -0.35}, 45, 45)
add_tree_sprite("tree-02", {0, -0.1}, 38, 38, {others = {"tree-02-red"}})
add_tree_sprite("tree-03", {0, -0.1}, 52, 52)
add_tree_sprite("tree-04", {0, -0.2}, 58, 58)
add_tree_sprite("tree-05", {0, -0.2}, 31, 31)
add_tree_sprite("tree-06", {0, 0}, 55, 55, {others = {"tree-06-brown"}})
add_tree_sprite("tree-07", {0, -0.2}, 49, 50)
add_tree_sprite("tree-08", {0, -0.25}, 46, 46, {others = {"tree-08-brown", "tree-08-red"}})
add_tree_sprite("tree-09", {0, -0.5}, 87, 86, {others = {"tree-09-brown", "tree-09-red"}})

if (mods and mods["alien-biomes"]) or (script and script.active_mods["alien-biomes"]) then
  require('mods.alien-biomes')
end