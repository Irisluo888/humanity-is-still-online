extends SceneTree
var failures=0
var checks=0
var c: Node
var skip_1404=false
var store_method="extinguisher"
var ending_method="quarantine"
func _initialize() -> void:call_deferred("run")
func check(v: bool,name: String) -> void:
 checks+=1;print("PASS: " if v else "FAIL: ",name)
 if not v:failures+=1
func frames(n=8) -> void:
 for i in range(n):await process_frame
func capture(name: String) -> void:
 if current_scene.has_method("continue_dialogue"):current_scene.typing=9999
 await frames(15);await RenderingServer.frame_post_draw
 check(root.get_texture().get_image().save_png("res://artifacts/ch01_qa/"+name+".png")==OK,"capture "+name)
func press(key: int) -> void:
 var e=InputEventKey.new();e.physical_keycode=key;e.pressed=true;root.push_input(e,true)
 e=InputEventKey.new();e.physical_keycode=key;root.push_input(e,true);await frames()
func at(id: String) -> void:
 var map=current_scene.map_world
 check(map.points.has(id),"actual map point "+id)
 if not map.points.has(id):quit(1);return
 map.player.position=map.points[id].pos+Vector3(0,0.1,0.6)
 await frames(3);await press(KEY_E)
func finish_event(choice="continue") -> void:
 check(c.state.event_active,"dialogue active "+c.beat().id)
 while c.state.page<c.beat().pages.size()-1:c.step_page()
 await frames(3)
 if c.beat().id=="store":await capture("14_attack_choices")
 if c.beat().id=="final":await capture("15_final_choices")
 if c.beat().id=="call":await capture("16_phone_call")
 if c.beat().id=="knock1":await capture("17_second_knock")
 var texts={"skip":"直接下楼","weapon":"使用武器 / 耐久-3","extinguisher":"使用柜台旁灭火器（用后耗尽）","hands":"徒手救援 / 生命-25","leave":"逃离现场 / 陈姨未获救","yes":"答应午餐","quarantine":"联系医疗救援","colleague_help":"联系老马和小鱼","aid_pending":"隔门提供医疗物资（需1）","missing":"拒绝开门","public":"向群里公开","private":"暂时隐瞒"}
 if choice=="opened_door":
  var found=find_button(current_scene,"直接开门 / 特殊高风险");check(found!=null,"high risk choice visible")
  if found:found.pressed.emit()
  await frames(2)
  var dialog: ConfirmationDialog=null
  for node in current_scene.get_children():
   if node is ConfirmationDialog:dialog=node
  check(dialog!=null,"opening door requires second confirmation")
  if dialog:dialog.confirmed.emit();dialog.queue_free()
 elif texts.has(choice):
  var found=find_button(current_scene,texts[choice]);check(found!=null,"choice UI "+choice)
  if found:found.pressed.emit()
 else:
  if c.beat().id in ["store","final","1203","lunch","end"]:c.next(choice)
  else:
   current_scene.typing=999;current_scene.body_text.visible_characters=-1
   await press(KEY_SPACE)
 await frames()
func find_button(node: Node,text: String) -> Button:
 if node is Button and node.text==text:return node
 for child in node.get_children():
  var b=find_button(child,text)
  if b:return b
 return null
func run() -> void:
 root.size=Vector2i(1280,720);c=root.get_node("Chapter");c.save_path="user://ch01_qa.json";c.fresh()
 change_scene_to_file("res://scenes/ch01.tscn");await frames(20)
 check(not c.developer_mode,"developer tools default off")
 check(find_button(current_scene,"前往 home")==null and find_button(current_scene,"拾取饮水 / 容量校验")==null,"no state edit controls")
 await capture("01_street")
 var origin=current_scene.map_world.player.position
 var e=InputEventKey.new();e.physical_keycode=KEY_D;e.pressed=true;root.push_input(e,true)
 for i in range(15):await physics_frame
 e=InputEventKey.new();e.physical_keycode=KEY_D;root.push_input(e,true)
 check(current_scene.map_world.player.position.distance_to(origin)>0.1,"WASD actually moves CharacterBody3D")
 await at("delivery");check(c.beat().id=="repair","real delivery API enters repair")
 await at("repair");await finish_event();check(c.beat().id=="group","repair ends")
 await at("home");await at("pc")
 check(current_scene.has_method("chapter_messages"),"original desktop shared chapter messages")
 current_scene.open_app("消息");await frames()
 await capture("12_desktop_chat")
 current_scene.return_chapter();await frames();await finish_event()
 current_scene.show_phone();current_scene.close_phone();await frames();await finish_event("yes")
 check(c.beat().id=="orders","group and lunch advance through device")
 await at("door");await at("pickup");check(c.beat().id=="1203" and World(c).current_order().status=="配送中","main meal picked through original order logic")
 await at("garden");check(current_scene.map_world.kind=="garden" and current_scene.map_world.scene_file_path.ends_with("garden.tscn"),"garden actual resource loaded")
 await capture("02_garden")
 await at("building");check(c.state.place=="hallway","building enters independent hallway")
 await capture("03_hallway")
 if skip_1404:await finish_event("skip")
 else:await finish_event();await finish_event()
 check(c.state.place=="elevator","optional1404 precedes elevator")
 await capture("04_elevator");await finish_event()
 await at("store");check(current_scene.map_world.kind=="store","store actual interior")
 await capture("05_store_before")
 await at("extinguisher");await at("attack")
 check(not c.fast_home(),"attack cannot fast home")
 await capture("06_attack");await finish_event(store_method)
 check(c.state.scene_states.store.chen_saved==(store_method!="leave"),"chosen store outcome saved")
 if store_method=="extinguisher":check(c.state.flags.extinguisher_used,"extinguisher consumed")
 await capture("07_store_after")
 check(c.fast_home(),"resolved attack restores fast home")
 await frames();await capture("08_home")
 await at("pc");current_scene.open_app("热榜");await frames();await capture("13_desktop_news");current_scene.return_chapter();await frames();await at("bed");await finish_event()
 check(c.beat().id=="knock1" and c.state.event_active,"knock begins after nighttime review")
 await capture("09_knock")
 await finish_event();check(c.beat().id=="call","call after anonymous knocks")
 await finish_event();check(c.beat().id=="reveal","identity revealed only after phone")
 await capture("10_reveal");await finish_event();await finish_event(ending_method)
 check(not c.state.flags.get("ch01_complete",false),"final choice does not prematurely end chapter")
 await finish_event("public");await capture("11_ending")
 check(c.state.flags.ch01_complete,"complete chapter through UI route")
 check(c.save() and c.restore(),"new schema save restore")
 for skip in [false,true]:
  for outcome in ["quarantine","colleague_help","aid_pending","missing","opened_door"]:
   c.fresh()
   var guard=0
   while c.beat().id!="end" and guard<30:
    guard+=1;c.state.place=c.beat().place
    var id=c.beat().id
    check(c.next(outcome if id=="final" else ("hands" if id=="store" else ("skip" if id=="1203" and skip else "continue"))),"branch "+id)
   c.state.place="home";c.next("private")
   check(c.state.flags.ch01_zhou_outcome==outcome and c.state.exposure==(outcome=="opened_door"),"ending outcome "+outcome)
 c.fresh();var before=World(c).health;c.state.encounter=true;c.sync()
 check(not c.fast_home(),"normal encounter blocks home")
 check(c.resolve_encounter("escape",1) and not c.state.exposure and World(c).health==before-10,"failed escape no infection")
 c.state.durability=1;c.state.encounter=true;check(not c.resolve_encounter("weapon"),"insufficient durability rejected")
 c.state.encounter=false;c.sync()
 var w=World(c);w.inventory.water=16;check(not c.take("water"),"overweight pickup rejected")
 c.state.place="garden";c.remember_position(Vector3(3,0.1,4));c.enter("home");c.enter("garden")
 check(c.state.positions.garden[0]==3,"per-map position retained")
 var bad={"state":c.state.duplicate(true),"health":85,"stamina":75,"inventory":w.inventory};bad.state.positions.garden=["bad",0,0]
 check(not c.valid(bad),"malformed position rejected before mutation")
 print("QA CHECKS: ",checks," FAILURES: ",failures);quit(1 if failures else 0)
func World(_chapter: Node) -> Node:return root.get_node("WorldData")
