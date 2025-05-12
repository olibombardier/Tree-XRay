local xrayTreeBlacklist = require("blacklist")
local xraySprites = require("xray-sprites")

local trees = table.deepcopy(data.raw["tree"])

local emptyAnim = {
  filename = "__Tree_XRay__/graphics/empty.png",
  width = 1,
  height = 1,
  frame_count = 1
}

local trunkSprite = {
  filename = "__Tree_XRay__/graphics/tree-xray.png",
  width = 72,
  height = 73,
  shift = { 0, -3 },
  frame_count = 2
}

local changeSelectionBox = settings.startup["x-ray-tree-selection-box-affected"].value
local halfSelectionBox = settings.startup["x-ray-tree-selection-box"].value / 2

local function createXrayTree(original)
  local newTree = table.deepcopy(original)
  newTree.name = newTree.name .. "-xray"
  if changeSelectionBox then
    newTree.selection_box = { { -halfSelectionBox, -halfSelectionBox }, { halfSelectionBox, halfSelectionBox } }
  end

  if newTree.variations then
    for _, variation in pairs(newTree.variations) do
      local frameCount = variation.leaves.frame_count
      variation.leaves = table.deepcopy(emptyAnim)
      variation.normal = nil

      variation.leaves.frame_sequence = {}
      for i = 1, frameCount or 1 do
        variation.leaves.frame_sequence[i] = 1
      end

      local trunk = xraySprites[original.name] or trunkSprite
      variation.trunk = trunk
    end
  end

  if newTree.pictures then
    for index, picture in pairs(newTree.pictures) do
      newTree.pictures[index] = trunkSprite
    end
  end

  data:extend { newTree }
end

for name, original in pairs(trees) do
  if not xrayTreeBlacklist[name] and xraySprites[original.name] then
    createXrayTree(original)
  end
end
