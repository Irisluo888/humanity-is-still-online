extends Control
const Kit=preload("res://ui/kit.gd")
func _ready() -> void:
 MessageManager.reset("demo");MessageManager.set_context(1427,{},"home");MessageManager.queue_script("rider_group",1427)
 var box=Kit.base(self);box.add_child(Kit.label("骑手群 / 独立聊天测试 · 游戏时间23:47固定",24))
 var panel=preload("res://ui/message_panel.gd").new();box.add_child(panel)
 var note=Kit.label("关闭窗口不停止已开始的消息演出；预设回复会等待你的选择。",16);box.add_child(note)
