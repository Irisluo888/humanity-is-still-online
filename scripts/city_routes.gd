extends "res://scripts/city_district.gd"
var board: PanelContainer
var guidance: Label
var route_nodes: Array=[]
var neighbors={"market":{"person":"local_8","place":"market","point":Vector3(-5,0,-1.5),"label":"早市摊主"},"books":{"person":"local_5","place":"books","point":Vector3(4,0,2),"label":"旧书摊主"}}
func _ready() -> void:
 super._ready()
 var layer=CanvasLayer.new();add_child(layer)
 guidance=Label.new();guidance.position=Vector2(24,20);guidance.add_theme_font_size_override("font_size",18);layer.add_child(guidance)
 var toggle=Button.new();toggle.text="订单板 / Tab（再次按关闭）";toggle.position=Vector2(24,650);toggle.pressed.connect(toggle_board);layer.add_child(toggle)
 board=preload("res://ui/delivery_board.gd").new();board.position=Vector2(24,80);layer.add_child(board);board.hide()
 for key in neighbors:
  var data: Dictionary=neighbors[key]
  var sign=Label3D.new();sign.text=data.label+" / E";sign.position=data.point+Vector3(0,2,0)
  sign.billboard=BaseMaterial3D.BILLBOARD_ENABLED;sign.no_depth_test=true;sign.pixel_size=0.012;sign.font_size=32;add_child(sign)
  var portrait=Sprite3D.new();portrait.texture=load("res://assets/art/avatars/avatar_%d.png" % (8 if key=="market" else 5))
  portrait.billboard=BaseMaterial3D.BILLBOARD_ENABLED;portrait.texture_filter=BaseMaterial3D.TEXTURE_FILTER_NEAREST
  portrait.pixel_size=0.018;portrait.position=data.point+Vector3(0,1,0);add_child(portrait)
func toggle_board() -> void:
 board.visible=not board.visible
 if board.visible:board.refresh()
func _input(event: InputEvent) -> void:
 if event is InputEventKey and event.pressed and not event.echo and event.physical_keycode==KEY_TAB:
  get_viewport().set_input_as_handled();toggle_board()
func _physics_process(delta: float) -> void:
 if is_instance_valid(board) and board.visible:
  if is_instance_valid(player): player.velocity=Vector3.ZERO
  return
 super._physics_process(delta)
 update_guidance()
func update_guidance() -> void:
 if not is_instance_valid(guidance): return
 var target: Vector3=WorldData.delivery_target()
 var offset=Vector2(target.x-player.position.x,target.z-player.position.z)
 var screen=Vector2(offset.x-offset.y,offset.x+offset.y)
 var horizontal="右" if screen.x>0.8 else ("左" if screen.x < -0.8 else "")
 var vertical="下" if screen.y>0.8 else ("上" if screen.y < -0.8 else "")
 var detail="已到附近，按 E 交互" if offset.length()<2 else "目标距离 %.1f 米 · 向%s%s方移动" % [offset.length(),horizontal,vertical]
 if WorldData.current_order().get("status","") not in ["待取餐","配送中"]:
  for order in WorldData.orders:
   if WorldData.today(order) and order.status in ["待取餐","配送中"]:detail="请先在订单板追踪未完成任务，再按方向前往"
 guidance.text="榆灯巷 / "+WorldData.objective()+"\n"+detail+"\nTab 打开订单板；加单可选"
func _unhandled_key_input(event: InputEvent) -> void:
 if is_instance_valid(board) and board.visible:return
 if event is InputEventKey and event.pressed and not event.echo and event.physical_keycode==KEY_E:
  var best=2.0
  for point in sites.values():best=minf(best,Vector2(player.position.x,player.position.z).distance_to(Vector2(point.x,point.z)))
  for point in portals.values():best=minf(best,Vector2(player.position.x,player.position.z).distance_to(Vector2(point.x,point.z)))
  var selected=""
  for key in neighbors:
   var point: Vector3=neighbors[key].point
   var distance=Vector2(player.position.x,player.position.z).distance_to(Vector2(point.x,point.z))
   if distance<best:best=distance;selected=key
  if not selected.is_empty():
   var data: Dictionary=neighbors[selected]
   WorldData.discover(data.place)
   if WorldData.current_order().get("person_id","")==data.person and WorldData.current_order().get("status","")=="配送中":
    WorldData.deliver_order(WorldData.active_order_id)
   else:WorldData.talk(data.person,data.place,data.point)
   return
 super._unhandled_key_input(event)
