extends SceneTree
func _initialize() -> void: call_deferred("run")
func run() -> void:
 var w=root.get_node("WorldData")
 w.new_campaign(); assert(w.depart())
 assert(not w.pickup_order())
 w.city_position=w.SHOP; assert(w.pickup_order())
 w.city_position=w.CUSTOMER; assert(w.deliver_order(w.active_order_id)); assert(not w.deliver_order(w.active_order_id))
 assert(w.night_messages.is_empty())
 w.city_position=w.HOME; assert(w.return_home()); assert(w.night_messages.size()==1)
 assert(not w.rest()); w.mark_reviewed(); assert(w.rest()); assert(w.day==2)
 assert(w.save_game("user://phase1_test.json")); w.day=99; assert(w.load_game("user://phase1_test.json")); assert(w.day==2)
 print("PASS: pickup proximity, delivery, deduplication, night reveal, review gate, next day, save/load")
 change_scene_to_file("res://scenes/bedroom.tscn")
 for i in range(10): await process_frame
 await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("res://artifacts/phase1/bedroom.png")
 change_scene_to_file("res://scenes/city_delivery.tscn")
 for i in range(10): await process_frame
 await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("res://artifacts/phase1/city.png")
 quit()
