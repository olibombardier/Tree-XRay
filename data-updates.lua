require("blacklist")

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
  shift = {0, -3},
  width_in_frames = 1,
  height_in_frames = 1,
}

local changeSelectionBox = settings.startup["x-ray-tree-selection-box-affected"].value
local halfSelectionBox = settings.startup["x-ray-tree-selection-box"].value / 2

local specificSprites = {}
specificSprites["tree-01"] = {
  filename = "__Tree_XRay__/graphics/trees/tree-01.png",
  width = 45,
  height = 45,
  shift = {0, -0.8},
  width_in_frames = 1,
  height_in_frames = 1,
}
specificSprites["tree-02"] = {
  filename = "__Tree_XRay__/graphics/trees/tree-02.png",
  width = 38,
  height = 38,
  shift = {0, -1},
  width_in_frames = 1,
  height_in_frames = 1,
}
specificSprites["tree-02-red"] = specificSprites["tree-02"]
specificSprites["tree-03"] = {
  filename = "__Tree_XRay__/graphics/trees/tree-03.png",
  width = 52,
  height = 52,
  shift = {0, -1},
  width_in_frames = 1,
  height_in_frames = 1,
}
specificSprites["tree-04"] = {
  filename = "__Tree_XRay__/graphics/trees/tree-04.png",
  width = 58,
  height = 58,
  shift = {0, -1},
  width_in_frames = 1,
  height_in_frames = 1,
}
specificSprites["tree-05"] = {
  filename = "__Tree_XRay__/graphics/trees/tree-05.png",
  width = 31,
  height = 31,
  shift = {0, -1},
  width_in_frames = 1,
  height_in_frames = 1,
}
specificSprites["tree-06"] = {
  filename = "__Tree_XRay__/graphics/trees/tree-06.png",
  width = 55,
  height = 55,
  shift = {0, -1},
  width_in_frames = 1,
  height_in_frames = 1,
}
specificSprites["tree-06-brown"] = specificSprites["tree-06"]
specificSprites["tree-07"] = {
  filename = "__Tree_XRay__/graphics/trees/tree-07.png",
  width = 49,
  height = 50,
  shift = {0, -1},
  width_in_frames = 1,
  height_in_frames = 1,
}
specificSprites["tree-08"] = {
  filename = "__Tree_XRay__/graphics/trees/tree-08.png",
  width = 46,
  height = 46,
  shift = {0, -1},
  width_in_frames = 1,
  height_in_frames = 1,
}
specificSprites["tree-08-brown"] = specificSprites["tree-08"]
specificSprites["tree-08-red"] = specificSprites["tree-08"]
specificSprites["tree-09"] = {
  filename = "__Tree_XRay__/graphics/trees/tree-09.png",
  width = 87,
  height = 86,
  shift = {0, -2},
  width_in_frames = 1,
  height_in_frames = 1,
}
specificSprites["tree-09-brown"] = specificSprites["tree-09"]
specificSprites["tree-09-red"] = specificSprites["tree-09"]

local function createXrayTree(original)
  local newTree = table.deepcopy(original)
  newTree.name = newTree.name .. "-xray"
  if changeSelectionBox then
    newTree.selection_box = {{-halfSelectionBox, -halfSelectionBox}, {halfSelectionBox, halfSelectionBox}}
  end

  if newTree.variations then
    for index, variation in pairs(newTree.variations) do
      local frameCount = newTree.variations[index].leaves.frame_count
      newTree.variations[index].leaves = table.deepcopy(emptyAnim)
      newTree.variations[index].leaves.frame_count = frameCount
      newTree.variations[index].normal = nil
      newTree.variations[index].shadow = nil

      local trunk = specificSprites[original.name] or trunkSprite

      newTree.variations[index].trunk = { 
        width = trunk.width,
        height = trunk.height,
        frame_count = frameCount+1,
        stripes = {}
      }
      for i=0,frameCount do
        newTree.variations[index].trunk.stripes[i] = trunk
      end
    end
  end

  if newTree.pictures then
    for index, picture in pairs(newTree.pictures) do
      newTree.pictures[index] = trunkSprite
    end
  end

  data:extend{newTree}
end

for name, original in pairs(trees) do
  if not xrayTreeBlacklist[name] then
    createXrayTree(original)
  end
end