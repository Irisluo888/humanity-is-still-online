extends PanelContainer
signal close_requested
signal app_requested(tab: String)
const P=preload("res://ui/phone/palette.gd")
const GROUPS=[["rider_group","night_group"],["xiaoyu","xiaoyu_late"],["zhou_warning"],["aqiang"],["laoma"]]
const PEOPLE={"aqiang":["阿强","A","骑手同事 · 外向健谈"],"chen":["陈姨","C","便利店老板"],"laoma":["老马","L","骑手驿站负责人"],"zhou":["老周","L","骑手前辈"],"lin":["林晓","L","联系人"],"xiaoyu":["小鱼","X","朋友 · 骑手"]}
@export_enum("聊天","通讯录","群聊","私聊") var initial_page="聊天"
var initial_thread=""
var page="聊天"
var column: VBoxContainer
var body: VBoxContainer
var list: VBoxContainer
var conversation: Control
var search: LineEdit
var composer: LineEdit
var selected_reply={}
var time_label: Label
var search_text=""
var seen_ranks={}
var navigation={}
func _ready():
 size_flags_horizontal=SIZE_EXPAND_FILL;size_flags_vertical=SIZE_EXPAND_FILL
 add_theme_stylebox_override("panel",P.style(Color("eee4f2"),30,16))
 var gradient=Gradient.new();gradient.colors=PackedColorArray([Color("eedcf5"),Color("fff1f2"),Color("e4e3f4")]);gradient.offsets=PackedFloat32Array([0,.53,1])
 var texture=GradientTexture2D.new();texture.gradient=gradient;texture.fill_from=Vector2.ZERO;texture.fill_to=Vector2(1,1)
 var bg=TextureRect.new();bg.texture=texture;bg.mouse_filter=MOUSE_FILTER_IGNORE;bg.set_anchors_and_offsets_preset(PRESET_FULL_RECT);add_child(bg)
 column=VBoxContainer.new();column.add_theme_constant_override("separation",9);add_child(column)
 var status=HBoxContainer.new();column.add_child(status);time_label=P.label("",13);time_label.size_flags_horizontal=SIZE_EXPAND_FILL;status.add_child(time_label)
 var island=PanelContainer.new();island.custom_minimum_size=Vector2(86,20);island.add_theme_stylebox_override("panel",P.style(Color("302a3b"),12,0));status.add_child(island)
 var indicators=P.label("▂▄▆  88%",11);indicators.size_flags_horizontal=SIZE_EXPAND_FILL;indicators.horizontal_alignment=HORIZONTAL_ALIGNMENT_RIGHT;status.add_child(indicators)
 var top=HBoxContainer.new();column.add_child(top);var brand=P.label("♡  消息  /  LOCAL MESSAGES",10,P.MUTED);brand.size_flags_horizontal=SIZE_EXPAND_FILL;top.add_child(brand);top.add_child(P.button("关闭",func():close_requested.emit()))
 body=VBoxContainer.new();body.size_flags_vertical=SIZE_EXPAND_FILL;column.add_child(body)
 var nav=HBoxContainer.new();column.add_child(nav)
 for item in ["聊天","通讯录","发现","我"]:
  var b=P.button(item,func():show_page(item));b.size_flags_horizontal=SIZE_EXPAND_FILL;nav.add_child(b);navigation[item]=b
 var home=CenterContainer.new();column.add_child(home);var bar=PanelContainer.new();bar.custom_minimum_size=Vector2(100,4);bar.add_theme_stylebox_override("panel",P.style(Color("73637e"),2,0));home.add_child(bar)
 MessageManager.changed.connect(refresh_list)
 if not initial_thread.is_empty():open_thread(initial_thread)
 elif initial_page=="群聊":open_thread("rider_group")
 elif initial_page=="私聊":open_thread("xiaoyu")
 else:show_page(initial_page)
func _process(_dt):
 if is_instance_valid(time_label):time_label.text=clock_text(MessageManager.current_minute)
func clock_text(minute: int) -> String:
 return "%02d:%02d"%[(minute%1440)/60,minute%60]
func clear_body():
 for child in body.get_children():body.remove_child(child);child.queue_free()
 list=null;conversation=null;search=null;composer=null;selected_reply={}
func heading(title: String,back: Callable=Callable()):
 var row=HBoxContainer.new();body.add_child(row)
 if back.is_valid():row.add_child(P.button("‹",back))
 var l=P.label(title,23);l.size_flags_horizontal=SIZE_EXPAND_FILL;row.add_child(l);row.add_child(preload("res://ui/phone/ornament.gd").new())
func make_list():
 var scroll=ScrollContainer.new();scroll.size_flags_vertical=SIZE_EXPAND_FILL;scroll.horizontal_scroll_mode=ScrollContainer.SCROLL_MODE_DISABLED;body.add_child(scroll)
 list=VBoxContainer.new();list.add_theme_constant_override("separation",6);list.size_flags_horizontal=SIZE_EXPAND_FILL;scroll.add_child(list)
func show_page(target: String):
 page=target;clear_body();search_text="";heading(target)
 for key in navigation:
  navigation[key].add_theme_stylebox_override("normal",P.style(Color("ecc9e2") if key==target else Color("ffffff66"),12,8))
 if target in ["聊天","通讯录"]:
  var row=HBoxContainer.new();body.add_child(row);search=LineEdit.new();search.placeholder_text="搜索会话" if target=="聊天" else "搜索联系人";search.size_flags_horizontal=SIZE_EXPAND_FILL;search.add_theme_stylebox_override("normal",P.style(Color("ffffff99"),12,9));search.add_theme_color_override("font_color",P.INK);search.add_theme_color_override("font_placeholder_color",P.MUTED);row.add_child(search)
  search.text_changed.connect(func(text):search_text=text;refresh_list())
  row.add_child(P.button("＋",func():show_page("通讯录")))
  make_list();refresh_list()
 elif target=="发现":
  body.add_child(P.wrap("生活里的线索，都在这里。",16,P.MUTED));make_list()
  for tab in ["接单","地图","新闻","背包","通知"]:list.add_child(P.button(tab,func():app_requested.emit(tab)))
 else:
  body.add_child(P.avatar("player",76));body.add_child(P.label("我 · 夜班骑手",21));body.add_child(P.wrap("本地通讯录与消息历史
手机与电脑同步已读状态。",16,P.MUTED))
  body.add_child(P.button("声音设置",func():LocalAudio.show_settings(self)))
func refresh_list():
 if not is_instance_valid(list) or page not in ["聊天","通讯录"]:return
 for child in list.get_children():list.remove_child(child);child.queue_free()
 if page=="通讯录":
  var grid=GridContainer.new();grid.columns=2;list.add_child(grid)
  for feature in ["新朋友","群聊","标签","星标朋友"]:
   var b=P.button("✧  "+feature,func():contact_feature(feature));b.size_flags_horizontal=SIZE_EXPAND_FILL;grid.add_child(b)
  var last_letter=""
  for id in PEOPLE:
   var info=PEOPLE[id]
   if not search_text.is_empty() and search_text not in info[0]:continue
   if info[1]!=last_letter:list.add_child(P.label(info[1],12,P.MUTED));last_letter=info[1]
   var row=preload("res://ui/phone/contact_item.gd").new();row.contact(id,info[0],info[2]);list.add_child(row);row.pressed.connect(profile.bind(id))
  return
 var entries=[]
 for group in GROUPS:
  var selected=group[0];var last={};var unread=0
  for id in group:
   unread+=MessageManager.get_unread_count(id);var messages=MessageManager.get_thread_messages(id)
   if not messages.is_empty() and (last.is_empty() or messages.back().get("display_order",0)>last.get("display_order",0)):last=messages.back();selected=id
  entries.append({"group":group,"id":selected,"last":last,"unread":unread,"rank":last.get("display_order",0)})
 entries.sort_custom(func(a,b):return a.rank>b.rank)
 for entry in entries:
  var title=thread_name(entry.id)
  if not search_text.is_empty() and search_text not in title:continue
  var sender=entry.last.get("sender_id","");var preview=entry.last.get("text","暂无消息")
  if not sender.is_empty():preview=MessageManager.catalog.contacts[sender].name+"："+preview
  var row=preload("res://ui/phone/list_item.gd").new();row.setup(contact_id(entry.id),title,preview,clock_text(int(entry.last.sent_at)) if not entry.last.is_empty() else "",entry.unread);row.set_meta("thread_id",entry.id);row.set_meta("unread",entry.unread);list.add_child(row);row.pressed.connect(open_thread.bind(entry.id))
  if seen_ranks.has(entry.group[0]) and entry.rank>seen_ranks[entry.group[0]]:row.arrival()
  seen_ranks[entry.group[0]]=entry.rank
 var notices=MessageManager.get_notifications();var unread=0
 for n in notices:
  if not n.get("read",false):unread+=1
 var system=preload("res://ui/phone/list_item.gd").new();system.setup("system","系统通知",notices.back().title if not notices.is_empty() else "暂无通知","",unread)
 if search_text.is_empty() or search_text in "系统通知":list.add_child(system);system.pressed.connect(func():app_requested.emit("通知"))
 else:system.queue_free()
func thread_name(id: String) -> String:
 return "临川夜班骑手互助群（86）" if id in ["rider_group","night_group"] else MessageManager.catalog.threads[id].name
func contact_id(id: String) -> String:
 if id in ["rider_group","night_group"]:return "group"
 if id=="zhou_warning":return "zhou"
 if id=="xiaoyu_late":return "xiaoyu"
 return id
func profile(id: String):
 page="资料";clear_body();heading("个人资料",func():show_page("通讯录"));body.add_child(P.avatar(id,90));body.add_child(P.label(PEOPLE[id][0],25));body.add_child(P.wrap("备注："+PEOPLE[id][0]+"
"+PEOPLE[id][2],17,P.MUTED))
 body.add_child(P.button("发消息",func():open_thread(latest_contact_thread(id))))
func latest_contact_thread(id: String) -> String:
 var result="zhou_warning" if id=="zhou" else id
 var rank=-1
 for group in GROUPS:
  if result not in group:continue
  for thread in group:
   var messages=MessageManager.get_thread_messages(thread)
   if not messages.is_empty() and messages.back().get("display_order",0)>rank:result=thread;rank=messages.back().get("display_order",0)
 return result
func contact_feature(feature: String):
 if feature=="群聊":open_thread("rider_group");return
 page=feature;clear_body();heading(feature,func():show_page("通讯录"))
 if feature=="星标朋友":
  for id in ["xiaoyu","zhou"]:body.add_child(P.button(PEOPLE[id][0],profile.bind(id)))
 elif feature=="标签":body.add_child(P.wrap("骑手同事：老周、阿强、老马、小鱼
生活联系：陈姨、林晓",17))
 else:body.add_child(P.wrap("暂无新的好友请求。联系人随剧情认识，不在此添加虚构用户。",16,P.MUTED))
func open_thread(id: String):
 if not MessageManager.catalog.threads.has(id):return
 page="对话";clear_body();
 for key in navigation:navigation[key].add_theme_stylebox_override("normal",P.style(Color("ecc9e2") if key=="聊天" else Color("ffffff66"),12,8))
 heading("骑手互助群 · 86" if id in ["rider_group","night_group"] else thread_name(id),func():show_page("聊天"))
 var options=HBoxContainer.new();body.add_child(options)
 options.add_child(P.button("更多",func():info("消息保存在本机，已读状态与电脑同步。")))
 for group in GROUPS:
  if id not in group:continue
  for other in group:
   if other!=id and not MessageManager.get_thread_messages(other).is_empty():options.add_child(P.button("往期会话",open_thread.bind(other)))
 var pane=preload("res://ui/message_panel.gd").new();pane.phone_skin=true;pane.auto_select=false;pane.thread_id=id;body.add_child(pane);pane.selector.hide();conversation=pane
 var row=HBoxContainer.new();body.add_child(row);row.add_child(P.button("＋",func():info("附件入口已预留；当前章节通过剧情接收图片。")))
 composer=LineEdit.new();composer.editable=false;composer.placeholder_text="选择上方回复";composer.size_flags_horizontal=SIZE_EXPAND_FILL;composer.add_theme_stylebox_override("normal",P.style(Color("ffffffbb"),12,7));composer.add_theme_stylebox_override("read_only",P.style(Color("ffffffbb"),12,7));composer.add_theme_color_override("font_placeholder_color",P.MUTED);composer.add_theme_color_override("font_uneditable_color",P.INK);row.add_child(composer)
 row.add_child(P.button("♡",func():info("当前使用剧情预设回复，暂不发送表情。")))
 row.add_child(P.button("发送",send_reply));row.add_child(P.button("♪",func():info("语音入口已预留；当前章节不录音。")))
 pane.reply_selected.connect(func(message_id,choice_id,text):selected_reply={"message":message_id,"choice":choice_id};composer.text=text)
func send_reply():
 if selected_reply.is_empty():info("请先选择一条剧情回复。");return
 MessageManager.choose_reply(selected_reply.message,selected_reply.choice);selected_reply={};composer.text=""
func info(text: String):
 var dialog=AcceptDialog.new();dialog.dialog_text=text;dialog.title="消息";add_child(dialog);dialog.confirmed.connect(dialog.queue_free);dialog.canceled.connect(dialog.queue_free);dialog.popup_centered(Vector2i(330,130))
