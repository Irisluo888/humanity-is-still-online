extends Node
# Single digital store. Game minutes qualify arrival; real seconds only animate presentation.
signal changed
signal message_arrived(message: Dictionary)
signal message_revealed(message: Dictionary)
signal player_sent_message(message: Dictionary)
signal unread_count_changed(thread_id: String,count: int)
signal news_published(article: Dictionary)
signal notification_posted(notification: Dictionary)
var catalog: Dictionary=JSON.parse_string(FileAccess.get_file_as_string("res://data/messaging.json"))
var records: Dictionary={}
var articles: Dictionary={}
var notifications: Dictionary={}
var calls: Dictionary={}
var started: Dictionary={}
var remaining: Dictionary={}
var choices: Dictionary={}
var current_minute=0
var context_flags: Dictionary={}
var context_scene=""
var serial=0
var profile="chapter"
var presentation_paused=false
var presentation_speed=1.0
func reset(scope="chapter") -> void:
 profile=scope;records={};articles={};notifications={};calls={};started={};remaining={};choices={};serial=0;current_minute=0;context_flags={};context_scene="";changed.emit()
func set_context(minute: int,flags: Dictionary={},scene="") -> void:
 current_minute=minute;context_flags=flags.duplicate(true);context_scene=scene;process_due()
func eligible(requirements: Dictionary) -> bool:
 for key in requirements.get("flags",{}):
  if context_flags.get(key)!=requirements.flags[key]:return false
 if requirements.has("scene") and context_scene!=requirements.scene:return false
 for id in requirements.get("read_ids",[]):
  if not records.has(id) or not records[id].read:return false
 for key in requirements.get("replies",{}):
  if choices.get(key)!=requirements.replies[key]:return false
 return true
func queue_message(spec: Dictionary) -> bool:
 if not spec.get("id") is String or spec.id.is_empty() or records.has(spec.id):return false
 if not catalog.threads.has(spec.get("thread_id","")) or not catalog.contacts.has(spec.get("sender_id","")) or not spec.get("text") is String:return false
 serial+=1
 var message=spec.duplicate(true)
 message.merge({"sent_at":current_minute,"arrive_at":current_minute,"delay_seconds":1.5,"requires":{},"attachments":[],"choices":[]},false)
 if not numeric(message.sent_at) or not numeric(message.arrive_at) or not numeric(message.delay_seconds) or message.delay_seconds<0:return false
 if not message.requires is Dictionary:return false
 message.merge({"delivered":false,"revealed":false,"read":false,"ordinal":serial},true)
 records[message.id]=message;process_due();return true
func queue_script(id: String,at_minute: int,requirements: Dictionary={}) -> void:
 if not catalog.scripts.has(id):return
 for item in catalog.scripts[id]:
  var spec: Dictionary=item.duplicate(true);spec.sent_at=at_minute;spec.arrive_at=at_minute;spec.requires=requirements
  queue_message(spec)
func process_due() -> void:
 var modified=false
 for message in records.values():
  if not message.delivered and message.arrive_at<=current_minute and eligible(message.requires):
   message.delivered=true;modified=true
   if not started.has(message.thread_id):post_notification("pending_"+message.thread_id,"message",catalog.threads[message.thread_id].name,"收到新消息，打开会话查看。",message.thread_id)
   message_arrived.emit(message.duplicate(true))
 for article in articles.values():
  if not article.published and article.published_at<=current_minute and eligible(article.requires):
   article.published=true;modified=true;post_notification("news_"+article.id,"news",article.title,article.text,"news");news_published.emit(article.duplicate(true))
 for call in calls.values():
  if call.status=="queued" and call.arrive_at<=current_minute and eligible(call.requires):call.status="ringing";modified=true;post_notification("call_"+call.id,"call",catalog.contacts[call.sender_id].name,"来电","phone")
 if modified:changed.emit()
func begin_thread(thread_id: String) -> void:
 if not catalog.threads.has(thread_id):return
 if not started.has(thread_id):started[thread_id]=true;remaining[thread_id]=0.4
func ordered(thread_id: String) -> Array:
 var result=[]
 for message in records.values():
  if message.thread_id==thread_id:result.append(message)
 result.sort_custom(func(a,b):return a.ordinal<b.ordinal)
 return result
func pending(thread_id: String) -> Dictionary:
 for message in ordered(thread_id):
  if not message.revealed:return message
 return {}
func typing_sender(thread_id: String) -> String:
 if not started.has(thread_id):return ""
 var message=pending(thread_id)
 if message.is_empty() or not message.delivered or not message.choices.is_empty():return ""
 return "" if message.sender_id=="player" else catalog.contacts[message.sender_id].name
func waiting_reply(thread_id: String) -> Dictionary:
 var message=pending(thread_id)
 if not message.is_empty() and message.delivered and not message.choices.is_empty():return message.duplicate(true)
 return {}
func _process(delta: float) -> void:
 tick_presentation(delta)
func tick_presentation(delta: float) -> void:
 if presentation_paused or delta<0:return
 for thread_id in started.keys():
  var message=pending(thread_id)
  if message.is_empty() or not message.delivered or not message.choices.is_empty():continue
  remaining[thread_id]=float(remaining.get(thread_id,0))-delta*presentation_speed
  if remaining[thread_id]>0:continue
  message.revealed=true
  if message.sender_id=="player":message.read=true
  var next=pending(thread_id)
  remaining[thread_id]=float(next.get("delay_seconds",1.5))
  post_notification("message_"+message.id,"message",catalog.threads[message.thread_id].name,message.text,message.thread_id)
  message_revealed.emit(message.duplicate(true));unread_count_changed.emit(thread_id,get_unread_count(thread_id));changed.emit()
func choose_reply(message_id: String,choice_id: String) -> bool:
 if not records.has(message_id):return false
 var message: Dictionary=records[message_id]
 if not message.delivered or message.revealed or pending(message.thread_id).id!=message_id:return false
 for option in message.choices:
  if option.id!=choice_id:continue
  choices[message_id]=choice_id;message.text=option.text;message.revealed=true;message.read=true;remaining[message.thread_id]=1.2
  player_sent_message.emit(message.duplicate(true));message_revealed.emit(message.duplicate(true));process_due();changed.emit();return true
 return false
func send_message(thread_id: String,text: String,stable_id="") -> bool:
 var value=text.strip_edges()
 if value.is_empty() or value.length()>1000:return false
 var id=stable_id if not stable_id.is_empty() else "player_%06d"%(serial+1)
 if not queue_message({"id":id,"thread_id":thread_id,"sender_id":"player","text":value}):return false
 records[id].revealed=true;records[id].read=true;player_sent_message.emit(records[id].duplicate(true));changed.emit();return true
func get_thread_messages(thread_id: String) -> Array:
 var result=[]
 for m in ordered(thread_id):
  if m.delivered and m.revealed:result.append(m.duplicate(true))
 return result
func get_unread_count(thread_id: String) -> int:
 var count=0
 for m in records.values():
  if m.thread_id==thread_id and m.delivered and m.sender_id!="player" and not m.read and m.revealed:count+=1
 if not started.has(thread_id):
  for m in records.values():
   if m.thread_id==thread_id and m.delivered and not m.read:return 1
 return count
func mark_read(thread_id: String,ids: Array=[]) -> void:
 var modified=false
 for m in records.values():
  if m.thread_id==thread_id and m.revealed and not m.read and (ids.is_empty() or m.id in ids):m.read=true;modified=true
 if modified:
  for n in notifications.values():
   if n.target==thread_id:n.read=get_unread_count(thread_id)==0
  unread_count_changed.emit(thread_id,get_unread_count(thread_id));process_due();changed.emit()
func is_read(id: String) -> bool:return records.has(id) and records[id].read
func thread_finished(thread_id: String) -> bool:
 return not ordered(thread_id).is_empty() and pending(thread_id).is_empty()
func queue_news(spec: Dictionary) -> bool:
 if not spec.get("id") is String or articles.has(spec.id) or not spec.get("text") is String:return false
 var article=spec.duplicate(true);article.merge({"title":spec.text.split("\n")[0].replace("标题：",""),"published_at":current_minute,"requires":{},"read":false,"published":false},false)
 articles[article.id]=article;process_due();return true
func get_news() -> Array:
 var result=[]
 for article in articles.values():
  if article.published:result.append(article.duplicate(true))
 result.sort_custom(func(a,b):return a.published_at<b.published_at if a.published_at!=b.published_at else a.id<b.id)
 return result
func read_news(id: String) -> void:
 if articles.has(id) and articles[id].published:articles[id].read=true;changed.emit()
func post_notification(id: String,kind: String,title: String,text: String,target: String) -> void:
 if notifications.has(id):return
 var n={"id":id,"kind":kind,"title":title,"text":text,"target":target,"read":false,"at":current_minute};notifications[id]=n;notification_posted.emit(n.duplicate(true))
func queue_call(id: String,sender_id: String,at: int,requires: Dictionary={}) -> bool:
 if calls.has(id) or not catalog.contacts.has(sender_id):return false
 calls[id]={"id":id,"sender_id":sender_id,"arrive_at":at,"requires":requires.duplicate(true),"status":"queued"};process_due();return true
func answer_call(id: String) -> bool:
 if not calls.has(id) or calls[id].status!="ringing":return false
 calls[id].status="answered";changed.emit();return true
func format_time(minute: int) -> String:return "第%d天 %02d:%02d"%[minute/1440,(minute%1440)/60,minute%60]
func numeric(value: Variant) -> bool:return (value is int or value is float) and is_finite(float(value))
func save_data() -> Dictionary:
 return {"schema":1,"profile":profile,"minute":current_minute,"serial":serial,"records":records.duplicate(true),"articles":articles.duplicate(true),"notifications":notifications.duplicate(true),"calls":calls.duplicate(true),"started":started.duplicate(true),"remaining":remaining.duplicate(true),"choices":choices.duplicate(true)}
func valid_data(data: Variant) -> bool:
 if not data is Dictionary or data.get("schema")!=1 or not data.get("profile") is String:return false
 if not numeric(data.get("minute")) or data.minute<0 or not numeric(data.get("serial")):return false
 for key in ["records","articles","notifications","calls","started","remaining","choices"]:
  if not data.get(key) is Dictionary or data[key].size()>20000:return false
 var ordinals=[]
 for id in data.records:
  var m=data.records[id]
  if not m is Dictionary or m.get("id")!=id:return false
  if not catalog.threads.has(m.get("thread_id","")) or not catalog.contacts.has(m.get("sender_id","")) or not m.get("text") is String:return false
  for key in ["sent_at","arrive_at","ordinal","delay_seconds"]:
   if not numeric(m.get(key)) or m[key]<0:return false
  if m.ordinal in ordinals:return false
  ordinals.append(m.ordinal)
  for key in ["delivered","revealed","read"]:
   if not m.get(key) is bool:return false
  if m.revealed and not m.delivered:return false
  if not m.get("requires") is Dictionary or not m.get("choices") is Array or not m.get("attachments") is Array:return false
  for option in m.choices:
   if not option is Dictionary or not option.get("id") is String or not option.get("text") is String:return false
 for id in data.articles:
  var n=data.articles[id]
  if not n is Dictionary or n.get("id")!=id or not n.get("text") is String or not n.get("title") is String or not numeric(n.get("published_at")) or not n.get("requires") is Dictionary or not n.get("read") is bool or not n.get("published") is bool:return false
 for id in data.started:
  if not catalog.threads.has(id) or not data.started[id] is bool:return false
 for id in data.remaining:
  if not catalog.threads.has(id) or not numeric(data.remaining[id]):return false
 for id in data.calls:
  var item=data.calls[id]
  if not item is Dictionary or item.get("id")!=id or not catalog.contacts.has(item.get("sender_id","")) or item.get("status") not in ["queued","ringing","answered"] or not numeric(item.get("arrive_at")) or not item.get("requires") is Dictionary:return false
 for id in data.notifications:
  var n=data.notifications[id]
  if not n is Dictionary:return false
  for key in ["id","kind","title","text","target"]:
   if not n.get(key) is String:return false
  if n.id!=id or not n.get("read") is bool or not numeric(n.get("at")):return false
 return true
func load_data(data: Variant) -> bool:
 if not valid_data(data):return false
 profile=data.profile;current_minute=int(data.minute);serial=int(data.serial)
 records=data.records.duplicate(true);articles=data.articles.duplicate(true);notifications=data.notifications.duplicate(true);calls=data.calls.duplicate(true);started=data.started.duplicate(true);remaining=data.remaining.duplicate(true);choices=data.choices.duplicate(true)
 changed.emit();return true
func migrate_legacy(messages: Array,read_ids: Array,news: Array,minute: int) -> void:
 reset();current_minute=minute
 for old in messages:
  var spec={}
  for items in catalog.scripts.values():
   for item in items:
    if item.id==old.id:spec=item.duplicate(true)
  if spec.is_empty():continue
  spec.text=str(old.text).split("：",true,1)[-1];spec.sent_at=minute;spec.arrive_at=minute
  if queue_message(spec):
   records[old.id].revealed=true;records[old.id].read=old.id in read_ids
 for article in news:queue_news(article)
 changed.emit()
