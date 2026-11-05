extends "res://scripts/phase1_route_test.gd"
func snap(name: String) -> void:
 await frames();await RenderingServer.frame_post_draw
 check(root.get_texture().get_image().save_png("res://artifacts/phase2_delivery/"+name+".png")==OK,"capture "+name)
func find_button(node: Node,prefix: String) -> Button:
 if node is Button and node.text.begins_with(prefix):return node
 for child in node.get_children():
  var result=find_button(child,prefix)
  if result!=null:return result
 return null
func press_tab() -> void:
 var event=InputEventKey.new();event.physical_keycode=KEY_TAB;event.pressed=true;root.push_input(event,true)
 event=InputEventKey.new();event.physical_keycode=KEY_TAB;event.pressed=false;root.push_input(event,true)
 await frames()
func shop_path() -> void:
 await walk(Vector2(-0.8,7.5));await walk(Vector2(-0.8,0));await walk(Vector2(-7,0));await walk(Vector2(-7,2))
func run() -> void:
 Engine.time_scale=5
 var w=root.get_node("WorldData");w.new_campaign()
 check(w.orders.size()==3,"three distinct daily orders")
 check(not w.cancel_order("day_1_order_001"),"base order cannot be cancelled")
 check(w.accept_order("day_1_order_003") and w.cancel_order("day_1_order_003"),"uncollected optional order can be accepted then cancelled")
 check(not w.accept_order("day_1_order_003") and w.income()==0,"cancelled order cannot reopen or pay")
 w.new_campaign();w.depart()
 change_scene_to_file("res://scenes/city_delivery.tscn");await frames()
 await press_tab();check(current_scene.board.visible,"Tab opens delivery board")
 var before: Vector3=current_scene.player.position
 Input.action_press("ui_right");for i in range(20):await physics_frame
 release();check(current_scene.player.position.distance_to(before)<0.05,"open board pauses movement")
 var board=current_scene.board
 board.selected_id="day_1_order_002";board.refresh()
 find_button(board,"接取并追踪").pressed.emit();await frames()
 check(w.current_order().person_id=="local_8","board accepts and focuses market order")
 board.selected_id="day_1_order_003";board.refresh();find_button(board,"接取并追踪").pressed.emit();await frames()
 check(not w.accept_order("day_1_order_003"),"duplicate acceptance rejected")
 await snap("01_order_board")
 w.focus_order("day_1_order_001");await press_tab()
 await shop_path();await press_e();check(w.current_order().status=="配送中","collect first meal")
 check(not w.cancel_order("day_1_order_001"),"collected base cannot cancel")
 await walk(Vector2(-7,0));await walk(Vector2(-0.8,1.8));await walk(Vector2(6,1.8));await walk(Vector2(6,-3.8));await press_e()
 check(w.current_order().status=="已送达","first resident receives correct order")
 await walk(Vector2(6,0));await walk(Vector2(0,2));await walk(Vector2(0,8));await press_e()
 check(w.location=="city" and w.period=="day","cannot close day with accepted orders remaining")
 w.focus_order("day_1_order_002");await shop_path();await press_e()
 check(not w.cancel_order("day_1_order_002"),"collected optional order cannot cancel")
 check(not w.deliver_order(w.active_order_id),"delivery rejected at pickup point")
 await walk(Vector2(-7,0));await walk(Vector2(-5,-1.5));await press_e()
 check(w.current_order().status=="已送达","market customer receives distinct order")
 await press_e();var count=w.pending_messages.size();await press_e()
 check(w.pending_messages.size()==count,"repeated NPC talk cannot duplicate night message")
 check(w.encountered_npcs.has("local_8"),"NPC encounter recorded")
 await snap("02_market_delivery")
 w.focus_order("day_1_order_003");await walk(Vector2(-7,0));await walk(Vector2(-7,2));await press_e()
 await walk(Vector2(-7,0));await walk(Vector2(-0.8,1.8));await walk(Vector2(4,1.8));await walk(Vector2(4,2));await press_e()
 check(w.current_order().status=="已送达" and is_equal_approx(w.income(),18.5),"third delivery totals correct income")
 check(not w.deliver_order(w.active_order_id) and is_equal_approx(w.income(),18.5),"repeat delivery cannot duplicate pay")
 check(w.night_posts.is_empty() and w.pending_posts.size()==3,"three deliveries wait until night to reveal")
 check(w.save_game("user://multi_delivery_day.json"),"save three deliveries and pending NPC events")
 await walk(Vector2(0,2));await walk(Vector2(0,8));await press_e()
 check(w.period=="night" and w.night_posts.size()==3,"home reveals all three posts")
 check(w.pending_posts.is_empty() and w.pending_messages.is_empty(),"pending queues drained once")
 # Move via the room's key input as in the original route test.
 var room=current_scene
 for i in range(600):
  if room.is_near_computer():break
  var offset=Vector2(95,175)-room.player_uv
  var screen=Vector2(2*(offset.x-offset.y),offset.x+offset.y)
  for code in [KEY_A,KEY_D,KEY_W,KEY_S]:
   var event=InputEventKey.new();event.physical_keycode=code
   event.pressed=(code==KEY_A and screen.x < -2) or (code==KEY_D and screen.x>2) or (code==KEY_W and screen.y < -2) or (code==KEY_S and screen.y>2)
   root.push_input(event,true)
  await process_frame
 for code in [KEY_A,KEY_D,KEY_W,KEY_S]:
  var event=InputEventKey.new();event.physical_keycode=code;event.pressed=false;root.push_input(event,true)
 await press_e()
 check(current_scene.scene_file_path=="res://scenes/desktop.tscn","after multi-delivery can investigate desktop")
 if current_scene.scene_file_path=="res://scenes/desktop.tscn":
  current_scene.open_app("接单");await snap("03_desktop_orders")
  current_scene.open_app("动态")
  var scroll=current_scene.windows["动态"].body.get_child(1)
  for i in range(8):await process_frame
  scroll.scroll_vertical=int(scroll.get_v_scroll_bar().max_value)
  await snap("04_night_posts")
 check(w.save_game("user://multi_delivery_night.json"),"save nightly multi-order state")
 print("MULTI DELIVERY FAILURES: ",failures)
 quit(1 if failures else 0)
