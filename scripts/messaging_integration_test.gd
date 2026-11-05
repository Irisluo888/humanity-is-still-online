extends SceneTree
var failures=0
var c: Node
var m: Node
func _initialize():call_deferred("run")
func check(v: bool,text: String):
 print("PASS: " if v else "FAIL: ",text)
 if not v:failures+=1
func frames(n=14):
 for i in range(n):await process_frame
func drain(thread: String):
 m.begin_thread(thread)
 for i in range(120):
  var reply=m.waiting_reply(thread)
  if not reply.is_empty():m.choose_reply(reply.id,reply.choices[0].id)
  m.tick_presentation(3)
  if m.thread_finished(thread):break
 m.mark_read(thread);await frames()
func snap(name: String):
 await frames();await RenderingServer.frame_post_draw
 check(root.get_texture().get_image().save_png("res://artifacts/digital_systems/"+name+".png")==OK,"capture "+name)
func run():
 root.size=Vector2i(1280,720);c=root.get_node("Chapter");m=root.get_node("MessageManager");m.set_process(false);c.save_path="user://digital_integration.json"
 c.debug_jump(2);check(m.profile=="chapter","chapter owns active store")
 check(m.get_thread_messages("rider_group").is_empty(),"chapter does not preload visible transcript")
 change_scene_to_file("res://scenes/ch01.tscn");await frames()
 current_scene.show_phone();await frames();var before=c.game_minute()
 m.tick_presentation(.5);await frames();m.tick_presentation(3);await frames()
 await snap("04_phone_live")
 check(c.game_minute()==before,"phone presentation leaves WorldData game time unchanged")
 var shown=m.get_thread_messages("rider_group").size()
 current_scene.close_phone();await frames();m.tick_presentation(3);await frames()
 check(m.get_thread_messages("rider_group").size()==shown+1 and m.get_unread_count("rider_group")>0,"closed phone continues new unread deliveries")
 check("新消息1" in current_scene.hud.text,"world HUD unread badge updates without rebuilding map")
 check(current_scene.notification_toast.is_inside_tree() and current_scene.notification_toast.visible,"world notification actually appears")
 await snap("09_world_notification")
 change_scene_to_file("res://scenes/desktop.tscn");await frames(20);current_scene.open_app("消息");await frames()
 check(m.get_unread_count("rider_group")==0,"desktop reads same phone messages")
 var pane=current_scene.windows["消息"].body.get_child(0)
 pane.hide();var unread=m.get_unread_count("rider_group");m.tick_presentation(3);await frames()
 check(m.get_unread_count("rider_group")>unread,"hidden desktop does not auto-read new messages")
 pane.show();await frames();check(m.get_unread_count("rider_group")==0,"reopened desktop marks visible messages read")
 await snap("05_desktop_live")
 # Save exact countdown and pending choice, and restore without replaying prior messages.
 var count=m.get_thread_messages("rider_group").size();check(c.save(),"save pending digital sequence")
 var state=m.save_data();check(c.restore(),"restore digital sequence")
 check(m.get_thread_messages("rider_group").size()==count and m.remaining==state.remaining,"presentation cursor countdown retained")
 await drain("rider_group");check(m.choices.has("rider_group_007"),"reply choice recorded")
 check(c.group_reviewed(),"chapter gate requires fully presented read group")
 # Legacy source state migration: preserve unknown historical IDs as recovered records too.
 c.save();var old=JSON.parse_string(FileAccess.get_file_as_string(c.save_path));old.erase("digital_system")
 old.state.messages.append({"id":"legacy_extra","thread":"old_thread","text":"旧记录：必须保留"});old.state.read.append("legacy_extra")
 var f=FileAccess.open(c.save_path,FileAccess.WRITE);f.store_string(JSON.stringify(old));f.close()
 check(c.restore() and m.records.has("legacy_extra") and m.is_read("legacy_extra"),"legacy chapter history and read IDs migrate without loss")
 # Night releases by game milestone and completed read stages, never all at once.
 c.debug_jump(9);change_scene_to_file("res://scenes/ch01.tscn");await frames()
 check(c.game_minute()==2670 and not m.articles.has("news_ch01_003") and not m.records.has("zhou_warning_000"),"20:30 has no 22:17 hospital or Zhou warning")
 await drain("night_group");c.review_digital();await frames()
 check(c.game_minute()==2777 and m.articles.news_ch01_003.published and m.records.has("zhou_warning_000"),"read milestone releases 22:17 private and hospital news")
 check(not m.records.has("xiaoyu_late_000"),"23:35 private still hidden")
 await drain("zhou_warning");c.review_digital();await frames()
 check(c.game_minute()==2855 and m.records.has("xiaoyu_late_000"),"23:35 next segment after warning read")
 current_scene.selected_thread="xiaoyu_late";current_scene.show_phone();await frames()
 m.tick_presentation(.5);await frames();await snap("06_private_message")
 await drain("xiaoyu_late");current_scene.close_phone();await frames();check(c.state.flags.get("night_read",false),"all night messages unlock rest")
 current_scene.show_phone(false,"新闻");await frames();await snap("07_phone_news")
 current_scene.close_phone();c.debug_jump(11);await frames()
 check(m.calls.zhou_door_call.status=="ringing","story call uses queued call record")
 check(m.answer_call("zhou_door_call") and not m.answer_call("zhou_door_call"),"phone answers exactly once")
 await snap("08_phone_call")
 check(not m.articles.has("news_ch01_004"),"chapter ending news not prematurely published")
 # Leave a partial queue fixture for a genuinely separate engine process.
 c.debug_jump(2);m.begin_thread("rider_group");m.tick_presentation(.5);await frames()
 check(c.save(),"save partial queue for separate process")
 current_scene.queue_free();await frames(10)
 print("DIGITAL INTEGRATION FAILURES: ",failures);quit(1 if failures else 0)
