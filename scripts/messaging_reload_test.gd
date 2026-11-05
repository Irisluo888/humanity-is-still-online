extends SceneTree
func _initialize():call_deferred("run")
func run():
 var c=root.get_node("Chapter");var m=root.get_node("MessageManager");m.set_process(false);c.save_path="user://digital_integration.json"
 if not c.restore():push_error("digital reload failed");quit(1);return
 var before=m.get_thread_messages("rider_group").size();var minute=c.game_minute();m.tick_presentation(3)
 var valid=before==1 and m.get_thread_messages("rider_group").size()==2 and c.game_minute()==minute
 print("PASS: new process resumes pending sequence without duplicate history or time advance" if valid else "FAIL: cross process sequence")
 quit(0 if valid else 1)
