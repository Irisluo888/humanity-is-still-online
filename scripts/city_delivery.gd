extends "res://scripts/city.gd"
var player: CharacterBody3D
var info: Label
var sites = {"取餐":Vector3(-7,0,2),"送达":Vector3(6,0,-4),"回家":Vector3(0,0,8),"food":Vector3(-5,0,2),"water":Vector3(-2,0,1),"medicine":Vector3(3,0,1)}
func _ready() -> void:
 if not WorldData.campaign:
  WorldData.new_campaign(); WorldData.depart()
 WorldData.location="city"
 super._ready()
 for child in get_children():
  if child is CanvasLayer: child.queue_free()
 # Give the existing authored greybox actual building collisions.
 for child in get_children():
  if child is MeshInstance3D:
   child.create_trimesh_collision()
 player=CharacterBody3D.new(); add_child(player); player.position=WorldData.city_position+Vector3(0,0.1,0)
 var hit=CollisionShape3D.new(); var shape=CapsuleShape3D.new(); shape.radius=0.25; shape.height=1.5; hit.shape=shape; hit.position.y=0.8; player.add_child(hit)
 var sprite=Sprite3D.new(); sprite.texture=load("res://assets/art/refined/rider_uniform.png"); sprite.pixel_size=0.018; sprite.position.y=0.9; sprite.billboard=BaseMaterial3D.BILLBOARD_ENABLED; sprite.texture_filter=BaseMaterial3D.TEXTURE_FILTER_NEAREST; player.add_child(sprite)
 for key in sites:
  var label=Label3D.new(); label.text=key if key in ["取餐","送达","回家"] else WorldData.item_name(key)
  label.position=sites[key]+Vector3(0,2,0); label.billboard=BaseMaterial3D.BILLBOARD_ENABLED; label.font_size=40; label.pixel_size=0.014; label.no_depth_test=true; add_child(label)
 var layer=CanvasLayer.new(); add_child(layer)
 info=Label.new(); info.position=Vector2(24,500); layer.add_child(info)
 var panel=preload("res://ui/loop_panel.gd").new(); panel.position=Vector2(1000,24); panel.custom_minimum_size.x=250; layer.add_child(panel)
func _physics_process(delta: float) -> void:
 var axis=Vector2(float(Input.is_physical_key_pressed(KEY_D))-float(Input.is_physical_key_pressed(KEY_A)),float(Input.is_physical_key_pressed(KEY_S))-float(Input.is_physical_key_pressed(KEY_W))).normalized()
 if Input.is_action_pressed("ui_left"): axis.x=-1
 if Input.is_action_pressed("ui_right"): axis.x=1
 if Input.is_action_pressed("ui_up"): axis.y=-1
 if Input.is_action_pressed("ui_down"): axis.y=1
 var direction=Vector3(axis.x+axis.y,0,axis.y-axis.x).normalized()
 player.velocity=Vector3(direction.x*3,-3,direction.z*3); player.move_and_slide()
 player.position.x=clampf(player.position.x,-10,10); player.position.z=clampf(player.position.z,-9,9)
 WorldData.city_position=player.position
 info.text=WorldData.time_text()+"\n"+WorldData.objective()+"\nWASD / 方向键移动 · 靠近标记按E"
func _unhandled_key_input(event: InputEvent) -> void:
 if event is InputEventKey and event.pressed and not event.echo and event.physical_keycode==KEY_E:
  var nearest_key=""
  var best=2.0
  for candidate in sites:
   var distance=Vector2(player.position.x,player.position.z).distance_to(Vector2(sites[candidate].x,sites[candidate].z))
   if distance<best: best=distance; nearest_key=candidate
  for key in sites:
   if key!=nearest_key: continue
   match key:
    "取餐": WorldData.pickup_order()
    "送达": WorldData.deliver_order(WorldData.active_order_id)
    "回家":
     if WorldData.return_home(): get_tree().change_scene_to_file("res://scenes/bedroom.tscn")
    _: WorldData.collect_item(key,sites[key])
   return
