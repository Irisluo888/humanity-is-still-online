extends "res://scripts/city_routes.gd"
var planner=preload("res://scripts/cruise_planner.gd").new()
var planner_ready:=false
var cruising:=false
var path_points:=PackedVector3Array()
var path_index:=0
var planned_target:=Vector3.ZERO
var cruise_label: Label
var cruise_button: Button
var route_line: MeshInstance3D
var story_panel: PanelContainer
var shown_story:=""
var stuck_time:=0.0
var last_position:=Vector3.ZERO
var last_unfinished_count:=-1
func _ready() -> void:
 super._ready()
 var layer=CanvasLayer.new();add_child(layer)
 cruise_label=Label.new();cruise_label.position=Vector2(24,600);cruise_label.add_theme_font_size_override("font_size",16);layer.add_child(cruise_label)
 cruise_button=Button.new();cruise_button.text="自动巡航 / F";cruise_button.position=Vector2(320,650);cruise_button.pressed.connect(toggle_cruise);layer.add_child(cruise_button)
 story_panel=PanelContainer.new();story_panel.position=Vector2(300,150);story_panel.custom_minimum_size=Vector2(650,330)
 var style=StyleBoxFlat.new();style.bg_color=Color("26364a");style.border_color=Color("c3a67d");style.set_border_width_all(2);style.set_content_margin_all(20);story_panel.add_theme_stylebox_override("panel",style)
 layer.add_child(story_panel);story_panel.hide()
 route_line=MeshInstance3D.new();add_child(route_line)
 call_deferred("prepare_planner")
func prepare_planner() -> void:
 await get_tree().physics_frame
 await get_tree().physics_frame
 if not is_instance_valid(player):return
 planner.build(get_world_3d().direct_space_state,player.get_rid());planner_ready=true
 cruise_label.text="请先处理配送插曲；有未完成已接订单时才可继续巡航。" if not WorldData.pending_story().is_empty() else "F只配送已接订单；送完原地停止，收工需自行回家。"
func manual_input() -> bool:
 for code in [KEY_W,KEY_A,KEY_S,KEY_D,KEY_UP,KEY_LEFT,KEY_DOWN,KEY_RIGHT]:
  if Input.is_physical_key_pressed(code):return true
 for action in ["ui_left","ui_right","ui_up","ui_down"]:
  if Input.is_action_pressed(action):return true
 return false
func _notification(what: int) -> void:
 if what==NOTIFICATION_APPLICATION_FOCUS_OUT and cruising:stop_cruise("窗口失焦，巡航已暂停。")
func _input(event: InputEvent) -> void:
 if event is InputEventKey and event.pressed and not event.echo:
  var code: int=event.physical_keycode if event.physical_keycode!=0 else event.keycode
  if code==KEY_F:
   get_viewport().set_input_as_handled();toggle_cruise();return
  if code in [KEY_ESCAPE,KEY_E,KEY_TAB,KEY_W,KEY_A,KEY_S,KEY_D,KEY_UP,KEY_LEFT,KEY_DOWN,KEY_RIGHT] and cruising:stop_cruise("已切回手动操作。")
 super._input(event)
func toggle_board() -> void:
 if not WorldData.pending_story().is_empty():return
 if cruising:stop_cruise("打开订单板，巡航暂停。")
 super.toggle_board()
func unfinished_count() -> int:
 var count:=0
 for order in WorldData.orders:
  if WorldData.today(order) and order.status in ["待取餐","配送中"]:count+=1
 return count
func update_cruise_controls() -> void:
 if not is_instance_valid(cruise_button):return
 var count=unfinished_count()
 if count>0 and count!=last_unfinished_count and not cruising and WorldData.pending_story().is_empty():
  cruise_label.text="有%d份未完成的已接订单，按F开始配送巡航；收工由你决定。" % count
 last_unfinished_count=count
 cruise_button.disabled=not cruising and (count==0 or not planner_ready or not WorldData.pending_story().is_empty())
 if cruising:cruise_button.text="停止配送巡航 / F"
 elif count==0:cruise_button.text="巡航不可用 / 暂无已接订单"
 else:cruise_button.text="配送巡航 / F（待完成%d单）" % count
func toggle_cruise() -> void:
 if cruising:stop_cruise("巡航已停止。");return
 if not planner_ready:WorldData.tell("路线正在准备，请稍候再按F。");return
 if not WorldData.pending_story().is_empty():WorldData.tell("先处理眼前的配送插曲，再继续巡航。");return
 if not select_next_order():
  stop_cruise("暂无未完成的已接订单。请先接新单；收工需自行回家。")
  WorldData.tell("巡航只配送已接订单，不自动接新单，也不自动收工。")
  update_cruise_controls();return
 board.hide()
 cruising=true;stuck_time=0;last_position=player.position
 plan_route()
func select_next_order() -> bool:
 if WorldData.current_order().get("status","") in ["待取餐","配送中"] and WorldData.today(WorldData.current_order()):return true
 for order in WorldData.orders:
  if WorldData.today(order) and order.status in ["待取餐","配送中"]:WorldData.focus_order(order.id);return true
 return false
func plan_route() -> void:
 if unfinished_count()==0:
  stop_cruise("已接订单全部完成。可接新单或自行返回住所收工。")
  update_cruise_controls();return
 planned_target=WorldData.delivery_target()
 path_points=planner.path(player.position,planned_target);path_index=0
 if path_points.is_empty():stop_cruise("没有找到安全路线，请手动绕行后再按F。");return
 draw_route()
 cruise_label.text="巡航中 / "+WorldData.objective()+" · F / 方向键可停止"
func draw_route() -> void:
 var mesh=ImmediateMesh.new();var material=StandardMaterial3D.new();material.albedo_color=Color("9ab6a6");material.shading_mode=BaseMaterial3D.SHADING_MODE_UNSHADED
 if path_points.size()>1:
  mesh.surface_begin(Mesh.PRIMITIVE_LINE_STRIP,material)
  for point in path_points:mesh.surface_add_vertex(point+Vector3(0,0.03,0))
  mesh.surface_end()
 route_line.mesh=mesh
func stop_cruise(text: String) -> void:
 cruising=false;path_points.clear()
 if is_instance_valid(route_line):route_line.mesh=null
 if is_instance_valid(player):player.velocity=Vector3.ZERO
 if is_instance_valid(cruise_label):cruise_label.text=text
func sync_story() -> bool:
 var order=WorldData.pending_story()
 if order.is_empty():story_panel.hide();shown_story="";return false
 if cruising:stop_cruise("遇到配送插曲，巡航暂停。"+("选择后有已接任务才可继续。" if unfinished_count()>0 else "本轮配送已完成，请自行决定接单或收工。"))
 if shown_story!=order.id:
  shown_story=order.id
  for child in story_panel.get_children():story_panel.remove_child(child);child.queue_free()
  var event=WorldData.event_by_id(order.story_event)
  var column=VBoxContainer.new();column.add_theme_constant_override("separation",16);story_panel.add_child(column)
  for text in ["配送插曲 / "+event.title,event.body]:
   var label=Label.new();label.text=text;label.custom_minimum_size.x=600;label.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;label.add_theme_font_size_override("font_size",20);column.add_child(label)
  for choice in ["remember","continue"]:
   var value: String=choice
   var button=Button.new();button.text="聊两句并记下（5分钟）" if value=="remember" else "先完成配送，暂不追问"
   button.custom_minimum_size.y=36;button.pressed.connect(func():WorldData.resolve_story(value);story_panel.hide());column.add_child(button)
  var note=Label.new();note.text="结果会留在今天的记录里；回家后查看动态与消息。";note.add_theme_font_size_override("font_size",16);column.add_child(note)
 story_panel.show();return true
func _unhandled_key_input(event: InputEvent) -> void:
 if not WorldData.pending_story().is_empty():return
 super._unhandled_key_input(event)
func _physics_process(delta: float) -> void:
 if not is_instance_valid(story_panel):return
 update_cruise_controls()
 if sync_story():
  player.velocity=Vector3.ZERO
  info.text=WorldData.time_text()+"\n配送已完成，眼前的插曲等待选择。"
  guidance.text="榆灯巷 / 配送插曲\n选择后如有未完成已接订单，可按F继续；当前不会自动移动。"
  return
 if not cruising:
  if unfinished_count()==0 and WorldData.pending_story().is_empty():cruise_label.text="暂无未完成的已接订单；接新单后才能巡航。收工需自行回家。"
  super._physics_process(delta);return
 if unfinished_count()==0:
  stop_cruise("已接订单全部完成，已原地停止。请自行决定接单或收工。")
  update_cruise_controls();return
 if manual_input():stop_cruise("已切回手动操作。");super._physics_process(delta);return
 WorldData.city_position=player.position
 if Vector2(player.position.x,player.position.z).distance_to(Vector2(planned_target.x,planned_target.z))<0.7:
  var order=WorldData.current_order()
  var acted=false
  if order.get("status","")=="待取餐":acted=WorldData.pickup_order()
  elif order.get("status","")=="配送中":acted=WorldData.deliver_order(WorldData.active_order_id)
  else:
   stop_cruise("当前订单已结束，请接单后再使用配送巡航。")
   update_cruise_controls();return
  if not WorldData.pending_story().is_empty():sync_story();return
  if not acted:stop_cruise("当前目标无法交互，请检查订单状态。");return
  if select_next_order():plan_route()
  else:stop_cruise("已接订单全部完成，已原地停止。可接新单或自行回家。")
  update_cruise_controls();return
 while path_index<path_points.size() and Vector2(player.position.x,player.position.z).distance_to(Vector2(path_points[path_index].x,path_points[path_index].z))<0.16:path_index+=1
 if path_index>=path_points.size():stop_cruise("已到路线终点，请靠近目标按E。");return
 var direction=path_points[path_index]-player.position;direction.y=0;direction=direction.normalized()
 player.velocity=Vector3(direction.x*3,-3,direction.z*3);player.move_and_slide()
 WorldData.city_position=player.position
 if player.position.distance_to(last_position)<0.005:stuck_time+=delta
 else:stuck_time=0
 last_position=player.position
 if stuck_time>1.5:stop_cruise("路线被挡住，巡航已暂停；手动绕行后再按F。")
 info.text=WorldData.time_text()+"\n"+WorldData.objective()+"\n巡航沿可通行路线移动，不会穿过建筑。"
 update_guidance()

func update_guidance() -> void:
 super.update_guidance()
 if unfinished_count()==0 and WorldData.pending_story().is_empty() and is_instance_valid(guidance):
  guidance.text="本轮已接订单均已完成\nTab查看并接取新单；收工请自行回到住所入口按E。"
