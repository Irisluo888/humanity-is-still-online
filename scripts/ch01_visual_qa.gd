extends "res://scripts/ch01_qa_test.gd"
func run() -> void:
 root.size=Vector2i(1280,720);c=root.get_node("Chapter");c.save_path="user://ch01_visual_qa.json";c.debug_jump(9)
 change_scene_to_file("res://scenes/ch01.tscn");await frames(20)
 await press(KEY_P);check(current_scene.opened,"P opens actual phone")
 await capture("20_phone_chat")
 for pair in [["新闻","21_phone_news"],["接单","22_phone_orders"],["地图","23_phone_map"],["背包","24_phone_inventory"]]:
  var tab=find_button(current_scene,pair[0]);check(tab!=null,"phone tab "+pair[0])
  if tab:tab.pressed.emit()
  await capture(pair[1])
 current_scene.close_phone();await frames()
 root.size=Vector2i(1920,1080);await frames();await capture("25_home_1080p")
 root.size=Vector2i(1280,720);change_scene_to_file("res://scenes/start.tscn");await frames(20);await capture("26_menu")
 check(find_button(current_scene,"原始3D灰盒预览")==null and find_button(current_scene,"桌面原型预览")==null,"normal menu has no prototype entries")
 print("VISUAL UI FAILURES: ",failures);quit(1 if failures else 0)
