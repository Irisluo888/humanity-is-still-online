extends "res://scripts/city_delivery.gd"
var district_transition := false
var portals = {"shop":Vector3(-9,0,-1),"corridor":Vector3(9,0,1)}
func _ready() -> void:
 super._ready()
 for area in portals:
  var marker=Label3D.new()
  marker.text="便利店 / E进入" if area=="shop" else "居民楼走廊 / E进入"
  marker.position=portals[area]+Vector3(0,2.2,0)
  marker.billboard=BaseMaterial3D.BILLBOARD_ENABLED
  marker.no_depth_test=true; marker.font_size=36; marker.pixel_size=0.012
  add_child(marker)
func _physics_process(delta: float) -> void:
 super._physics_process(delta)
 if district_transition: return
 for area in portals:
  if WorldData.near(portals[area]):
   info.text+="\nE / 进入"+("便利店" if area=="shop" else "居民楼走廊")
func _unhandled_key_input(event: InputEvent) -> void:
 if district_transition: return
 if event is InputEventKey and event.pressed and not event.echo and event.physical_keycode==KEY_E:
  var nearest_distance=2.0
  for point in sites.values():
   nearest_distance=minf(nearest_distance,Vector2(player.position.x,player.position.z).distance_to(Vector2(point.x,point.z)))
  var selected=""
  for area in portals:
   var point: Vector3=portals[area]
   var distance=Vector2(player.position.x,player.position.z).distance_to(Vector2(point.x,point.z))
   if distance<nearest_distance: nearest_distance=distance; selected=area
  for area in portals:
   if area==selected and WorldData.enter_district(area):
    district_transition=true
    get_tree().change_scene_to_file("res://scenes/district_interior.tscn")
    return
 super._unhandled_key_input(event)
