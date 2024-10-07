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
    icon = {
      filename = "__Tree_XRay__/graphics/icon/x-ray-x32.png",
      width = 32,
      height = 32,
    },
    toggleable = true,
    associated_control_input = "toggle-x-ray"
  },
}