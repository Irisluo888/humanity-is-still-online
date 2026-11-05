extends "res://scripts/city_cruise.gd"
var followup_hint: Label
func _ready() -> void:
 super._ready()
 var layer=CanvasLayer.new();add_child(layer)
 followup_hint=Label.new();followup_hint.position=Vector2(24,100);followup_hint.custom_minimum_size.x=750;followup_hint.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;followup_hint.add_theme_font_size_override("font_size",17);layer.add_child(followup_hint)
 var marker=Label3D.new();marker.name="FollowupMarker";marker.text="便签回访 / E核对";marker.position=WorldData.CUSTOMER+Vector3(0,3,0)
 marker.billboard=BaseMaterial3D.BILLBOARD_ENABLED;marker.no_depth_test=true;marker.font_size=32;marker.pixel_size=0.012;add_child(marker)
func _physics_process(delta: float) -> void:
 super._physics_process(delta)
 if not is_inside_tree() or not is_instance_valid(followup_hint):return
 var task: Dictionary=WorldData.active_followup()
 followup_hint.visible=not task.is_empty() and not board.visible and not story_panel.visible
 followup_hint.text="夜间线索回访：榆灯巷07号门口按E核对便签（需自行前往，不计配送）" if not task.is_empty() else ""
 get_node("FollowupMarker").visible=not task.is_empty()
func _unhandled_key_input(event: InputEvent) -> void:
 if event is InputEventKey and event.pressed and not event.echo and event.physical_keycode==KEY_E and not board.visible and WorldData.pending_story().is_empty():
  var task: Dictionary=WorldData.active_followup()
  if not task.is_empty() and WorldData.near(WorldData.CUSTOMER):
   var order: Dictionary=WorldData.current_order()
   var delivery_here=order.get("status","")=="配送中" and WorldData.delivery_target().distance_to(WorldData.CUSTOMER)<0.1
   if not delivery_here:
    if cruising:stop_cruise("已切回手动核对回访。")
    WorldData.complete_followup();return
 super._unhandled_key_input(event)
