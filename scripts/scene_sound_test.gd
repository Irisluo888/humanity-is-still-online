extends SceneTree
var fails=0
func _initialize():call_deferred("run")
func check(v,t):
 print("PASS: " if v else "FAIL: ",t)
 if not v:fails+=1
func frames():
 for i in range(15):await process_frame
func run():
 root.size=Vector2i(1280,720);var c=root.get_node("Chapter");var a=root.get_node("LocalAudio");c.fresh();change_scene_to_file("res://scenes/ch01.tscn");await frames()
 var map=current_scene.map_world;var count=a.played_count;map.held[KEY_D]=true;await create_timer(.5).timeout
 check(a.bike.playing and a.played_count==count,"riding uses bike loop without footsteps")
 map.held.clear();await create_timer(.2).timeout;check(not a.bike.playing and a.rain.playing,"stop bike while outdoor rain continues")
 await RenderingServer.frame_post_draw
 check(root.get_texture().get_image().save_png("res://artifacts/digital_systems/29_clear_signs.png")==OK,"capture clear building signs")
 check(current_scene.clear_sign_labels.size()>0,"full resolution labels exist")
 c.state.beat=1;c.state.flags.bike_fault_shown=true;c.sync();await frames();map=current_scene.map_world;map.held[KEY_D]=true;await create_timer(.5).timeout;map.held.clear()
 check(a.last_cue.begins_with("footstep") and not a.bike.playing,"walking uses footsteps instead of motor")
 for player in a.players:
  if player.stream!=null and player.playing:check(player.volume_db<=-29,"footsteps reduced12dB")
 for cue in ["finger_clamp","heavy_impact","glass_break","door_impact"]:
  await create_timer(.8).timeout;a.play(cue);check(a.last_cue==cue,"play "+cue)
 c.enter("home");await frames();check(not a.rain.playing,"indoors stops outdoor rain")
 current_scene.queue_free();await frames();await create_timer(2).timeout
 for player in a.players:player.stop();player.stream=null
 print("SCENE SOUND FAILURES: ",fails);quit(fails)
