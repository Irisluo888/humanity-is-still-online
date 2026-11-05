extends SceneTree
var failures := 0
func _initialize() -> void: call_deferred("run_checks")
func check(value: bool, title: String) -> void:
 if value: print("PASS: ",title)
 else: failures += 1; push_error(title)
func frames() -> void:
 for i in range(8): await process_frame
func key(code: int, pressed: bool) -> void:
 var event = InputEventKey.new()
 event.physical_keycode = code
 event.pressed = pressed
 root.push_input(event,true)
func snap(name: String) -> void:
 await frames()
 await RenderingServer.frame_post_draw
 var result = root.get_texture().get_image().save_png("res://artifacts/third_round_preview/"+name+".png")
 check(result == OK,"runtime screenshot "+name)
func run_checks() -> void:
 root.size = Vector2i(1280,720)
 change_scene_to_file("res://scenes/bedroom.tscn")
 await frames()
 var room = current_scene
 room.set_process(false)
 check(room.can_stand(room.player_uv),"spawn is on open floor")
 check(room.terminal_button.disabled,"computer disabled away from desk")
 key(KEY_E,true); key(KEY_E,false)
 await frames()
 check(current_scene==room,"E cannot open computer remotely")
 await snap("13_room_movement")
 var before: Vector2 = room.get_child(1).position
 key(KEY_D,true)
 for i in range(8): room._process(0.05)
 key(KEY_D,false)
 check(room.get_child(1).position.x > before.x+30,"D input moves right on screen")
 before = room.player_uv
 room._process(0.05)
 check(room.player_uv==before,"key release stops movement")
 key(KEY_LEFT,true)
 for i in range(8): room._process(0.05)
 key(KEY_LEFT,false)
 check(room.player_uv.distance_to(Vector2(150,180))<2,"arrow key returns along path")
 room.move_floor(Vector2(500,500))
 check(room.can_stand(room.player_uv) and room.player_uv.x<212 and room.player_uv.y<213,"large step cannot leave walk area")
 room.player_uv = Vector2(95,195)
 room.move_floor(Vector2(-25,20))
 check(room.can_stand(room.player_uv),"delivery box blocks crossing")
 check(not room.can_stand(Vector2(58,180)),"chair footprint is blocked")
 check(not room.can_stand(Vector2(150,100)),"bed/back area remains closed until depth layers exist")
 room.player_uv = Vector2(150,180)
 room.move_floor(Vector2(-55,-5))
 check(room.is_near_computer() and not room.terminal_button.disabled,"walk to desk enables interaction")
 await snap("14_room_near_computer")
 root.size = Vector2i(1920,1080)
 await snap("15_room_1080p")
 key(KEY_W,true)
 room._notification(Node.NOTIFICATION_APPLICATION_FOCUS_OUT)
 check(room.held.is_empty(),"focus loss clears held keys")
 key(KEY_E,true); key(KEY_E,false)
 await frames()
 check(current_scene.scene_file_path=="res://scenes/desktop.tscn","E enters desktop when near")
 change_scene_to_file("res://scenes/bedroom.tscn")
 await frames()
 check(current_scene.player_uv.distance_to(Vector2(95,175))<1,"return to room retains session position")
 print("ROOM WALK FAILURES: ",failures)
 quit(0 if failures==0 else 1)
