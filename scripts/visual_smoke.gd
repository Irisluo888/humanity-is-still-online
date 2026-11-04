extends SceneTree
func _initialize() -> void: call_deferred("run_test")
func buttons(node: Node, caption: String) -> Array:
 var result: Array = []
 if node is Button and node.text == caption: result.append(node)
 for child in node.get_children(): result.append_array(buttons(child,caption))
 return result
func run_test() -> void:
 var desktop = load("res://scenes/desktop.tscn").instantiate()
 root.add_child(desktop)
 await process_frame
 desktop.open_app("动态")
 desktop.open_app("消息")
 await process_frame
 var feed = desktop.windows["动态"]
 var message = desktop.windows["消息"]
 buttons(feed,"配送")[0].pressed.emit()
 assert(desktop.active_category == "配送")
 buttons(message,"修伞的人")[0].pressed.emit()
 assert(desktop.selected_contact == 3)
 var inputs = message.find_children("*","LineEdit",true,false)
 inputs[0].text = "本地测试留言"
 buttons(message,"记录")[0].pressed.emit()
 assert(desktop.chat_history[3][0] == "本地测试留言")
 var title = message.get_child(0).get_child(0)
 title.get_child(1).pressed.emit()
 assert(not message.visible)
 buttons(desktop.tasks,"消息")[0].pressed.emit()
 assert(message.visible)
 assert(desktop.get_child(desktop.get_child_count()-1) == message)
 var handle = title.get_child(0)
 var press = InputEventMouseButton.new()
 press.button_index = MOUSE_BUTTON_LEFT
 press.pressed = true
 handle.gui_input.emit(press)
 var motion = InputEventMouseMotion.new()
 message._input(motion)
 assert(message.position.x >= 0 and message.position.y >= 0)
 var release = InputEventMouseButton.new()
 release.button_index = MOUSE_BUTTON_LEFT
 release.pressed = false
 message._input(release)
 assert(not message.dragging)
 var store = root.get_node("WorldData")
 store.record_event("visual_test","resident_07","lane_07","白天共享测试")
 await process_frame
 assert(desktop.event_text().contains("白天共享测试"))
 for app in ["热榜","视频","AI助手","接单"]: desktop.open_app(app)
 assert(desktop.windows.size() == 6)
 message.closed.emit()
 assert(not desktop.windows.has("消息"))
 print("PASS: feed filter, contact, local message, minimize/restore/focus, drag handlers, shared refresh, six apps, close")
 desktop.queue_free()
 quit()
