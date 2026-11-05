extends SceneTree
var fails=0
func _initialize():call_deferred("run")
func check(v,t):
 print("PASS: " if v else "FAIL: ",t)
 if not v:fails+=1
func frames():
 for i in range(15):await process_frame
func run():
 root.size=Vector2i(1280,720);var a=root.get_node("LocalAudio");a.settings_path="user://audio_settings_test.cfg"
 change_scene_to_file("res://scenes/start.tscn");await frames();await create_timer(1.8).timeout
 check(a.music.playing and a.music_mode=="menu","menu music plays quietly")
 current_scene.show_settings();await frames();var dialog
 for node in current_scene.get_children():
  if node.get_script()==load("res://ui/audio_settings.gd"):dialog=node
 check(dialog!=null and dialog.visible,"menu volume settings opens")
 dialog.sliders.Music.value=0;await frames()
 check(AudioServer.is_bus_mute(AudioServer.get_bus_index("Music")),"music slider0 mutes music only")
 check(not AudioServer.is_bus_mute(AudioServer.get_bus_index("SFX")),"music mute preserves effects")
 dialog.sliders.SFX.value=42;dialog.sliders.Master.value=70;dialog.sliders.Environment.value=25
 a.volumes={};a.load_settings()
 check(is_equal_approx(a.volumes.SFX,.42) and is_equal_approx(a.volumes.Master,.7) and is_equal_approx(a.volumes.Environment,.25) and a.volumes.Music==0,"settings persist and restore independently")
 for key in a.DEFAULTS:dialog.sliders[key].value=a.DEFAULTS[key]*100
 await frames();await RenderingServer.frame_post_draw
 check(root.get_texture().get_image().save_png("res://artifacts/digital_systems/30_audio_settings.png")==OK,"capture actual settings")
 dialog.confirmed.emit();await frames();check(not a.settings_open,"closing restores controls")
 var c=root.get_node("Chapter");c.fresh();change_scene_to_file("res://scenes/ch01.tscn");await frames();await create_timer(1.8).timeout
 check(a.music_mode=="city" and a.music.playing,"delivery uses city background loop")
 a.show_settings(current_scene);await frames();var settings
 for node in current_scene.get_children():
  if node.get_script()==load("res://ui/audio_settings.gd"):settings=node
 var pos=current_scene.map_world.player.position;current_scene.map_world.held[KEY_D]=true;await create_timer(.2).timeout
 check(current_scene.map_world.player.position.distance_to(pos)<.01,"settings prevents player movement")
 current_scene.map_world.held.clear();await RenderingServer.frame_post_draw
 check(root.get_texture().get_image().save_png("res://artifacts/digital_systems/31_ingame_audio_settings.png")==OK,"capture ingame settings")
 settings.confirmed.emit();await frames()
 c.state.encounter=true;c.sync();await frames();await create_timer(.5).timeout;check(not a.music.playing,"danger fades music out")
 c.state.encounter=false;c.state.place="home";c.sync();await frames();await create_timer(1.8).timeout;check(a.music_mode=="night" and a.music.playing,"home uses night music")
 current_scene.queue_free();await frames()
 a.set_process(false)
 if a.music_tween:a.music_tween.kill()
 a.music.stop();a.music.stream=null;a.rain.stop();a.bike.stop()
 for player in a.players:player.stop();player.stream=null
 await create_timer(1).timeout
 print("AUDIO SETTINGS FAILURES: ",fails);quit(fails)
