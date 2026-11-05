extends "res://scripts/bedroom.gd"
func _ready() -> void:
 super._ready()
 get_child(0).texture = load("res://assets/art/environment/bedroom.png")
 get_child(1).texture = load("res://assets/art/characters/rider_home.png")
 var gear = TextureRect.new()
 gear.texture = load("res://assets/art/furniture/delivery_gear.png")
 gear.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
 gear.position = Vector2(355,450)
 gear.size = Vector2(128,96)
 add_child(gear)
 var preview = Button.new()
 preview.text = "查看骑手服角色"
 preview.position = Vector2(870,640)
 preview.size = Vector2(240,40)
 preview.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/rider_gallery.tscn"))
 add_child(preview)
