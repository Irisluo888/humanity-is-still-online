extends SceneTree
var failures:=0
func _initialize() -> void: call_deferred("prepare_regression")
func prepare_regression() -> void:
 root.get_node("WorldData").forced_story_roll=0.99
 run()
func check(value: bool,text: String) -> void:
 print(("PASS: " if value else "FAIL: ")+text)
 if not value: failures+=1
func frames(count: int=8) -> void:
 for i in range(count): await process_frame
func release() -> void:
 for action in ["ui_left","ui_right","ui_up","ui_down"]: Input.action_release(action)
func walk(target: Vector2) -> void:
 var city=current_scene
 for i in range(1800):
  var delta=target-Vector2(city.player.position.x,city.player.position.z)
  if delta.length()<0.25: break
  release()
  var x=delta.x-delta.y; var y=delta.x+delta.y
  if abs(x)>0.15: Input.action_press("ui_right" if x>0 else "ui_left")
  if abs(y)>0.15: Input.action_press("ui_down" if y>0 else "ui_up")
  await physics_frame
 release()
 check(target.distance_to(Vector2(city.player.position.x,city.player.position.z))<0.4,"walk reaches "+str(target))
func press_e() -> void:
 var event=InputEventKey.new(); event.physical_keycode=KEY_E; event.pressed=true; root.push_input(event,true)
 event=InputEventKey.new(); event.physical_keycode=KEY_E; event.pressed=false; root.push_input(event,true)
 await frames()
func snap(name: String) -> void:
 await frames(); await RenderingServer.frame_post_draw
 check(root.get_texture().get_image().save_png("res://artifacts/phase1/"+name+".png")==OK,"capture "+name)
func run() -> void:
 Engine.time_scale=5
 var w=root.get_node("WorldData"); w.new_campaign(); w.depart()
 change_scene_to_file("res://scenes/city_delivery.tscn"); await frames()
 await walk(Vector2(0,7.5)); await walk(Vector2(-0.8,7.5)); await walk(Vector2(-0.8,0)); await walk(Vector2(-7,0)); await walk(Vector2(-7,2)); await press_e()
 check(w.current_order().status=="配送中","E picks up at shop")
 await walk(Vector2(-5,2)); await press_e(); check(w.inventory.food==1,"food pickup")
 await walk(Vector2(-5,0)); await walk(Vector2(-2,0.5)); await press_e(); check(w.inventory.water==1,"water pickup")
 await walk(Vector2(3,0.5)); await press_e(); check(w.inventory.medicine==1,"medicine pickup")
 await walk(Vector2(6,0)); await walk(Vector2(6,-3.8)); await press_e()
 check(w.current_order().status=="已送达","E delivers at customer")
 await snap("route_delivered")
 await walk(Vector2(6,0)); await walk(Vector2(0,2)); await walk(Vector2(0,8)); await press_e()
 check(current_scene.scene_file_path=="res://scenes/bedroom.tscn" and w.period=="night","return home changes to night")
 await snap("route_night")
 # Continue through the room's real key event handling, not a state teleport.
 var room=current_scene
 for i in range(600):
  if room.is_near_computer(): break
  var offset=Vector2(95,175)-room.player_uv
  var screen=Vector2(2*(offset.x-offset.y),offset.x+offset.y)
  for code in [KEY_A,KEY_D,KEY_W,KEY_S]:
   var event=InputEventKey.new();event.physical_keycode=code
   event.pressed=(code==KEY_A and screen.x < -2) or (code==KEY_D and screen.x>2) or (code==KEY_W and screen.y < -2) or (code==KEY_S and screen.y>2)
   root.push_input(event,true)
  await process_frame
 for code in [KEY_A,KEY_D,KEY_W,KEY_S]:
  var event=InputEventKey.new();event.physical_keycode=code;event.pressed=false;root.push_input(event,true)
 check(room.is_near_computer(),"room movement approaches computer")
 await press_e()
 check(current_scene.scene_file_path=="res://scenes/desktop.tscn","E opens computer")
 if current_scene.scene_file_path=="res://scenes/desktop.tscn":
  current_scene.open_app("消息"); await snap("route_messages")
  check(w.reviewed,"message review gate completed")
 change_scene_to_file("res://scenes/bedroom.tscn");await frames()
 check(w.rest() and w.day==2,"rest advances to day 2")
 check(w.save_game("user://phase1_route_test.json"),"save complete route")
 print("ROUTE FAILURES: ",failures)
 quit(1 if failures else 0)
