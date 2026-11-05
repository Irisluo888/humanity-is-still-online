extends Control
@export var screen="聊天"
func _ready():
 if MessageManager.records.is_empty():
  MessageManager.reset();MessageManager.set_context(1427);MessageManager.queue_script("rider_group",1427);MessageManager.queue_script("xiaoyu",1427)
 var bg=ColorRect.new();bg.color=Color("292c3e");bg.set_anchors_and_offsets_preset(PRESET_FULL_RECT);add_child(bg)
 var center=CenterContainer.new();center.set_anchors_and_offsets_preset(PRESET_FULL_RECT);add_child(center)
 var app=preload("res://ui/phone/messenger.gd").new();app.name="Messenger";app.custom_minimum_size=Vector2(438,684);app.initial_page=screen;center.add_child(app)
 app.close_requested.connect(func():get_tree().quit())
 app.app_requested.connect(func(tab):app.info("此独立预览不包含"+tab+"；在第一章手机中使用该入口。"))
