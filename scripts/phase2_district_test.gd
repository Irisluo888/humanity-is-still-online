extends "res://scripts/phase1_route_test.gd"
func snap(name: String) -> void:
 await frames(); await RenderingServer.frame_post_draw
 check(root.get_texture().get_image().save_png("res://artifacts/phase2/"+name+".png")==OK,"capture "+name)
func run() -> void:
 Engine.time_scale=5
 var w=root.get_node("WorldData"); w.new_campaign(); w.depart()
 check(not w.enter_district("shop"),"remote district entry rejected")
 change_scene_to_file("res://scenes/city_delivery.tscn"); await frames()
 await walk(Vector2(-0.8,7.5)); await walk(Vector2(-0.8,0)); await walk(Vector2(-7.9,0.5))
 var actual=Vector2(current_scene.player.position.x,current_scene.player.position.z)
 var pickup_closer=actual.distance_to(Vector2(-7,2))<=actual.distance_to(Vector2(-9,-1))
 await press_e()
 check((w.location=="city" and w.current_order().status=="配送中") if pickup_closer else w.location=="shop","actual nearest target wins in overlapping interaction ranges")
 if w.location=="shop": await press_e()
 var original_status: String=w.current_order().status
 await walk(Vector2(-9,-1))
 await snap("street_shop_entrance")
 await press_e()
 check(w.location=="shop" and current_scene.scene_file_path=="res://scenes/district_interior.tscn","E enters convenience shop")
 if w.location!="shop": quit(1); return
 check(current_scene.safe_spawn(Vector3(2.8,0,-0.7))==Vector3(0,0.1,3),"shelf-overlap spawn rejected")
 check(current_scene.safe_spawn(Vector3(50,0,50))==Vector3(0,0.1,3),"outside spawn rejected")
 await walk(Vector2(0,-0.5))
 await press_e(); check(w.location=="shop","far exit E cannot teleport out")
 Input.action_press("ui_right"); Input.action_press("ui_down")
 for i in range(100): await physics_frame
 release()
 check(current_scene.player.position.x<2.0,"shelf collision blocks real movement")
 await walk(Vector2(0,-0.5)); await walk(Vector2(0,3.6))
 await snap("convenience_shop")
 check(w.save_game("user://phase2_shop_test.json"),"save inside shop")
 await press_e()
 check(w.location=="city" and current_scene.scene_file_path=="res://scenes/city_delivery.tscn","shop exit returns to street")
 check(Vector2(current_scene.player.position.x,current_scene.player.position.z).distance_to(Vector2(-9,-1))<0.5,"street return stays at correct entrance")
 await walk(Vector2(-9,0)); await walk(Vector2(-0.8,0)); await walk(Vector2(-0.8,2)); await walk(Vector2(9,2)); await walk(Vector2(9,1)); await press_e()
 check(w.location=="corridor","E enters resident corridor")
 if w.location!="corridor": quit(1); return
 await walk(Vector2(0,-2))
 Input.action_press("ui_right"); Input.action_press("ui_up")
 for i in range(100): await physics_frame
 release()
 check(current_scene.player.position.z > -3.7,"corridor back wall blocks movement")
 await walk(Vector2(0,1))
 check(w.save_game("user://phase2_corridor_test.json"),"save interior position for next process")
 await snap("resident_corridor")
 await walk(Vector2(0,4)); await press_e()
 check(w.location=="city","corridor returns to street")
 check(w.current_order().status==original_status and w.period=="day" and w.income()==0,"exploration preserves order, period and income")
 print("DISTRICT FAILURES: ",failures)
 quit(1 if failures else 0)
