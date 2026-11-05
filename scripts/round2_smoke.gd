extends SceneTree
var failures := 0
func _initialize() -> void: call_deferred("run_checks")
func check(value: bool, description: String) -> void:
 if value: print("PASS: ",description)
 else:
  failures += 1
  push_error(description)
func find_button(node: Node, prefix: String) -> Button:
 if node is Button and node.text.begins_with(prefix): return node
 for child in node.get_children():
  var found = find_button(child,prefix)
  if found != null: return found
 return null
func frames(count: int = 3) -> void:
 for i in range(count): await process_frame
func click(position: Vector2) -> void:
 var motion = InputEventMouseMotion.new()
 motion.position = position
 root.push_input(motion,true)
 for pressed in [true,false]:
  var event = InputEventMouseButton.new()
  event.button_index = MOUSE_BUTTON_LEFT
  event.pressed = pressed
  event.position = position
  root.push_input(event,true)
 await frames()
func run_checks() -> void:
 root.size = Vector2i(1280,720)
 var desktop = load("res://scenes/desktop.tscn").instantiate()
 root.add_child(desktop)
 await frames()
 for app in ["动态","消息","视频","热榜","AI助手","接单"]: desktop.open_app(app)
 await frames()
 check(desktop.windows.size()==6,"six existing apps retained")
 for frame in desktop.windows.values():
  check(frame.position.x>=0 and frame.position.y>=0 and frame.position.x+frame.size.x<=1281 and frame.position.y+frame.size.y<=677,"window fits desktop work area")
 desktop.open_app("动态")
 check(desktop.focused_app=="动态","focus switches to feed")
 await frames()
 var feed_scroll: ScrollContainer = desktop.windows["动态"].body.get_child(1)
 var wheel = InputEventMouseButton.new()
 wheel.position = feed_scroll.get_global_rect().get_center()
 wheel.button_index = MOUSE_BUTTON_WHEEL_DOWN
 wheel.factor = 5.0
 wheel.pressed = true
 root.push_input(wheel,true)
 await frames()
 check(feed_scroll.scroll_vertical > 0,"mouse wheel scrolls forum content")
 find_button(desktop.windows["动态"],"求助").pressed.emit()
 check(desktop.active_category=="求助","forum category filter")
 desktop.show_post(desktop.content.posts[0])
 check(desktop.windows.has("帖子详情"),"post detail and comments open")
 desktop.windows["帖子详情"].closed.emit()
 desktop.open_app("消息")
 var message = desktop.windows["消息"]
 find_button(message,"楼道邻居").pressed.emit()
 await frames()
 check(desktop.selected_contact==2 and desktop.unread[2]==0,"contact selection clears unread count")
 var inputs = message.find_children("*","LineEdit",true,false)
 inputs[0].text = "第二轮本地留言测试"
 inputs[0].text_submitted.emit(inputs[0].text)
 check(desktop.chat_history[2].back()=="第二轮本地留言测试","local text submission preserved")
 find_button(message,"附件").pressed.emit()
 check(desktop.chat_history[2].back().contains("order_001"),"local attachment links shared order")
 await frames()
 # Exercise real viewport mouse routing for minimize and taskbar restore.
 var bar = message.get_child(0).get_child(0).get_child(0)
 var minimize: Button = bar.get_child(1)
 await click(minimize.get_global_rect().get_center())
 check(not message.visible,"mouse click minimizes window")
 await click(desktop.task_buttons["消息"].get_global_rect().get_center())
 check(message.visible and desktop.focused_app=="消息","mouse click restores and focuses taskbar window")
 await click(desktop.task_buttons["消息"].get_global_rect().get_center())
 check(not message.visible,"taskbar active window toggles minimized")
 desktop.open_app("消息")
 await frames()
 var handle: Label = bar.get_child(0)
 var start: Vector2 = handle.get_global_rect().get_center()
 var press = InputEventMouseButton.new()
 press.button_index = MOUSE_BUTTON_LEFT
 press.pressed = true
 press.position = start
 root.push_input(press,true)
 await frames(1)
 check(message.dragging,"titlebar receives mouse drag start")
 var motion = InputEventMouseMotion.new()
 motion.position = Vector2(-400,-400)
 motion.relative = motion.position-start
 root.push_input(motion,true)
 await frames(1)
 var release = InputEventMouseButton.new()
 release.button_index = MOUSE_BUTTON_LEFT
 release.pressed = false
 release.position = motion.position
 root.push_input(release,true)
 await frames()
 check(not message.dragging and message.position.x==0 and message.position.y==0,"real drag clamps at top-left boundary")
 desktop.open_app("视频")
 var video = desktop.windows["视频"]
 find_button(video,"七号楼门口").pressed.emit()
 await frames()
 check(desktop.video_index==2,"video selection switches local cover and text")
 find_button(video,"播放 / 暂停").pressed.emit()
 var before: float = desktop.video_position
 desktop._process(1.0)
 check(desktop.video_position>before,"static video simulation advances progress")
 find_button(video,"播放 / 暂停").pressed.emit()
 check(not desktop.video_playing,"video pause")
 var store = root.get_node("WorldData")
 store.record_event("round2_test","resident_07","lane_07","第二轮共享记录验证")
 await frames()
 check(desktop.event_text().contains("第二轮共享记录验证"),"day/night shared event refresh retained")
 desktop.windows["消息"].closed.emit()
 check(not desktop.windows.has("消息"),"close removes window and task")
 root.size = Vector2i(1920,1080)
 await frames()
 desktop.clamp_windows()
 check(desktop.windows.size()==5,"1080p layout preserves windows")
 desktop.queue_free()
 await frames()
 var room = load("res://scenes/bedroom.tscn").instantiate()
 root.add_child(room)
 await frames()
 check(find_button(room,"使用电脑") != null,"bedroom has interactive terminal entrance")
 current_scene = room
 # The terminal now requires approaching the desk.
 room.player_uv = Vector2(95,175)
 room.update_actor()
 find_button(room,"使用电脑").pressed.emit()
 await frames(6)
 check(current_scene != null and current_scene.scene_file_path == "res://scenes/desktop.tscn","bedroom terminal changes to desktop scene")
 find_button(current_scene,"开始 / 住所").pressed.emit()
 await frames(6)
 check(current_scene != null and current_scene.scene_file_path == "res://scenes/bedroom.tscn","desktop returns to bedroom")
 find_button(current_scene,"返回主菜单").pressed.emit()
 await frames(6)
 check(current_scene != null and current_scene.scene_file_path == "res://scenes/start.tscn","bedroom returns to original menu")
 print("ROUND2 TEST FAILURES: ",failures)
 quit(0 if failures==0 else 1)
