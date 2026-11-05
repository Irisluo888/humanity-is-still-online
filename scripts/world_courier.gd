extends "res://scripts/world_delivery.gd"
var courier: Dictionary=JSON.parse_string(FileAccess.get_file_as_string("res://data/courier_events.json"))
var random_source:=RandomNumberGenerator.new()
# Test override is intentionally not persisted; normal play always uses local RNG.
var forced_story_roll:=-1.0
func _ready() -> void:
 random_source.randomize()
 super._ready()
func add_daily_order() -> void:
 super.add_daily_order()
 for order in orders:
  if not today(order):continue
  var key: String=order.get("route_key","soup")
  var previous=""
  for old in orders:
   if int(old.get("day",0))==day-1 and old.get("route_key","soup")==key:previous=old.item
  var choices: Array=[]
  for meal in courier.menus[key]:
   if meal!=previous:choices.append(meal)
  order.item=choices[random_source.randi_range(0,choices.size()-1)]
  order.story_roll=forced_story_roll if forced_story_roll>=0 else random_source.randf()
  order.story_probability=float(courier.probability)
  order.story_candidate=courier.events[random_source.randi_range(0,courier.events.size()-1)].id
  order.story_triggered=false;order.story_resolved=false;order.story_choice=""
func route_for(order: Dictionary) -> Dictionary:
 var route=super.route_for(order).duplicate(true)
 var suffix="谢谢。门铃还没修好，下次也请敲两下。"
 match order.get("route_key","soup"):
  "market":suffix="通道已收拾好，辛苦。"
  "books":suffix="雨停前书摊还在棚里，谢谢。"
 route.reply=order.get("item",route.item)+"收到了，"+suffix
 return route
func pending_story() -> Dictionary:
 for order in orders:
  if today(order) and order.get("story_triggered",false) and not order.get("story_resolved",false):return order
 return {}
func event_by_id(id: String) -> Dictionary:
 for event in courier.events:
  if event.id==id:return event
 return {}
func deliver_order(id: String) -> bool:
 if campaign and not pending_story().is_empty():tell("先处理眼前的配送插曲，再继续送达。");return false
 if not super.deliver_order(id):return false
 if not campaign:return true
 var order=order_by_id(id)
 # Old saves without a stored draw receive a draw only after their first successful delivery.
 if not order.has("story_roll"):
  order.story_roll=forced_story_roll if forced_story_roll>=0 else random_source.randf()
  order.story_probability=float(courier.probability)
  order.story_candidate=courier.events[random_source.randi_range(0,courier.events.size()-1)].id
 var triggered=float(order.story_roll)<float(order.story_probability)
 order.story_triggered=triggered;order.story_resolved=not triggered;order.story_choice=""
 if triggered:
  var used: Array=[]
  for other in orders:
   if today(other) and other.id!=id and other.get("story_triggered",false):used.append(other.get("story_event",""))
  var candidates: Array=[]
  for event in courier.events:
   if event.id not in used:candidates.append(event.id)
  if candidates.is_empty():order.story_triggered=false;order.story_resolved=true;return true
  order.story_event=order.story_candidate if order.story_candidate in candidates else candidates[0]
  record_event("courier_trigger_"+id,order.person_id,order.place_id,"配送插曲："+event_by_id(order.story_event).title)
  tell("配送插曲："+event_by_id(order.story_event).title)
 return true
func resolve_story(choice: String) -> bool:
 if choice not in ["remember","continue"]:return false
 var order=pending_story()
 if order.is_empty():return false
 var event=event_by_id(order.story_event)
 order.story_resolved=true;order.story_choice=choice
 if choice=="remember":
  minute=mini(1439,minute+5);save_clue(event.title+"："+event.remember)
 var detail=event.remember if choice=="remember" else "你选择先完成配送，暂未追问。"
 pending_posts.append({"order_id":order.id,"person_id":order.person_id,"place_id":order.place_id,"text":"配送见闻 / "+event.title+"："+detail})
 pending_messages.append({"person_id":order.person_id,"text":event.night})
 record_event("courier_choice_"+order.id,order.person_id,order.place_id,event.title+" / "+detail)
 tell("插曲已记录。"+("花费5分钟核对，线索已保存。" if choice=="remember" else "继续配送。"))
 return true
func return_home() -> bool:
 if not pending_story().is_empty():tell("先选择如何处理眼前的配送插曲。");return false
 return super.return_home()
func valid_save(data: Variant) -> bool:
 if not super.valid_save(data):return false
 for order in data.orders:
  for field in ["story_roll","story_probability"]:
   if order.has(field):
    var value=order[field]
    if not (value is float or value is int) or not is_finite(float(value)) or value<0 or value>1:return false
  for field in ["story_triggered","story_resolved"]:
   if order.has(field) and not order[field] is bool:return false
  for field in ["story_candidate","story_event"]:
   if order.has(field) and event_by_id(str(order[field])).is_empty():return false
  if order.get("story_triggered",false):
   if order.status!="已送达" or event_by_id(str(order.get("story_event",""))).is_empty():return false
   if not order.get("story_resolved",false) and data.period!="day":return false
  if order.has("story_choice") and order.story_choice not in ["","remember","continue"]:return false
 return true
