extends SceneTree
var fails=0
func _initialize():call_deferred("run")
func frames():
 for i in range(15):await process_frame
func check(v,t):
 print("PASS: " if v else "FAIL: ",t)
 if not v:fails+=1
func snap(n):
 await RenderingServer.frame_post_draw
 check(root.get_texture().get_image().save_png("res://artifacts/digital_systems/"+n+".png")==OK,n)
func run():
 root.size=Vector2i(1280,720);var c=root.get_node("Chapter");var audio=root.get_node("LocalAudio");c.fresh();change_scene_to_file("res://scenes/ch01.tscn");await frames()
 check(current_scene.map_world.get_node_or_null("UrbanBuilding")!=null,"urban models instantiated")
 await snap("27_urban_street")
 var map=current_scene.map_world;var before=audio.played_count;map.held[KEY_D]=true;await create_timer(.5).timeout;map.held.clear()
 check(audio.played_count>before,"actual walking triggers footstep playback")
 before=audio.played_count;map.locked=true;await create_timer(.5).timeout;check(audio.played_count==before,"locked stationary player makes no footsteps")
 check(c.enter("home"),"door travel works");await frames();check(audio.last_cue=="doorOpen_1","door sound starts after successful travel")
 c.debug_jump(5);c.state.flags.morning_transition_pending=false;c.state.event_active=false;c.state.place="garden";c.sync();await frames()
 await snap("28_urban_garden")
 check(current_scene.map_world.points.has("building") and current_scene.map_world.points.has("store"),"garden interaction points retained")
 current_scene.queue_free();await frames();await create_timer(2).timeout
 for player in audio.players:player.stop();player.stream=null
 await frames();print("ASSET INTEGRATION FAILURES: ",fails);quit(fails)
