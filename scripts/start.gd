extends Control
const Kit = preload("res://ui/kit.gd")
func _ready() -> void:
 var box = Kit.base(self)
 box.add_child(Kit.label("H / O     •     LOCAL SYSTEM     /     版本 0.1", 18))
 box.add_child(Kit.label("人类暂未下线", 64))
 box.add_child(Kit.label("HUMANITY IS STILL ONLINE", 28))
 box.add_child(Kit.label("城市暂停营业。生活还在自动续费。", 24))
 box.add_child(HSeparator.new())
 box.add_child(Kit.button("01   开始体验  →", func(): get_tree().change_scene_to_file("res://scenes/city.tscn")))
 box.add_child(Kit.button("02   桌面预览  →", func(): get_tree().change_scene_to_file("res://scenes/desktop.tscn")))
 var resume = Kit.button("继续游戏 · 尚未开放", func(): pass)
 resume.disabled = true
 box.add_child(resume)
 box.add_child(Kit.button("设置", show_settings))
 box.add_child(Kit.button("退出游戏", func(): get_tree().quit()))
 box.add_child(Kit.label("● 临川市：照常运转（据系统自述）     /     网络：离线本地模式", 18))
func show_settings() -> void:
 var dialog = AcceptDialog.new()
 dialog.title = "基础设置"
 dialog.dialog_text = "当前采用窗口模式；可拖动窗口边缘调整大小。\n原型暂无音频。所有内容在本地运行。"
 add_child(dialog)
 dialog.confirmed.connect(dialog.queue_free)
 dialog.popup_centered(Vector2i(480, 180))
