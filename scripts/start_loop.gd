extends "res://scripts/start.gd"
func _ready() -> void:
 var column=Kit.base(self)
 column.add_child(Kit.label("人类暂未下线",54))
 column.add_child(Kit.label("第一章 · 有人在敲门",25))
 column.add_child(Kit.label("夜里还有人在线。也有人站在门外。",20))
 column.add_child(HSeparator.new())
 column.add_child(Kit.button("开始新游戏",func():confirm_action("开始第一章将替换未保存会话，原存档保留。",func():Chapter.developer_mode=false;Chapter.fresh();get_tree().change_scene_to_file("res://scenes/ch01.tscn"))))
 var resume=Kit.button("继续第一章",func():
  if Chapter.restore():get_tree().change_scene_to_file("res://scenes/ch01.tscn"))
 resume.disabled=not FileAccess.file_exists(Chapter.SAVE);column.add_child(resume)
 if FileAccess.file_exists(WorldData.SAVE_PATH):column.add_child(Kit.button("继续旧版配送存档",resume_game))
 column.add_child(Kit.button("设置",show_settings))
 column.add_child(Kit.button("退出游戏",func():get_tree().quit()))
 column.add_child(Kit.label("WASD移动 · E交互 · P手机 · B背包 · 空格继续对白",17))
func confirm_action(text: String,action: Callable) -> void:
 var dialog=ConfirmationDialog.new(); dialog.dialog_text=text; add_child(dialog)
 dialog.confirmed.connect(func(): action.call(); dialog.queue_free())
 dialog.canceled.connect(dialog.queue_free); dialog.popup_centered(Vector2i(500,180))
func begin() -> void:
 var action=func():
  Chapter.session_active=false
  WorldData.new_campaign()
  get_tree().change_scene_to_file("res://scenes/bedroom.tscn")
 if WorldData.campaign or FileAccess.file_exists(WorldData.SAVE_PATH): confirm_action("开始新游戏会替换当前未保存会话。旧存档在你再次点击保存前仍保留。",action)
 else: action.call()
func resume_game(backup: bool = false) -> void:
 if WorldData.load_game(WorldData.SAVE_PATH+(".bak" if backup else "")):
  Chapter.session_active=false
  get_tree().change_scene_to_file(WorldData.scene_for_location())
 else:
  var dialog=AcceptDialog.new(); dialog.dialog_text=WorldData.last_save_error; add_child(dialog)
  dialog.confirmed.connect(dialog.queue_free); dialog.popup_centered(Vector2i(520,180))
func preview(path: String) -> void:
 var action=func(): WorldData.campaign=false; get_tree().change_scene_to_file(path)
 if WorldData.campaign: confirm_action("进入预览会离开当前会话。需要保留进度时，请先返回游戏保存。",action)
 else: action.call()
