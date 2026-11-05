extends "res://scripts/ch01_qa_test.gd"
func _initialize():
 Engine.time_scale=3
 super._initialize()
func capture(_name: String) -> void:pass
func at(id: String) -> void:
 var map=current_scene.map_world
 if not map.points.has(id):check(false,"missing walk point "+id);quit(1);return
 var goal: Vector3=map.points[id].pos+Vector3(0,0.1,0.6)
 var grid=AStarGrid2D.new();grid.region=Rect2i(0,0,37,29);grid.cell_size=Vector2(0.5,0.5);grid.diagonal_mode=AStarGrid2D.DIAGONAL_MODE_NEVER;grid.update()
 var probe=PhysicsShapeQueryParameters3D.new();var capsule=CapsuleShape3D.new();capsule.radius=0.32;capsule.height=1.65;probe.shape=capsule;probe.exclude=[map.player.get_rid()]
 var space=map.get_world_3d().direct_space_state
 for x in range(37):
  for y in range(29):
   var point=Vector3(-9+x*0.5,0.95,-7+y*0.5);probe.transform=Transform3D(Basis.IDENTITY,point)
   var solid=not space.intersect_shape(probe,1).is_empty() or absf(point.x)>7.8 or absf(point.z)>5.8
   grid.set_point_solid(Vector2i(x,y),solid)
 var start=Vector2i(roundi((map.player.position.x+9)*2),roundi((map.player.position.z+7)*2))
 var finish=Vector2i(roundi((goal.x+9)*2),roundi((goal.z+7)*2))
 grid.set_point_solid(start,false)
 var path=grid.get_id_path(start,finish)
 check(not path.is_empty(),"walkable path to "+id)
 if path.is_empty():quit(1);return
 for cell in path:
  var point=Vector3(-9+cell.x*0.5,0,-7+cell.y*0.5)
  var limit=0
  while Vector2(map.player.position.x-point.x,map.player.position.z-point.z).length()>0.23 and limit<120:
   limit+=1;var delta=point-map.player.position;var screen=Vector2(delta.x-delta.z,delta.x+delta.z)
   map.held[KEY_D]=screen.x>0.12;map.held[KEY_A]=screen.x< -0.12;map.held[KEY_S]=screen.y>0.12;map.held[KEY_W]=screen.y< -0.12
   await physics_frame
  map.held.clear()
  if limit>=120:check(false,"movement stuck on "+id);quit(1);return
 check(map.player.position.distance_to(map.points[id].pos)<1.9,"walk reaches E range "+id)
 await press(KEY_E)
