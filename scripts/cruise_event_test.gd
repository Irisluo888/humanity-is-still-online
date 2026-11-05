extends "res://scripts/phase1_route_test.gd"
func _initialize() -> void:call_deferred("run")
func snap(name: String) -> void:
 await frames();await RenderingServer.frame_post_draw
 check(root.get_texture().get_image().save_png("res://artifacts/cruise_events/"+name+".png")==OK,"capture "+name)
func key_f() -> void:
 var event=InputEventKey.new();event.physical_keycode=KEY_F;event.pressed=true;root.push_input(event,true)
 event=InputEventKey.new();event.physical_keycode=KEY_F;root.push_input(event,true)
 await frames()
func await_route(limit: int=6000) -> void:
 for i in range(limit):
  if current_scene.scene_file_path!="res://scenes/city_delivery.tscn":return
  if not current_scene.cruising and current_scene.cruise_label.text.begins_with("窗口失焦"):
   print("INFO: focus safety pause observed; test sends F to resume")
   await key_f()
   continue
  if not current_scene.cruising:
   print("CRUISE STOP: ",current_scene.cruise_label.text," / position ",current_scene.player.position," / target ",current_scene.planned_target," / index ",current_scene.path_index)
   return
  await physics_frame
 check(false,"cruise did not exceed timeout")
func find_button(node: Node,prefix: String) -> Button:
 if node is Button and node.text.begins_with(prefix):return node
 for child in node.get_children():
  var result=find_button(child,prefix)
  if result!=null:return result
 return null
func run() -> void:
 Engine.time_scale=3
 var w=root.get_node("WorldData");w.forced_story_roll=0.99;w.new_campaign()
 var meals: Array=[]
 for order in w.orders:meals.append(order.item)
 w.accept_order("day_1_order_002");w.accept_order("day_1_order_003");w.focus_order("day_1_order_001");w.depart()
 change_scene_to_file("res://scenes/city_delivery.tscn");await frames(30)
 check(current_scene.planner_ready,"physics collision grid prepared")
 check(current_scene.planner.path(Vector3(0,0,8),Vector3(6,0,-4)).size()>2,"planner finds nontrivial walkable route")
 await key_f();check(current_scene.cruising,"F starts cruise")
 await snap("01_cruise_route")
 Input.action_press("ui_right");await physics_frame;await physics_frame;release()
 check(not current_scene.cruising,"manual direction interrupts cruise")
 await key_f();await await_route()
 check(current_scene.scene_file_path=="res://scenes/city_delivery.tscn" and w.period=="day","cruise completes orders but never automatically closes day")
 if current_scene.scene_file_path!="res://scenes/city_delivery.tscn":quit(1);return
 check(not current_scene.cruising and current_scene.cruise_button.disabled,"finished queue stops and disables cruise")
 await walk(Vector2(0,2));await walk(Vector2(0,8));await press_e()
 check(current_scene.scene_file_path=="res://scenes/bedroom.tscn","manual return-home interaction still closes day")
 check(w.daytime_orders.size()==3 and is_equal_approx(w.income(),18.5),"cruise delivers all three exactly once")
 check(w.night_posts.size()==3,"miss roll produces no extra story post")
 w.mark_reviewed();check(w.rest(),"cruise day can rest")
 for i in range(3):check(w.orders[i+3].item!=meals[i],"next-day meal differs for route "+str(i))
 check(w.save_game("user://courier_variety_test.json"),"save changed daily menus")
 change_scene_to_file("res://scenes/desktop.tscn");await frames();current_scene.open_app("接单")
 await snap("05_next_day_orders")
 w.forced_story_roll=0.0;w.new_campaign();w.depart()
 change_scene_to_file("res://scenes/city_delivery.tscn");await frames(30)
 await key_f();await await_route()
 check(not w.pending_story().is_empty(),"hit roll triggers delivery vignette")
 check(current_scene.story_panel.visible and not current_scene.cruising,"event pauses cruise and displays choice")
 var event_id: String=w.pending_story().story_event
 check(w.save_game("user://courier_pending_test.json"),"save unresolved event and fixed draw")
 await snap("02_delivery_event")
 check(not w.return_home(),"pending event blocks closing day")
 find_button(current_scene.story_panel,"聊两句").pressed.emit();await frames()
 check(w.pending_story().is_empty() and w.clues.size()==1,"remember choice stores clue")
 check(not w.resolve_story("remember"),"choice cannot resolve twice")
 await key_f();await await_route()
 check(w.period=="day" and not current_scene.cruising,"resolving last-order event does not enable home cruise")
 await walk(Vector2(6,0));await walk(Vector2(0,2));await walk(Vector2(0,8));await press_e()
 check(w.period=="night" and w.night_posts.size()==2,"delivery and chosen event reveal at night")
 check(w.night_messages.size()==2,"event has linked night message")
 change_scene_to_file("res://scenes/desktop.tscn");await frames();current_scene.open_app("动态")
 for i in range(8):await process_frame
 var scroll=current_scene.windows["动态"].body.get_child(1);scroll.scroll_vertical=int(scroll.get_v_scroll_bar().max_value)
 await snap("03_event_night")
 check(w.save_game("user://courier_resolved_test.json"),"save resolved event")
 print("CRUISE EVENT FAILURES: ",failures)
 quit(1 if failures else 0)
