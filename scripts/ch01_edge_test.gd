extends SceneTree
var failures=0
var c: Node
func _initialize():call_deferred("run")
func check(v: bool,text: String):
 print("PASS: " if v else "FAIL: ",text)
 if not v:failures+=1
func frames(n=12):
 for i in range(n):await process_frame
func run():
 c=root.get_node("Chapter");c.save_path="user://ch01_edge.json";c.debug_jump(8);c.state.event_active=false;c.sync()
 var w=root.get_node("WorldData")
 var money=c.state.money;var count=w.inventory.water
 check(c.buy("water") and w.inventory.water==count+1 and c.state.money==money-3,"store stock purchase costs money and adds weight")
 var weight=c.weight();check(c.use_item("water") and is_equal_approx(c.weight(),weight-0.5),"consumption updates weight")
 c.fresh();w.location="city";w.period="day";w.city_position=w.SHOP;w.pickup_order();w.city_position=w.delivery_target()
 var earned_before=c.state.money
 check(c.complete_delivery(w.active_order_id) and c.state.money==earned_before+13.5,"delivery income updates chapter balance")
 var earned=c.state.money
 check(not c.complete_delivery(w.active_order_id) and c.state.money==earned,"duplicate delivery cannot duplicate income")
 for choice in ["weapon","extinguisher","hands","leave"]:
  c.debug_jump(8);var durability=c.state.durability;var hp=w.health
  check(c.next(choice),"store choice accepted "+choice)
  check(c.state.scene_states.store.chen_saved==(choice!="leave"),"Chen outcome persists "+choice)
  check(c.state.durability==durability-(3 if choice=="weapon" else 0),"weapon cost "+choice)
  check(w.health==hp-(25 if choice=="hands" else 0),"hands health cost "+choice)
 c.debug_jump(8);c.state.durability=2;check(not c.next("weapon"),"low durability cannot rescue by weapon")
 c.debug_jump(13);w.inventory.medicine=0;check(not c.next("aid_pending"),"no medicine disables aid")
 check(not c.fast_home(),"door danger blocks home before and after reload")
 check(c.save() and c.restore() and c.state.event_active and not c.fast_home(),"mid-danger save resumes locked choice")
 var before=c.state.duplicate(true)
 var f=FileAccess.open(c.save_path,FileAccess.WRITE);f.store_string("{}");f.close()
 check(not c.restore() and c.state==before,"corrupt save leaves memory untouched")
 c.debug_jump(9);c.state.place="street";c.state.event_active=false;c.sync()
 var resources=[w.health,w.stamina,c.weight(),c.state.durability,c.state.money]
 check(c.fast_home() and resources==[w.health,w.stamina,c.weight(),c.state.durability,c.state.money],"home free exact resource preservation")
 c.state.place="street";c.sync();change_scene_to_file("res://scenes/ch01.tscn");await frames()
 for i in range(130):await physics_frame
 var map=current_scene.map_world
 check(not c.state.encounter,"no contact no encounter")
 map.player.position=Vector3(2,0.1,1)
 for i in range(5):await physics_frame
 check(c.state.encounter,"actual Area3D overlap triggers encounter")
 c.resolve_encounter("force");await frames()
 check(not c.state.encounter and current_scene.map_world.player.position.distance_to(Vector3(2,0,1))>1,"resolution physically separates")
 for i in range(130):await physics_frame
 check(not c.state.encounter,"no repeated contact popup after cooldown")
 var pos=current_scene.map_world.player.position
 current_scene.show_phone();await frames()
 current_scene.map_world.held[KEY_D]=true
 for i in range(20):await physics_frame
 check(current_scene.map_world.player.position.distance_to(pos)<0.05,"phone locks movement")
 current_scene.map_world.held.clear();current_scene.close_phone();await frames()
 current_scene.show_phone(false,"消息");await frames();check(current_scene.opened,"phone app is real panel")
 current_scene.close_phone();await frames()
 # A real collision wall, not only bounds clamping.
 map=current_scene.map_world;map.player.position=Vector3(6,0.1,-3);map.held[KEY_W]=true;map.held[KEY_D]=true
 for i in range(100):await physics_frame
 map.held.clear();check(map.player.position.z>-3.6,"building collision blocks entry through facade")
 c.debug_jump(10);await frames();root.size=Vector2i(960,540);await frames()
 await RenderingServer.frame_post_draw
 check(root.get_texture().get_image().save_png("res://artifacts/ch01_qa/18_scaled_960.png")==OK,"scaled runtime screenshot")
 c.debug_jump(8);c.state.event_active=false;c.state.place="garden";c.remember_position(Vector3(3,0.1,4));c.state.scene_states.store={"broken":true,"chen_saved":false};c.state.flags.ch01_store_owner_saved=false
 check(c.save(),"prepare fresh process position scene state save")
 var migrated=JSON.parse_string(FileAccess.get_file_as_string(c.save_path));migrated.state.schema=1
 for key in ["positions","scene_states","stock","money","event_active","page"]:migrated.state.erase(key)
 check(c.valid(migrated),"legacy chapter schema accepted without new map fields")
 print("EDGE FAILURES: ",failures);quit(1 if failures else 0)
