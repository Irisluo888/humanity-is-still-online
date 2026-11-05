extends SceneTree
var fails=0
func _initialize():call_deferred("run")
func check(v,t):
 print("PASS: " if v else "FAIL: ",t)
 if not v:fails+=1
func frames():
 for i in range(15):await process_frame
func find_list(node):
 if node.get_script()==load("res://ui/phone_messages.gd"):return node
 for child in node.get_children():
  var f=find_list(child)
  if f:return f
 return null
func snap(n):
 await RenderingServer.frame_post_draw
 check(root.get_texture().get_image().save_png("res://artifacts/digital_systems/"+n+".png")==OK,n)
func run():
 root.size=Vector2i(1280,720);var c=root.get_node("Chapter");var m=root.get_node("MessageManager");c.fresh();m.set_process(false)
 change_scene_to_file("res://scenes/ch01.tscn");await frames();m.tick_presentation(.5)
 current_scene.show_phone();await frames();var p=find_list(current_scene)
 check(p.list.get_child(0).get_meta("thread_id")=="xiaoyu","phone newest contact first")
 m.queue_message({"id":"sort_zhou","thread_id":"zhou_warning","sender_id":"zhou","text":"路上慢点，到家说一声。"});m.tick_presentation(.5);await frames()
 check(p.list.get_child(0).get_meta("thread_id")=="zhou_warning" and p.list.get_child(0).get_meta("unread")==1,"new arrival moves contact to top with badge")
 await snap("25_phone_latest_first")
 change_scene_to_file("res://scenes/desktop.tscn");await frames();current_scene.open_app("消息");await frames();var desktop=current_scene.windows["消息"].body.get_child(0)
 check(desktop.list.get_child(0).get_meta("thread_id")=="zhou_warning","desktop uses same latest-first rows")
 await snap("26_desktop_contacts")
 desktop.list.get_child(0).pressed.emit();await frames()
 check(desktop.conversation.thread_id=="zhou_warning" and not desktop.conversation.selector.visible,"desktop contact opens nonfolded conversation")
 check(m.get_unread_count("zhou_warning")==0,"desktop read shared with phone")
 desktop.show_list();await frames()
 check(desktop.list.get_child(0).get_meta("thread_id")=="zhou_warning","reading does not reorder latest contact")
 current_scene.queue_free();await frames();print("CONTACT ORDER FAILURES: ",fails);quit(fails)
