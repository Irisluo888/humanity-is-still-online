extends SceneTree
var failures:=0
func _initialize() -> void: call_deferred("run")
func check(value: bool,text: String) -> void:
 print(("PASS: " if value else "FAIL: ")+text)
 if not value: failures+=1
func run() -> void:
 var w=root.get_node("WorldData")
 check(not w.campaign,"fresh process starts without loaded campaign")
 check(w.load_game("user://phase1_route_test.json"),"separate process loads route save")
 check(w.day==2 and w.period=="day" and w.location=="home","day and location restored")
 check(w.inventory.medicine==1 and w.inventory.food==0 and w.inventory.water==0,"inventory and rest consumption persisted")
 check(is_equal_approx(w.income(),6.5) and w.night_messages.size()==1,"income and linked messages persisted")
 var path="user://phase1_corruption_test.json"
 check(w.save_game(path),"write isolated test slot")
 w.minute=500
 check(w.save_game(path),"replace save with backup")
 var file=FileAccess.open(path,FileAccess.WRITE); file.store_string("{}"); file.close()
 var before=w.day
 check(not w.load_game(path) and w.day==before,"invalid schema rejected without progress mutation")
 check(w.load_game(path+".bak") and w.minute==480,"previous save backup restores")
 check(w.use_item("medicine") and w.health==100 and w.inventory.medicine==0,"consume medicine restores health and decrements inventory")
 check(not w.load_game("user://phase1_nonexistent_slot.json"),"missing save rejected")
 change_scene_to_file(w.scene_for_location())
 for i in range(10): await process_frame
 await RenderingServer.frame_post_draw
 check(root.get_texture().get_image().save_png("res://artifacts/phase1/reloaded_day2.png")==OK,"loaded scene renders")
 print("RELOAD FAILURES: ",failures)
 quit(1 if failures else 0)
