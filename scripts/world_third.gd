extends "res://scripts/world_data.gd"
var daytime_orders: Array = []
var encountered_npcs: Array = []
var night_posts: Array = []
var night_messages: Array = []
var assistant_history: Array = [{"role":"assistant","text":"我会整理本机记录。可以问门铃、保温袋、雨天和订单；未知消息仍需核实。"}]
var clues: Array = []
func _ready() -> void:
 super._ready()
 var data: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/desktop_third.json"))
 for contact in data.contacts: people[contact.id] = contact.name
 places.merge({"market":"老城早市","shop":"晚班便利店","books":"旧书摊"},true)
 for record in data.orders:
  var found := false
  for order in orders:
   if order.id == record.id:
    order.merge(record,true)
    found = true
    break
  if not found: orders.append(record.duplicate(true))
func deliver_order(id: String) -> bool:
 for order in orders:
  if order.id != id: continue
  if order.status == "已送达": return false
  order.status = "已送达"
  daytime_orders.append(order.duplicate(true))
  if not encountered_npcs.has(order.person_id): encountered_npcs.append(order.person_id)
  var text: String = str(people[order.person_id]) + "：" + str(order.item) + "已收到，谢谢。地点：" + str(places[order.place_id])
  night_posts.append({"order_id":id,"person_id":order.person_id,"place_id":order.place_id,"text":text})
  night_messages.append({"person_id":order.person_id,"text":text})
  record_event("delivered_"+id,order.person_id,order.place_id,text)
  return true
 return false
func income() -> float:
 var total := 0.0
 for order in orders:
  if order.status == "已送达": total += float(order.get("fee",0))
 return total
func ask_local(query: String) -> String:
 var data: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/desktop_third.json"))
 var reply := "缓存没有匹配信息。我无法确认，请到现场或联系当事人核实。"
 for rule in data.assistant_rules:
  if query.contains(rule.keyword): reply = rule.reply; break
 if query.contains("整理") or query.contains("线索"): reply = "当前城市记录：\n" + str(events.size()) + "条事件；遇见" + str(encountered_npcs.size()) + "位居民。\n" + str(daytime_orders.size()) + "笔本次送达记录。"
 assistant_history.append({"role":"user","text":query})
 assistant_history.append({"role":"assistant","text":reply})
 return reply
func save_clue(text: String) -> void:
 if not clues.has(text): clues.append(text)
