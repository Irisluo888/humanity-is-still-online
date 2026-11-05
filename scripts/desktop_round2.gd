extends "res://scripts/desktop_visual.gd"
const R2 = "res://assets/pixel_round2/"
const R2Frame = preload("res://ui/round2_window.gd")
var content: Dictionary
var task_buttons: Dictionary = {}
var focused_app := ""
var video_index := 0
var video_playing := false
var video_position := 0.0
var video_progress: ProgressBar
var widget_clock: Label
var widget_date: Label
var music_playing := false
var music_progress: ProgressBar
var desktop_notes: TextEdit
var notes_value := "□ 核对今晚的配送记录\n□ 记得把雨衣晾起来\n□ 门铃没电，请敲两下"
func _ready() -> void:
 content = JSON.parse_string(FileAccess.get_file_as_string("res://data/desktop_round2.json"))
 active_category = "全部"
 var skin = Theme.new()
 skin.default_font_size = 15
 for type in ["Button","LineEdit","TextEdit"]:
  for state in ["normal","hover","pressed","focus","disabled"]:
   var style = StyleBoxFlat.new()
   style.bg_color = Color("c9d0d0") if state != "hover" else Color("aebfc7")
   style.border_color = Color("768798")
   style.set_border_width_all(1)
   style.set_content_margin_all(5)
   skin.set_stylebox(state,type,style)
  skin.set_color("font_color",type,Color("28364a"))
  skin.set_color("font_hover_color",type,Color("172335"))
  skin.set_color("font_pressed_color",type,Color("172335"))
  skin.set_color("font_placeholder_color",type,Color("677787"))
 theme = skin
 var wallpaper = TextureRect.new()
 wallpaper.texture = load(R2 + "wallpaper.png")
 wallpaper.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
 wallpaper.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 add_child(wallpaper)
 var icons = VBoxContainer.new()
 icons.position = Vector2(16,18)
 icons.add_theme_constant_override("separation",8)
 add_child(icons)
 var apps = ["动态","热榜","视频","消息","AI助手","接单"]
 for i in range(6):
  var app: String = apps[i]
  var button = Button.new()
  button.text = app
  button.icon = load(ART + "app_%d.png" % i)
  button.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
  button.expand_icon = true
  button.add_theme_constant_override("icon_max_width",32)
  button.custom_minimum_size = Vector2(102,64)
  button.add_theme_stylebox_override("normal",StyleBoxEmpty.new())
  button.add_theme_color_override("font_color",Color("e0e6e7"))
  button.pressed.connect(func(): open_app(app))
  icons.add_child(button)
 var info = Kit.label("HOME / 07\n雨夜，先把生活接上。",18)
 info.position = Vector2(150,28)
 add_child(info)
 make_widgets()
 var task_panel = PanelContainer.new()
 task_panel.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
 task_panel.offset_top = -44
 var style = StyleBoxFlat.new()
 style.bg_color = Color("26364a")
 style.border_color = Color("82919b")
 style.border_width_top = 2
 task_panel.add_theme_stylebox_override("panel",style)
 add_child(task_panel)
 tasks = HBoxContainer.new()
 tasks.add_theme_constant_override("separation",4)
 task_panel.add_child(tasks)
 var start = small_button("关闭电脑" if Chapter.session_active else "开始 / 住所",func():
  if Chapter.session_active and has_method("return_chapter"):call("return_chapter")
  else:get_tree().change_scene_to_file("res://scenes/bedroom.tscn"),110)
 tasks.add_child(start)
 var return_button = small_button("主菜单",func(): get_tree().change_scene_to_file("res://scenes/start.tscn"),75)
 tasks.add_child(return_button)
 var spacer = Control.new()
 spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
 tasks.add_child(spacer)
 clock = Kit.label("",14)
 tasks.add_child(clock)
 WorldData.changed.connect(refresh)
 get_viewport().size_changed.connect(clamp_windows)
func small_button(value: String, action: Callable, width: float = 80) -> Button:
 var b = Kit.button(value,action)
 b.custom_minimum_size = Vector2(width,30)
 return b
func box(parent: Node, color: String, padding: int = 10) -> VBoxContainer:
 var panel = PanelContainer.new()
 var style = StyleBoxFlat.new()
 style.bg_color = Color(color)
 style.set_content_margin_all(padding)
 panel.add_theme_stylebox_override("panel",style)
 parent.add_child(panel)
 var col = VBoxContainer.new()
 col.add_theme_constant_override("separation",7)
 panel.add_child(col)
 return col
func scroll_box(parent: Node, width: float, color: String = "dddcd4") -> VBoxContainer:
 var scroll = ScrollContainer.new()
 scroll.custom_minimum_size.x = width
 scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
 scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
 scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
 parent.add_child(scroll)
 var col = box(scroll,color)
 col.get_parent().size_flags_horizontal = Control.SIZE_EXPAND_FILL
 return col
func image(parent: Node, file: String, dimensions: Vector2) -> void:
 var tex = TextureRect.new()
 tex.texture = load(R2+file)
 tex.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
 tex.custom_minimum_size = dimensions
 tex.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
 tex.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
 parent.add_child(tex)
func make_widgets() -> void:
 var holder = VBoxContainer.new()
 holder.position = Vector2(1010,24)
 holder.custom_minimum_size.x = 245
 holder.add_theme_constant_override("separation",12)
 add_child(holder)
 var time_box = box(holder,"253449",12)
 widget_clock = Kit.label("",34)
 time_box.add_child(widget_clock)
 widget_date = Kit.label("",15)
 time_box.add_child(widget_date)
 var calendar = GridContainer.new()
 calendar.columns = 7
 time_box.add_child(calendar)
 var today = Time.get_date_dict_from_system()
 var first = Time.get_datetime_dict_from_unix_time(int(Time.get_unix_time_from_datetime_dict({"year":today.year,"month":today.month,"day":1,"hour":0,"minute":0,"second":0})))
 for caption in ["日","一","二","三","四","五","六"]: calendar.add_child(Kit.label(caption,14))
 for i in range(first.weekday): calendar.add_child(Kit.label(" ",14))
 var days = 31
 if today.month in [4,6,9,11]: days = 30
 elif today.month == 2: days = 29 if today.year % 4 == 0 and (today.year % 100 != 0 or today.year % 400 == 0) else 28
 for day in range(1,days+1):
  var label = Kit.label("[%d]" % day if day == today.day else str(day),13)
  label.custom_minimum_size.x = 28
  calendar.add_child(label)
 var note = box(holder,"b5a184",10)
 copy(note,"便笺 / 晚班之后",200)
 desktop_notes = TextEdit.new()
 desktop_notes.text = notes_value
 desktop_notes.custom_minimum_size = Vector2(220,86)
 desktop_notes.text_changed.connect(func(): notes_value = desktop_notes.text)
 note.add_child(desktop_notes)
 var music = box(holder,"28384d",10)
 var row = HBoxContainer.new()
 music.add_child(row)
 image(row,"video_0.png",Vector2(64,48))
 row.add_child(Kit.label("雨沿 / 无音频演示\n本地播放器",14))
 music_progress = ProgressBar.new()
 music_progress.max_value = 180
 music_progress.show_percentage = false
 music_progress.custom_minimum_size.y = 8
 music.add_child(music_progress)
 var play = small_button("播放 / 暂停",func(): music_playing = not music_playing,120)
 music.add_child(play)
func _process(delta: float) -> void:
 if is_instance_valid(clock): clock.text = "离线  |  音量 0  |  电源 AC  |  " + Time.get_time_string_from_system()
 if is_instance_valid(widget_clock):
  widget_clock.text = Time.get_time_string_from_system().left(5)
  widget_date.text = Time.get_date_string_from_system() + " / 本机日历"
 if video_playing and is_instance_valid(video_progress):
  video_position = fmod(video_position+delta,60.0)
  video_progress.value = video_position
 if music_playing and is_instance_valid(music_progress): music_progress.value = fmod(music_progress.value+delta,180.0)
func open_app(app: String) -> void:
 if windows.has(app):
  windows[app].show()
  focus_app(app)
  return
 var frame = R2Frame.new()
 add_child(frame)
 frame.setup(app)
 frame.custom_minimum_size = Vector2(880,550) if app == "动态" else (Vector2(720,510) if app == "消息" else Vector2(820,510))
 if app == "帖子详情": frame.custom_minimum_size = Vector2(560,440)
 frame.size = frame.custom_minimum_size
 frame.position = Vector2(125,90) if app == "动态" else (Vector2(470,160) if app == "消息" else Vector2(225,125))
 windows[app] = frame
 var task = small_button(app,func():
  if frame.visible and focused_app == app:
   frame.hide()
   choose_visible()
  else:
   frame.show()
   focus_app(app)
 ,82)
 tasks.add_child(task)
 tasks.move_child(task,tasks.get_child_count()-3)
 task_buttons[app] = task
 frame.focus_requested.connect(func(): focus_app(app))
 frame.minimized.connect(choose_visible)
 frame.closed.connect(func():
  windows.erase(app)
  task_buttons.erase(app)
  task.queue_free()
  frame.queue_free()
  choose_visible()
 )
 populate(app,frame.body)
 bind_focus(frame,frame)
 frame.clamp_to_screen()
 focus_app(app)
func focus_app(app: String) -> void:
 focused_app = app
 for key in windows:
  windows[key].set_active(key == app)
  if task_buttons.has(key): task_buttons[key].modulate = Color.WHITE if key == app else Color("9ca8b3")
 if windows.has(app): windows[app].move_to_front()
func choose_visible() -> void:
 focused_app = ""
 for child in get_children():
  for app in windows:
   if windows[app] == child and child.visible: focused_app = app
 if not focused_app.is_empty(): focus_app(focused_app)
func bind_focus(node: Node, frame: Control) -> void:
 if node is Control and not node.has_meta("r2_focus"):
  node.set_meta("r2_focus",true)
  node.gui_input.connect(func(event: InputEvent):
   if event is InputEventMouseButton and event.pressed:
    for app in windows:
     if windows[app] == frame: focus_app(app); break
  )
 for child in node.get_children(): bind_focus(child,frame)
func clamp_windows() -> void:
 for frame in windows.values(): frame.clamp_to_screen()
func populate(app: String, body: HBoxContainer) -> void:
 match app:
  "动态": build_feed(body)
  "消息": build_messages(body)
  "视频": build_video(body)
  "帖子详情": pass
  _: super.populate(app,body)
func build_feed(body: HBoxContainer) -> void:
 var nav = scroll_box(body,130,"c6cccb")
 copy(nav,"街坊存档",105)
 var feed = scroll_box(body,460)
 var side = scroll_box(body,230,"d2d6d2")
 for category in ["全部","附近","关注","最新","求助","闲聊","配送","异常记录"]:
  var choice: String = category
  nav.add_child(small_button(category,func(): active_category = choice; render_posts(feed),100))
 copy(side,"本地热门话题",195)
 for topic in ["01 / 雨天配送备注","02 / 楼道雨伞收纳","03 / 晚班保温袋"]: copy(side,topic,190,true)
 side.add_child(HSeparator.new())
 copy(side,"附近 / " + str(WorldData.places.lane_07),190)
 image(side,"thumb_2.png",Vector2(192,108))
 copy(side,"配送记录 " + str(WorldData.orders[0].id),190,true)
 copy(side,"缓存联系人",190)
 for i in range(3):
  var row = HBoxContainer.new()
  side.add_child(row)
  image(row,"avatar_%d.png" % i,Vector2(32,32))
  copy(row,content.contacts[i].name,145,true)
 render_posts(feed)
func clear_children(parent: Node) -> void:
 for child in parent.get_children():
  parent.remove_child(child)
  child.queue_free()
func render_posts(feed: VBoxContainer) -> void:
 clear_children(feed)
 copy(feed,active_category + " / 社区快照",425,true)
 var shown = 0
 var posts: Array = content.posts.duplicate()
 if active_category == "最新": posts.reverse()
 for post in posts:
  if active_category not in ["全部","最新"] and post.category != active_category: continue
  shown += 1
  var header = HBoxContainer.new()
  feed.add_child(header)
  image(header,"avatar_%d.png" % int(post.author),Vector2(40,40))
  copy(header,content.contacts[int(post.author)].name + "\n" + post.time + " · " + post.kind,370,true)
  copy(feed,post.text,420)
  if post.id == "door": copy(feed,event_text().strip_edges(),420,true)
  var pictures = HBoxContainer.new()
  feed.add_child(pictures)
  for id in post.images:
   image(pictures,"thumb_%d.png" % int(id),Vector2(192,108) if post.images.size()>1 else Vector2(256,144))
  var actions = HBoxContainer.new()
  feed.add_child(actions)
  var id: String = post.id
  actions.add_child(small_button("赞 %d" % (int(post.likes)+int(liked.get(id,false))),func(): liked[id] = not liked.get(id,false); render_posts(feed),90))
  var record: Dictionary = post
  actions.add_child(small_button("评论 %d / 查看" % post.comments.size(),func(): show_post(record),135))
  if post.kind == "带评论": copy(feed,"街坊回复：" + post.comments[0],420,true)
  feed.add_child(HSeparator.new())
 if shown == 0: copy(feed,"暂无这一分类的缓存记录。",420,true)
 if windows.has("动态"): bind_focus(feed,windows["动态"])
func show_post(post: Dictionary) -> void:
 open_app("帖子详情")
 var body: HBoxContainer = windows["帖子详情"].body
 clear_children(body)
 var detail = scroll_box(body,535)
 copy(detail,content.contacts[int(post.author)].name + " / " + post.time,500,true)
 copy(detail,post.text,500)
 for id in post.images: image(detail,"thumb_%d.png" % int(id),Vector2(320,180))
 copy(detail,"街坊评论",500)
 for comment in post.comments: copy(detail,"— " + comment,500,true)
 bind_focus(body,windows["帖子详情"])
func build_messages(body: HBoxContainer) -> void:
 var people = scroll_box(body,220,"bcc8cd")
 copy(people,"联系人 / 本机缓存",195)
 var chat_root = VBoxContainer.new()
 chat_root.size_flags_horizontal = Control.SIZE_EXPAND_FILL
 body.add_child(chat_root)
 for i in range(content.contacts.size()):
  var id: int = i
  var contact: Dictionary = content.contacts[i]
  var row = HBoxContainer.new()
  people.add_child(row)
  image(row,"avatar_%d.png" % i,Vector2(40,40))
  var preview = contact.preview.left(8)
  var button = small_button(contact.name + (" (%d)" % unread[i] if unread[i]>0 else "") + "\n" + contact.time + " " + preview,func():
   selected_contact = id
   unread[id] = 0
   clear_children(body)
   build_messages(body)
   bind_focus(body,windows["消息"])
  ,145)
  button.alignment = HORIZONTAL_ALIGNMENT_LEFT
  people.add_child(HSeparator.new())
  row.add_child(button)
 var heading = box(chat_root,"d2d8d5",10)
 var contact: Dictionary = content.contacts[selected_contact]
 copy(heading,contact.name + (" · 在线" if contact.online else " · 离开"),440)
 var transcript = scroll_box(chat_root,470,"e0e0d9")
 copy(transcript,contact.time + " / 留存记录",440,true)
 bubble(transcript,contact.preview + "。",false)
 bubble(transcript,"收到，回家后核对一下。",true)
 if selected_contact == 0: bubble(transcript,event_text().strip_edges(),false)
 if selected_contact in [0,4]:
  image(transcript,"thumb_%d.png" % (2 if selected_contact==0 else 1),Vector2(192,108))
  copy(transcript,"附件 / 门口留影.png · " + contact.time,430,true)
 for value in chat_history.get(selected_contact,[]): bubble(transcript,value,true)
 var composer = box(chat_root,"becad0",8)
 var row = HBoxContainer.new()
 composer.add_child(row)
 row.add_child(small_button("附件",func():
  if not chat_history.has(selected_contact): chat_history[selected_contact] = []
  chat_history[selected_contact].append("[本地文件] 配送备注.txt / " + str(WorldData.orders[0].id))
  clear_children(body)
  build_messages(body)
  bind_focus(body,windows["消息"])
 ,50))
 var input = LineEdit.new()
 input.placeholder_text = "本地留言，不发送到网络"
 input.size_flags_horizontal = Control.SIZE_EXPAND_FILL
 input.custom_minimum_size.x = 240
 row.add_child(input)
 var send = func():
  if input.text.strip_edges().is_empty(): return
  if not chat_history.has(selected_contact): chat_history[selected_contact] = []
  chat_history[selected_contact].append(input.text.strip_edges())
  clear_children(body)
  build_messages(body)
  bind_focus(body,windows["消息"])
 row.add_child(small_button("发送",send,55))
 input.text_submitted.connect(func(_value: String): send.call())
func bubble(parent: Node, value: String, own: bool) -> void:
 var row = HBoxContainer.new()
 parent.add_child(row)
 if own:
  var spacer = Control.new()
  spacer.custom_minimum_size.x = 60
  row.add_child(spacer)
 else: image(row,"avatar_%d.png" % selected_contact,Vector2(32,32))
 var col = box(row,"abc4cc" if own else "f0ece2",9)
 copy(col,value,330)
 copy(col,"已存于本机" if own else content.contacts[selected_contact].time,330,true)
func build_video(body: HBoxContainer) -> void:
 var list = scroll_box(body,195,"33465c")
 list.add_child(Kit.label("本地目击片段",17))
 var stage = scroll_box(body,595,"263548")
 for i in range(content.clips.size()):
  var id: int = i
  image(list,"video_%d.png" % i,Vector2(168,94))
  list.add_child(small_button(content.clips[i].title,func(): video_index = id; video_position = 0; video_playing = false; clear_children(body); build_video(body); bind_focus(body,windows["视频"]),168))
 var clip: Dictionary = content.clips[video_index]
 stage.add_child(Kit.label(clip.title,22))
 image(stage,"video_%d.png" % video_index,Vector2(448,252))
 var row = HBoxContainer.new()
 stage.add_child(row)
 row.add_child(small_button("播放 / 暂停",func(): video_playing = not video_playing,110))
 row.add_child(Kit.label("00:00—01:00 / 静态封面模拟播放",14))
 video_progress = ProgressBar.new()
 video_progress.max_value = 60
 video_progress.value = video_position
 video_progress.show_percentage = false
 video_progress.custom_minimum_size.y = 10
 stage.add_child(video_progress)
 stage.add_child(Kit.label(content.contacts[int(clip.author)].name + " / 本地缓存",15))
 stage.add_child(Kit.label(clip.description,16))
 stage.add_child(Kit.label("评论：" + clip.comment,16))
 stage.add_child(Kit.label("关联配送记录：" + str(WorldData.orders[0].id),14))
func refresh() -> void:
 for app in windows:
  if app == "帖子详情": continue
  clear_children(windows[app].body)
  populate(app,windows[app].body)
  bind_focus(windows[app],windows[app])
