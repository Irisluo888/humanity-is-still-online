extends SceneTree
var failures=0
var c: Node
var m: Node
func _initialize():call_deferred("run")
func check(ok: bool,text: String):
 print("PASS: " if ok else "FAIL: ",text)
 if not ok:failures+=1
func frames(n=12):
 for i in range(n):await process_frame
func snap(name: String):
 await frames();await RenderingServer.frame_post_draw
 check(root.get_texture().get_image().save_png("res://artifacts/digital_systems/"+name+".png")==OK,"capture "+name)
func run():
 root.size=Vector2i(1280,720);c=root.get_node("Chapter");m=root.get_node("MessageManager");m.set_process(false)
 c.debug_jump(2);change_scene_to_file("res://scenes/ch01.tscn");await frames()
 var minute=m.current_minute
 m.tick_presentation(.5);await frames()
 check(m.get_thread_messages("rider_group").size()==1,"unopened group starts without manual selection")
 check(current_scene.notification_toast.visible,"unopened group notification visible")
 current_scene.show_phone();await frames()
 m.queue_message({"id":"test_private","thread_id":"xiaoyu","sender_id":"xiaoyu","text":"到家了吗？"})
 m.tick_presentation(.5);await frames()
 check(m.get_thread_messages("xiaoyu").size()==1,"other contact delivers while group open")
 check(current_scene.notification_toast.visible and current_scene.notification_toast.target=="xiaoyu","other contact banner visible over phone")
 await snap("10_private_push")
 current_scene.notification_toast.requested.emit("xiaoyu");await frames()
 check(current_scene.selected_thread=="xiaoyu" and m.get_unread_count("xiaoyu")==0,"banner opens new conversation and marks read")
 check(m.current_minute==minute,"delivery does not advance game clock")
 c.debug_jump(5);c.state.event_active=false;c.state.place="garden";c.sync();await frames()
 var w=root.get_node("WorldData");w.orders.back().status="配送中";w.active_order_id=w.orders.back().id
 current_scene.interact_point("building");await frames()
 check(c.state.place=="hallway12" and current_scene.map_world.kind=="hallway12","building loads independent floor12")
 check(w.orders.back().status=="配送中","building entrance does not finish delivery")
 check(not current_scene.map_world.points.has("door"),"floor12 has no1404 door")
 await snap("11_floor12")
 c.save_path="user://message_floor_fix.json"
 c.remember_position(Vector3(-2,0.1,1))
 check(c.save() and c.restore() and c.state.place=="hallway12" and c.state.positions.has("hallway12"),"floor12 save restores independent position")
 await frames()
 current_scene.interact_point("resident");await frames()
 check(w.orders.back().status=="已送达" and c.state.event_active,"1203 doorstep delivers meal")
 c.next();await frames()
 check(c.state.place=="hallway12" and not c.modal(),"choosing14 keeps player on12 until stairs used")
 check(c.fast_home(),"optional investigation can leave temporarily")
 c.state.place="garden";c.sync();await frames()
 current_scene.interact_point("building");await frames()
 check(c.state.place=="hallway12","unfinished14 investigation can reenter building")
 current_scene.interact_point("up14");await frames()
 check(c.state.place=="hallway" and not current_scene.map_world.points.has("resident"),"stairs load floor14 without1203")
 await snap("12_floor14")
 current_scene.interact_point("door");await frames();check(c.state.event_active,"1404 interaction starts at correct door")
 c.next();c.next();await frames();check(c.state.place=="garden","elevator storyline still returns garden")
 current_scene.queue_free();await frames(20)
 print("MESSAGE FLOOR FIX FAILURES: ",failures);quit(failures)
