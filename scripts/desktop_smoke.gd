extends SceneTree
func _initialize() -> void:
 call_deferred("run_test")
func run_test() -> void:
 var desktop = load("res://scenes/desktop.tscn").instantiate()
 root.add_child(desktop)
 await process_frame
 for app in ["动态", "热榜", "视频", "消息", "AI助手", "接单"]:
  desktop.open_app(app)
 assert(desktop.windows.size() == 6)
 var win = desktop.windows["动态"]
 win.hide()
 desktop.open_app("动态")
 assert(win.visible)
 root.get_node("WorldData").record_event("test", "resident_07", "lane_07", "共享数据验证")
 await process_frame
 assert(desktop.event_text().contains("共享数据验证"))
 desktop.windows["视频"].closed.emit()
 assert(not desktop.windows.has("视频"))
 print("PASS: six layouts, task restore, shared event refresh, close")
 desktop.queue_free()
 quit()
