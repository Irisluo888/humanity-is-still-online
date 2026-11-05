extends "res://scripts/desktop_round2.gd"
const ART3 = "res://assets/art/"
var selected_news := 0
var selected_order := 0
var seen_messages_count := 0
func _ready() -> void:
 super._ready()
 content = JSON.parse_string(FileAccess.get_file_as_string("res://data/desktop_third.json"))
 unread.resize(content.contacts.size())
 for i in range(unread.size()):
  if unread[i] == null: unread[i] = 0
 get_child(0).texture = load(ART3+"backgrounds/wallpaper.png")
 var icons = get_child(1)
 for i in range(6): icons.get_child(i).icon = load(ART3+"icons/app_%d.png" % i)
func image(parent: Node, file: String, dimensions: Vector2) -> void:
 var folder = "environment/"
 if file.begins_with("avatar_"): folder = "avatars/"
 elif file.begins_with("thumb_"): folder = "social/"
 elif file.begins_with("video_"): folder = "video/"
 var tex = TextureRect.new()
 tex.texture = load(ART3+folder+file)
 tex.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
 tex.custom_minimum_size = dimensions
 tex.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
 tex.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
 parent.add_child(tex)
func populate(app: String, body: HBoxContainer) -> void:
 match app:
  "热榜": build_news(body)
  "AI助手": build_assistant(body)
  "接单": build_orders(body)
  "新闻详情": pass
  _: super.populate(app,body)
func render_posts(feed: VBoxContainer) -> void:
 super.render_posts(feed)
 if not WorldData.night_posts.is_empty():
  copy(feed,"配送之后 / 本地关联动态",420)
  for post in WorldData.night_posts:
   copy(feed,post.text,420)
   copy(feed,"关联订单："+post.order_id,420,true)
  bind_focus(feed,windows["动态"])
func build_messages(body: HBoxContainer) -> void:
 super.build_messages(body)
 var chat_root = body.get_child(1)
 var scroll = chat_root.get_child(1)
 var transcript = scroll.get_child(0).get_child(0)
 clear_children(transcript)
 var contact: Dictionary = content.contacts[selected_contact]
 for message in contact.history:
  timed_bubble(transcript,message.text,message.own,message.time)
 for message in WorldData.night_messages:
  if message.person_id == contact.id: bubble(transcript,message.text,false)
 for message in chat_history.get(selected_contact,[]): bubble(transcript,message,true)
 if selected_contact in [0,4]:
  image(transcript,"thumb_%d.png" % (2 if selected_contact==0 else 1),Vector2(160,90))
  copy(transcript,"本地附件 / 配送现场留影",430,true)
func bubble(parent: Node, value: String, own: bool) -> void:
 timed_bubble(parent,value,own,"")
func timed_bubble(parent: Node, value: String, own: bool, timestamp: String) -> void:
 var row = HBoxContainer.new()
 parent.add_child(row)
 if own:
  var spacer = Control.new()
  spacer.custom_minimum_size.x = 60
  row.add_child(spacer)
 else: image(row,"avatar_%d.png" % selected_contact,Vector2(32,32))
 var col = box(row,"abc4cc" if own else "f0ece2",9)
 copy(col,value,330)
 copy(col,timestamp if not timestamp.is_empty() else "本地留存记录",330,true)
func build_news(body: HBoxContainer) -> void:
 var headlines = scroll_box(body,310,"c7d0d1")
 var article = scroll_box(body,470)
 copy(headlines,"城市资讯 / 本地热度",280)
 for i in range(content.news.size()):
  var index: int = i
  var news: Dictionary = content.news[i]
  var button = small_button("%02d  %s\n%s · %s · 热度%d" % [news.rank,news.title,news.tag,news.time,news.heat],func(): selected_news=index; render_news(article),285)
  button.alignment = HORIZONTAL_ALIGNMENT_LEFT
  headlines.add_child(button)
 render_news(article)
func render_news(article: VBoxContainer) -> void:
 clear_children(article)
 var news: Dictionary = content.news[selected_news]
 copy(article,news.title,440)
 copy(article,news.time+" / "+news.tag+" / 热度 "+str(news.heat),440,true)
 article.add_child(HSeparator.new())
 copy(article,news.summary,440)
 copy(article,news.body,440)
 image(article,"thumb_%d.png" % (selected_news%8),Vector2(320,180))
 article.add_child(small_button("打开新闻详情",func():
  open_app("新闻详情")
  var target: HBoxContainer = windows["新闻详情"].body
  clear_children(target)
  var page = scroll_box(target,780)
  copy(page,news.title,740)
  copy(page,news.time+" / "+news.tag,740,true)
  copy(page,news.body,740)
  copy(page,"相关地点："+str(WorldData.places.lane_07),740,true)
  bind_focus(target,windows["新闻详情"])
 ,150))
 if windows.has("热榜"): bind_focus(article,windows["热榜"])
func build_assistant(body: HBoxContainer) -> void:
 var sidebar = scroll_box(body,230,"c5d0d1")
 copy(sidebar,"问询与线索",200)
 copy(sidebar,"离线预设整理器\n不会连接在线模型。",200,true)
 for keyword in ["门铃","保温袋","雨天","订单","整理线索"]:
  var query: String = keyword
  sidebar.add_child(small_button(keyword,func(): ask(query),190))
 sidebar.add_child(HSeparator.new())
 copy(sidebar,"已记录线索",200)
 if WorldData.clues.is_empty(): copy(sidebar,"点击“记录最近回复”保留一条资料。",200,true)
 for clue in WorldData.clues: copy(sidebar,clue,200,true)
 var main = VBoxContainer.new()
 main.size_flags_horizontal = Control.SIZE_EXPAND_FILL
 body.add_child(main)
 var history = scroll_box(main,550)
 for message in WorldData.assistant_history:
  copy(history,"你" if message.role=="user" else "离线助手",520,true)
  copy(history,message.text,520)
  history.add_child(HSeparator.new())
 var composer = box(main,"bccbd0",8)
 var input = LineEdit.new()
 input.placeholder_text = "输入门铃、保温袋、订单，或整理线索"
 composer.add_child(input)
 var row = HBoxContainer.new()
 composer.add_child(row)
 row.add_child(small_button("发送",func(): ask(input.text),70))
 row.add_child(small_button("记录最近回复",func():
  WorldData.save_clue(WorldData.assistant_history.back().text)
  rebuild("AI助手")
 ,140))
 input.text_submitted.connect(ask)
func ask(query: String) -> void:
 if query.strip_edges().is_empty(): return
 WorldData.ask_local(query.strip_edges())
 rebuild("AI助手")
func build_orders(body: HBoxContainer) -> void:
 var list = scroll_box(body,275,"c4cfd1")
 copy(list,"今日订单 / 本地原型",245)
 copy(list,"已送达收入：¥%.2f" % WorldData.income(),245)
 for i in range(WorldData.orders.size()):
  var index: int = i
  var order: Dictionary = WorldData.orders[i]
  list.add_child(small_button(order.id+" / "+order.item+"\n"+order.status+" · ¥%.2f" % float(order.fee),func(): selected_order=index; rebuild("接单"),245))
 var details = scroll_box(body,505)
 selected_order = mini(selected_order,WorldData.orders.size()-1)
 var order: Dictionary = WorldData.orders[selected_order]
 copy(details,"订单详情 / "+order.id,475)
 copy(details,order.item+" / "+str(WorldData.people[order.person_id]),475)
 copy(details,"配送地址："+order.address,475)
 copy(details,"备注："+order.note,475)
 copy(details,"状态："+order.status+" / 配送费 ¥%.2f" % float(order.fee),475,true)
 image(details,"thumb_%d.png" % (selected_order%8),Vector2(320,180))
 var button = small_button("记录送达（本地原型）",func(): WorldData.deliver_order(order.id),200)
 button.disabled = order.status=="已送达"
 details.add_child(button)
 copy(details,"配送历史",475)
 for item in WorldData.orders:
  if item.status=="已送达": copy(details,item.id+" / "+item.address+" / ¥%.2f" % float(item.fee),475,true)
 copy(details,"送达会更新共享事件、居民动态和消息。当前不是完整配送玩法。",475,true)
func rebuild(app: String) -> void:
 if not windows.has(app): return
 clear_children(windows[app].body)
 populate(app,windows[app].body)
 bind_focus(windows[app],windows[app])
func refresh() -> void:
 for i in range(seen_messages_count,WorldData.night_messages.size()):
  var message: Dictionary = WorldData.night_messages[i]
  for index in range(content.contacts.size()):
   if content.contacts[index].id == message.person_id:
    content.contacts[index].preview = message.text
    unread[index] = int(unread[index]) + 1
 seen_messages_count = WorldData.night_messages.size()
 for app in windows:
  if app in ["帖子详情","新闻详情"]: continue
  rebuild(app)
