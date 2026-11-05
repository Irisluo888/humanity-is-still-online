extends Node3D
const Kit=preload("res://ui/kit.gd")
var player: CharacterBody3D
var prompt: Label
var transitioning:=false
var area: String
var solids: Array[Rect2]=[]
func block(at: Vector3,dimensions: Vector3,color: String,solid: bool=false) -> void:
 var mesh=MeshInstance3D.new(); var box=BoxMesh.new(); box.size=dimensions; mesh.mesh=box
 var material=StandardMaterial3D.new(); material.albedo_color=Color(color); material.roughness=0.95
 mesh.material_override=material; mesh.position=at; add_child(mesh)
 if solid:
  var body=StaticBody3D.new(); body.position=at; add_child(body)
  var hit=CollisionShape3D.new(); var shape=BoxShape3D.new(); shape.size=dimensions; hit.shape=shape; body.add_child(hit)
  if at.y>0: solids.append(Rect2(at.x-dimensions.x/2.0-0.3,at.z-dimensions.z/2.0-0.3,dimensions.x+0.6,dimensions.z+0.6))
func label_at(text: String,at: Vector3) -> void:
 var label=Label3D.new(); label.text=text; label.position=at
 label.billboard=BaseMaterial3D.BILLBOARD_ENABLED; label.no_depth_test=true
 label.font_size=32; label.pixel_size=0.012; add_child(label)
func safe_spawn(point: Vector3) -> Vector3:
 if abs(point.x)>4.5 or point.z < -3.5 or point.z>4.3 or abs(point.y)>1: return Vector3(0,0.1,3)
 for rect in solids:
  if rect.has_point(Vector2(point.x,point.z)): return Vector3(0,0.1,3)
 return Vector3(point.x,0.1,point.z)
func _ready() -> void:
 if not WorldData.campaign:
  WorldData.new_campaign(); WorldData.depart(); WorldData.city_position=Vector3(-9,0,-1); WorldData.enter_district("shop")
 if WorldData.location not in ["shop","corridor"]:
  get_tree().call_deferred("change_scene_to_file",WorldData.scene_for_location()); return
 area=WorldData.location
 block(Vector3(0,-0.2,0.3),Vector3(10,0.4,9.4),"69717a",true)
 block(Vector3(0,1.5,-4),Vector3(10,3,0.3),"45536a",true)
 for x in [-5,5]: block(Vector3(x,1.5,0.3),Vector3(0.3,3,9.4),"4b596b",true)
 for x in [-3.2,3.2]: block(Vector3(x,0.6,4.9),Vector3(3.6,1.2,0.3),"4b596b",true)
 # An invisible low threshold collider keeps the open-looking exit inside the play area.
 var exit_wall=StaticBody3D.new(); exit_wall.position=Vector3(0,0.5,5.1); add_child(exit_wall)
 var exit_hit=CollisionShape3D.new(); var exit_shape=BoxShape3D.new(); exit_shape.size=Vector3(10,2,0.3); exit_hit.shape=exit_shape; exit_wall.add_child(exit_hit)
 if area=="shop":
  block(Vector3(-3,0.7,-1.5),Vector3(2.8,1.4,1.4),"8c7863",true)
  block(Vector3(2.8,1.1,-0.7),Vector3(1.2,2.2,4.3),"667985",true)
  for z in [-2.1,-0.8,0.6]:
   for y in [0.6,1.3,2.0]:
    block(Vector3(2.1,y,z),Vector3(0.55,0.12,0.9),"a8a497")
    for offset in [-0.25,0,0.25]: block(Vector3(1.98,y+0.19,z+offset),Vector3(0.2,0.3,0.17),"a49172")
  block(Vector3(-3.6,1.2,-3.3),Vector3(1.1,2.4,0.8),"8c9fa6",true)
  label_at("货架 / 保持通道畅通",Vector3(2.5,2.8,0))
  label_at("晚班便利店",Vector3(-2,2.5,-2.5))
 else:
  # Corridor doors are blocked scenery, not unexplored scene entrances.
  for x in [-4.8,4.8]:
   for z in [-2.3,1]:
    block(Vector3(x,1.25,z),Vector3(0.12,2.5,1.3),"8c7964")
    block(Vector3(x*0.99,1.1,z+0.4),Vector3(0.12,0.1,0.1),"c2ac87")
  block(Vector3(-3,0.45,-2.7),Vector3(2,0.9,0.8),"7a7065",true)
  block(Vector3(3,1.1,-3.2),Vector3(1.5,2.2,0.8),"576b77",true)
  label_at("公共布告 / 不堆放杂物",Vector3(0,2.2,-3.6))
  label_at("住户门（暂未开放）",Vector3(-4,2.7,-1))
 label_at("返回榆灯巷 / E",Vector3(0,2.5,4))
 var light=DirectionalLight3D.new(); light.rotation_degrees=Vector3(-50,-25,0); light.light_energy=1.2; add_child(light)
 var world=WorldEnvironment.new(); var env=Environment.new(); env.background_mode=Environment.BG_COLOR; env.background_color=Color("253243")
 env.ambient_light_source=Environment.AMBIENT_SOURCE_COLOR; env.ambient_light_color=Color("b6b2a1"); env.ambient_light_energy=0.6; world.environment=env; add_child(world)
 player=CharacterBody3D.new(); add_child(player); player.position=safe_spawn(WorldData.interior_position)
 var hit=CollisionShape3D.new(); var capsule=CapsuleShape3D.new(); capsule.radius=0.25; capsule.height=1.5; hit.shape=capsule; hit.position.y=0.8; player.add_child(hit)
 var sprite=Sprite3D.new(); sprite.texture=load("res://assets/art/refined/rider_uniform.png"); sprite.pixel_size=0.018; sprite.position.y=0.9
 sprite.billboard=BaseMaterial3D.BILLBOARD_ENABLED; sprite.texture_filter=BaseMaterial3D.TEXTURE_FILTER_NEAREST; player.add_child(sprite)
 var camera=Camera3D.new(); camera.projection=Camera3D.PROJECTION_ORTHOGONAL; camera.size=15; camera.position=Vector3(10,13,14); add_child(camera); camera.look_at(Vector3(0,0,0)); camera.current=true
 var layer=CanvasLayer.new(); add_child(layer)
 var heading=Kit.label(("晚班便利店" if area=="shop" else "居民楼公共走廊")+" / 可探索灰盒",24); heading.position=Vector2(24,24); layer.add_child(heading)
 prompt=Kit.label("",18); prompt.position=Vector2(24,560); layer.add_child(prompt)
 var exit_button=Kit.button("返回街道 / 靠近出口按E",leave)
 exit_button.position=Vector2(24,650); layer.add_child(exit_button)
 var panel=preload("res://ui/loop_panel.gd").new(); panel.position=Vector2(1000,24); panel.custom_minimum_size.x=250; layer.add_child(panel)
func _physics_process(_delta: float) -> void:
 if transitioning or not is_instance_valid(player): return
 var axis=Vector2(float(Input.is_physical_key_pressed(KEY_D))-float(Input.is_physical_key_pressed(KEY_A)),float(Input.is_physical_key_pressed(KEY_S))-float(Input.is_physical_key_pressed(KEY_W)))
 if Input.is_action_pressed("ui_left"): axis.x=-1
 if Input.is_action_pressed("ui_right"): axis.x=1
 if Input.is_action_pressed("ui_up"): axis.y=-1
 if Input.is_action_pressed("ui_down"): axis.y=1
 var direction=Vector3(axis.x+axis.y,0,axis.y-axis.x).normalized()
 player.velocity=Vector3(direction.x*3,-3,direction.z*3); player.move_and_slide()
 if player.position.y < -3: player.position=Vector3(0,0.1,3)
 WorldData.interior_position=player.position
 var near_exit=Vector2(player.position.x,player.position.z).distance_to(Vector2(0,4))<=1.3
 prompt.text="WASD / 方向键移动 · 出口需要靠近后按E\n"+("按E返回街道；配送和时间进度保持。" if near_exit else "出口在门廊前侧。房门为场景占位，暂不可进入。")
func _unhandled_key_input(event: InputEvent) -> void:
 if event is InputEventKey and event.pressed and not event.echo and event.physical_keycode==KEY_E: leave()
func leave() -> void:
 if transitioning or not is_instance_valid(player): return
 WorldData.interior_position=player.position
 if WorldData.leave_district():
  transitioning=true
  get_tree().change_scene_to_file("res://scenes/city_delivery.tscn")
 else: WorldData.tell("请先走到前侧的街道出口。")
