data:extend{
  {
    type = "custom-input",
    name = "toggle-x-ray",
    key_sequence = "CONTROL + T"
  },
  {
    type = "shortcut",
    name = "x-ray-toggle",
    action = "lua",
    icon = "__Tree_XRay__/graphics/icon/x-ray-x32.png",
    icon_size = 32,
    small_icon = "__Tree_XRay__/graphics/icon/x-ray-x32.png",
    small_icon_size = 32,
    toggleable = true,
    associated_control_input = "toggle-x-ray",
    order = "xray-a"
  },
  {
    type = "selection-tool",
    stack_size = 1,
    name = "x-ray-selection",
    select = {
      border_color = {r = 0, g = 0.9, b=0},
      cursor_box_type = "entity",
      mode = "trees"
    },
    alt_select = {
      border_color = {r = 0.9, g = 0.2, b=0},
      cursor_box_type = "entity",
      mode = "trees"
    },
    icon = "__Tree_XRay__/graphics/icon/x-ray-selection.png",
    icon_size = 64,
    small_icon = "__Tree_XRay__/graphics/icon/x-ray-selection.png",
    small_icon_size = 64,
    flags = {"only-in-cursor", "not-stackable", "spawnable"},
    auto_recycle = false,
    hidden = true
  },
  {
    type = "custom-input",
    name = "give-x-ray-selection",
    key_sequence = "ALT + D",
    consuming = "game-only",
    item_to_spawn = "x-ray-selection",
    action = "spawn-item"
  },
  {
    type = "shortcut",
    name = "give-x-ray-selection",
    order = "xray-b",
    localised_name = {"shortcut.give-x-ray-selection"},
    associated_control_input = "give-x-ray-selection",
    action = "spawn-item",
    item_to_spawn = "x-ray-selection",
    icon = "__Tree_XRay__/graphics/icon/x-ray-selection.png",
    icon_size = 64,
    small_icon = "__Tree_XRay__/graphics/icon/x-ray-selection.png",
    small_icon_size = 64,
  }
}