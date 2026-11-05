extends SceneTree
var failures=0
func _initialize():call_deferred("run")
func check(ok,t):
 print("PASS: " if ok else "FAIL: ",t)
 if not ok:failures+=1
func frames():
 for i in range(15):await process_frame
func snap(n):
 await RenderingServer.frame_post_draw
 check(root.get_texture().get_image().save_png("res://artifacts/digital_systems/"+n+".png")==OK,"capture "+n)
func run():
 root.size=Vector2i(1280,720)
 var c=root.get_node("Chapter");var m=root.get_node("MessageManager")
 c.fresh();change_scene_to_file("res://scenes/ch01.tscn");await frames();await create_timer(.6).timeout
 current_scene.selected_thread="xiaoyu";current_scene.show_phone();await frames()
 check(m.choose_reply("opening_xiaoyu_001","last_order"),"reply accepted")
 await create_timer(2).timeout
 check(m.records.opening_xiaoyu_002.revealed,"Xiaoyu replies after player's reply")
 check(not current_scene.notification_toast.visible,"phone open suppresses popup")
 await snap("18_phone_followup")
 current_scene.close_phone();await frames();await create_timer(2).timeout
 check(current_scene.notification_toast.visible,"closed phone resumes incoming popups")
 c.debug_jump(3);c.state.event_active=false;c.next("yes");await frames();await create_timer(1).timeout
 check(current_scene.fault_remaining>0,"morning transition active")
 await snap("19_morning_transition")
 await create_timer(3.5).timeout
 check(not current_scene.map_world.locked and c.beat().id=="orders","morning restores delivery controls")
 change_scene_to_file("res://scenes/desktop.tscn");await frames()
 m.post_notification("desktop_test","message","小鱼","明天见，记得休息。","xiaoyu");await frames()
 var toast
 for node in current_scene.get_children():
  if node.get_script()==load("res://ui/notification_toast.gd"):toast=node
 check(toast.desktop_mode and toast.status.text=="消息 / 桌面通知","desktop-specific notification")
 await snap("20_desktop_notification")
 toast.requested.emit("xiaoyu");await frames()
 check(current_scene.windows["消息"].body.get_child(0).thread_id=="xiaoyu","desktop notification opens conversation")
 current_scene.queue_free();await frames();print("TRANSITION FAILURES: ",failures);quit(failures)
