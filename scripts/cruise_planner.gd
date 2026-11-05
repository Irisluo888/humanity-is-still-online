extends RefCounted
var grid:=AStarGrid2D.new()
const ORIGIN:=Vector2(-10,-9)
const STEP:=0.5
func build(space: PhysicsDirectSpaceState3D,exclude: RID) -> void:
 grid.region=Rect2i(0,0,41,37);grid.cell_size=Vector2(STEP,STEP);grid.offset=ORIGIN
 grid.diagonal_mode=AStarGrid2D.DIAGONAL_MODE_NEVER;grid.update()
 var capsule=CapsuleShape3D.new();capsule.radius=0.4;capsule.height=1.5
 var query=PhysicsShapeQueryParameters3D.new();query.shape=capsule;query.exclude=[exclude];query.collision_mask=1
 for y in range(37):
  for x in range(41):
   var point=ORIGIN+Vector2(x,y)*STEP
   query.transform=Transform3D(Basis.IDENTITY,Vector3(point.x,1.0,point.y))
   var ray=PhysicsRayQueryParameters3D.create(Vector3(point.x,8,point.y),Vector3(point.x,0.15,point.y))
   ray.exclude=[exclude]
   grid.set_point_solid(Vector2i(x,y),not space.intersect_shape(query,1).is_empty() or not space.intersect_ray(ray).is_empty())
func closest(point: Vector3) -> Vector2i:
 var best:=Vector2i(-1,-1);var distance:=INF
 for y in range(37):
  for x in range(41):
   var id=Vector2i(x,y)
   if grid.is_point_solid(id):continue
   var actual=ORIGIN+Vector2(id)*STEP
   var value=actual.distance_squared_to(Vector2(point.x,point.z))
   if value<distance:distance=value;best=id
 return best
func path(from: Vector3,to: Vector3) -> PackedVector3Array:
 var start=closest(from);var goal=closest(to)
 var result:=PackedVector3Array()
 if start.x<0 or goal.x<0:return result
 var end=ORIGIN+Vector2(goal)*STEP
 if end.distance_to(Vector2(to.x,to.z))>1.1:return result
 for point in grid.get_point_path(start,goal):result.append(Vector3(point.x,0.12,point.y))
 return result
