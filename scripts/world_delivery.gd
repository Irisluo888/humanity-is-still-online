extends "res://scripts/world_loop.gd"
var routes: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/delivery_routes.json"))
func add_daily_order() -> void:
 for i in range(3):
  var key: String=["soup","market","books"][i]
  var order: Dictionary=routes[key].duplicate(true)
  order.id="day_%d_order_%03d" % [day,i+1]; order.day=day; order.route_key=key
  order.status="待取餐" if i==0 else "可接单"
  orders.append(order)
  if i==0: active_order_id=order.id
func route_for(order: Dictionary) -> Dictionary:
 return routes.get(order.get("route_key","soup"),routes.soup)
func today(order: Dictionary) -> bool:
 return int(order.get("day",day if str(order.get("id","")).begins_with("day_%d_" % day) else 0))==day
func order_by_id(id: String) -> Dictionary:
 for order in orders:
  if order.id==id: return order
 return {}
func accept_order(id: String) -> bool:
 var order=order_by_id(id)
 if not campaign or period!="day" or not today(order) or order.get("status","")!="可接单": return false
 order.status="待取餐"; active_order_id=id
 tell("已接单："+order.item+"。"+objective()); return true
func focus_order(id: String) -> bool:
 var order=order_by_id(id)
 if not campaign or period!="day" or not today(order) or order.get("status","") not in ["待取餐","配送中"]: return false
 active_order_id=id; tell(objective()); return true
func cancel_order(id: String) -> bool:
 var order=order_by_id(id)
 if not campaign or period!="day" or not today(order): return false
 if order.get("route_key","soup")=="soup": tell("今日基础配送需要完成，不能取消。"); return false
 if order.get("status","") not in ["可接单","待取餐"]: tell("取餐后不能取消，请完成配送。"); return false
 order.status="已取消"
 if active_order_id==id:
  for candidate in orders:
   if today(candidate) and candidate.status in ["待取餐","配送中"]: active_order_id=candidate.id; break
 tell("订单已取消，未产生收入。其余配送继续。")
 return true
func objective() -> String:
 if period=="night": return super.objective()
 var order=current_order()
 if order.is_empty(): return "打开订单板查看今日配送"
 var route=route_for(order)
 if order.status=="待取餐": return "取餐："+route.pickup_name+" / "+order.item
 if order.status=="配送中": return "送达："+order.address+" / "+order.item
 for candidate in orders:
  if today(candidate) and candidate.status in ["待取餐","配送中"]: return "还有配送未完成：Tab打开订单板切换追踪"
 return "可接其他订单，或返回住所收工"
func delivery_target() -> Vector3:
 var order=current_order()
 if not order.is_empty() and order.status in ["待取餐","配送中"]:
  var route=route_for(order)
  var point: Array=route.pickup if order.status=="待取餐" else route.target
  return Vector3(point[0],point[1],point[2])
 return HOME
func pickup_order() -> bool:
 var order=current_order()
 if order.is_empty(): return false
 var point: Array=route_for(order).pickup
 if not campaign or period!="day" or not near(Vector3(point[0],point[1],point[2])) or order.status!="待取餐": return false
 order.status="配送中"; minute+=45; stamina=maxi(0,stamina-8)
 tell("已取餐："+order.item+"。"+objective()); return true
func deliver_order(id: String) -> bool:
 if not campaign: return super.deliver_order(id)
 var order=order_by_id(id)
 if order.is_empty() or id!=active_order_id or not today(order) or period!="day" or order.status!="配送中": return false
 var route=route_for(order); var point: Array=route.target
 if not near(Vector3(point[0],point[1],point[2])): return false
 order.status="已送达"; daytime_orders.append(order.duplicate(true))
 if not encountered_npcs.has(order.person_id): encountered_npcs.append(order.person_id)
 var text=str(people[order.person_id])+"："+route.reply
 pending_posts.append({"order_id":id,"person_id":order.person_id,"place_id":order.place_id,"text":text})
 pending_messages.append({"person_id":order.person_id,"text":text})
 minute+=75; stamina=maxi(0,stamina-12)
 record_event("delivered_"+id,order.person_id,order.place_id,"第%d天送达%s。" % [day,order.item])
 tell("送达完成，收入 +¥%.2f。可追踪其他订单或返回住所。" % float(order.fee)); return true
func return_home() -> bool:
 if not campaign or period!="day" or not near(HOME): return false
 var completed=""
 for order in orders:
  if not today(order): continue
  if order.status in ["待取餐","配送中"]:
   tell("还有已接配送未处理，请完成或取消未取餐的加单。Tab查看订单。")
   return false
  if order.status=="已送达": completed=order.id
 if completed.is_empty(): tell("至少完成一单配送后再收工。"); return false
 active_order_id=completed
 for order in orders:
  if today(order) and order.status=="可接单": order.status="已结束"
 return super.return_home()
func discover(place_id: String) -> bool:
 if not campaign or period!="day" or not places.has(place_id): return false
 var id="visit_%d_%s" % [day,place_id]
 for event in events:
  if event.id==id: return false
 record_event(id,"resident_07",place_id,"到访"+str(places[place_id])+"，已记入今日地点。")
 return true
func talk(person_id: String,place_id: String,point: Vector3) -> bool:
 if not campaign or period!="day" or not near(point) or not people.has(person_id): return false
 var id="talk_%d_%s" % [day,person_id]
 for event in events:
  if event.id==id: tell("已与"+str(people[person_id])+"核对过今日配送备注。"); return false
 if not encountered_npcs.has(person_id): encountered_npcs.append(person_id)
 pending_messages.append({"person_id":person_id,"text":"今天在街上核对过的配送备注已记下，雨天慢一点。"})
 record_event(id,person_id,place_id,"与"+str(people[person_id])+"核对配送地址。")
 tell(str(people[person_id])+"：请按订单地址送达，别把通道堵住。")
 return true
func enter_district(area: String) -> bool:
 if not super.enter_district(area): return false
 discover("shop" if area=="shop" else "lane_07")
 return true
func valid_save(data: Variant) -> bool:
 if not super.valid_save(data): return false
 for order in data.orders:
  if order.status not in ["可接单","待取餐","配送中","已送达","已取消","已结束"]: return false
  if not routes.has(order.get("route_key","soup")): return false
  if order.has("day") and (not (order.day is float or order.day is int) or order.day<1): return false
 return true
