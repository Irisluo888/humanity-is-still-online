extends "res://scripts/bedroom_walk.gd"
func _ready() -> void:
 if WorldData.campaign: saved_position=WorldData.room_position
 super._ready()
 if not WorldData.campaign: return
 WorldData.location="home"
 get_child(2).text="出租屋 / "+WorldData.time_text()
 var panel=preload("res://ui/loop_panel.gd").new()
 panel.position=Vector2(1000,24); panel.custom_minimum_size.x=250; add_child(panel)
 var row=HBoxContainer.new(); row.position=Vector2(28,600); row.add_theme_constant_override("separation",12); add_child(row)
 var leave=Kit.button("出门配送",func():
  WorldData.room_position=player_uv
  if WorldData.depart(): get_tree().change_scene_to_file("res://scenes/city_delivery.tscn")
 )
 row.add_child(leave)
 var sleep_button=Kit.button("休息到下一天",func():
  if not WorldData.rest(): WorldData.tell("晚上核对动态或消息后才能休息。")
 )
 row.add_child(sleep_button)
 var update=func():
  get_child(2).text="出租屋 / "+WorldData.time_text()
  leave.disabled=WorldData.period!="day"
  sleep_button.disabled=WorldData.period!="night" or not WorldData.reviewed
 update.call(); WorldData.changed.connect(update)
func update_actor() -> void:
 super.update_actor()
 if WorldData.campaign: WorldData.room_position=player_uv
func use_computer() -> void:
 if WorldData.campaign:
  if transitioning or not is_near_computer(): return
  WorldData.room_position=player_uv
  WorldData.location="desktop"
 super.use_computer()
