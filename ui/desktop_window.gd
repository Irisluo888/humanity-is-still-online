extends PanelContainer
signal closed
signal minimized
var dragging := false
var offset := Vector2.ZERO
var body: HBoxContainer
func setup(title: String) -> void:
 custom_minimum_size = Vector2(740, 410)
 size = custom_minimum_size
 var col = VBoxContainer.new()
 add_child(col)
 var bar = HBoxContainer.new()
 col.add_child(bar)
 var handle = Label.new()
 handle.text = "  " + title + "  /  本地缓存"
 handle.size_flags_horizontal = Control.SIZE_EXPAND_FILL
 handle.mouse_filter = Control.MOUSE_FILTER_STOP
 bar.add_child(handle)
 handle.gui_input.connect(func(event: InputEvent):
  if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
   dragging = event.pressed
   offset = get_global_mouse_position() - position
   move_to_front()
 )
 for caption in ["_", "×"]:
  var b = Button.new()
  b.text = caption
  bar.add_child(b)
  if caption == "_": b.pressed.connect(func(): hide(); minimized.emit())
  else: b.pressed.connect(func(): closed.emit())
 body = HBoxContainer.new()
 body.size_flags_vertical = Control.SIZE_EXPAND_FILL
 col.add_child(body)
 gui_input.connect(func(event: InputEvent):
  if event is InputEventMouseButton and event.pressed: move_to_front()
 )
func _input(event: InputEvent) -> void:
 if event is InputEventMouseButton and not event.pressed: dragging = false
 if event is InputEventMouseMotion and dragging:
  var target = get_global_mouse_position() - offset
  position = Vector2(clampf(target.x, 0, maxf(0, get_viewport_rect().size.x-size.x)), clampf(target.y, 0, maxf(0, get_viewport_rect().size.y-size.y-48)))
