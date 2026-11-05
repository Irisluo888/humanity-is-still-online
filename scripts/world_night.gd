extends "res://scripts/world_courier.gd"
var night_catalog: Array=JSON.parse_string(FileAccess.get_file_as_string("res://data/night_content.json"))
var desktop_state: Dictionary={"chat":{},"read":[]}
var unlocked_content: Dictionary={}
var followups: Array=[]
func new_campaign() -> void:
 desktop_state={"chat":{},"read":[]};unlocked_content={};followups=[]
 super.new_campaign()
func card_by_id(id: String) -> Dictionary:
 for card in night_catalog:
  if card.id==id:return card
 return {}
func sync_unlocks() -> void:
 if not campaign or period!="night" or location not in ["home","desktop"]:return
 var modified=false
 for card in night_catalog:
  if day<int(card.min_day) or unlocked_content.has(card.id):continue
  for event in events:
   if event.place_id!=card.place_id:continue
   var matched=false
   for prefix in card.prefixes:
    if str(event.id).begins_with(prefix):matched=true
   if not matched:continue
   unlocked_content[card.id]={"day":day,"source_event":event.id}
   modified=true;break
 ensure_message_ids()
 if modified:changed.emit()
func ensure_message_ids() -> void:
 for i in range(night_messages.size()):
  if not night_messages[i].has("message_id"):night_messages[i].message_id="night_%05d" % i
  if not night_messages[i].has("received_day"):night_messages[i].received_day=day
func return_home() -> bool:
 if not super.return_home():return false
 sync_unlocks();return true
func unread_for(person_id: String) -> int:
 ensure_message_ids()
 var count=0
 for message in night_messages:
  if message.person_id==person_id and message.message_id not in desktop_state.read:count+=1
 return count
func read_contact(person_id: String) -> void:
 ensure_message_ids()
 for message in night_messages:
  if message.person_id==person_id and message.message_id not in desktop_state.read:desktop_state.read.append(message.message_id)
func send_chat(person_id: String,value: String) -> bool:
 var text=value.strip_edges()
 if not campaign or not people.has(person_id) or text.is_empty() or text.length()>1000:return false
 if not desktop_state.chat.has(person_id):desktop_state.chat[person_id]=[]
 var records: Array=desktop_state.chat[person_id]
 records.append({"id":"local_%s_%d" % [person_id,records.size()],"text":text,"time":time_text()})
 changed.emit();return true
func queue_followup(content_id: String) -> bool:
 if not campaign or period!="night" or not unlocked_content.has(content_id):return false
 var card=card_by_id(content_id)
 if not card.get("followup",false):return false
 var id="followup_"+content_id
 for task in followups:
  if task.id==id:tell("这条回访已记录，不会重复创建。");return false
 followups.append({"id":id,"content_id":content_id,"source_event":unlocked_content[content_id].source_event,"person_id":card.person_id,"place_id":card.place_id,"available_day":day+1,"status":"accepted","text":"到榆灯巷07号门口核对便签位置"})
 save_clue(card.title+"：第%d晚获知，次日到%s门口核对。" % [day,str(places[card.place_id])])
 tell("已记录次日回访。配送巡航不会自动处理回访或收工。")
 return true
func active_followup() -> Dictionary:
 if not campaign or period!="day":return {}
 for task in followups:
  if task.status=="accepted" and int(task.available_day)<=day:return task
 return {}
func complete_followup() -> bool:
 var task=active_followup()
 if task.is_empty() or not near(CUSTOMER):return false
 task.status="completed"
 var text="已当面核对七号门口便签位置；门铃仍需维修，不据此推断异常。"
 save_clue(text)
 record_event(task.id,task.person_id,task.place_id,text)
 pending_posts.append({"order_id":task.id,"person_id":task.person_id,"place_id":task.place_id,"text":"回访记录："+text})
 pending_messages.append({"person_id":task.person_id,"text":"今天在门口核对过了，便签已经放到避雨处。谢谢。"})
 tell("回访完成，记录会在收工后的夜间信息中出现。")
 return true
func extra_save_data() -> Dictionary:
 return {"night_system":{"schema":1,"desktop":desktop_state,"unlocks":unlocked_content,"followups":followups}}
func apply_extra_save(data: Dictionary) -> void:
 var state: Dictionary=data.get("night_system",{})
 desktop_state=state.get("desktop",{"chat":{},"read":[]}).duplicate(true)
 unlocked_content=state.get("unlocks",{}).duplicate(true)
 followups=state.get("followups",[]).duplicate(true)
 for message in night_messages:
  if not message.has("received_day"):message.received_day=0
 ensure_message_ids();sync_unlocks()
func valid_save(data: Variant) -> bool:
 if not super.valid_save(data):return false
 var message_ids: Array=[]
 for message in data.night_messages:
  if message.has("message_id"):
   if not message.message_id is String or message.message_id in message_ids:return false
   message_ids.append(message.message_id)
  if message.has("received_day"):
   if not (message.received_day is float or message.received_day is int) or message.received_day<0 or message.received_day>data.day:return false
 if not data.has("night_system"):return true
 var state=data.night_system
 if not state is Dictionary or state.get("schema",0)!=1:return false
 var desktop=state.get("desktop")
 if not desktop is Dictionary or not desktop.get("chat") is Dictionary or not desktop.get("read") is Array:return false
 if desktop.read.size()>20000 or desktop.chat.size()>people.size():return false
 for id in desktop.read:
  if not id is String:return false
 for person in desktop.chat:
  if not people.has(person) or not desktop.chat[person] is Array or desktop.chat[person].size()>5000:return false
  for message in desktop.chat[person]:
   if not message is Dictionary:return false
   for key in ["id","text","time"]:
    if not message.get(key) is String:return false
   if message.text.length()>1000:return false
 if not state.get("unlocks") is Dictionary or not state.get("followups") is Array or state.followups.size()>100:return false
 var source_ids: Array=[]
 for event in data.events:source_ids.append(event.id)
 for id in state.unlocks:
  if card_by_id(id).is_empty():return false
  var unlock=state.unlocks[id]
  if not unlock is Dictionary or not unlock.get("source_event") is String or unlock.source_event not in source_ids:return false
  if not (unlock.get("day") is float or unlock.get("day") is int) or unlock.day<1 or unlock.day>data.day:return false
 var ids: Array=[]
 for task in state.followups:
  if not task is Dictionary or task.get("id") in ids:return false
  for key in ["id","content_id","source_event","person_id","place_id","status","text"]:
   if not task.get(key) is String:return false
  if not card_by_id(task.content_id).get("followup",false) or not people.has(task.person_id) or not places.has(task.place_id):return false
  var card=card_by_id(task.content_id)
  if task.person_id!=card.person_id or task.place_id!=card.place_id or task.source_event not in source_ids or not state.unlocks.has(task.content_id):return false
  if task.status not in ["accepted","completed"]:return false
  if not (task.get("available_day") is float or task.get("available_day") is int) or task.available_day<1:return false
  ids.append(task.id)
 return true
