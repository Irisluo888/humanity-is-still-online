extends "res://scripts/phase1_route_test.gd"
func snap(name: String) -> void:
 await frames(); await RenderingServer.frame_post_draw
 check(root.get_texture().get_image().save_png("res://artifacts/phase2/"+name+".png")==OK,"capture "+name)
func run() -> void:
 var w=root.get_node("WorldData")
 check(w.load_game("user://phase2_corridor_test.json"),"new process loads corridor save")
 check(w.location=="corridor","interior location persisted")
 change_scene_to_file(w.scene_for_location()); await frames()
 check(current_scene.area=="corridor","continue chooses correct interior variant")
 check(Vector2(current_scene.player.position.x,current_scene.player.position.z).distance_to(Vector2(0,1))<0.5,"interior position persisted")
 await snap("corridor_reloaded")
 var old: Dictionary=JSON.parse_string(FileAccess.get_file_as_string("user://phase1_route_test.json"))
 old.erase("interior_position")
 var file=FileAccess.open("user://phase2_legacy_test.json",FileAccess.WRITE); file.store_string(JSON.stringify(old)); file.close()
 check(w.load_game("user://phase2_legacy_test.json"),"old phase1 schema without optional interior field still loads")
 check(w.location=="home" and w.interior_position==Vector3(0,0,3),"legacy save gets safe interior default")
 print("DISTRICT RELOAD FAILURES: ",failures)
 quit(1 if failures else 0)
