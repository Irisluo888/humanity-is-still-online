extends SceneTree
func _initialize():call_deferred("run")
func run():
 var c=root.get_node("Chapter");c.save_path="user://ch01_edge.json"
 if not c.restore():push_error("reload failed");quit(1);return
 var pass_all=c.state.positions.garden[0]==3 and c.state.scene_states.store.chen_saved==false
 change_scene_to_file("res://scenes/ch01.tscn")
 for i in range(30):await process_frame
 pass_all=pass_all and current_scene.map_world.kind=="garden" and current_scene.map_world.player.position.distance_to(Vector3(3,0,4))<0.3
 print("PASS: new process restores correct map position and Chen scene state" if pass_all else "FAIL: reload state")
 quit(0 if pass_all else 1)
