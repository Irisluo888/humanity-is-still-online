extends Control
var world: Node3D
var target=""
var phase=0.0
func _ready():mouse_filter=MOUSE_FILTER_IGNORE
func _process(delta):phase+=delta;queue_redraw()
func _draw():
 if not is_instance_valid(world) or target.is_empty() or not world.points.has(target):return
 var camera=world.get_viewport().get_camera_3d()
 var destination=world.points[target].pos
 var p=camera.unproject_position(destination+Vector3(0,0.3,0))*2
 var start=camera.unproject_position(world.player.position)*2
 var direction=(p-start).normalized()
 for i in range(1,int(start.distance_to(p)/24)):
  var point=start+direction*(i*24)
  draw_circle(point,2,Color("d6b575"))
 var bounce=sin(phase*4)*5
 draw_colored_polygon(PackedVector2Array([p+Vector2(-12,-30+bounce),p+Vector2(12,-30+bounce),p+Vector2(0,-14+bounce)]),Color("f4c77d"))
 draw_arc(p,18,0,TAU,24,Color("efd19b"),2)
