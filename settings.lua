data:extend({
  {
      type = "int-setting",
      name = "x-ray-tile-radius",
      setting_type = "runtime-per-user",
      minimum_value = 1,
      default_value = 15
  },
  {
    type = "int-setting",
    name = "x-ray-frequency",
    setting_type = "runtime-global",
    minimum_value = 1,
    maximum_value = 60,
    default_value = 6
  },
  {
    type = "bool-setting",
    name = "x-ray-tree-selection-box-affected",
    setting_type = "startup",
    default_value = true,
    order = "a"
  },
  {
    type = "double-setting",
    name = "x-ray-tree-selection-box",
    setting_type = "startup",
    minimum_value = 0,
    maximum_value = 2,
    default_value = 1.1,
    order = "b"
  }
})