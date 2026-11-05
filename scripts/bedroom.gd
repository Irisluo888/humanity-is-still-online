extends Control
const Kit = preload("res://ui/kit.gd")
func _ready() -> void:
 var room = TextureRect.new()
 room.texture = load("res://assets/pixel_round2/bedroom.png")
 room.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
 room.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 add_child(room)
 var rider = TextureRect.new()
 rider.texture = load("res://assets/pixel_round2/rider_home.png")
 rider.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
 rider.position = Vector2(602,432)
 rider.size = Vector2(64,128)
 add_child(rider)
 var title = Kit.label("出租屋 / 晚班之后\n年轻女骑手的夜间住所 · 静态视觉原型",20)
 title.position = Vector2(28,24)
 add_child(title)
 var terminal = Kit.button("使用电脑 / 进入桌面",func(): get_tree().change_scene_to_file("res://scenes/desktop.tscn"))
 terminal.position = Vector2(474,368)
 terminal.custom_minimum_size = Vector2(220,36)
 add_child(terminal)
 var back = Kit.button("返回主菜单",func(): get_tree().change_scene_to_file("res://scenes/start.tscn"))
 back.position = Vector2(28,650)
 add_child(back)
