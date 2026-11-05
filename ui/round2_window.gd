extends PanelContainer
signal closed
signal minimized
signal focus_requested
var body: HBoxContainer
var titlebar: PanelContainer
var dragging := false
var offset := Vector2.ZERO
var caption: Label
func setup(title: String) -> void:
 custom_minimum_size = Vector2(560,400)
 mouse_filter = Control.MOUSE_FILTER_STOP
 var border = StyleBoxFlat.new()
 border.bg_color = Color("2a394c")
 border.border_color = Color("8c9ca9")
 border.set_border_width_all(2)
 border.shadow_color = Color(0.04,0.06,0.1,0.55)
 border.shadow_size = 8
 border.shadow_offset = Vector2(5,6)
 add_theme_stylebox_override("panel",border)
 var col = VBoxContainer.new()
 col.add_theme_constant_override("separation",0)
 add_child(col)
 titlebar = PanelContainer.new()
 col.add_child(titlebar)
 var bar = HBoxContainer.new()
 titlebar.add_child(bar)
 caption = Label.new()
 caption.text = "  " + title + "  /  LOCAL"
 caption.add_theme_font_size_override("font_size",17)
 caption.custom_minimum_size.y = 32
 caption.size_flags_horizontal = Control.SIZE_EXPAND_FILL
 caption.mouse_filter = Control.MOUSE_FILTER_STOP
 bar.add_child(caption)
 caption.gui_input.connect(func(event: InputEvent):
  if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
   dragging = event.pressed
   offset = caption.get_global_transform() * event.position - position
   if event.pressed: focus_requested.emit()
 )
 for control in ["minimize","close"]:
  var b = Button.new()
  b.icon = load("res://assets/pixel_desktop/" + control + ".png")
  b.custom_minimum_size = Vector2(28,28)
  var control_style = StyleBoxFlat.new()
  control_style.bg_color = Color("344b62")
  control_style.border_color = Color("91a5b1")
  control_style.set_border_width_all(1)
  b.add_theme_stylebox_override("normal",control_style)
  bar.add_child(b)
  if control == "close": b.pressed.connect(func(): closed.emit())
  else: b.pressed.connect(func(): dragging = false; hide(); minimized.emit())
 body = HBoxContainer.new()
 body.add_theme_constant_override("separation",1)
 body.size_flags_vertical = Control.SIZE_EXPAND_FILL
 col.add_child(body)
 set_active(true)
func set_active(active: bool) -> void:
 var style = StyleBoxFlat.new()
 style.bg_color = Color("496581") if active else Color("343e50")
 style.border_color = Color("91a5b1") if active else Color("586575")
 style.border_width_bottom = 1
 titlebar.add_theme_stylebox_override("panel",style)
func clamp_to_screen() -> void:
 var area = get_viewport_rect().size
 position = Vector2(clampf(position.x,0,maxf(0,area.x-size.x)),clampf(position.y,0,maxf(0,area.y-size.y-46)))
func _input(event: InputEvent) -> void:
 if event is InputEventMouseButton and not event.pressed: dragging = false
 if event is InputEventMouseMotion and dragging and visible:
  position = event.position - offset
  clamp_to_screen()
