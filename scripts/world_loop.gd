extends "res://scripts/world_third.gd"
const SCHEMA := 1
const SAVE_PATH := "user://campaign_v1.json"
const HOME := Vector3(0,0,8)
const SHOP := Vector3(-7,0,2)
const CUSTOMER := Vector3(6,0,-4)
var campaign := false
var day := 1
var period := "day"
var minute := 480
var location := "home"
var inventory: Dictionary = {"food":0,"water":0,"medicine":0}
var stamina := 75
var health := 85
var collected: Array = []
var pending_posts: Array = []
var pending_messages: Array = []
var reviewed := false
var room_position := Vector2(150,180)
var city_position := HOME
var interior_position := Vector3(0,0,3)
var notice := ""
var notes := ""
var active_order_id := ""
var last_save_error := ""
func new_campaign() -> void:
 campaign = true
 day = 1; period = "day"; minute = 480; location = "home"
 inventory = {"food":0,"water":0,"medicine":0}
 stamina = 75; health = 85; collected = []; pending_posts = []; pending_messages = []
 reviewed = false; room_position = Vector2(150,180); city_position = HOME; interior_position = Vector3(0,0,3)
 events = []; orders = []; daytime_orders = []; encountered_npcs = []; night_posts = []; night_messages = []
 assistant_history = [{"role":"assistant","text":"离线记录已准备。白天到现场取餐、送达；回家后核对居民消息。"}]
 clues = []; notes = ""; add_daily_order()
 tell("新的一天：出门取餐，送到榆灯巷07号，再回家核对消息。")
func add_daily_order() -> void:
 var data: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/desktop_third.json"))
 var order: Dictionary = data.orders[0].duplicate(true)
 order.id = "day_%d_order_001" % day
 order.status = "待取餐"; order.day = day
 active_order_id = order.id
 orders.append(order)
func current_order() -> Dictionary:
 for order in orders:
  if order.id == active_order_id: return order
 return {}
func tell(text: String) -> void:
 notice = text
 changed.emit()
func time_text() -> String:
 return "第 %d 天 · %s · %02d:%02d" % [day,"白天" if period=="day" else "夜晚",minute/60,minute%60]
func objective() -> String:
 if period == "night": return "核对消息或动态，再休息到次日" if not reviewed else "调查已记录，可以休息到次日"
 var order = current_order()
 if order.get("status","")=="待取餐": return "前往热汤铺取餐（靠近按 E）"
 if order.get("status","")=="配送中": return "送到榆灯巷07号（靠近按 E）"
 return "返回住所，核对居民消息"
func depart() -> bool:
 if not campaign or period!="day" or location!="home": return false
 location = "city"; city_position = HOME; minute = maxi(minute,510)
 tell(objective()); return true
func near(point: Vector3) -> bool:
 return location=="city" and Vector2(city_position.x,city_position.z).distance_to(Vector2(point.x,point.z))<2.0
func pickup_order() -> bool:
 var order = current_order()
 if not campaign or period!="day" or not near(SHOP) or order.get("status","")!="待取餐": return false
 order.status = "配送中"; minute += 45; stamina = maxi(0,stamina-8)
 tell("已取热汤。前往榆灯巷07号，按备注敲两下。")
 return true
func deliver_order(id: String) -> bool:
 if not campaign: return super.deliver_order(id)
 # Campaign completion is only possible at the actual delivery destination.
 var order = current_order()
 if id!=active_order_id or period!="day" or not near(CUSTOMER) or order.get("status","")!="配送中": return false
 order.status = "已送达"; daytime_orders.append(order.duplicate(true))
 if not encountered_npcs.has(order.person_id): encountered_npcs.append(order.person_id)
 var text = "七号住户：热汤收到了，谢谢。门铃还没修好，下次也请敲两下。"
 pending_posts.append({"order_id":id,"person_id":order.person_id,"place_id":order.place_id,"text":text})
 pending_messages.append({"person_id":order.person_id,"text":text})
 minute += 75; stamina = maxi(0,stamina-12)
 record_event("delivered_"+id,order.person_id,order.place_id,"第%d天已在门口送达热汤。" % day)
 tell("送达完成，收入 +¥6.50。可收集补给后返回住所。")
 return true
func return_home() -> bool:
 if not campaign or period!="day" or not near(HOME): return false
 var order = current_order()
 if order.get("status","")!="已送达":
  tell("先完成今天的配送再收工。取餐点和收件地址均在这条街上。")
  return false
 period = "night"; minute = 1140; location = "home"; reviewed = false
 night_posts.append_array(pending_posts); night_messages.append_array(pending_messages)
 pending_posts.clear(); pending_messages.clear(); room_position = Vector2(150,180)
 tell("夜晚回到住所。电脑中有今天配送关联的消息。")
 return true
func collect_item(item: String, point: Vector3) -> bool:
 if not campaign or period!="day" or not near(point) or not inventory.has(item): return false
 var id = "%d_%s" % [day,item]
 if id in collected: return false
 collected.append(id); inventory[item] = int(inventory[item])+1; minute += 5
 tell("已领取补给："+item_name(item)+"。每种补给每天领取一次。")
 return true
func item_name(item: String) -> String:
 return {"food":"饭团","water":"饮用水","medicine":"急救包"}.get(item,item)
func use_item(item: String) -> bool:
 if not campaign or int(inventory.get(item,0))<=0: return false
 if item=="medicine":
  if health>=100: tell("身体状态良好，暂不需要急救包。"); return false
  health = mini(100,health+15)
 else:
  if stamina>=100: tell("体力已恢复，无需消耗补给。"); return false
  stamina = mini(100,stamina+(20 if item=="food" else 10))
 inventory[item] = int(inventory[item])-1
 tell("已使用"+item_name(item)); return true
func mark_reviewed() -> void:
 if campaign and period=="night" and not reviewed:
  reviewed = true; minute += 20
  tell("今天的配送消息已核对。回住所休息可进入下一天。")
func rest() -> bool:
 if not campaign or location!="home" or period!="night" or not reviewed: return false
 var supplied = int(inventory.food)>0 and int(inventory.water)>0
 if supplied:
  inventory.food = int(inventory.food)-1; inventory.water = int(inventory.water)-1
 stamina = mini(100,stamina+(50 if supplied else 25))
 day += 1; period = "day"; minute = 480; reviewed = false; add_daily_order()
 tell("第%d天早上。%s" % [day,"晚饭和饮水消耗各1份，体力恢复50。" if supplied else "补给不足，普通休息恢复25体力。"])
 return true
func save_game(path: String = SAVE_PATH) -> bool:
 if not campaign: return false
 var payload = {"schema":SCHEMA,"day":day,"period":period,"minute":minute,"location":location,"inventory":inventory,"stamina":stamina,"health":health,"collected":collected,"pending_posts":pending_posts,"pending_messages":pending_messages,"reviewed":reviewed,"room_position":[room_position.x,room_position.y],"city_position":[city_position.x,city_position.y,city_position.z],"interior_position":[interior_position.x,interior_position.y,interior_position.z],"orders":orders,"active_order_id":active_order_id,"events":events,"daytime_orders":daytime_orders,"encountered_npcs":encountered_npcs,"night_posts":night_posts,"night_messages":night_messages,"assistant_history":assistant_history,"clues":clues,"notes":notes}
 payload.merge(extra_save_data(),true)
 var file = FileAccess.open(path+".tmp",FileAccess.WRITE)
 if file==null: last_save_error="无法写入本地存档。"; tell(last_save_error); return false
 file.store_string(JSON.stringify(payload,"  ")); file.flush(); file.close()
 var absolute = ProjectSettings.globalize_path(path)
 if FileAccess.file_exists(path):
  if DirAccess.copy_absolute(absolute,absolute+".bak")!=OK: last_save_error="备份旧存档失败，旧档未覆盖。"; tell(last_save_error); return false
  if DirAccess.remove_absolute(absolute)!=OK: last_save_error="旧存档无法替换。"; tell(last_save_error); return false
 if DirAccess.rename_absolute(absolute+".tmp",absolute)!=OK:
  if FileAccess.file_exists(path+".bak"): DirAccess.copy_absolute(absolute+".bak",absolute)
  last_save_error="保存失败，已尝试保留旧档。"; tell(last_save_error); return false
 last_save_error=""; tell("已保存到本机。继续游戏将恢复当前位置与当天记录。")
 return true
func valid_save(data: Variant) -> bool:
 if not data is Dictionary or data.get("schema",0)!=SCHEMA: return false
 for key in ["day","minute","stamina","health"]:
  if not data.get(key) is float and not data.get(key) is int: return false
 if data.day<1 or data.day>9999 or data.minute<0 or data.minute>=1440 or data.stamina<0 or data.stamina>100 or data.health<0 or data.health>100: return false
 if data.get("period") not in ["day","night"] or data.get("location") not in ["home","city","desktop","shop","corridor"]: return false
 if data.location in ["city","shop","corridor"] and data.period!="day": return false
 if data.has("interior_position"):
  if not data.interior_position is Array or data.interior_position.size()!=3: return false
  for value in data.interior_position:
   if not (value is float or value is int) or not is_finite(float(value)) or abs(value)>1000: return false
 if not data.get("reviewed") is bool or not data.get("notes") is String: return false
 if not data.get("inventory") is Dictionary: return false
 for key in ["food","water","medicine"]:
  var value = data.inventory.get(key)
  if not (value is float or value is int) or value<0 or value>999: return false
 for key in ["collected","pending_posts","pending_messages","orders","events","daytime_orders","encountered_npcs","night_posts","night_messages","assistant_history","clues"]:
  if not data.get(key) is Array or data[key].size()>20000: return false
 for key in ["collected","encountered_npcs","clues"]:
  for value in data[key]:
   if not value is String: return false
 for key in ["room_position","city_position"]:
  if not data.get(key) is Array or data[key].size()!=(2 if key=="room_position" else 3): return false
  for value in data[key]:
   if not (value is float or value is int) or not is_finite(float(value)) or abs(value)>1000: return false
 var ids: Array = []
 for order in data.orders:
  if not order is Dictionary: return false
  for key in ["id","person_id","place_id","item","status","address","note"]:
   if not order.get(key) is String: return false
  if order.id in ids or not people.has(order.person_id) or not places.has(order.place_id): return false
  ids.append(order.id)
  if not (order.get("fee") is float or order.get("fee") is int) or order.fee<0: return false
 if data.get("active_order_id") not in ids: return false
 for key in ["pending_posts","night_posts"]:
  for post in data[key]:
   if not post is Dictionary or not post.get("text") is String or not post.get("order_id") is String: return false
 for key in ["pending_messages","night_messages"]:
  for message in data[key]:
   if not message is Dictionary or not message.get("text") is String or not message.get("person_id") is String: return false
 for message in data.assistant_history:
  if not message is Dictionary or not message.get("text") is String or message.get("role") not in ["user","assistant"]: return false
 for event in data.events:
  if not event is Dictionary: return false
  for key in ["id","person_id","place_id","text"]:
   if not event.get(key) is String: return false
 return true
func load_game(path: String = SAVE_PATH) -> bool:
 if not FileAccess.file_exists(path): last_save_error="尚无本地存档。"; return false
 var data: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
 if not valid_save(data): last_save_error="存档损坏或版本不兼容。当前进度未改变；可尝试恢复备份。"; return false
 campaign = true
 day=int(data.day); period=data.period; minute=int(data.minute); location=data.location
 inventory=data.inventory; stamina=int(data.stamina); health=int(data.health); collected=data.collected
 pending_posts=data.pending_posts; pending_messages=data.pending_messages; reviewed=data.reviewed
 room_position=Vector2(data.room_position[0],data.room_position[1]); city_position=Vector3(data.city_position[0],data.city_position[1],data.city_position[2])
 var indoor: Array=data.get("interior_position",[0,0,3])
 interior_position=Vector3(indoor[0],indoor[1],indoor[2])
 orders=data.orders; active_order_id=data.active_order_id; events=data.events; daytime_orders=data.daytime_orders
 encountered_npcs=data.encountered_npcs; night_posts=data.night_posts; night_messages=data.night_messages
 assistant_history=data.assistant_history; clues=data.clues; notes=data.notes; last_save_error=""
 apply_extra_save(data)
 tell("本地存档已读取。")
 return true
func scene_for_location() -> String:
 if location in ["shop","corridor"]: return "res://scenes/district_interior.tscn"
 return {"home":"res://scenes/bedroom.tscn","city":"res://scenes/city_delivery.tscn","desktop":"res://scenes/desktop.tscn"}.get(location,"res://scenes/bedroom.tscn")

func enter_district(area: String) -> bool:
 if not campaign or period!="day" or location!="city": return false
 var portals={"shop":Vector3(-9,0,-1),"corridor":Vector3(9,0,1)}
 if not portals.has(area) or not near(portals[area]): return false
 location=area; interior_position=Vector3(0,0,3)
 tell("进入晚班便利店。热汤取餐点仍在街道；靠近出口按E返回。" if area=="shop" else "进入居民楼公共走廊。靠近街道出口按E返回。")
 return true
func leave_district() -> bool:
 if not campaign or location not in ["shop","corridor"]: return false
 if Vector2(interior_position.x,interior_position.z).distance_to(Vector2(0,4))>1.3: return false
 location="city"
 tell("回到榆灯巷。"+objective())
 return true

# Small optional save extension; legacy schema-1 saves remain valid.
func extra_save_data() -> Dictionary:
 return {}
func apply_extra_save(_data: Dictionary) -> void:
 pass
