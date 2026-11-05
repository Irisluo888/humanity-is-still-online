extends Control
func _ready() -> void:
 var kit = preload("res://ui/kit.gd")
 var col = kit.base(self)
 col.add_child(kit.label("女骑手 / 出门与归家",28))
 col.add_child(kit.label("同一位年轻成年女性 · 低马尾、自然比例与统一像素颗粒",20))
 var row = HBoxContainer.new()
 row.alignment = BoxContainer.ALIGNMENT_CENTER
 row.add_theme_constant_override("separation",64)
 col.add_child(row)
 for variant in ["uniform","home"]:
  var panel = VBoxContainer.new()
  panel.custom_minimum_size.x = 360
  row.add_child(panel)
  var heading = kit.label("白天 / 骑手服" if variant == "uniform" else "夜晚 / 居家服",20)
  heading.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
  panel.add_child(heading)
  var texture = TextureRect.new()
  texture.texture = load("res://assets/art/refined/rider_"+variant+".png")
  texture.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
  texture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
  texture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
  texture.custom_minimum_size = Vector2(192,384)
  panel.add_child(texture)
  var details = kit.label("头盔 · 反光条 · 配送包" if variant == "uniform" else "针织上衣 · 长裤 · 室内鞋",18)
  details.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
  panel.add_child(details)
 col.add_child(kit.label("原创站立像素稿 / 尚无行走和骑车动画",18))
 col.add_child(kit.button("返回住所",func(): get_tree().change_scene_to_file("res://scenes/bedroom.tscn")))
