extends Node3D
const Kit = preload("res://ui/kit.gd")
func block(pos: Vector3, size: Vector3, color: Color) -> void:
 var mesh = MeshInstance3D.new()
 var shape = BoxMesh.new()
 shape.size = size
 mesh.mesh = shape
 var material = StandardMaterial3D.new()
 material.albedo_color = color
 mesh.material_override = material
 mesh.position = pos
 add_child(mesh)
func _ready() -> void:
 block(Vector3(0,-0.2,0), Vector3(24,0.4,20), Color("bcbdb0"))
 block(Vector3(0,0.02,0), Vector3(22,0.04,4), Color("777f82"))
 for x in [-8, -3, 3, 8]:
  block(Vector3(x,2.0,-5), Vector3(3,4,4), Color("e5d9b7"))
  block(Vector3(x,1.4,5), Vector3(3,2.8,3), Color("acb9b4"))
 block(Vector3(0,0.65,0), Vector3(0.6,1.3,0.6), Color("ff854a"))
 block(Vector3(0,1.5,0), Vector3(0.55,0.5,0.55), Color("e8f496"))
 var camera = Camera3D.new()
 camera.position = Vector3(16,18,20)
 camera.projection = Camera3D.PROJECTION_ORTHOGONAL
 camera.size = 27
 add_child(camera)
 camera.look_at(Vector3.ZERO)
 camera.current = true
 var light = DirectionalLight3D.new()
 light.rotation_degrees = Vector3(-55,-30,0)
 add_child(light)
 var layer = CanvasLayer.new()
 add_child(layer)
 var panel = VBoxContainer.new()
 panel.position = Vector2(24,24)
 layer.add_child(panel)
 panel.add_child(Kit.label("临川 · 老城区 / 灰盒预览", 28))
 panel.add_child(Kit.label("橘色角色为占位物 · 当前版本仅预览，无移动系统", 18))
 panel.add_child(Kit.button("返回启动界面", func(): get_tree().change_scene_to_file("res://scenes/start.tscn")))
 panel.add_child(Kit.button("查看电脑桌面", func(): get_tree().change_scene_to_file("res://scenes/desktop.tscn")))

 var record = WorldData.orders[0]
 panel.add_child(Kit.label("共享订单：" + str(record.id) + " / " + str(WorldData.places[record.place_id]) + " / " + str(record.status), 18))
