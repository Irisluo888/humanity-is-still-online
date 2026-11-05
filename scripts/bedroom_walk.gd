extends "res://scripts/bedroom_refined.gd"
# Navigation uses the same 2:1 isometric floor coordinates as the authored PNG.
static var saved_position := Vector2(150,180)
var player_uv := Vector2(150,180)
var held: Dictionary = {}
var navigation: Dictionary
var terminal_button: Button
var hint: Label
var transitioning := false
func _ready() -> void:
 super._ready()
 navigation = JSON.parse_string(FileAccess.get_file_as_string("res://data/room_navigation.json"))
 player_uv = saved_position if can_stand(saved_position) else Vector2(150,180)
 terminal_button = get_child(3)
 for connection in terminal_button.pressed.get_connections():
  terminal_button.pressed.disconnect(connection.callable)
 terminal_button.pressed.connect(use_computer)
 hint = Label.new()
 hint.position = Vector2(28,88)
 hint.add_theme_font_size_override("font_size",16)
 add_child(hint)
 update_actor()
func _input(event: InputEvent) -> void:
 if event is InputEventKey:
  var key: int = event.physical_keycode if event.physical_keycode != 0 else event.keycode
  if key in [KEY_W,KEY_A,KEY_S,KEY_D,KEY_UP,KEY_LEFT,KEY_DOWN,KEY_RIGHT]:
   held[key] = event.pressed
   get_viewport().set_input_as_handled()
  elif key == KEY_E and event.pressed and not event.echo:
   get_viewport().set_input_as_handled()
   use_computer()
func _notification(what: int) -> void:
 if what == NOTIFICATION_APPLICATION_FOCUS_OUT: held.clear()
func down(a: int,b: int) -> float:
 return 1.0 if held.get(a,false) or held.get(b,false) else 0.0
func _process(delta: float) -> void:
 if navigation == null or transitioning: return
 var direction = Vector2(down(KEY_D,KEY_RIGHT)-down(KEY_A,KEY_LEFT),down(KEY_S,KEY_DOWN)-down(KEY_W,KEY_UP))
 if direction.is_zero_approx(): return
 var screen_step = direction.normalized()*float(navigation.speed)*minf(delta,0.05)
 # Screen-space speed is constant, including diagonals; inverse floor projection.
 move_floor(Vector2(screen_step.x/4.0+screen_step.y/2.0,screen_step.y/2.0-screen_step.x/4.0))
func can_stand(point: Vector2) -> bool:
 var bounds: Array = navigation.walk_area
 if not Rect2(bounds[0]+3,bounds[1]+3,bounds[2]-6,bounds[3]-6).has_point(point): return false
 for item in navigation.obstacles:
  if Rect2(item[0]-3,item[1]-3,item[2]+6,item[3]+6).has_point(point): return false
 return true
func move_floor(offset: Vector2) -> void:
 # Small steps prevent tunnelling through furniture, with sliding along edges.
 var steps = maxi(1,int(ceil(offset.length()/1.5)))
 var step = offset/steps
 for i in range(steps):
  var next = player_uv+Vector2(step.x,0)
  if can_stand(next): player_uv = next
  next = player_uv+Vector2(0,step.y)
  if can_stand(next): player_uv = next
 saved_position = player_uv
 update_actor()
func is_near_computer() -> bool:
 return player_uv.distance_to(Vector2(navigation.terminal[0],navigation.terminal[1])) <= float(navigation.interaction_radius)
func update_actor() -> void:
 var feet = Vector2(640+2*(player_uv.x-player_uv.y),208+player_uv.x+player_uv.y)
 get_child(1).position = (feet-Vector2(48,186)).round()
 var nearby = is_near_computer()
 terminal_button.disabled = not nearby
 terminal_button.text = "使用电脑 / E 进入桌面" if nearby else "使用电脑 / 请先靠近电脑桌"
 hint.text = "WASD / 方向键移动 · E 使用电脑\n" + ("电脑就在手边，按 E 开始调查。" if nearby else "先往左上方的电脑桌走。活动范围：床前与电脑前。")
func use_computer() -> void:
 if transitioning or not is_near_computer(): return
 transitioning = true
 held.clear()
 saved_position = player_uv
 get_tree().change_scene_to_file("res://scenes/desktop.tscn")
