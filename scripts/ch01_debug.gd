extends Node
func _ready() -> void:
 if not OS.is_debug_build():get_tree().change_scene_to_file("res://scenes/start.tscn");return
 Chapter.developer_mode=true
 if Chapter.state.is_empty():Chapter.fresh()
 get_tree().change_scene_to_file("res://scenes/ch01.tscn")
