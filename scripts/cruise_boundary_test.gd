extends "res://scripts/cruise_event_test.gd"
func snap(name: String) -> void:
 await frames();await RenderingServer.frame_post_draw
 check(root.get_texture().get_image().save_png("res://artifacts/cruise_boundary/"+name+".png")==OK,"capture "+name)
func run() -> void:
 Engine.time_scale=3
 var w=root.get_node("WorldData");w.forced_story_roll=0.99;w.new_campaign();w.depart()
 change_scene_to_file("res://scenes/city_delivery.tscn");await frames(30)
 check(not current_scene.cruise_button.disabled,"accepted base order enables cruise")
 await key_f();await await_route()
 check(w.daytime_orders.size()==1 and is_equal_approx(w.income(),6.5),"only accepted order delivered")
 check(w.location=="city" and w.period=="day" and current_scene.scene_file_path=="res://scenes/city_delivery.tscn","completion stays on street in daytime")
 check(not current_scene.cruising and current_scene.cruise_button.disabled,"finished queue disables cruise button")
 check(w.order_by_id("day_1_order_002").status=="可接单" and w.order_by_id("day_1_order_003").status=="可接单","optional orders are never auto-accepted")
 var stopped=Vector2(current_scene.player.position.x,current_scene.player.position.z)
 await key_f()
 for i in range(60):await physics_frame
 check(not current_scene.cruising,"F cannot start idle cruise without accepted orders")
 check(Vector2(current_scene.player.position.x,current_scene.player.position.z).distance_to(stopped)<0.05,"idle cruise does not move toward home")
 check(w.night_posts.is_empty() and w.pending_posts.size()==1,"completion does not reveal night content or close day")
 await snap("01_stopped_after_delivery")
 check(w.accept_order("day_1_order_002"),"player may explicitly accept another order")
 await frames();check(not current_scene.cruise_button.disabled,"new accepted order re-enables cruise")
 await snap("02_new_order_available")
 await key_f();await await_route()
 check(w.daytime_orders.size()==2 and is_equal_approx(w.income(),13.5),"second explicit order can cruise normally")
 check(w.period=="day" and w.location=="city" and current_scene.cruise_button.disabled,"second completion again stops without closing day")
 check(w.order_by_id("day_1_order_003").status=="可接单","remaining unaccepted order remains available")
 await walk(Vector2(-0.8,-1));await walk(Vector2(-0.8,2));await walk(Vector2(0,8));await press_e()
 check(w.location=="home" and w.period=="night","manual home interaction still closes day")
 print("CRUISE BOUNDARY FAILURES: ",failures)
 quit(1 if failures else 0)
