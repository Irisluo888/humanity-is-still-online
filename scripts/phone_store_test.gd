extends SceneTree
var fails=0
func _initialize():call_deferred("run")
func check(v,t):
 print("PASS: " if v else "FAIL: ",t)
 if not v:fails+=1
func frames():
 for i in range(15):await process_frame
func snap(n):
 await RenderingServer.frame_post_draw
 check(root.get_texture().get_image().save_png("res://artifacts/digital_systems/"+n+".png")==OK,n)
func find_phone(node):
 if node.get_script()==load("res://ui/phone_messages.gd"):return node
 for child in node.get_children():
  var found=find_phone(child)
  if found:return found
 return null
func run():
 root.size=Vector2i(1280,720);var c=root.get_node("Chapter");var m=root.get_node("MessageManager");c.fresh()
 change_scene_to_file("res://scenes/ch01.tscn");await frames();await create_timer(.6).timeout
 current_scene.show_phone();await frames();var p=find_phone(current_scene)
 check(p.list.get_child_count()==3,"three separate contact rows")
 check(m.get_unread_count("xiaoyu")>0,"contact list does not mark messages read")
 await snap("21_contact_list")
 p.list.get_child(1).pressed.emit();await frames()
 check(not p.conversation.selector.visible and m.get_unread_count("xiaoyu")==0,"contact click opens chat without dropdown and clears unread")
 await snap("22_contact_chat")
 p.show_list();await frames();p.list.get_child(2).pressed.emit();await frames()
 check(p.conversation.thread_id=="zhou_warning","empty contact stays selected instead of switching to other unread")
 c.debug_jump(8);c.state.flags.morning_transition_pending=false;c.state.event_active=false;c.sync();await frames()
 check(current_scene.map_world.get_node_or_null("StoreMan")==null,"man absent before Chen conversation")
 await snap("23_store_before_arrival")
 await create_timer(4.1).timeout
 current_scene.interact_point("shop");await frames()
 check(current_scene.map_world.get_node_or_null("StoreMan")==null,"Chen speaks before man enters")
 c.step_page();await frames();var man=current_scene.map_world.get_node("StoreMan");var first=man.position
 await snap("24_store_entrance")
 await create_timer(2.1).timeout
 check(man.position.distance_to(first)>1 and man.position.distance_to(Vector3(5,.975,1.2))<.1,"man walks from entrance to counter")
 current_scene.queue_free();await frames();print("PHONE STORE FAILURES: ",fails);quit(fails)
