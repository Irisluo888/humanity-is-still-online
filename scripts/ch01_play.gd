extends Control
const Kit=preload("res://ui/kit.gd")
const ART="res://assets/art/ch01/"
var map_world: Node3D
var viewport: SubViewport
var overlay: Control
var dialogue: PanelContainer
var body_text: RichTextLabel
var hint: Label
var hud: Label
var phone: PanelContainer
var opened=false
var typing=0.0
var saved_notice=""
var notice_timer=0.0
var notification_toast: PanelContainer
var call_status_label: Label
var call_status_detail: Label
var call_answer: Button
var ui_scale: Control
var app_tab="消息"
var selected_thread="rider_group"
var phone_notification_target=""
var last_cue=""
var rebuild_queued=false
var guidance: Control
var task_card: PanelContainer
var task_title: Label
var task_detail: Label
var fault_remaining=0.0
var fault_panel: PanelContainer
func _ready() -> void:
 if Chapter.state.is_empty():Chapter.fresh()
 Chapter.updated.connect(request_rebuild)
 MessageManager.changed.connect(update_digital_hud)
 rebuild()
func button(parent: Node,text: String,fn: Callable) -> Button:
 var b=Kit.button(text,fn);b.add_theme_font_size_override("font_size",17);parent.add_child(b);return b
func label(parent: Node,text: String,width: int=0,size: int=18) -> Label:
 var l=Kit.label(text,size)
 if width>0:l.custom_minimum_size.x=width;l.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
 parent.add_child(l);return l
func style(panel: PanelContainer,color="253345") -> void:
 var s=StyleBoxFlat.new();s.bg_color=Color(color);s.border_color=Color("7a939b");s.set_border_width_all(2)
 for side in ["left","right","top","bottom"]:s.set("content_margin_"+side,12)
 panel.add_theme_stylebox_override("panel",s)
func request_rebuild() -> void:
 if rebuild_queued:return
 rebuild_queued=true;rebuild.call_deferred()
func rebuild() -> void:
 rebuild_queued=false
 opened=false
 for child in get_children():remove_child(child);child.queue_free()
 var bg=ColorRect.new();bg.color=Color("1d2c3c");bg.set_anchors_and_offsets_preset(PRESET_FULL_RECT);add_child(bg)
 ui_scale=Control.new();ui_scale.size=Vector2(1280,720);add_child(ui_scale)
 viewport=SubViewport.new();viewport.size=Vector2i(640,360);viewport.own_world_3d=true;viewport.render_target_update_mode=SubViewport.UPDATE_ALWAYS;ui_scale.add_child(viewport)
 map_world=load(Chapter.MAPS[Chapter.state.place]).instantiate();viewport.add_child(map_world);map_world.hotspot.connect(interact_point)
 var view=TextureRect.new();view.texture=viewport.get_texture();view.size=Vector2(1280,720);view.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST;view.mouse_filter=MOUSE_FILTER_IGNORE;ui_scale.add_child(view)
 var top=PanelContainer.new();top.position=Vector2(20,16);top.size=Vector2(1240,68);style(top);ui_scale.add_child(top)
 var row=HBoxContainer.new();top.add_child(row)
 label(row,"有人在敲门  /  "+str(Chapter.catalog.places[Chapter.state.place]),0,22)
 var spacer=Control.new();spacer.size_flags_horizontal=SIZE_EXPAND_FILL;row.add_child(spacer)
 label(row,Chapter.clock_text(),0,16)
 hud=label(row,digital_hud_text(),0,17)
 hint=Kit.label(objective(),18);hint.position=Vector2(24,98);ui_scale.add_child(hint)
 var bottom=HBoxContainer.new();bottom.position=Vector2(24,666);bottom.add_theme_constant_override("separation",12);ui_scale.add_child(bottom)
 button(bottom,"手机 P",func():show_phone(false)).disabled=Chapter.modal()
 button(bottom,"背包 B",func():show_phone(false,"背包")).disabled=Chapter.modal()
 button(bottom,"立即回家",func():Chapter.fast_home()).disabled=Chapter.modal() or Chapter.state.place=="home"
 button(bottom,"保存",func():
  notice("已保存第一章" if Chapter.save() else "保存失败，请检查本地目录"))
 button(bottom,"菜单",func():get_tree().change_scene_to_file("res://scenes/start.tscn")).disabled=Chapter.modal()
 if Chapter.state.flags.get("ch01_complete",false):ending()
 elif Chapter.state.encounter:encounter_ui()
 elif Chapter.state.event_active:show_dialogue()
 var toast=preload("res://ui/notification_toast.gd").new();toast.position=Vector2(925,92);toast.allow_display=func():return not opened
 if Chapter.modal():toast.position=Vector2(20,150)
 notification_toast=toast;ui_scale.add_child(toast)
 toast.requested.connect(func(target):
  if Chapter.modal():return
  if opened:
   if is_instance_valid(phone):phone.queue_free()
   opened=false
  if MessageManager.catalog.threads.has(target):selected_thread=target;phone_notification_target=target;show_phone(false,"消息")
  elif target=="news":show_phone(false,"新闻"))
 map_world.locked=Chapter.modal()
 build_guidance()
 if Chapter.state.flags.get("morning_transition_pending",false):
  Chapter.state.flags.morning_transition_pending=false;show_morning_transition()
 if Chapter.beat().id=="repair" and not Chapter.state.flags.get("bike_fault_shown",false):
  Chapter.state.flags.bike_fault_shown=true;fault_remaining=3.5
  fault_panel=PanelContainer.new();fault_panel.position=Vector2(330,145);style(fault_panel);ui_scale.add_child(fault_panel)
  var fault_box=VBoxContainer.new();fault_panel.add_child(fault_box)
  label(fault_box,"电动车突然断电",0,26)
  var closeup=preload("res://ui/ch01_closeup.gd").new();closeup.custom_minimum_size=Vector2(600,288);fault_box.add_child(closeup)
  label(fault_box,"接线松动了……推到骑手驿站，请老周帮忙。",570,21)
func show_morning_transition() -> void:
 fault_remaining=4.0
 var curtain=ColorRect.new();curtain.color=Color("101c30");curtain.size=Vector2(1280,720);curtain.z_index=110;ui_scale.add_child(curtain)
 var title=label(curtain,"第二天 · 清晨",0,42);title.position=Vector2(460,270)
 var subtitle=label(curtain,"雨停了一会儿。该出门取餐，开始今天的配送了。",0,24);subtitle.position=Vector2(325,345)
 curtain.modulate.a=0
 var tween=create_tween();tween.tween_property(curtain,"modulate:a",1.0,0.5)
 tween.tween_property(curtain,"color",Color("6b8795"),1.8)
 tween.tween_interval(0.7);tween.tween_property(curtain,"modulate:a",0.0,1.0);tween.tween_callback(curtain.queue_free)
func build_guidance() -> void:
 guidance=preload("res://ui/ch01_guidance.gd").new();guidance.world=map_world;ui_scale.add_child(guidance)
 task_card=PanelContainer.new();task_card.position=Vector2(24,520);task_card.custom_minimum_size=Vector2(520,126);style(task_card,"30495a");ui_scale.add_child(task_card)
 var row=HBoxContainer.new();row.add_theme_constant_override("separation",16);task_card.add_child(row)
 var icon=TextureRect.new();icon.texture=load(ART+"delivery_scooter.png");icon.custom_minimum_size=Vector2(94,80);icon.expand_mode=TextureRect.EXPAND_IGNORE_SIZE;icon.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED;icon.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST;row.add_child(icon)
 var col=VBoxContainer.new();row.add_child(col);task_title=label(col,"",360,24);task_detail=label(col,"",360,18)
func update_guidance() -> void:
 if not is_instance_valid(task_card):return
 var stage=Chapter.beat().id
 var target=""
 var heading=""
 var detail=""
 if stage=="delivery":target="delivery";heading="最后一单 · 送到临街民居";detail="WASD移动，跟随金色路标。\n到达门前后按 E 交付餐食。"
 elif stage=="repair":target="repair";heading="电动车故障 · 找老周";detail="前往骑手驿站，靠近老周按 E。\n位置在街道中央，金色路标已更新。"
 elif stage=="group" and Chapter.state.place=="street":target="home";heading="车修好了 · 回家报平安";detail="沿金色路标回住所，靠近入口按 E。"
 if not map_world.points.has(target):target=""
 task_card.visible=not target.is_empty() and not opened and not Chapter.modal() and fault_remaining<=0
 guidance.visible=task_card.visible;guidance.target=target
 task_title.text=heading;task_detail.text=detail
func digital_hud_text() -> String:
 var unseen=0
 for id in MessageManager.catalog.threads:unseen+=MessageManager.get_unread_count(id)
 return "生命 %d  体力 %d  负重 %.1f/8kg  耐久 %d%s"%[WorldData.health,WorldData.stamina,Chapter.weight(),Chapter.state.durability,("  感染暴露" if Chapter.state.exposure else "")+("  新消息%d"%unseen if unseen else "")]
func update_digital_hud() -> void:
 if is_instance_valid(hud):hud.text=digital_hud_text()
func objective() -> String:
 if saved_notice.is_empty():
  if Chapter.beat().id=="1203" and Chapter.state.place=="hallway12":return "12楼：靠近1203门口，按E交付餐食。"
  if Chapter.beat().id=="1404" and Chapter.state.place=="hallway":return "14楼：靠近1404门口，按E查看纸条。"
 var objectives={"delivery":"餐食已在箱中：前往右上方临街民居，靠近黄色送餐标记按E。","repair":"电动车故障：到驿站修车摊找老周。","group":"回家后在电脑或手机里读完骑手群。","lunch":"查看小鱼的私信。","orders":"出门，到取餐窗口领取幸福花园1203餐食；普通订单可在手机查看。","1203":"到幸福花园三栋入口，给1203交付。","1404":"从12楼楼梯前往14楼，再到1404门前查看。","elevator":"电梯下行中。","store":"从小区进入陈姨便利店，先观察环境，再接近柜台。","night":"回家查看骑手群和新闻，之后到床边休息。","knock1":"门外有人。","call":"手机响了。","reveal":"再次确认门外的人。","final":"决定如何帮助老周。","end":"回复骑手群，再查看章末消息。"}
 return saved_notice if not saved_notice.is_empty() else objectives.get(Chapter.beat().id,"")
func show_dialogue() -> void:
 if Chapter.page().get("visual","")=="elevator_hand":
  var closeup=preload("res://ui/ch01_closeup.gd").new();closeup.mode="hand";closeup.position=Vector2(340,130);closeup.custom_minimum_size=Vector2(600,288);ui_scale.add_child(closeup)
 if Chapter.beat().id in ["call","reveal","final"] or (Chapter.beat().id=="knock1" and Chapter.state.page>=1):
  var eye=load("res://scripts/ch01_peephole.gd").new();eye.position=Vector2(300,86);eye.size=Vector2(700,550);eye.clip_contents=true;eye.revealed=Chapter.beat().id in ["reveal","final"];eye.stage=10 if Chapter.beat().id!="knock1" else int(Chapter.state.page);ui_scale.add_child(eye)
 dialogue=PanelContainer.new();dialogue.position=Vector2(100,448);dialogue.size=Vector2(1080,200);style(dialogue,"202e40");ui_scale.add_child(dialogue)
 var row=HBoxContainer.new();row.add_theme_constant_override("separation",18);dialogue.add_child(row)
 var page: Dictionary=Chapter.page()
 var cue=page.get("cue","")
 var cue_id=Chapter.beat().id+str(Chapter.state.page)
 if not cue.is_empty() and last_cue!=cue_id:
  last_cue=cue_id
  var audio=AudioStreamPlayer.new();audio.stream=load("res://assets/audio/ch01/"+cue+".wav");audio.volume_db=-10;add_child(audio);audio.finished.connect(audio.queue_free);audio.play()
 var portrait=TextureRect.new();portrait.custom_minimum_size=Vector2(76,144);portrait.expand_mode=TextureRect.EXPAND_IGNORE_SIZE;portrait.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED;portrait.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
 if not page.portrait.is_empty():portrait.texture=load("res://assets/art/refined/rider_uniform.png" if page.portrait=="rider" else ART+page.portrait+".png")
 row.add_child(portrait)
 var box=VBoxContainer.new();box.size_flags_horizontal=SIZE_EXPAND_FILL;row.add_child(box)
 label(box,page.speaker,0,20)
 body_text=RichTextLabel.new();body_text.bbcode_enabled=false;body_text.text=page.text;body_text.custom_minimum_size=Vector2(900,82);body_text.fit_content=true;body_text.scroll_active=false;body_text.add_theme_font_size_override("normal_font_size",21);box.add_child(body_text);typing=0;body_text.visible_characters=0
 if Chapter.beat().id=="call":
  var call_card=PanelContainer.new();call_card.position=Vector2(980,130);call_card.size=Vector2(260,210);style(call_card);ui_scale.add_child(call_card)
  var call_box=VBoxContainer.new();call_card.add_child(call_box);call_status_label=label(call_box,"来电 · 老周",0,24)
  call_status_detail=label(call_box,"等待接听……" if Chapter.state.page==0 else "电话接通，留意门外的动静。",230,17)
  if Chapter.state.page==0:call_answer=button(call_box,"接听",continue_dialogue)
  else:label(call_box,"通话中……",230)
 var choices=HBoxContainer.new();choices.add_theme_constant_override("separation",8);box.add_child(choices)
 if Chapter.state.page<Chapter.beat().pages.size()-1:button(choices,"继续 / 空格",continue_dialogue)
 else:build_choices(box)
func continue_dialogue() -> void:
 if is_instance_valid(body_text) and body_text.visible_characters>=0 and body_text.visible_characters<body_text.get_total_character_count():typing=999;body_text.visible_characters=-1;return
 if Chapter.beat().id=="call" and Chapter.state.page==0:
  MessageManager.answer_call("zhou_door_call")
 if Chapter.step_page():return
 if Chapter.beat().id not in ["1203","lunch","store","final","end"]:finish()
func finish(choice="continue") -> void:Chapter.next(choice)
func build_choices(box: VBoxContainer) -> void:
 var id: String=Chapter.beat().id
 match id:
  "1203":
   button(box,"去14楼看看（可选）",func():finish())
   button(box,"直接下楼",func():finish("skip"))
  "lunch":
   button(box,"答应午餐",func():finish("yes"));button(box,"明天再说",func():finish("no"))
  "store":
   button(box,"使用武器 / 耐久-3",func():finish("weapon")).disabled=Chapter.state.durability<3
   button(box,"使用柜台旁灭火器（用后耗尽）",func():finish("extinguisher")).disabled=Chapter.state.flags.get("extinguisher_used",false)
   button(box,"徒手救援 / 生命-25",func():finish("hands"))
   button(box,"逃离现场 / 陈姨未获救",func():finish("leave"))
  "final":
   for pair in [["联系医疗救援","quarantine"],["联系老马和小鱼","colleague_help"],["隔门提供医疗物资（需1）","aid_pending"],["拒绝开门","missing"]]:
    var key: String=pair[1];button(box,pair[0],func():finish(key)).disabled=key=="aid_pending" and WorldData.inventory.medicine<1
   button(box,"直接开门 / 特殊高风险",confirm_open)
  "end":
   button(box,"向群里公开",func():finish("public"));button(box,"暂时隐瞒",func():finish("private"))
  _:button(box,"继续 / 空格",continue_dialogue)
 # Choices grow upward so nothing crosses the bottom HUD.
 dialogue.position.y=448 if id not in ["store","final"] else 300
func confirm_open() -> void:
 var dialog=ConfirmationDialog.new();dialog.dialog_text="开门会触发特殊高风险接触，可能受伤并记录感染暴露。确认？";add_child(dialog);dialog.confirmed.connect(func():finish("opened_door"));dialog.popup_centered(Vector2i(500,180))
func ending() -> void:
 var p=PanelContainer.new();p.position=Vector2(270,210);p.size=Vector2(740,300);style(p);ui_scale.add_child(p)
 var box=VBoxContainer.new();p.add_child(box);label(box,"第一章 · 有人在敲门 — 完",0,30)
 label(box,Chapter.catalog.outcomes.get(Chapter.state.flags.get("ch01_zhou_outcome",""),""),680,21)
 label(box,"临川市多地出现异常暴力事件。部分区域配送暂停。
冰箱里的食物和饮水有限，你需要为明天作准备。",680)
 label(box,"你"+("已经向骑手群说明情况。" if Chapter.state.flags.get("ch01_told_group",false) else "暂时没有公开老周的去向。"),680)
func encounter_ui() -> void:
 var p=PanelContainer.new();p.position=Vector2(300,230);p.size=Vector2(680,330);style(p);ui_scale.add_child(p)
 var box=VBoxContainer.new();p.add_child(box);label(box,"近距离接触 / 必须先脱离",0,24)
 button(box,"逃跑 / 成功率%d%%"%int(Chapter.escape_chance()*100),func():Chapter.resolve_encounter("escape"))
 button(box,"使用装备 / 耐久-2",func():Chapter.resolve_encounter("weapon")).disabled=Chapter.state.durability<2
 button(box,"饮水防护 / 水-1",func():Chapter.resolve_encounter("protect")).disabled=WorldData.inventory.water<1
 button(box,"强行挣脱 / 生命与体力-10",func():Chapter.resolve_encounter("force"))
 label(box,"普通接触不产生感染暴露；失败也能脱离。",620)
func show_phone(computer=false,tab="消息") -> void:
 if Chapter.modal() or opened or fault_remaining>0:return
 opened=true;app_tab=tab;map_world.locked=true
 if is_instance_valid(notification_toast):notification_toast.hide()
 phone=PanelContainer.new();phone.position=Vector2(700,104) if not computer else Vector2(120,100);phone.size=Vector2(540,540) if not computer else Vector2(1040,540);style(phone);ui_scale.add_child(phone)
 render_phone(computer)
func render_phone(computer: bool=false) -> void:
 for node in phone.get_children():phone.remove_child(node);node.queue_free()
 var col=VBoxContainer.new();phone.add_child(col)
 var row=HBoxContainer.new();col.add_child(row);label(row,"本地电脑" if computer else "本地手机 / 离线",0,22)
 button(row,"关闭",close_phone)
 var tabs=HBoxContainer.new();col.add_child(tabs)
 for name in ["消息","接单","地图","新闻","背包","通知"]:
  var selected: String=name;button(tabs,name,func():app_tab=selected;render_phone(computer)).custom_minimum_size.x=70
 var scroll=ScrollContainer.new();scroll.custom_minimum_size=Vector2(490 if not computer else 980,410);scroll.size_flags_vertical=SIZE_EXPAND_FILL;col.add_child(scroll)
 var box=VBoxContainer.new();box.custom_minimum_size.x=460 if not computer else 940;scroll.add_child(box)
 var width=450 if not computer else 920
 match app_tab:
  "消息":
   scroll.vertical_scroll_mode=ScrollContainer.SCROLL_MODE_DISABLED
   var pane=preload("res://ui/phone_messages.gd").new();pane.initial_thread=phone_notification_target;phone_notification_target="";pane.custom_minimum_size=Vector2(width,380);box.add_child(pane)
  "新闻":
   scroll.vertical_scroll_mode=ScrollContainer.SCROLL_MODE_DISABLED
   var browser=preload("res://ui/news_panel.gd").new();browser.custom_minimum_size=Vector2(width,375);box.add_child(browser)
  "接单":
   label(box,"本段配送收入 ¥%.2f · 可用金额 ¥%.2f"%[WorldData.income(),Chapter.state.money],width)
   for order in WorldData.orders:
    label(box,order.item+" → "+order.address+"
"+order.status,width)
    var order_id: String=order.id
    if order.status=="可接单":button(box,"接受这笔订单",func():WorldData.accept_order(order_id);render_phone(computer))
    elif order.status in ["待取餐","配送中"]:button(box,"追踪这笔订单",func():WorldData.focus_order(order_id);render_phone(computer))
  "地图":
   label(box,"当前位置："+Chapter.catalog.places[Chapter.state.place],width,22)
   label(box,"住处 ↔ 老城区街道 ↔ 幸福花园 ↔ 便利店
三栋入口 → 12楼1203交付 → 可选楼梯前往14楼 → 电梯下楼
靠近场景标记按E交互。",width)
  "通知":
   for n in MessageManager.get_notifications():
    label(box,n.title+" · "+MessageManager.format_time(int(n.at))+"\n"+n.text,width,17)
    MessageManager.read_notification(n.id);box.add_child(HSeparator.new())
  "背包":
   label(box,"携带 %.1f / 8kg · 装备耐久 %d"%[Chapter.weight(),Chapter.state.durability],width)
   for pair in [["饭团","food"],["饮水","water"],["医疗物资","medicine"]]:
    var item: String=pair[1];button(box,pair[0]+" ×%d / 使用"%WorldData.inventory[item],func():Chapter.use_item(item))
func close_phone() -> void:
 if is_instance_valid(phone):phone.queue_free()
 opened=false;map_world.locked=false
 Chapter.review_digital()
 request_rebuild()
func notice(text: String) -> void:
 saved_notice=text;notice_timer=4;hint.text=text
func travel(place: String) -> void:
 var reason=Chapter.travel_reason(place)
 if not reason.is_empty():notice(reason);return
 Chapter.enter(place)
func interact_point(id: String) -> void:
 if Chapter.modal() or opened or fault_remaining>0:return
 saved_notice=""
 var beat: String=Chapter.beat().id
 match id:
  "home":travel("home")
  "street":travel("street")
  "garden":travel("garden")
  "store":travel("store")
  "exit":travel("garden" if Chapter.state.place=="store" else "street")
  "pc":get_tree().change_scene_to_file("res://scenes/desktop.tscn")
  "door":
   if Chapter.state.place=="home":travel("street")
   elif Chapter.state.place=="hallway":Chapter.start_event()
  "bed":
   if beat=="night" and Chapter.state.flags.get("night_read",false):
    Chapter.start_event()
   else:notice("先查看晚间骑手群、老周和小鱼的新消息，再休息。")
  "repair":
   if beat=="repair":Chapter.start_event()
   else:notice("老周修过的接线还牢固。")
  "pickup":
   if beat in ["orders","1203"]:
    var chosen: Dictionary=WorldData.current_order()
    if chosen.is_empty() or chosen.status not in ["待取餐","配送中"]:
     chosen=WorldData.order_by_id("order_ch01_003")
     if chosen.status=="可接单":WorldData.accept_order(chosen.id)
    WorldData.active_order_id=chosen.id;WorldData.location="city";WorldData.period="day";WorldData.city_position=WorldData.SHOP
    if WorldData.pickup_order():
     if chosen.id=="order_ch01_003" and beat=="orders":Chapter.next()
     notice("已取餐："+chosen.address)
    else:notice("餐食已领取，请前往收餐处。")
  "delivery":
   if beat=="delivery":
    var order: Dictionary=WorldData.current_order()
    if order.is_empty():notice("订单不存在，请读取存档或重新开始。");return
    if order.status=="待取餐":order.status="配送中"
    WorldData.location="city";WorldData.period="day";WorldData.city_position=WorldData.delivery_target()
    if Chapter.complete_delivery(order.id):
     Chapter.next();notice("已送达，收入已到账。电动车接线故障：到中间驿站找老周修车（E）。")
    elif order.status=="已送达":Chapter.next()
    else:notice("交付未成功，请检查手机中的订单状态。")
   elif beat in ["orders","1203"]:
    var selected: Dictionary=WorldData.current_order()
    if selected.id!="order_ch01_003" and selected.status=="配送中":
     WorldData.location="city";WorldData.period="day";WorldData.city_position=WorldData.delivery_target()
     if Chapter.complete_delivery(selected.id):notice("普通配送已完成。可继续接单或送1203。")
    else:notice("1203需从幸福花园三栋入口送上楼。")
  "building":
   if beat=="1404":travel("hallway12")
   elif beat=="1203":
    var main=WorldData.order_by_id("order_ch01_003")
    if main.status!="配送中":notice("请先去取餐窗口领取1203的餐食。");return
    WorldData.active_order_id=main.id;WorldData.location="city";WorldData.period="day";WorldData.city_position=WorldData.delivery_target()
    Chapter.enter("hallway12")
   else:notice("三栋门口暂时没有需要配送的订单。")
  "resident":
   if Chapter.state.place=="hallway12" and beat=="1203":
    var main=WorldData.order_by_id("order_ch01_003")
    WorldData.active_order_id=main.id;WorldData.location="city";WorldData.period="day";WorldData.city_position=WorldData.delivery_target()
    if main.status=="已送达" or Chapter.complete_delivery(main.id):Chapter.start_event()
  "up14":
   if beat=="1404":travel("hallway")
   else:notice("请先到1203门口交付餐食。")
  "extinguisher":Chapter.state.flags.extinguisher_seen=true;notice("柜台旁挂着灭火器，紧急时可以取用。")
  "attack":
   if beat=="store":Chapter.start_event()
   else:notice("柜台已经清理，便利店暂停营业。")
  "supplies":
   if Chapter.buy("water"):notice("已购买饮水，支出3元。")
   else:notice("容量不足、库存不足或便利店已停业。")
  "shop":
   if beat=="store":
    Chapter.state.flags.extinguisher_seen=true;Chapter.start_event()
   elif Chapter.buy("water"):notice("购买饮水成功，支出3元。")
   else:notice("暂时无法购买。")
  "rack":notice("三份1404外卖：交易号A014、A027、A039。地址相同，交易编号不同。")
  "board":notice("近期楼道异味请注意卫生。手写：已经好几天了，你们到底管不管？")
  "guard":notice("门卫：三栋从花园北侧进去，便利店在右边。")
  "supply":
   if Chapter.collect_loose("street_water","water"):notice("拾取饮水，负重增加0.5kg。")
   else:notice("已经取走，或背包容量不足。")
  "photo":notice("照片上是刚入行时的你和老周。他教过你修车，也送你回过家。")
  "fridge":notice("冰箱里有饭团和饮水，可在背包中使用。")
  "storage":
   if Chapter.repair_weapon():notice("装备修复，消耗一份食物和饮水。")
   else:notice("装备完好，或缺少维修物资。")
  _:notice("这里留下了熟悉的生活痕迹。")
func _process(delta: float) -> void:
 if fault_remaining>0:
  fault_remaining=maxf(0,fault_remaining-delta)
  if fault_remaining==0 and is_instance_valid(fault_panel):fault_panel.queue_free()
 update_guidance()
 if is_instance_valid(call_status_label):
  var answered=MessageManager.calls.get("zhou_door_call",{}).get("status","")=="answered"
  call_status_label.text="通话中 · 老周" if answered else "来电 · 老周"
  if is_instance_valid(call_status_detail):call_status_detail.text="电话接通，留意门外的动静。" if answered else "等待接听……"
  if is_instance_valid(call_answer):call_answer.visible=not answered
 if notice_timer>0:
  notice_timer-=delta
  if notice_timer<=0:saved_notice=""
 if is_instance_valid(ui_scale):ui_scale.scale=size/Vector2(1280,720)
 if is_instance_valid(map_world):
  map_world.locked=opened or Chapter.modal() or fault_remaining>0
  if not Chapter.modal() and not opened and saved_notice.is_empty():hint.text=map_world.hint if not map_world.hint.is_empty() else objective()
 if is_instance_valid(body_text):
  typing+=delta*38;body_text.visible_characters=int(typing)
func _notification(what: int) -> void:
 if what==NOTIFICATION_APPLICATION_FOCUS_OUT and is_instance_valid(map_world):map_world.held.clear()
func _input(event: InputEvent) -> void:
 if event is InputEventKey and is_instance_valid(map_world):
  map_world.held[event.physical_keycode]=event.pressed
  if event.pressed and not event.echo and event.physical_keycode in [KEY_SPACE,KEY_ENTER,KEY_E] and Chapter.state.event_active:
   continue_dialogue();get_viewport().set_input_as_handled()
func _unhandled_key_input(event: InputEvent) -> void:
 if not event is InputEventKey or not event.pressed or event.echo:return
 if event.physical_keycode==KEY_P:
  if opened:close_phone()
  else:show_phone()
 if event.physical_keycode==KEY_B and not opened:show_phone(false,"背包")

 if event.physical_keycode==KEY_E and not Chapter.modal() and not opened and fault_remaining<=0:map_world.interact()
 if event.physical_keycode==KEY_F8 and OS.is_debug_build() and Chapter.developer_mode:debug_menu()
func debug_menu() -> void:
 if not Chapter.developer_mode:return
 var dialog=AcceptDialog.new();dialog.title="开发调试 / 默认关闭";var box=VBoxContainer.new();dialog.add_child(box)
 for pair in [["修车",1],["群聊",2],["花园",5],["电梯",7],["便利店",8],["夜间",9],["敲门",10],["结尾",14]]:
  var i: int=pair[1];button(box,pair[0],func():dialog.queue_free();Chapter.debug_jump(i))
 add_child(dialog);dialog.popup_centered(Vector2i(330,430))
