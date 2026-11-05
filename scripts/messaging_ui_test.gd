extends SceneTree
var failures=0
func _initialize():call_deferred("run")
func frames(n=12):
 for i in range(n):await process_frame
func check(v: bool,text: String):
 print("PASS: " if v else "FAIL: ",text)
 if not v:failures+=1
func snap(name: String):
 await frames();await RenderingServer.frame_post_draw
 check(root.get_texture().get_image().save_png("res://artifacts/digital_systems/"+name+".png")==OK,"capture "+name)
func run():
 root.size=Vector2i(1280,720);change_scene_to_file("res://scenes/messaging_test.tscn");await frames(20)
 var m=root.get_node("MessageManager")
 await create_timer(1.5).timeout
 check(m.get_thread_messages("rider_group").size()>0 and m.get_thread_messages("rider_group").size()<4,"real seconds reveal a few messages only")
 await snap("01_live_group")
 m.set_process(false)
 for i in range(8):m.tick_presentation(3)
 await frames();await snap("02_reply")
 var pane=current_scene.get_child(1).get_child(0).get_child(1)
 check(pane.has_method("add_bubble"),"actual shared conversation component")
 m.choose_reply("rider_group_007","ask")
 for i in range(5):m.tick_presentation(3)
 await frames();await snap("03_bubbles")
 pane.hide();var count=m.get_thread_messages("rider_group").size();m.tick_presentation(3)
 check(m.get_thread_messages("rider_group").size()==count+1,"hidden window continues presentation")
 pane.show();await frames();check(m.current_minute==1427,"UI open close does not move game clock")
 current_scene.queue_free();await frames(10)
 print("MESSAGE UI FAILURES: ",failures);quit(1 if failures else 0)
