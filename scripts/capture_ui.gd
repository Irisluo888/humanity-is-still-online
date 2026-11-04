extends SceneTree
func _initialize() -> void:
 call_deferred("capture")
func save_view(name: String) -> void:
 for i in range(8): await process_frame
 await RenderingServer.frame_post_draw
 var image = root.get_texture().get_image()
 var error = image.save_png("res://artifacts/ui_preview/" + name + ".png")
 assert(error == OK)
 print("Captured ",name," ",image.get_size())
func capture() -> void:
 root.size = Vector2i(1280,720)
 var desktop = load("res://scenes/desktop.tscn").instantiate()
 root.add_child(desktop)
 await save_view("01_desktop")
 desktop.open_app("动态")
 await save_view("02_feed_window")
 desktop.windows["动态"].hide()
 desktop.open_app("消息")
 await save_view("03_message_window")
 desktop.open_app("动态")
 desktop.open_app("消息")
 await save_view("04_multi_window")
 root.size = Vector2i(1920,1080)
 await save_view("05_multi_window_1080p")
 desktop.queue_free()
 quit()
