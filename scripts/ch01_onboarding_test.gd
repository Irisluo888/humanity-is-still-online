extends SceneTree
var failures=0
var c: Node
var m: Node
func _initialize():call_deferred("run")
func check(v: bool,t: String):
 print("PASS: " if v else "FAIL: ",t)
 if not v:failures+=1
func frames(n=12):
 for i in range(n):await process_frame
func snap(n: String):
 await frames();await RenderingServer.frame_post_draw
 check(root.get_texture().get_image().save_png("res://artifacts/digital_systems/"+n+".png")==OK,"capture "+n)
func run():
 root.size=Vector2i(1280,720);c=root.get_node("Chapter");m=root.get_node("MessageManager");c.fresh()
 change_scene_to_file("res://scenes/ch01.tscn");await frames();await create_timer(.6).timeout
 check(current_scene.task_card.visible and current_scene.guidance.target=="delivery","visible task card and delivery route")
 check(m.records.has("opening_xiaoyu_000") and m.records.opening_xiaoyu_000.revealed,"original Xiaoyu delivery message actually arrives")
 check(current_scene.notification_toast.visible and current_scene.notification_toast.status.text.contains("手机"),"phone-shaped notification during delivery")
 await snap("13_delivery_guidance")
 current_scene.notification_toast.requested.emit("xiaoyu");await frames();check(current_scene.opened,"opening message opens phone")
 check(m.choose_reply("opening_xiaoyu_001","last_order"),"opening original preset reply")
 current_scene.close_phone();await frames()
 current_scene.interact_point("delivery");await frames()
 check(c.beat().id=="repair" and current_scene.fault_remaining>0,"delivery triggers bike breakdown animation")
 await snap("14_bike_fault")
 await create_timer(3.7).timeout
 check(current_scene.task_card.visible and current_scene.guidance.target=="repair" and not current_scene.map_world.locked,"breakdown ends and repair guidance visible")
 await snap("15_repair_guidance")
 current_scene.interact_point("repair");await frames();check(c.state.event_active,"repair dialogue accessible")
 c.debug_jump(2);change_scene_to_file("res://scenes/desktop.tscn");await frames(20);current_scene.open_app("消息");current_scene.open_app("热榜");await frames()
 m.queue_message({"id":"desktop_popup_test","thread_id":"xiaoyu","sender_id":"xiaoyu","text":"到家了吗？"});await create_timer(.6).timeout
 var toast: Node
 for node in current_scene.get_children():
  if node.get_script()==load("res://ui/notification_toast.gd"):toast=node
 check(toast!=null and toast.visible and toast.z_index==100,"desktop toast remains above newly opened windows")
 await snap("16_desktop_phone_push")
 toast.requested.emit("xiaoyu");await frames();check(current_scene.windows["消息"].body.get_child(0).thread_id=="xiaoyu","notification switches existing desktop chat")
 c.debug_jump(7)
 for i in range(c.beat().pages.size()):
  if c.beat().pages[i].get("visual","")=="elevator_hand":c.state.page=i
 change_scene_to_file("res://scenes/ch01.tscn");await frames();await create_timer(1.5).timeout
 var found=false
 for node in current_scene.ui_scale.get_children():
  if node.get_script()==load("res://ui/ch01_closeup.gd") and node.mode=="hand":found=true
 check(found and c.state.event_active and current_scene.map_world.locked,"hand closeup bound to exact elevator story page")
 await snap("17_elevator_hand")
 current_scene.typing=999;current_scene.body_text.visible_characters=-1;current_scene.continue_dialogue();await frames()
 check(c.page().speaker=="男人","closeup continues original man's dialogue")
 current_scene.queue_free();await frames(20);print("ONBOARDING FAILURES: ",failures);quit(failures)
