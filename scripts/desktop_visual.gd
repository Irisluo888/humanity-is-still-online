extends "res://scripts/desktop.gd"
const ART = "res://assets/pixel_desktop/"
var active_category := "全部"
var selected_contact := 0
var chat_history: Dictionary = {}
var liked: Dictionary = {}
var unread: Array = [1,1,1,0,0,0,0,0]
var names := ["七号住户", "站点值班员", "楼道邻居", "修伞的人", "晚班店员", "旧书摊主", "窗台园丁", "系统通知"]
func _ready() -> void:
 super._ready()
 var theme_data = theme
 for type in ["Button", "LineEdit"]:
  for state in ["normal", "hover", "pressed", "focus", "disabled"]:
   var style = StyleBoxFlat.new()
   style.bg_color = Color("35465a") if state != "hover" else Color("52677c")
   style.border_color = Color("83919e")
   style.set_border_width_all(1)
   style.set_content_margin_all(6)
   theme_data.set_stylebox(state,type,style)
 var wall: TextureRect = get_child(0)
 wall.texture = load(ART + "wallpaper.png")
 var icons = get_child(1)
 for i in range(6):
  var button: Button = icons.get_child(i)
  button.icon = load(ART + "app_%d.png" % i)
  button.custom_minimum_size = Vector2(100,66)
  button.expand_icon = true
  button.add_theme_constant_override("icon_max_width",32)
  button.add_theme_stylebox_override("normal",StyleBoxEmpty.new())
 var widget = PanelContainer.new()
 widget.position = Vector2(1010,40)
 widget.size = Vector2(240,120)
 add_child(widget)
 var notes = VBoxContainer.new()
 widget.add_child(notes)
 notes.add_child(Kit.label("  本地便笺 / DAY 00",18))
 notes.add_child(Kit.label("  □ 核对配送记录\n  □ 查看街坊留言\n  网络：离线缓存可用",16))
 move_child(widget,2)
func open_app(app: String) -> void:
 var existed = windows.has(app)
 super.open_app(app)
 var frame: Control = windows[app]
 if not existed:
  frame.custom_minimum_size = Vector2(880,530) if app == "动态" else (Vector2(660,470) if app == "消息" else Vector2(740,410))
  frame.size = frame.custom_minimum_size
  frame.position = Vector2(145,100) if app == "动态" else Vector2(570,210)
  frame.position.x = minf(frame.position.x,1280-frame.size.x)
  var titlebar = frame.get_child(0).get_child(0)
  for j in [1,2]:
   var control: Button = titlebar.get_child(j)
   control.text = ""
   control.icon = load(ART + ("minimize.png" if j == 1 else "close.png"))
  frame.resized.connect(func(): clamp_frame(frame))
  clamp_frame(frame)
func picture(parent: Node, file: String, dimensions: Vector2) -> void:
 var image = TextureRect.new()
 image.texture = load(ART + file)
 image.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
 image.custom_minimum_size = dimensions
 image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
 image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
 parent.add_child(image)
func copy(parent: Node, value: String, width: float, muted: bool = false) -> Label:
 var label = Label.new()
 label.text = value
 label.add_theme_color_override("font_color", Color("647182") if muted else Color("263347"))
 label.add_theme_font_size_override("font_size",16)
 label.custom_minimum_size.x = width
 label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
 parent.add_child(label)
 return label
func paper(parent: Node, width: float) -> VBoxContainer:
 var panel = PanelContainer.new()
 panel.custom_minimum_size.x = width
 var style = StyleBoxFlat.new()
 style.bg_color = Color("d7d9d5")
 style.set_content_margin_all(12)
 panel.add_theme_stylebox_override("panel",style)
 parent.add_child(panel)
 var box = VBoxContainer.new()
 box.add_theme_constant_override("separation",8)
 panel.add_child(box)
 return box
func populate(app: String, body: HBoxContainer) -> void:
 if app != "动态" and app != "消息":
  super.populate(app,body)
  return
 body.add_theme_constant_override("separation",2)
 if app == "动态": build_feed(body)
 else: build_messages(body)
func build_feed(body: HBoxContainer) -> void:
 var nav = column(body,120)
 var menu = paper(nav,120)
 copy(menu,"街坊 / LOCAL",90,true)
 var feed = column(body,460)
 var side = paper(column(body,220),215)
 for category in ["全部", "邻里", "配送"]:
  var choice: String = category
  var button = Kit.button(category,func(): active_category = choice; render_posts(feed))
  button.custom_minimum_size.x = 90
  menu.add_child(button)
 copy(side,"附近便笺",180)
 picture(side,"thumb_2.png",Vector2(180,99))
 copy(side,str(WorldData.places.lane_07),180)
 copy(side,"共享配送记录\n" + str(WorldData.orders[0].id),180,true)
 copy(side,"认识的街坊",180)
 var people = HBoxContainer.new()
 side.add_child(people)
 for i in range(4): picture(people,"avatar_%d.png" % i,Vector2(38,38))
 copy(side,"只显示本机缓存\n信息仍需现场核实。",180,true)
 render_posts(feed)
func render_posts(feed: VBoxContainer) -> void:
 for child in feed.get_children():
  feed.remove_child(child)
  child.queue_free()
 var posts = ["楼下的门铃还没修好。送东西的朋友，请敲两下。", "雨伞晾在楼道左侧，请留出通行的位置。", "晚班结束，记得核对箱里的保温袋。", "窗边的薄荷长了新叶。今天先不挪盆。"]
 for i in range(4):
  if active_category == "配送" and i != 0 and i != 2: continue
  if active_category == "邻里" and i == 2: continue
  var card = paper(feed,435)
  var header = HBoxContainer.new()
  card.add_child(header)
  picture(header,"avatar_%d.png" % i,Vector2(40,40))
  copy(header,names[i] + "\n" + "%02d:15 · 缓存留言" % (8+i),330,true)
  copy(card,posts[i],405)
  if i == 0: copy(card,event_text().strip_edges(),405,true)
  picture(card,"thumb_%d.png" % i,Vector2(280,154))
  var row = HBoxContainer.new()
  card.add_child(row)
  var id: int = i
  var like = Kit.button("赞 " + str(12+i+int(liked.get(i,false))),func(): liked[id] = not liked.get(id,false); render_posts(feed))
  like.custom_minimum_size.x = 95
  row.add_child(like)
  copy(row,"留言 %d   /   本地快照" % (2+i),270,true)
func build_messages(body: HBoxContainer) -> void:
 var contacts = paper(column(body,190),190)
 var chat = paper(column(body,440),435)
 copy(contacts,"联系人 / 缓存",160,true)
 for i in range(8):
  var index: int = i
  var row = HBoxContainer.new()
  contacts.add_child(row)
  picture(row,"avatar_%d.png" % i,Vector2(32,32))
  var b = Kit.button(names[i] + (" •" if unread[i] > 0 else ""),func():
   selected_contact = index
   unread[index] = 0
   for child in body.get_children():
    body.remove_child(child)
    child.queue_free()
   build_messages(body)
   bind_focus(body,windows["消息"])
  )
  b.custom_minimum_size.x = 125
  row.add_child(b)
 render_chat(chat)
func bubble(parent: Node, value: String, own: bool) -> void:
 var row = HBoxContainer.new()
 parent.add_child(row)
 if own:
  var space = Control.new()
  space.custom_minimum_size.x = 60
  row.add_child(space)
 else: picture(row,"avatar_%d.png" % selected_contact,Vector2(32,32))
 var panel = PanelContainer.new()
 var style = StyleBoxFlat.new()
 style.bg_color = Color("aabfca") if own else Color("eeeae0")
 style.set_content_margin_all(10)
 panel.add_theme_stylebox_override("panel",style)
 row.add_child(panel)
 copy(panel,value,285)
func render_chat(chat: VBoxContainer) -> void:
 for child in chat.get_children():
  chat.remove_child(child)
  child.queue_free()
 copy(chat,names[selected_contact] + " / 本地会话",390)
 copy(chat,"08:15 · 原型缓存记录",390,true)
 var greetings = ["门口的便笺已经贴好，配送地址没有变化。", "收班后记得核对保温袋数量。", "楼道左侧的伞还在晾，路过慢一点。", "修好的伞放在门边，别拿错。", "店门前有积水，请从侧边走。", "旧书已收进棚里，不用担心淋雨。", "薄荷今天先不挪盆了。", "缓存读取完成，当前无网络连接。"]
 bubble(chat,greetings[selected_contact],false)
 bubble(chat,"收到，我会核对记录。",true)
 if selected_contact == 0: bubble(chat,event_text().strip_edges(),false)
 for message in chat_history.get(selected_contact,[]): bubble(chat,message,true)
 copy(chat,"消息仅保存在本次运行，不发送到网络。",390,true)
 var row = HBoxContainer.new()
 chat.add_child(row)
 var input = LineEdit.new()
 input.placeholder_text = "输入本地留言…"
 input.custom_minimum_size.x = 280
 row.add_child(input)
 var send = func():
  if input.text.strip_edges().is_empty(): return
  if not chat_history.has(selected_contact): chat_history[selected_contact] = []
  chat_history[selected_contact].append(input.text.strip_edges())
  render_chat(chat)
 var send_button = Kit.button("记录",send)
 send_button.custom_minimum_size.x = 65
 row.add_child(send_button)
 input.text_submitted.connect(func(_value: String): send.call())

func clamp_frame(frame: Control) -> void:
 frame.position = Vector2(clampf(frame.position.x,0,maxf(0,get_viewport_rect().size.x-frame.size.x)),clampf(frame.position.y,0,maxf(0,get_viewport_rect().size.y-frame.size.y-48)))
