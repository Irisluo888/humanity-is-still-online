extends SceneTree
var failures=0
func _initialize():call_deferred("run")
func frames(n=15):
 for i in range(n):await process_frame
func check(value,text):
 print("PASS: " if value else "FAIL: ",text)
 if not value:failures+=1
func snap(name):
 await frames();await RenderingServer.frame_post_draw
 check(root.get_texture().get_image().save_png("res://artifacts/phone_y2k/"+name+".png")==OK,"screenshot "+name)
func click(control):
 var pos=control.get_global_rect().get_center()
 var motion=InputEventMouseMotion.new();motion.position=pos;root.push_input(motion,true)
 var event=InputEventMouseButton.new();event.position=pos;event.button_index=MOUSE_BUTTON_LEFT;event.pressed=true;root.push_input(event,true)
 event=InputEventMouseButton.new();event.position=pos;event.button_index=MOUSE_BUTTON_LEFT;root.push_input(event,true);await frames()
func run():
 root.size=Vector2i(1280,720)
 var m=root.get_node("MessageManager");m.reset();m.set_context(1427);m.queue_script("rider_group",1427);m.queue_script("xiaoyu",1427)
 change_scene_to_file("res://scenes/phone/chat_list.tscn");await frames(30)
 var app=current_scene.get_child(1).get_child(0)
 await create_timer(1.6).timeout
 check(m.get_thread_messages("rider_group").size()>0,"real timed queue reveals messages")
 m.set_process(false)
 for i in range(6):m.tick_presentation(3)
 await frames();await snap("01_chat_list")
 check(app.list.get_child_count()==6,"six independent conversation entries")
 await click(app.navigation["通讯录"]);check(app.page=="通讯录","mouse click opens contacts");await snap("02_contacts")
 var count=0
 for child in app.list.get_children():
  if child.has_meta("contact_id"):count+=1
 check(count==6,"six existing character contact entries")
 app.list.get_parent().scroll_vertical=10000;await frames();await snap("12_contacts_lower")
 check(app.list.get_parent().scroll_vertical>0,"contacts scroll to remaining people")
 app.search.text="陈姨";app.search.text_changed.emit("陈姨");await frames()
 check(app.list.get_child_count()==3,"contact search narrows to one with category")
 app.profile("chen");await frames();await snap("03_profile")
 app.show_page("聊天");await frames();await click(app.list.get_child(0));check(app.page=="对话","mouse click opens chat row");await snap("04_group_chat")
 check(app.conversation.phone_skin,"phone bubbles use dedicated skin")
 check(m.get_unread_count("rider_group")==0,"opening conversation updates shared read state")
 var reply=m.waiting_reply("rider_group")
 if not reply.is_empty():
  app.conversation.reply_row.get_child(1).pressed.emit();await frames();check(not app.selected_reply.is_empty(),"preset fills composer without sending")
  await click(app.body.get_child(app.body.get_child_count()-1).get_child(3));check(m.choices.has(reply.id),"send button commits preset to existing manager")
  await snap("08_player_reply")
 else:check(false,"preset available")
 app.open_thread("xiaoyu");await frames();await snap("05_private_chat")
 var pane=app.conversation
 var long_text="雨夜配送请注意路况，楼道灯光比较暗，到达后先确认门牌。".repeat(8)
 m.queue_message({"id":"qa_phone_long","thread_id":"xiaoyu","sender_id":"xiaoyu","text":long_text,"delay_seconds":0})
 var pending_reply=m.waiting_reply("xiaoyu")
 if not pending_reply.is_empty():m.choose_reply(pending_reply.id,pending_reply.choices[0].id)
 for i in range(15):m.tick_presentation(3)
 await frames()
 check(pane.transcript.get_child(pane.transcript.get_child_count()-1).size.y>100,"long bubble expands vertically")
 check(app.size.x<=438 and pane.scroll.get_h_scroll_bar().max_value<=pane.scroll.size.x+1,"long text stays within phone width")
 await snap("09_long_text")
 m.queue_message({"id":"qa_media","thread_id":"xiaoyu","sender_id":"xiaoyu","text":"测试附件：本地图像与音频扩展","attachments":["res://assets/art/ch01/xiaoyu.png","res://assets/audio/ch01/vibrate.wav"],"delay_seconds":0})
 m.tick_presentation(3);await frames()
 var bubble=pane.transcript.get_child(pane.transcript.get_child_count()-1);var audio
 for child in bubble.get_children():
  if child is AudioStreamPlayer:audio=child
 check(audio!=null and audio.bus=="SFX","local audio attachment uses sound effects bus")
 if audio:audio.play();check(audio.playing,"attachment player starts actual local stream");audio.stop()
 await snap("11_attachment_extension")
 var saved=m.save_data();check(m.load_data(saved),"existing save schema reloads with added empty contact threads")
 app.show_page("聊天");var before=m.get_thread_messages("rider_group").size()
 m.queue_message({"id":"qa_closed","thread_id":"rider_group","sender_id":"zhou","text":"测试：关闭对话后继续送达","delay_seconds":0})
 m.queue_message({"id":"qa_future","thread_id":"rider_group","sender_id":"zhou","text":"未来消息不可见","arrive_at":1437})
 m.tick_presentation(3);await frames()
 check(m.get_thread_messages("rider_group").size()==before+1,"closed conversation continues delivery but future message stays hidden")
 check(app.list.get_child(0).get_meta("thread_id")=="rider_group" and app.list.get_child(0).get_meta("unread")>0,"latest message raises conversation with unread badge")
 check(not m.records.qa_future.delivered and not m.records.qa_future.revealed,"future-dated fixture remains undelivered")
 check(m.current_minute==1427,"UI does not advance game time")
 app.list.get_parent().scroll_vertical=10000;await frames();await snap("13_system_notification_row")
 app.list.get_parent().scroll_vertical=0;await frames()
 root.size=Vector2i(960,540);await frames();await snap("06_scaled")
 root.size=Vector2i(1280,720)
 var c=root.get_node("Chapter");c.fresh();change_scene_to_file("res://scenes/ch01.tscn");await frames(30);current_scene.show_phone();await frames();await snap("07_ingame")
 check(current_scene.phone.get_child(0).has_method("show_page"),"actual chapter phone uses new UI")
 current_scene.close_phone();await frames();check(not current_scene.opened,"closing phone unlocks game")
 current_scene.show_phone(true);await frames();check(current_scene.phone.size.x>900,"desktop retains wide original interface")
 await snap("10_desktop_unchanged")
 current_scene.close_phone();await frames()
 current_scene.queue_free();await frames()
 var a=root.get_node("LocalAudio");a.set_process(false)
 if a.music_tween:a.music_tween.kill()
 a.music.stop();a.music.stream=null;a.rain.stop();a.bike.stop()
 for p in a.players:p.stop();p.stream=null
 await create_timer(1).timeout
 print("PHONE Y2K FAILURES: ",failures);quit(failures)
