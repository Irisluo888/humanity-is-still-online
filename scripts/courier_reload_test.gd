extends "res://scripts/phase1_route_test.gd"
func _initialize() -> void:call_deferred("run")
func snap(name: String) -> void:
 await frames();await RenderingServer.frame_post_draw
 check(root.get_texture().get_image().save_png("res://artifacts/cruise_events/"+name+".png")==OK,"capture "+name)
func run() -> void:
 var w=root.get_node("WorldData")
 check(w.load_game("user://courier_pending_test.json"),"fresh process restores pending event")
 var pending=w.pending_story();var event_id: String=pending.story_event;var roll: float=pending.story_roll
 check(roll==0.0 and pending.story_triggered,"saved draw and hit outcome persist")
 change_scene_to_file(w.scene_for_location());await frames(30)
 check(current_scene.story_panel.visible and not current_scene.cruising,"restored event shown but cruise never auto-restarts")
 await snap("04_restored_choice")
 var minute=w.minute
 check(w.resolve_story("continue") and w.clues.is_empty() and w.minute==minute,"continue choice costs no time and creates no clue")
 check(w.pending_posts.size()==2 and w.pending_messages.size()==2,"continue choice still links night content once")
 check(not w.resolve_story("continue"),"duplicate choice rejected")
 check(w.load_game("user://courier_resolved_test.json"),"remembered branch restores")
 check(w.pending_story().is_empty() and w.clues.size()==1,"remembered clue and resolved state persist")
 check(w.order_by_id("day_1_order_001").story_event==event_id and w.order_by_id("day_1_order_001").story_roll==roll,"load never redraws event identity or probability")
 var raw: Dictionary=JSON.parse_string(FileAccess.get_file_as_string("user://courier_resolved_test.json"))
 raw.orders[0].story_roll=2.0
 var file=FileAccess.open("user://courier_invalid_test.json",FileAccess.WRITE);file.store_string(JSON.stringify(raw));file.close()
 check(not w.load_game("user://courier_invalid_test.json") and w.clues.size()==1,"invalid probability metadata rejected atomically")
 w.forced_story_roll=0.0;w.new_campaign();w.depart()
 w.accept_order("day_1_order_002");w.accept_order("day_1_order_003")
 var seen: Array=[]
 for order in w.orders:
  w.focus_order(order.id);w.city_position=w.SHOP;check(w.pickup_order(),"story branch collects accepted order")
  var target=w.delivery_target();w.city_position=target
  check(w.deliver_order(order.id),"story branch delivers at correct point")
  var event=w.pending_story();check(not event.is_empty() and event.story_event not in seen,"vignette does not repeat within a day")
  seen.append(event.story_event);w.resolve_story("continue")
 check(w.pending_posts.size()==6,"three delivery and three story records only")
 var previous: Dictionary={}
 for order in w.orders:previous[order.route_key]=order.item
 for next_day in range(2,12):
  w.day=next_day;w.add_daily_order()
  for order in w.orders:
   if not w.today(order):continue
   check(previous[order.route_key]!=order.item,"no adjacent-day repeat: day %d %s" % [next_day,order.route_key])
   previous[order.route_key]=order.item
 print("COURIER RELOAD FAILURES: ",failures)
 quit(1 if failures else 0)
