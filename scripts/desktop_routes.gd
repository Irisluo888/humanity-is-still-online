extends "res://scripts/desktop_loop.gd"
func _ready() -> void:
 super._ready()
 if WorldData.campaign:
  # Keep app tasks before the expanding spacer even with the save button present.
  tasks.move_child(tasks.get_child(tasks.get_child_count()-1),2)
func build_orders(body: HBoxContainer) -> void:
 if not WorldData.campaign:super.build_orders(body);return
 var board=preload("res://ui/delivery_board.gd").new();board.custom_minimum_size=Vector2(800,440);body.add_child(board)
func refresh() -> void:
 super.refresh()
 if WorldData.campaign and get_child_count()>2:get_child(2).text="HOME / 07\n"+WorldData.objective()
