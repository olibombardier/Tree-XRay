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
    associated_control_input = "toggle-x-ray"
  },
}