extends "res://scripts/cruise_event_test.gd"
func snap(name: String) -> void:
 await frames();await RenderingServer.frame_post_draw
 check(root.get_texture().get_image().save_png("res://artifacts/phase3/"+name+".png")==OK,"capture "+name)
func find_input(node: Node) -> LineEdit:
 if node is LineEdit:return node
 for child in node.get_children():
  var result=find_input(child)
  if result!=null:return result
 return null
func enter_computer() -> void:
 var room=current_scene
 for i in range(600):
  if room.is_near_computer():break
  var offset=Vector2(95,175)-room.player_uv
  var screen=Vector2(2*(offset.x-offset.y),offset.x+offset.y)
  for code in [KEY_A,KEY_D,KEY_W,KEY_S]:
   var event=InputEventKey.new();event.physical_keycode=code
   event.pressed=(code==KEY_A and screen.x < -2) or (code==KEY_D and screen.x>2) or (code==KEY_W and screen.y < -2) or (code==KEY_S and screen.y>2)
   root.push_input(event,true)
  await process_frame
 for code in [KEY_A,KEY_D,KEY_W,KEY_S]:
  var event=InputEventKey.new();event.physical_keycode=code;event.pressed=false;root.push_input(event,true)
 await press_e()
 check(current_scene.scene_file_path=="res://scenes/desktop.tscn","room input enters computer")
func run() -> void:
 Engine.time_scale=3
 var w=root.get_node("WorldData");w.forced_story_roll=0.99;w.new_campaign();w.depart()
 check(w.unlocked_content.is_empty(),"new daytime campaign has no private night unlocks")
 check(not w.queue_followup("door_followup"),"locked followup cannot be queued")
 change_scene_to_file("res://scenes/city_delivery.tscn");await frames(30)
 await walk(Vector2(-0.8,7.5));await walk(Vector2(-0.8,0));await walk(Vector2(-9,-1));await press_e()
 check(w.location=="shop","shop visit recorded through actual entrance")
 await press_e();check(w.location=="city","shop returns to street")
 w.sync_unlocks();check(w.unlocked_content.is_empty(),"daytime visit does not reveal night-only information")
 w.accept_order("day_1_order_002");w.focus_order("day_1_order_001")
 await key_f();await await_route()
 check(w.daytime_orders.size()==2 and w.period=="day","two deliveries finish without automatic night transition")
 check(w.unlocked_content.is_empty(),"daytime deliveries remain gated until return home")
 await walk(Vector2(-0.8,-1));await walk(Vector2(-0.8,2));await walk(Vector2(0,8));await press_e()
 check(w.unlocked_content.has("door_followup") and w.unlocked_content.has("market_passage") and w.unlocked_content.has("shop_shelves"),"night unlocks match delivery and visited places")
 check(not w.unlocked_content.has("day2_door_video"),"day-two video remains locked on first night")
 check(w.unread_for("resident_07")==1 and w.unread_for("local_8")==1,"per-person unread messages match incoming delivery records")
 await enter_computer()
 current_scene.open_app("热榜");current_scene.selected_news=current_scene.content.news.size()-1;current_scene.rebuild("热榜")
 check(current_scene.content.news.size()==12,"visited places unlock two extra news records")
 await snap("07_unlocked_news")
 current_scene.open_app("动态")
 var card: Dictionary={}
 for post in current_scene.content.posts:
  if post.get("night_card_id","")=="door_followup":card=post
 check(not card.is_empty() and card.source.contains("来源") and card.source_event.begins_with("delivered_"),"unlocked post exposes traceable source")
 current_scene.show_post(card);await frames()
 await snap("01_source_and_followup")
 find_button(current_scene.windows["帖子详情"],"记录线索").pressed.emit();await frames()
 check(w.followups.size()==1 and int(w.followups[0].available_day)==2,"player explicitly queues next-day followup")
 check(not w.queue_followup("door_followup") and w.followups.size()==1,"followup button cannot duplicate task")
 check(w.active_followup().is_empty() and not w.complete_followup(),"night cannot complete a next-day visit")
 current_scene.open_app("消息");await frames()
 check(w.unread_for("resident_07")==0 and w.unread_for("local_8")==1,"visible contact read does not mark others read")
 var input=find_input(current_scene.windows["消息"]);input.text="明天我会到门口核对便签。"
 find_button(current_scene.windows["消息"],"发送").pressed.emit();await frames()
 check(w.desktop_state.chat.resident_07.size()==1,"send action stores local conversation")
 check(not w.send_chat("resident_07","   "),"empty chat is rejected")
 current_scene.windows["消息"].closed.emit();await frames();current_scene.open_app("消息");await frames()
 check(w.desktop_state.chat.resident_07.size()==1,"close/reopen does not duplicate chat")
 var chat_scroll=current_scene.windows["消息"].body.get_child(1).get_child(1);chat_scroll.scroll_vertical=int(chat_scroll.get_v_scroll_bar().max_value)
 await snap("02_persistent_messages")
 current_scene.desktop_notes.text="明日：七号门口核对便签";current_scene.desktop_notes.text_changed.emit()
 current_scene.ask("门铃");w.save_clue(w.assistant_history.back().text)
 check(w.save_game("user://phase3_night_test.json"),"save chat read notes assistant clues and scheduled visit")
 check(w.notes.contains("明日") and w.clues.size()>=2,"notes and clues share game state")
 find_button(current_scene,"开始 / 住所").pressed.emit();await frames()
 check(w.rest() and w.day==2,"night investigation advances to next day")
 w.depart();change_scene_to_file("res://scenes/city_delivery.tscn");await frames(30)
 check(not w.active_followup().is_empty() and current_scene.get_node("FollowupMarker").visible,"next-day goal is visible in city")
 check(not w.complete_followup(),"followup cannot be completed remotely")
 await walk(Vector2(0,2));await walk(Vector2(6,2));await walk(Vector2(6,-3.8))
 await snap("03_daytime_followup")
 var income=w.income();await press_e()
 check(w.followups[0].status=="completed" and is_equal_approx(w.income(),income),"actual E visit completes clue goal without delivery income")
 var records=w.events.size();await press_e();check(w.events.size()==records,"repeated visit cannot duplicate result")
 await snap("06_followup_completed")
 check(not w.unlocked_content.has("day2_door_video"),"next-day video is still gated during daytime")
 await key_f();await await_route()
 await walk(Vector2(6,0));await walk(Vector2(0,2));await walk(Vector2(0,8));await press_e()
 check(w.unlocked_content.has("day2_door_video"),"date-gated video unlocks on second night")
 await enter_computer();current_scene.open_app("视频");current_scene.video_index=6;current_scene.rebuild("视频");await snap("04_unlocked_video")
 check(current_scene.content.clips.size()==7,"new clip augments rather than replaces six public clips")
 check(w.save_game("user://phase3_completed_test.json"),"save completed followup and newly unlocked video")
 print("NIGHT SYSTEM FAILURES: ",failures)
 quit(1 if failures else 0)
