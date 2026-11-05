extends SceneTree
func _initialize() -> void: call_deferred("capture")
func snap(name: String) -> void:
 for i in range(8): await process_frame
 await RenderingServer.frame_post_draw
 var image = root.get_texture().get_image()
 assert(image.save_png("res://artifacts/third_round_preview/"+name+".png")==OK)
 print("Captured ",name," ",image.get_size())
func capture() -> void:
 root.size = Vector2i(1280,720)
 var desktop = load("res://scenes/desktop.tscn").instantiate()
 root.add_child(desktop)
 await snap("01_desktop")
 var index = 2
 for app in ["动态","消息","热榜","视频","AI助手","接单"]:
  for frame in desktop.windows.values(): frame.hide()
  desktop.open_app(app)
  if app=="动态": desktop.active_category="最新"; desktop.rebuild("动态")
  if app=="视频": desktop.video_index=4; desktop.rebuild("视频")
  if app=="AI助手": desktop.ask("门铃"); desktop.ask("整理线索")
  await snap("%02d_%s" % [index,["feed","messages","news","video","assistant","orders"][index-2]])
  index += 1
 desktop.queue_free()
 await process_frame
 var rider = load("res://scenes/rider_gallery.tscn").instantiate()
 root.add_child(rider)
 await snap("08_rider")
 rider.queue_free()
 await process_frame
 var bedroom = load("res://scenes/bedroom.tscn").instantiate()
 root.add_child(bedroom)
 await snap("09_bedroom")
 bedroom.queue_free()
 await process_frame
 desktop = load("res://scenes/desktop.tscn").instantiate()
 root.add_child(desktop)
 root.get_node("WorldData").deliver_order("order_001")
 desktop.open_app("动态")
 for i in range(4): await process_frame
 var feed_scroll = desktop.windows["动态"].body.get_child(1)
 feed_scroll.scroll_vertical = int(feed_scroll.get_v_scroll_bar().max_value)
 await snap("10_linked_feed")
 desktop.windows["动态"].hide()
 desktop.open_app("消息")
 for i in range(4): await process_frame
 var chat_scroll = desktop.windows["消息"].body.get_child(1).get_child(1)
 chat_scroll.scroll_vertical = int(chat_scroll.get_v_scroll_bar().max_value)
 await snap("11_linked_messages")
 root.size = Vector2i(1920,1080)
 desktop.open_app("热榜")
 await snap("12_news_1080p")
 desktop.queue_free()
 quit()
