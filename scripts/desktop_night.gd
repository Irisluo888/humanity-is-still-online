extends "res://scripts/desktop_routes.gd"
var public_content: Dictionary={}
var chapter_thread="rider_group"
func _ready() -> void:
 super._ready()
 tasks.add_child(small_button("声音",func():LocalAudio.show_settings(self),65))
 if Chapter.session_active and not Chapter.state.is_empty():
  tasks.add_child(small_button("返回第一章",return_chapter,110))
  tasks.add_child(small_button("章节消息",chapter_inbox,90))
  var toast=preload("res://ui/notification_toast.gd").new();toast.desktop_mode=true;toast.position=Vector2(925,32);add_child(toast)
  toast.requested.connect(func(target):
   if target=="news":open_app("热榜")
   elif MessageManager.catalog.threads.has(target):
    chapter_thread=target;open_app("消息")
    if windows.has("消息"):
     var pane=windows["消息"].body.get_child(0)
     pane.open_thread(target))
 if Chapter.session_active and get_child_count()>2:get_child(2).text="第一章 / 住所电脑\n消息与手机同步，关闭窗口后返回房间。"
 if not WorldData.campaign:return
 public_content=content.duplicate(true)
 WorldData.sync_unlocks()
 apply_night_content()
func contact_index(person_id: String) -> int:
 for i in range(content.contacts.size()):
  if content.contacts[i].id==person_id:return i
 return 0
func apply_night_content() -> void:
 if public_content.is_empty():return
 content=public_content.duplicate(true)
 for post in content.posts:post.time="往期 / "+post.time
 for card in WorldData.night_catalog:
  if not WorldData.unlocked_content.has(card.id):continue
  var unlocked: Dictionary=WorldData.unlocked_content[card.id]
  var source="第%d晚解锁 · 来源：%s现场记录" % [int(unlocked.day),str(WorldData.places[card.place_id])]
  match card.kind:
   "post":content.posts.append({"id":"night_"+card.id,"author":contact_index(card.person_id),"time":"第%d晚" % int(unlocked.day),"kind":"单图","category":"配送","text":card.title+"\n"+card.text,"images":[card.image],"likes":0,"comments":["请以现场核对为准。"],"night_card_id":card.id,"source":source,"source_event":unlocked.source_event})
   "news":content.news.append({"id":"night_"+card.id,"rank":content.news.size()+1,"heat":80,"time":"第%d晚" % int(unlocked.day),"tag":"现场关联","title":card.title,"summary":card.text,"body":card.text+"\n\n"+source,"cover":card.image})
   "video":content.clips.append({"title":card.title,"author":contact_index(card.person_id),"description":card.text+"\n"+source,"comment":"门口位置仍需当面核对。","cover":card.image})
 unread.resize(content.contacts.size())
 for i in range(content.contacts.size()):unread[i]=WorldData.unread_for(content.contacts[i].id)
func image(parent: Node,file: String,dimensions: Vector2) -> void:
 if WorldData.campaign and file.begins_with("video_"):
  var index=int(file.trim_prefix("video_").trim_suffix(".png"))
  if index>=6 and index<content.clips.size():file="thumb_%d.png" % int(content.clips[index].get("cover",2))
 super.image(parent,file,dimensions)
func event_text() -> String:
 if not WorldData.campaign:return super.event_text()
 return "这条为往期公开缓存；今日配送见闻收工后在关联动态查看。"
func show_post(post: Dictionary) -> void:
 super.show_post(post)
 if not WorldData.campaign or not post.has("night_card_id"):return
 var page=windows["帖子详情"].body.get_child(0).get_child(0).get_child(0)
 copy(page,post.source,500,true)
 var source_label=page.get_child(page.get_child_count()-1)
 var id: String=post.night_card_id
 if WorldData.card_by_id(id).get("followup",false):
  var action=small_button("记录线索 / 预约次日回访",func():WorldData.queue_followup(id),240)
  page.add_child(action);page.move_child(action,2);page.move_child(source_label,3)
  copy(page,"回访不计配送收入，也不加入自动配送队列。",500,true)
 bind_focus(page,windows["帖子详情"])
func render_posts(feed: VBoxContainer) -> void:
 super.render_posts(feed)
 if not WorldData.campaign:return
 for child in feed.get_children():
  if child is Label and child.text.begins_with("关联订单：followup_"):child.text="关联记录：已完成的便签回访"
 for task in WorldData.followups:
  copy(feed,"回访线索 / "+task.text,420)
  copy(feed,"可进行日期：第%d天 · %s" % [int(task.available_day),"已核对" if task.status=="completed" else "待前往"],420,true)
func build_messages(body: HBoxContainer) -> void:
 if Chapter.session_active:
  chapter_messages(body);return
 if not WorldData.campaign:super.build_messages(body);return
 selected_contact=clampi(selected_contact,0,content.contacts.size()-1)
 var chosen: Dictionary=content.contacts[selected_contact]
 WorldData.read_contact(chosen.id)
 var people=scroll_box(body,220,"bcc8cd")
 copy(people,"联系人 / 已读随存档保存",195)
 var chat=VBoxContainer.new();chat.size_flags_horizontal=Control.SIZE_EXPAND_FILL;body.add_child(chat)
 for i in range(content.contacts.size()):
  var index: int=i;var contact: Dictionary=content.contacts[i]
  var count: int=WorldData.unread_for(contact.id);unread[i]=count
  var preview: String=contact.preview
  for message in WorldData.night_messages:
   if message.person_id==contact.id:preview=message.text
  if not WorldData.desktop_state.chat.get(contact.id,[]).is_empty():preview=WorldData.desktop_state.chat[contact.id].back().text
  var row=HBoxContainer.new();people.add_child(row);image(row,"avatar_%d.png" % i,Vector2(40,40))
  var button=small_button(contact.name+(" (%d)" % count if count>0 else "")+"\n"+preview.left(9),func():selected_contact=index;rebuild("消息"),145)
  button.alignment=HORIZONTAL_ALIGNMENT_LEFT;row.add_child(button);people.add_child(HSeparator.new())
 var heading=box(chat,"d2d8d5",10);copy(heading,chosen.name+" / 本地记录",440)
 var transcript=scroll_box(chat,470,"e0e0d9")
 copy(transcript,"往期记录",430,true)
 for i in range(chosen.history.size()):
  var seed: Dictionary=chosen.history[i];var stable_id="cache_%s_%03d"%[chosen.id,i]
  if not MessageManager.records.has(stable_id):
   MessageManager.queue_message({"id":stable_id,"thread_id":"legacy_"+chosen.id,"sender_id":"player" if seed.own else chosen.id,"text":seed.text,"sent_at":0,"cached":true,"display_time":seed.time})
   MessageManager.records[stable_id].display_order=MessageManager.next_display_order();MessageManager.records[stable_id].revealed=true;MessageManager.records[stable_id].read=true
 for message in MessageManager.get_thread_messages("legacy_"+chosen.id):
  timed_bubble(transcript,message.text,message.sender_id=="player",message.get("display_time",MessageManager.format_time(int(message.sent_at))))
 var composer=box(chat,"becad0",8);var row=HBoxContainer.new();composer.add_child(row)
 row.add_child(small_button("附件",func():WorldData.send_chat(chosen.id,"[本地附件] 配送备注 / "+WorldData.active_order_id),50))
 var input=LineEdit.new();input.placeholder_text="本地留言，保存后可跨重启恢复";input.size_flags_horizontal=Control.SIZE_EXPAND_FILL;row.add_child(input)
 var send=func():
  var text=input.text
  if not WorldData.send_chat(chosen.id,text) and not text.strip_edges().is_empty():WorldData.tell("留言请控制在1000字以内。")
 row.add_child(small_button("发送",send,55));input.text_submitted.connect(func(_value: String):send.call())
 bind_focus(body,windows["消息"])
func refresh() -> void:
 if not WorldData.campaign:super.refresh();return
 if public_content.is_empty():return
 apply_night_content()
 for app in windows:
  if app not in ["帖子详情","新闻详情"]:rebuild(app)
 if get_child_count()>2:get_child(2).text="HOME / 07\n"+WorldData.objective()

func build_video(body: HBoxContainer) -> void:
 super.build_video(body)
 if not WorldData.campaign:return
 var stage=body.get_child(1).get_child(0).get_child(0)
 for child in stage.get_children():
  if child is Label:
   child.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
   child.custom_minimum_size.x=520

func render_news(article: VBoxContainer) -> void:
 super.render_news(article)
 if not WorldData.campaign or not content.news[selected_news].has("cover"):return
 for child in article.get_children():
  if child is TextureRect:child.texture=load("res://assets/art/social/thumb_%d.png" % int(content.news[selected_news].cover))

func chapter_inbox() -> void:open_app("消息")
func return_chapter() -> void:
 Chapter.review_digital()
 get_tree().change_scene_to_file("res://scenes/ch01.tscn")
func chapter_messages(body: HBoxContainer) -> void:
 var pane=preload("res://ui/phone_messages.gd").new();pane.custom_minimum_size=Vector2(730,420);body.add_child(pane)
func build_news(body: HBoxContainer) -> void:
 if not Chapter.session_active:super.build_news(body);return
 var browser=preload("res://ui/news_panel.gd").new();browser.custom_minimum_size=Vector2(730,420);body.add_child(browser)

func _process(delta: float) -> void:
 super._process(delta)
 if Chapter.session_active and is_instance_valid(clock):clock.text=Chapter.clock_text()+" · 离线"
