extends SceneTree
var failures := 0
func _initialize() -> void: call_deferred("run_checks")
func check(value: bool, description: String) -> void:
 if value: print("PASS: ",description)
 else: failures += 1; push_error(description)
func button(node: Node, prefix: String) -> Button:
 if node is Button and node.text.begins_with(prefix): return node
 for child in node.get_children():
  var result = button(child,prefix)
  if result != null: return result
 return null
func labels(node: Node) -> String:
 var result := ""
 if node is Label: result += node.text+"\n"
 for child in node.get_children(): result += labels(child)
 return result
func frames() -> void:
 for i in range(4): await process_frame
func run_checks() -> void:
 var desktop = load("res://scenes/desktop.tscn").instantiate()
 root.add_child(desktop)
 await frames()
 check(desktop.content.posts.size()>=8,"eight original posts")
 check(desktop.content.news.size()>=10,"ten ranked local news articles")
 check(desktop.content.clips.size()>=6,"six local video records")
 check(desktop.content.contacts.size()>=6,"independent contact histories")
 for app in ["动态","消息","热榜","视频","AI助手","接单"]: desktop.open_app(app)
 await frames()
 check(desktop.windows.size()==6,"six apps load without errors")
 button(desktop.windows["热榜"],"10 ").pressed.emit()
 check(desktop.selected_news==9,"tenth news item selected")
 button(desktop.windows["热榜"],"打开新闻详情").pressed.emit()
 check(desktop.windows.has("新闻详情"),"news detail opens")
 desktop.ask("门铃")
 check(root.get_node("WorldData").assistant_history.back().text.contains("敲门两下"),"offline keyword reply")
 button(desktop.windows["AI助手"],"记录最近回复").pressed.emit()
 check(root.get_node("WorldData").clues.size()==1,"clue recording")
 var history_count = root.get_node("WorldData").assistant_history.size()
 desktop.ask("未知测试词")
 check(root.get_node("WorldData").assistant_history.size()==history_count+2,"assistant dialogue history retained")
 check(root.get_node("WorldData").assistant_history.back().text.contains("无法确认"),"unknown query does not invent information")
 button(desktop.windows["视频"],"窗台雨声").pressed.emit()
 check(desktop.video_index==5,"sixth video selectable")
 var store = root.get_node("WorldData")
 var before: float = store.income()
 button(desktop.windows["接单"],"记录送达").pressed.emit()
 await frames()
 check(store.daytime_orders.size()==1 and store.encountered_npcs.has("resident_07"),"delivery logs order and encountered resident")
 check(is_equal_approx(store.income(),before+6.5),"income reflects completed order")
 check(store.night_posts.size()==1 and store.night_messages.size()==1,"delivery creates linked night post and message")
 check(labels(desktop.windows["动态"]).contains("热汤已收到"),"linked community post actually rendered")
 check(labels(desktop.windows["消息"]).contains("热汤已收到"),"linked contact message actually rendered")
 check(not store.deliver_order("order_001") and store.night_posts.size()==1,"duplicate completion cannot duplicate income/events")
 check(not store.deliver_order("unknown_id"),"unknown order rejected")
 desktop.windows["AI助手"].closed.emit()
 await frames()
 desktop.open_app("AI助手")
 check(labels(desktop.windows["AI助手"]).contains("未知测试词"),"assistant history survives window close/reopen")
 desktop.show_post(desktop.content.posts[7])
 check(desktop.windows.has("帖子详情"),"eighth post detail supported")
 desktop.queue_free()
 await frames()
 var bedroom = load("res://scenes/bedroom.tscn").instantiate()
 root.add_child(bedroom)
 await frames()
 check(button(bedroom,"查看骑手服角色") != null,"room links rider gallery")
 bedroom.queue_free()
 print("THIRD ROUND FAILURES: ",failures)
 quit(0 if failures==0 else 1)
