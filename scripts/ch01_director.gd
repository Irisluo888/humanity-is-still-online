extends Node
signal updated
var catalog: Dictionary=JSON.parse_string(FileAccess.get_file_as_string("res://data/ch01_story.json"))
var state: Dictionary={}
var session_active=false
var developer_mode=false
const SAVE="user://ch01_campaign.json"
var save_path=SAVE
const MAPS={"home":"res://scenes/ch01_maps/home.tscn","street":"res://scenes/ch01_maps/street.tscn","garden":"res://scenes/ch01_maps/garden.tscn","store":"res://scenes/ch01_maps/store.tscn","hallway":"res://scenes/ch01_maps/hallway.tscn","elevator":"res://scenes/ch01_maps/elevator.tscn"}
func fresh() -> void:
 WorldData.new_campaign();session_active=true
 state={"schema":2,"beat":0,"place":"street","flags":{},"completed":[],"messages":[],"news":[],"read":[],"danger":false,"durability":10,"capacity":8.0,"exposure":false,"positions":{},"scene_states":{},"encounter":false,"event_active":false,"page":0,"stock":{"water":4,"food":3,"medicine":1},"money":186.5}
 WorldData.inventory={"food":2,"water":2,"medicine":1}
 WorldData.forced_story_roll=0.99
 WorldData.orders[0].fee=13.5
 WorldData.orders[0].status="配送中"
 WorldData.orders[0].address="临街民居"
 sync()
func beat() -> Dictionary:return catalog.beats[int(state.beat)]
func modal() -> bool:return state.event_active or state.encounter
func sync() -> void:
 state.danger=state.encounter or (state.event_active and beat().danger)
 var id: String=beat().id
 if id=="orders" and not state.flags.get("chapter_orders_created",false):
  WorldData.orders=[];WorldData.add_daily_order()
  for i in range(3):
   var order: Dictionary=WorldData.orders[i]
   order.id="order_ch01_%03d"%(i+1);order.address=["普通居民楼","写字楼前台","幸福花园3栋1203"][i]
   order.item=["早餐","奶茶","家常菜"][i];order.pickup_name=["早餐铺","奶茶店","家常菜馆"][i];order.note=["送至门前交付","前台代收","老人腿脚不好，麻烦送上楼"][i];order.status="可接单";order.day=WorldData.day
  WorldData.active_order_id="";state.flags.chapter_orders_created=true
 if id=="group":publish_chat("rider_group")
 if id=="lunch":publish_chat("xiaoyu")
 if id=="night":
  publish_chat("night_group");publish_chat("zhou_warning");publish_chat("xiaoyu_late")
  for i in range(3):publish_news(i)
 if state.flags.get("ch01_complete",false):publish_news(3);publish_news(4)
 updated.emit()
func travel_reason(place: String) -> String:
 if modal():return "请先完成当前对话或事件。"
 if not MAPS.has(place):return "这里暂时无法进入。"
 if place=="garden" and int(state.beat)<5:return "先完成今晚送餐、修车和回家群聊；次日领取1203餐食后再前往幸福花园。"
 if place=="store" and not state.completed.has("elevator"):return "先完成三栋配送并乘电梯下楼，再前往便利店。"
 if place=="street" and beat().id in ["group","lunch"]:return "先在家查看骑手群和小鱼私信，明天再出门。"
 var links={"home":["street"],"street":["home","garden"],"garden":["street","store","hallway"],"store":["garden"],"hallway":["elevator"],"elevator":["garden"]}
 if place not in links.get(state.place,[]):return "请从对应的出入口前往这里。"
 return ""
func enter(place: String) -> bool:
 if not travel_reason(place).is_empty():return false
 state.place=place;sync();return true
func start_event() -> bool:
 if state.encounter or state.event_active or state.place!=beat().place:return false
 state.event_active=true;state.page=0;sync();return true
func page() -> Dictionary:return beat().pages[clampi(int(state.page),0,beat().pages.size()-1)]
func step_page() -> bool:
 if not state.event_active:return false
 if state.page<beat().pages.size()-1:
  state.page+=1;sync();return true
 return false
func publish_chat(thread: String) -> void:
 for i in range(catalog.chat[thread].size()):
  var id=thread+"_%03d"%i
  if not state.messages.any(func(m):return m.id==id):state.messages.append({"id":id,"thread":thread,"text":catalog.chat[thread][i]})
func publish_news(index: int) -> void:
 var item=catalog.news[index]
 if not state.news.any(func(n):return n.id==item.id):state.news.append(item.duplicate(true))
func mark_read(id: String) -> void:
 if id not in state.read:state.read.append(id)
func next(choice: String="continue") -> bool:
 var id: String=beat().id
 if id in state.completed or state.place!=beat().place:return false
 if id=="final":
  if choice not in ["quarantine","colleague_help","aid_pending","missing","opened_door"]:return false
  if choice=="aid_pending" and WorldData.inventory.medicine<1:return false
  if choice=="aid_pending":WorldData.inventory.medicine-=1
  state.flags.ch01_zhou_outcome=choice
  if choice=="opened_door":state.exposure=true;WorldData.health=maxi(1,WorldData.health-15)
 if id=="store":
  if choice not in ["weapon","extinguisher","hands","leave"]:return false
  if choice=="weapon" and state.durability<3:return false
  if choice=="extinguisher" and state.flags.get("extinguisher_used",false):return false
  if choice=="weapon":state.durability-=3
  if choice=="extinguisher":state.flags.extinguisher_used=true
  if choice=="hands":WorldData.health=maxi(1,WorldData.health-25)
  state.flags.ch01_store_owner_saved=choice!="leave"
  state.scene_states.store={"broken":true,"chen_saved":choice!="leave","method":choice}
 if id=="lunch":state.flags.ch01_lunch_yes=choice=="yes"
 if id=="end":state.flags.ch01_told_group=choice=="public";state.flags.ch01_complete=true
 state.completed.append(id);state.flags["ch01_"+id+"_done"]=true
 state.event_active=false;state.page=0
 if id!="end":state.beat+=1
 if id=="1203" and choice=="skip":state.beat+=1
 # Scene travel follows actual doors, except short mandatory scene transitions.
 if id in ["1203","1404"]:state.place=beat().place;state.event_active=true
 if id=="elevator":state.place="garden"
 if id=="lunch":state.place="home"
 if id in ["night","knock1","call","reveal"]:state.event_active=true
 if id=="final":state.event_active=true
 sync();return true
func fast_home() -> bool:
 if modal():return false
 state.place="home";sync();return true
func weight() -> float:return WorldData.inventory.food*0.4+WorldData.inventory.water*0.5+WorldData.inventory.medicine*0.2
func take(item: String) -> bool:
 var mass={"food":0.4,"water":0.5,"medicine":0.2}
 if not mass.has(item) or weight()+mass[item]>state.capacity:return false
 WorldData.inventory[item]+=1;updated.emit();return true
func collect_loose(id: String,item: String) -> bool:
 if modal() or id!="street_water" or item!="water" or state.place!="street" or state.flags.get("picked_"+id,false):return false
 if not take(item):return false
 state.flags["picked_"+id]=true;sync();return true
func buy(item: String) -> bool:
 if modal() or state.place!="store" or state.scene_states.get("store",{}).get("broken",false):return false
 if state.stock.get(item,0)<1 or state.money<3 or not take(item):return false
 state.money-=3;state.stock[item]-=1;sync();return true
func use_item(item: String) -> bool:
 if modal() or WorldData.inventory.get(item,0)<1:return false
 if item=="medicine":
  if WorldData.health>=100:return false
  WorldData.health=mini(100,WorldData.health+25)
 else:
  if WorldData.stamina>=100:return false
  WorldData.stamina=mini(100,WorldData.stamina+15)
 WorldData.inventory[item]-=1;sync();return true
func repair_weapon() -> bool:
 if modal() or state.place!="home" or state.durability>=10:return false
 if WorldData.inventory.water<1 or WorldData.inventory.food<1:return false
 WorldData.inventory.water-=1;WorldData.inventory.food-=1;state.durability=10;sync();return true
func escape_chance() -> float:return clampf(0.6+WorldData.stamina/250.0-weight()/25.0,0.15,0.95)
func resolve_encounter(method: String,roll: float=-1) -> bool:
 if not state.encounter or method not in ["weapon","protect","force","escape"]:return false
 if method=="weapon":
  if state.durability<2:return false
  state.durability-=2
 elif method=="protect":
  if WorldData.inventory.water<1:return false
  WorldData.inventory.water-=1
 elif method=="force" or (method=="escape" and (randf() if roll<0 else roll)>escape_chance()):
  WorldData.health=maxi(1,WorldData.health-10);WorldData.stamina=maxi(0,WorldData.stamina-10)
 state.encounter=false;state.flags.encounter_result="已脱离接触。普通遭遇不会感染。";sync();return true
func remember_position(pos: Vector3) -> void:
 if not state.is_empty():state.positions[state.place]=[pos.x,pos.y,pos.z]
func complete_delivery(id: String) -> bool:
 var order=WorldData.order_by_id(id)
 if order.is_empty() or not WorldData.deliver_order(id):return false
 state.money+=float(order.fee);sync();return true
func clock_text() -> String:
 var id: String=beat().id
 if id in ["delivery","repair"]:return "第0天 21:36"
 if id in ["group","lunch"]:return "第0天 23:47"
 if id in ["orders","1203","1404","elevator"]:return "第1天 午后"
 if id=="store":return "第1天 16:10"
 if id=="night":return "第1天 23:35"
 if id=="knock1":return "第1天 23:46"
 if id in ["call","reveal","final"]:return "第1天 23:53"
 return "第2天 00:17"
func save() -> bool:
 var data={"orders":WorldData.orders,"active_order_id":WorldData.active_order_id,"state":state,"health":WorldData.health,"stamina":WorldData.stamina,"inventory":WorldData.inventory}
 data.world={"events":WorldData.events,"daytime_orders":WorldData.daytime_orders,"encountered_npcs":WorldData.encountered_npcs,"pending_posts":WorldData.pending_posts,"pending_messages":WorldData.pending_messages}
 var f=FileAccess.open(save_path+".tmp",FileAccess.WRITE)
 if f==null:return false
 f.store_string(JSON.stringify(data));f.close()
 if FileAccess.file_exists(save_path):DirAccess.copy_absolute(save_path,save_path+".bak")
 return DirAccess.rename_absolute(save_path+".tmp",save_path)==OK
func valid(data: Variant) -> bool:
 if not data is Dictionary or not data.get("state") is Dictionary:return false
 var s: Dictionary=data.state
 if (s.get("schema")!=1 and s.get("schema")!=2) or not (s.get("beat") is float or s.get("beat") is int):return false
 if s.beat<0 or s.beat>=catalog.beats.size() or s.beat!=floor(s.beat) or not MAPS.has(s.get("place","")):return false
 if not s.get("flags") is Dictionary:return false
 for k in ["messages","news","read","completed"]:
  if not s.get(k) is Array or s[k].size()>10000:return false
 for k in ["durability","capacity"]:
  if not (s.get(k) is float or s.get(k) is int) or s[k]<0 or s[k]>100:return false
 for k in ["encounter","exposure"]:
  if not s.get(k) is bool:return false
 for k in ["health","stamina"]:
  if not (data.get(k) is float or data.get(k) is int) or data[k]<0 or data[k]>100:return false
 if not data.get("inventory") is Dictionary:return false
 for k in ["food","water","medicine"]:
  if not (data.inventory.get(k) is float or data.inventory.get(k) is int) or data.inventory[k]<0 or data.inventory[k]>1000:return false
 for list in [s.messages,s.news]:
  var ids=[]
  for entry in list:
   if not entry is Dictionary or not entry.get("id") is String or not entry.get("text") is String or entry.id in ids:return false
   ids.append(entry.id)
 if data.has("orders"):
  if not data.orders is Array or data.orders.size()>1000:return false
  var ids=[]
  for order in data.orders:
   if not order is Dictionary:return false
   for k in ["id","item","address","status","route_key"]:
    if not order.get(k) is String:return false
   if order.id in ids or order.status not in ["可接单","待取餐","配送中","已送达","已取消","已结束"] or order.route_key not in ["soup","market","books"]:return false
   ids.append(order.id)
 if data.has("world"):
  if not data.world is Dictionary:return false
  for k in ["events","daytime_orders","encountered_npcs","pending_posts","pending_messages"]:
   if not data.world.get(k) is Array:return false
 if s.get("schema")==2:
  for k in ["positions","scene_states","stock"]:
   if not s.get(k) is Dictionary:return false
  for key in s.positions:
   var v=s.positions[key]
   if not MAPS.has(key) or not v is Array or v.size()!=3:return false
   for n in v:
    if not (n is float or n is int) or not is_finite(float(n)) or absf(float(n))>100:return false
  if not s.get("event_active") is bool:return false
  if not (s.get("money") is float or s.get("money") is int) or s.money<0:return false
  if s.scene_states.has("store"):
   if not s.scene_states.store is Dictionary:return false
   for k in ["broken","chen_saved"]:
    if not s.scene_states.store.get(k) is bool:return false
  for k in ["water","food","medicine"]:
   if not (s.stock.get(k) is float or s.stock.get(k) is int) or s.stock[k]<0:return false
  if not (s.get("page") is float or s.get("page") is int) or s.page<0 or s.page>=catalog.beats[int(s.beat)].pages.size():return false
 return true
func restore() -> bool:
 var d=JSON.parse_string(FileAccess.get_file_as_string(save_path))
 if not valid(d):return false
 var s: Dictionary=d.state
 if int(s.schema)==1:
  s.merge({"positions":{},"scene_states":{},"stock":{"water":4,"food":3,"medicine":1},"money":186.5,"event_active":bool(s.get("danger",false)),"page":0},true);s.schema=2
 WorldData.new_campaign();WorldData.health=int(d.health);WorldData.stamina=int(d.stamina);WorldData.inventory=d.inventory
 if d.get("orders") is Array:WorldData.orders=d.orders
 if d.get("active_order_id") is String:WorldData.active_order_id=d.active_order_id
 if d.get("world") is Dictionary:
  for k in ["events","daytime_orders","encountered_npcs","pending_posts","pending_messages"]:
   if d.world.get(k) is Array:WorldData.set(k,d.world[k])
 session_active=true;state=s;sync();return true
func debug_jump(index: int) -> void:
 if not OS.is_debug_build():return
 fresh()
 while state.beat<index:
  state.place=beat().place
  next("quarantine" if beat().id=="final" else ("extinguisher" if beat().id=="store" else "continue"))
 state.place=beat().place;state.event_active=beat().id not in ["delivery","orders","group","night"]
 sync()
