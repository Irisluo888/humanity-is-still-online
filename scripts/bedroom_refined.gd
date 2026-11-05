extends "res://scripts/bedroom_third.gd"
func _ready() -> void:
 super._ready()
 get_child(0).texture = load("res://assets/art/refined/bedroom.png")
 var rider: TextureRect = get_child(1)
 rider.texture = load("res://assets/art/refined/rider_home.png")
 rider.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
 rider.position = Vector2(566, 354)
 rider.size = Vector2(96, 192)
 get_child(2).text = "出租屋 / 雨夜归来\n电脑、热茶，还有没收好的衣服。"
 # Keep the terminal interaction out of the furniture artwork.
 get_child(3).position = Vector2(490, 652)
 get_child(3).custom_minimum_size = Vector2(240, 36)
 get_child(4).position = Vector2(28, 652)
 # Delivery box and helmet are now painted into the consistent room perspective.
 get_child(5).hide()
 get_child(6).position = Vector2(1010, 652)
 get_child(6).size = Vector2(240, 36)
