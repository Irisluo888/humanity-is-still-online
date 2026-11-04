extends RefCounted
static func label(text: String, size: int = 20) -> Label:
 var n = Label.new()
 n.text = text
 n.add_theme_font_size_override("font_size", size)
 n.add_theme_color_override("font_color", Color("d6dce1"))
 return n
static func button(text: String, action: Callable) -> Button:
 var b = Button.new()
 b.text = text
 b.custom_minimum_size = Vector2(150, 32)
 b.pressed.connect(action)
 return b
static func base(root: Control) -> VBoxContainer:
 var bg = ColorRect.new()
 bg.color = Color("303747")
 bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 root.add_child(bg)
 var margin = MarginContainer.new()
 margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 for side in ["left", "right", "top", "bottom"]:
  margin.add_theme_constant_override("margin_" + side, 36)
 root.add_child(margin)
 var box = VBoxContainer.new()
 box.add_theme_constant_override("separation", 14)
 margin.add_child(box)
 return box
