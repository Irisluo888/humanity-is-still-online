extends SceneTree
func _initialize() -> void: call_deferred("capture")
func snap(name: String) -> void:
 for i in range(10): await process_frame
 await RenderingServer.frame_post_draw
 var image = root.get_texture().get_image()
 assert(image.save_png("res://artifacts/ui_preview/"+name+".png") == OK)
 print("Captured ",name," ",image.get_size())
func capture() -> void:
 root.size = Vector2i(1280,720)
 var desktop = load("res://scenes/desktop.tscn").instantiate()
 root.add_child(desktop)
 await snap("01_desktop")
 desktop.open_app("动态")
 await snap("02_feed")
 desktop.active_category = "最新"
 desktop.refresh()
 await snap("09_feed_variety")
 desktop.active_category = "全部"
 desktop.refresh()
 desktop.windows["动态"].hide()
 desktop.open_app("消息")
 await snap("03_messages")
 desktop.windows["消息"].hide()
 desktop.active_category = "全部"
 desktop.show_post(desktop.content.posts[0])
 await snap("08_post_detail")
 desktop.windows["帖子详情"].hide()
 desktop.open_app("视频")
 await snap("04_video")
 desktop.windows["视频"].hide()
 desktop.open_app("动态")
 desktop.open_app("消息")
 await snap("05_multi_window")
 root.size = Vector2i(1920,1080)
 await snap("07_multi_window_1080p")
 desktop.queue_free()
 await process_frame
 root.size = Vector2i(1280,720)
 var room = load("res://scenes/bedroom.tscn").instantiate()
 root.add_child(room)
 await snap("06_bedroom")
 room.queue_free()
 quit()
