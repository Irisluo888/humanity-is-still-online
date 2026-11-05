extends "res://scripts/phase1_route_test.gd"
func snap(name: String) -> void:
 await frames();await RenderingServer.frame_post_draw
 check(root.get_texture().get_image().save_png("res://artifacts/phase2_delivery/"+name+".png")==OK,"capture "+name)
func run() -> void:
 var w=root.get_node("WorldData")
 check(w.load_game("user://multi_delivery_day.json"),"new process loads three-order daytime save")
 check(w.daytime_orders.size()==3 and w.night_posts.is_empty() and w.pending_posts.size()==3,"delivery and unrevealed queues persist")
 check(w.pending_messages.size()==4 and w.encountered_npcs.size()==3,"NPC talk and distinct encounters persist")
 check(w.load_game("user://multi_delivery_night.json"),"new process loads nightly save")
 check(w.period=="night" and w.night_posts.size()==3 and is_equal_approx(w.income(),18.5),"night reveal and total income persist")
 check(not w.return_home() and w.night_posts.size()==3,"repeated close-day cannot reveal posts twice")
 var value: Dictionary=JSON.parse_string(FileAccess.get_file_as_string("user://multi_delivery_night.json"))
 value.orders[0].status="非法状态"
 var file=FileAccess.open("user://multi_invalid_test.json",FileAccess.WRITE);file.store_string(JSON.stringify(value));file.close()
 check(not w.load_game("user://multi_invalid_test.json") and w.night_posts.size()==3,"invalid order state rejected without mutation")
 change_scene_to_file(w.scene_for_location());await frames()
 current_scene.open_app("接单");await snap("05_restored_orders")
 change_scene_to_file("res://scenes/bedroom.tscn");await frames()
 check(w.rest(),"can rest after investigating multi-order day")
 check(w.day==2 and w.orders.size()==6 and w.current_order().status=="待取餐","next day adds three new orders and preserves history")
 check(not w.accept_order("day_1_order_002"),"previous day order cannot be accepted again")
 check(w.accept_order("day_2_order_002") and w.cancel_order("day_2_order_002"),"next-day optional cancellation")
 check(w.save_game("user://multi_cancel_test.json") and w.load_game("user://multi_cancel_test.json"),"cancelled state save/load")
 check(w.order_by_id("day_2_order_002").status=="已取消" and is_equal_approx(w.income(),18.5),"cancelled order never contributes income")
 print("MULTI RELOAD FAILURES: ",failures)
 quit(1 if failures else 0)
