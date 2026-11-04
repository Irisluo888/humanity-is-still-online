extends Control
const Kit = preload("res://ui/kit.gd")
const Frame = preload("res://ui/desktop_window.gd")
var windows: Dictionary = {}
var tasks: HBoxContainer
var clock: Label
func _ready() -> void:
 var theme_resource = Theme.new()
 var panel = StyleBoxFlat.new()
 panel.bg_color = Color("303747")
 panel.border_color = Color("80909a")
 panel.set_border_width_all(2)
 theme_resource.set_stylebox("panel", "PanelContainer", panel)
 theme = theme_resource
 var image = Image.create(320, 180, false, Image.FORMAT_RGB8)
 image.fill(Color("202937"))
 for x in range(320):
  for y in range(180):
   if y > 100 + (x / 27 as int) % 4 * 10:
    image.set_pixel(x,y,Color("303c4c"))
   if y > 115 and x % 19 < 3 and y % 17 < 4:
    image.set_pixel(x,y,Color("9e7554"))
 var wallpaper = TextureRect.new()
 wallpaper.texture = ImageTexture.create_from_image(image)
 wallpaper.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
 wallpaper.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 add_child(wallpaper)
 var icons = VBoxContainer.new()
 icons.position = Vector2(20,20)
 add_child(icons)
 var index = 0
 for app in ["动态", "热榜", "视频", "消息", "AI助手", "接单"]:
  var name: String = app
  var b = Kit.button(name, func(): open_app(name))
  var glyph = Image.create(16,16,false,Image.FORMAT_RGBA8)
  glyph.fill(Color.TRANSPARENT)
  for x in range(3,13):
   for y in range(3,13):
    if x == 3 or y == 3 or x == 12 or y == 12 or (x+y+index)%5 == 0:
     glyph.set_pixel(x,y,Color("c8a478"))
  b.icon = ImageTexture.create_from_image(glyph)
  b.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
  icons.add_child(b)
  index += 1
 var notice = Kit.label("住户终端 / 缓存模式\n白天记录 → 夜间资料\n所有内容本地运行",18)
 notice.position = Vector2(200,24)
 add_child(notice)
 tasks = HBoxContainer.new()
 tasks.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
 tasks.offset_top = -42
 add_child(tasks)
 tasks.add_child(Kit.button("返回",func(): get_tree().change_scene_to_file("res://scenes/start.tscn")))
 clock = Kit.label("",16)
 tasks.add_child(clock)
 WorldData.changed.connect(refresh)
func _process(_delta: float) -> void:
 clock.text = Time.get_time_string_from_system()
func open_app(app: String) -> void:
 if windows.has(app):
  windows[app].show()
  windows[app].move_to_front()
  return
 var frame = Frame.new()
 add_child(frame)
 frame.setup(app)
 frame.position = Vector2(200 + windows.size()*24, 100 + windows.size()*16)
 windows[app] = frame
 var task = Kit.button(app,func(): frame.show(); frame.move_to_front())
 task.custom_minimum_size.x = 90
 tasks.add_child(task)
 frame.closed.connect(func(): windows.erase(app); task.queue_free(); frame.queue_free())
 populate(app,frame.body)
 bind_focus(frame, frame)
func column(parent: Node, width: float) -> VBoxContainer:
 var scroll = ScrollContainer.new()
 scroll.custom_minimum_size.x = width
 scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
 parent.add_child(scroll)
 var col = VBoxContainer.new()
 col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
 scroll.add_child(col)
 return col
func text(parent: Node, value: String) -> void:
 var label = Kit.label(value,18)
 label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
 label.custom_minimum_size.x = 140
 parent.add_child(label)
func event_text() -> String:
 var result = ""
 for event in WorldData.events:
  result += str(WorldData.people.get(event.person_id,event.person_id)) + " / " + str(WorldData.places.get(event.place_id,event.place_id)) + "\n" + str(event.text) + "\n\n"
 return result
func populate(app: String, body: HBoxContainer) -> void:
 var left = column(body,160)
 if app == "动态":
  var feed = column(body,340)
  var right = column(body,170)
  for category in ["全部", "邻里", "配送"]:
   left.add_child(Kit.button(category,func():
    for child in feed.get_children(): child.queue_free()
    text(feed,category + " / 本地记录\n\n" + event_text())
   ))
  text(feed,"街坊记录\n\n" + event_text())
  text(right,"推荐地点\n" + str(WorldData.places.lane_07) + "\n\n消息来源：本地缓存")
 elif app == "消息":
  var chat = column(body,470)
  text(chat,"选择联系人查看记录")
  for id in WorldData.people:
   var person: String = id
   left.add_child(Kit.button(str(WorldData.people[id]),func():
    for child in chat.get_children(): child.queue_free()
    text(chat,str(WorldData.people[person]) + "\n\n" + event_text() + "\n当前仅浏览缓存，不发送消息。")
   ))
 elif app == "视频":
  text(left,"目击索引\n榆灯巷 / 片段 01")
  var video = column(body,300)
  text(video,"[ 本地片段预览 ]\n\n榆灯巷门口\n\n尚无视频素材，未播放。")
  text(column(body,190),"关联评论\n\n" + event_text())
 elif app == "热榜":
  text(left,"城市热点\n按缓存记录排列")
  text(column(body,480),"01 / 榆灯巷配送提醒\n\n" + event_text())
 elif app == "AI助手":
  text(left,"线索整理\n\n" + event_text())
  var chat = column(body,460)
  text(chat,"离线助手：输入关键词检索共享记录。")
  var input = LineEdit.new()
  input.placeholder_text = "输入地点、人物或记录关键词"
  chat.add_child(input)
  input.text_submitted.connect(func(query: String):
   var records = event_text()
   text(chat,"你：" + query + "\n助手：" + (records if not query.strip_edges().is_empty() and records.contains(query) else "缓存中没有匹配记录。"))
   input.clear()
  )
 elif app == "接单":
  text(left,"订单 / 本地缓存")
  var records = column(body,480)
  for order in WorldData.orders:
   text(records,str(order.id) + " / " + str(order.item) + "\n" + str(WorldData.places[order.place_id]) + " / " + str(WorldData.people[order.person_id]) + "\n状态：" + str(order.status))
  text(records,"配送关联记录\n\n" + event_text())
func refresh() -> void:
 for app in windows:
  var body: HBoxContainer = windows[app].body
  for child in body.get_children():
   body.remove_child(child)
   child.queue_free()
  populate(app,body)
  bind_focus(windows[app], windows[app])

func bind_focus(node: Node, frame: Control) -> void:
 if node is Control:
  node.gui_input.connect(func(event: InputEvent):
   if event is InputEventMouseButton and event.pressed:
    frame.move_to_front()
  )
 for child in node.get_children():
  bind_focus(child, frame)
