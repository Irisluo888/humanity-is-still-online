extends Node3D
signal hotspot(id: String)
@export var kind="street"
var player: CharacterBody3D
var points: Dictionary={}
var held: Dictionary={}
var locked=false
var encounter_cooldown=2.0
var hint=""
const ART="res://assets/art/ch01/"
func block(pos: Vector3,dim: Vector3,tex: String,solid=true) -> Node3D:
 var mesh=MeshInstance3D.new();var shape=BoxMesh.new();shape.size=dim;mesh.mesh=shape
 var mat=StandardMaterial3D.new();mat.albedo_texture=load(ART+("paving" if tex in ["facade","storefront"] else ("wood" if tex in ["desk","shelf","counter","fridge","elevator","door","bed","wardrobe"] else tex))+".png");mat.texture_filter=BaseMaterial3D.TEXTURE_FILTER_NEAREST;mat.roughness=1.0;mesh.material_override=mat;mesh.position=pos;add_child(mesh)
 if tex in ["facade","storefront","shelf","fridge","counter","door","elevator","wardrobe"]:
  for side in [0,1]:
   var face=MeshInstance3D.new();var quad=QuadMesh.new();quad.size=Vector2(dim.x if side==0 else dim.z,dim.y);face.mesh=quad
   var material=StandardMaterial3D.new();material.albedo_texture=load(ART+(tex if side==0 else "plaster")+".png");material.texture_filter=BaseMaterial3D.TEXTURE_FILTER_NEAREST;material.roughness=1;face.material_override=material
   face.position=Vector3(0,0,dim.z/2+0.005) if side==0 else Vector3(dim.x/2+0.005,0,0)
   if side==1:face.rotation.y=PI/2
   mesh.add_child(face)
 if tex in ["bed","desk"]:
  var surface=MeshInstance3D.new();var quad=QuadMesh.new();quad.size=Vector2(dim.x,dim.z);surface.mesh=quad;surface.rotation.x=-PI/2;surface.position.y=dim.y/2+0.006
  var material=StandardMaterial3D.new();material.albedo_texture=load(ART+tex+".png");material.texture_filter=BaseMaterial3D.TEXTURE_FILTER_NEAREST;surface.material_override=material;mesh.add_child(surface)
 if dim.y<0.5:mat.uv1_scale=Vector3(maxf(1,dim.x/2),maxf(1,dim.z/2),1)
 if solid:
  var body=StaticBody3D.new();var col=CollisionShape3D.new();var b=BoxShape3D.new();b.size=dim;col.shape=b;body.add_child(col);mesh.add_child(body)
 return mesh
func prop(id: String,pos: Vector3,height: float=2.0) -> Sprite3D:
 var s=Sprite3D.new();s.texture=load(ART+id+".png");s.pixel_size=height/96.0;s.position=pos+Vector3(0,height/2,0);s.billboard=BaseMaterial3D.BILLBOARD_ENABLED;s.texture_filter=BaseMaterial3D.TEXTURE_FILTER_NEAREST;add_child(s);return s
func marker(id: String,text: String,pos: Vector3) -> void:
 points[id]={"pos":pos,"text":text}
 var label=Label3D.new();label.text=text if id in ["delivery","repair","pickup","garden","building","store","home"] else "◆";label.position=pos+Vector3(0,1.8,0);label.billboard=BaseMaterial3D.BILLBOARD_ENABLED;label.font_size=40;label.pixel_size=0.012;label.modulate=Color("e0d4b5");add_child(label)
func plaque(text: String,pos: Vector3) -> void:
 var l=Label3D.new();l.text=text;l.position=pos;l.font_size=64;l.pixel_size=0.008;l.billboard=BaseMaterial3D.BILLBOARD_ENABLED;l.modulate=Color("e4c998");add_child(l)
func _ready() -> void:
 var dimensions=Vector3(6,0.3,6) if kind=="elevator" else (Vector3(16,0.3,8) if kind=="hallway" else Vector3(18,0.3,14))
 block(Vector3(0,-0.15,0),dimensions,"wood" if kind=="home" else ("tile" if kind in ["store","elevator","hallway"] else "paving"))
 var camera=Camera3D.new();camera.projection=Camera3D.PROJECTION_ORTHOGONAL;camera.size=9 if kind=="elevator" else (16 if kind=="hallway" else 19);camera.position=Vector3(14,18,20);add_child(camera);camera.look_at(Vector3(0,1.0,0));camera.current=true
 var env=WorldEnvironment.new();var e=Environment.new();e.background_mode=Environment.BG_COLOR;e.background_color=Color("263647");e.ambient_light_source=Environment.AMBIENT_SOURCE_COLOR;e.ambient_light_color=Color("c6c9c3");e.ambient_light_energy=0.75;env.environment=e;add_child(env)
 var sun=DirectionalLight3D.new();sun.rotation_degrees=Vector3(-55,-40,0);sun.light_energy=0.8;add_child(sun)
 match kind:
  "street":street()
  "garden":garden()
  "store":store()
  "hallway":hallway()
  "elevator":elevator()
  "home":home()
 player=CharacterBody3D.new();player.name="Rider";player.position=Vector3(-1,0.1,1.5 if kind=="elevator" else (2.5 if kind=="hallway" else 4));add_child(player)
 var capsule=CapsuleShape3D.new();capsule.radius=0.28;capsule.height=1.6
 var col=CollisionShape3D.new();col.shape=capsule;col.position.y=0.8;player.add_child(col)
 var s=Sprite3D.new();s.texture=load("res://assets/art/refined/"+("rider_home.png" if kind=="home" else "rider_uniform.png"));s.pixel_size=0.022;s.position.y=1.05;s.billboard=BaseMaterial3D.BILLBOARD_ENABLED;s.texture_filter=BaseMaterial3D.TEXTURE_FILTER_NEAREST;player.add_child(s)
 if Chapter.state.positions.has(kind):
  var p=Chapter.state.positions[kind];player.position=Vector3(clampf(p[0],-8,8),0.1,clampf(p[2],-6,6))
 if Chapter.state.completed.has("store") and kind in ["street","garden"]:
  prop("man",Vector3(2,0,1),1.9)
  var area=Area3D.new();area.position=Vector3(2,0,1);var hit=CollisionShape3D.new();var sh=CapsuleShape3D.new();sh.radius=0.45;sh.height=1.7;hit.shape=sh;hit.position.y=0.85;area.add_child(hit);add_child(area)
  area.body_entered.connect(func(body):
   if body==player and not locked and encounter_cooldown<=0:
    player.position+=Vector3(-1.8,0,1.5);Chapter.remember_position(player.position);Chapter.state.encounter=true;Chapter.sync())
func architecture(x: float,z: float,width: float,height: float,shop: bool=false) -> void:
 block(Vector3(x,height/2,z),Vector3(width,height,3),"storefront" if shop else "facade")
 block(Vector3(x,0.15,z+1.55),Vector3(width+0.2,0.3,0.25),"plaster")
 block(Vector3(x,height+0.1,z),Vector3(width+0.35,0.2,3.35),"paving")
 block(Vector3(x,height+0.3,z-0.6),Vector3(width/3,0.4,1),"plaster")
 # Recessed door, projecting shop awning and balcony give the facade actual depth.
 block(Vector3(x,0.95,z+1.53),Vector3(width/3,1.9,0.12),"door")
 block(Vector3(x,2.0,z+1.9),Vector3(width*0.9,0.18,0.9),"wood")
 if not shop:
  block(Vector3(x,height*0.66,z+1.8),Vector3(width*0.8,0.12,0.7),"plaster")
  for offset in [-0.35,0,0.35]:block(Vector3(x+width*offset,height*0.66+0.25,z+2),Vector3(0.045,0.5,0.045),"plaster")
  block(Vector3(x,height*0.66+0.5,z+2),Vector3(width*0.8,0.06,0.05),"plaster")
 block(Vector3(x+width*0.35,height*0.6,z+1.65),Vector3(0.5,0.4,0.3),"fridge")
func street() -> void:
 block(Vector3(0,0.015,1),Vector3(18,0.03,3),"road",false)
 for pair in [[-6,"早餐与家常菜"],[0,"骑手驿站"],[6,"临街民居"]]:
  architecture(pair[0],-5,4.5,4.0,pair[0]==-6);marker("sign_"+str(pair[0]),pair[1],Vector3(pair[0],1.5,-3.4))
 plaque("热食铺",Vector3(-6,2,-3.3));plaque("骑手驿站",Vector3(0,2,-3.3));plaque("临街民居",Vector3(6,2,-3.3))
 marker("pickup","取餐窗口",Vector3(-6,0,-2));marker("delivery","送餐处",Vector3(6,0,-2));marker("garden","幸福花园入口",Vector3(7,0,4));marker("home","返回住处",Vector3(-7,0,5))
 prop("zhou",Vector3(0,0,-2),1.9);prop("bike",Vector3(-1,0,-2),1.4);marker("repair","老周与修车摊",Vector3(0,0,-1))
 for x in [-6,-2,3,6]:prop("lamp",Vector3(x,0,2),2.8)
 for x in [-5,-3,0]:prop("bike",Vector3(x,0,4.8),1.2)
 if not Chapter.state.flags.get("picked_street_water",false):prop("water",Vector3(-3,0,3),0.8);marker("supply","饮水瓶 / 拾取",Vector3(-3,0,3))
 prop("bin",Vector3(5,0,5),1.2);prop("bench",Vector3(-4,0,2.7),1.3)
func garden() -> void:
 block(Vector3(0,0.1,-0.2),Vector3(6,0.2,4),"grass")
 block(Vector3(0,0.23,-0.2),Vector3(1.5,0.06,4),"paving",false)
 architecture(0,-5.5,5,4.8);marker("building","三栋 / 1203送餐",Vector3(0,0,-3))
 architecture(-6,-4.8,2,2.2,true);marker("guard","门卫亭",Vector3(-6,0,-2))
 architecture(6,-4.8,4,2.8,true);marker("store","陈姨便利店",Vector3(6,0,-2))
 plaque("幸福花园 · 3栋",Vector3(0,2,-3.8));plaque("便利店",Vector3(6,1.8,-2.8))
 marker("street","返回老城区",Vector3(-7,0,5))
 prop("rack",Vector3(3,0,-2),1.5);marker("rack","外卖架",Vector3(3,0,-2))
 block(Vector3(-4,1,0),Vector3(1.7,1.4,0.15),"door");marker("board","公告栏",Vector3(-4,0,1))
 for pair in [[-2,-1],[2,-1],[-2,1],[2,1]]:prop("tree",Vector3(pair[0],0,pair[1]),2.9)
 prop("bench",Vector3(0,0,2.7),1.2);marker("bench","花园长椅",Vector3(0,0,3.5))
 for x in [4,5.4,6.7]:prop("bike",Vector3(x,0,4.6),1.2)
 marker("bike","停车棚",Vector3(6,0,4));prop("bin",Vector3(-5,0,4),1.4);marker("bins","垃圾站",Vector3(-5,0,4.6))
 for x in [-2,0,2]:prop("flowers",Vector3(x,0,3.7),0.8)
func store() -> void:
 block(Vector3(0,1.6,-5),Vector3(18,3.2,0.3),"plaster")
 block(Vector3(-8,1.6,-1),Vector3(0.3,3.2,8),"plaster")
 for x in [-4,1]:block(Vector3(x,0.9,0),Vector3(2,1.8,3),"shelf")
 block(Vector3(-5,1.3,-4),Vector3(3,2.6,1),"fridge")
 block(Vector3(5,0.7,-1),Vector3(3,1.4,1.3),"counter")
 var chen=prop("chen",Vector3(5,0,-2.4),1.85)
 if not Chapter.state.scene_states.get("store",{}).get("broken",false):
  var man=prop("man",Vector3(5,0,1.2),1.95)
  if Chapter.state.event_active and Chapter.beat().id=="store" and Chapter.state.page>=Chapter.beat().pages.size()-2:
   man.texture=load(ART+"man_attack.png");man.position=Vector3(5,1,-2);chen.position.y=0.45;chen.modulate=Color("b79894");prop("briefcase",Vector3(4,0,0.8),1);prop("glass",Vector3(5,0,0.5),1)
 elif not Chapter.state.flags.get("ch01_store_owner_saved",false):chen.hide()
 marker("shop","陈姨 / 购物",Vector3(6,0,-0.1));marker("attack","柜台前",Vector3(4,0,1.5))
 if not Chapter.state.flags.get("extinguisher_used",false):prop("extinguisher",Vector3(7,0,2.3),1.2)
 marker("extinguisher","灭火器",Vector3(7,0,2.3))
 marker("supplies","饮水货架 / 购买3元",Vector3(-5,0,-2))
 marker("exit","返回小区",Vector3(0,0,5))
 for x in [-6,-3,0,3]:prop("bags",Vector3(x,0,4),0.8)
 if Chapter.state.scene_states.get("store",{}).get("broken",false):
  prop("blood",Vector3(5,0,1),1);prop("glass",Vector3(5,0,0.5),1);prop("briefcase",Vector3(4,0,0.8),1);prop("bags",Vector3(3,0,0),0.8)
  block(Vector3(4.5,0.1,1.8),Vector3(1.4,0.2,0.4),"shelf",false)
func hallway() -> void:
 block(Vector3(0,1.8,-4),Vector3(16,3.6,0.3),"plaster")
 for x in [-5,0,5]:block(Vector3(x,1.4,-3.7),Vector3(2,2.8,0.25),"door")
 plaque("1404",Vector3(0,2.8,-3.4));plaque("1203",Vector3(-5,2.8,-3.4))
 prop("bags",Vector3(0,0,-2.9),1.1);marker("door","1404 / 纸条与门内声音",Vector3(0,0,-2.3));marker("resident","1203 / 交付",Vector3(-5,0,-2.3));marker("exit","电梯间",Vector3(6,0,3))
func elevator() -> void:
 block(Vector3(0,1.7,-3),Vector3(6,3.4,0.3),"plaster");block(Vector3(-3,1.7,0),Vector3(0.3,3.4,6),"plaster")
 block(Vector3(0,1.5,-2.7),Vector3(3,3,0.2),"elevator");block(Vector3(2.5,1.6,-2.6),Vector3(0.4,0.8,0.1),"counter")
 plaque("8 ↓",Vector3(0,3,-2.3))
 marker("floor","下行 12 → 8 → 1",Vector3(0,2,-2.4));prop("man",Vector3(2,0,0),1.95)
func home() -> void:
 block(Vector3(0,1.8,-5),Vector3(18,3.6,0.3),"plaster");block(Vector3(-8,1.8,-1),Vector3(0.3,3.6,8),"plaster")
 block(Vector3(5,2.4,-4.7),Vector3(4,1.9,0.1),"facade",false)
 block(Vector3(-5,3.1,-4.4),Vector3(3,0.15,0.7),"wood",false)
 prop("bags",Vector3(-5,3.2,-4.4),0.65)
 block(Vector3(-5,0.85,-2),Vector3(3,1.7,1.5),"desk")
 block(Vector3(-5,2.2,-2.3),Vector3(1.6,1.2,0.6),"counter",false)
 block(Vector3(-5,1.8,-2.2),Vector3(0.3,0.5,0.2),"plaster",false)
 marker("pc","电脑",Vector3(-5,0,0))
 block(Vector3(4,0.5,-2),Vector3(3,1,4),"bed")
 block(Vector3(4,1.15,-3.3),Vector3(2.1,0.3,0.7),"tile",false)
 block(Vector3(4,0.9,-4),Vector3(3.1,1.8,0.2),"wood")
 marker("bed","床 / 休息",Vector3(4,0,1))
 block(Vector3(-6,1.1,3),Vector3(2,2.2,1.5),"fridge");marker("fridge","冰箱",Vector3(-4.5,0,3))
 block(Vector3(6,1.4,3),Vector3(2,2.8,1.5),"wardrobe");marker("storage","储物与修理",Vector3(4.3,0,3))
 block(Vector3(0,1.4,-4.7),Vector3(2,2.8,0.2),"door");marker("door","防盗门 / 出门",Vector3(0,0,-3))
 marker("photo","旧照片",Vector3(-2,0,-3));prop("flowers",Vector3(-2,0,-4),1.4);prop("bags",Vector3(2,0,3),0.9)
 var light=OmniLight3D.new();light.position=Vector3(-5,3,-2);light.light_color=Color("f0bc79");light.light_energy=1.5;light.omni_range=8;add_child(light)
 prop("bike",Vector3(1,0,3),1.2);marker("charger","充电器与外卖箱",Vector3(1,0,4))
func _physics_process(delta: float) -> void:
 encounter_cooldown=maxf(0,encounter_cooldown-delta)
 if locked or not is_instance_valid(player) or Chapter.state.place!=kind:return
 var x=float(held.get(KEY_D,false) or held.get(KEY_RIGHT,false))-float(held.get(KEY_A,false) or held.get(KEY_LEFT,false))
 var z=float(held.get(KEY_S,false) or held.get(KEY_DOWN,false))-float(held.get(KEY_W,false) or held.get(KEY_UP,false))
 var move=Vector3(x+z,0,z-x).normalized()*3
 player.velocity=Vector3(move.x,-2,move.z);player.move_and_slide()
 var limit=2.5 if kind=="elevator" else 8.0
 player.position.x=clampf(player.position.x,-limit,limit);player.position.z=clampf(player.position.z,-2.5 if kind=="elevator" else (-3.5 if kind=="hallway" else -6),2.5 if kind=="elevator" else (3.5 if kind=="hallway" else 6))
 Chapter.remember_position(player.position)
 hint="";var nearest=1.9
 for id in points:
  var distance=player.position.distance_to(points[id].pos)
  if distance<nearest:nearest=distance;hint="E · "+points[id].text
func interact() -> void:
 if locked:return
 var nearest=1.9;var selected=""
 for id in points:
  var distance=player.position.distance_to(points[id].pos)
  if distance<nearest:nearest=distance;selected=id
 if not selected.is_empty():hotspot.emit(selected)
