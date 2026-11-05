extends Node
const ROOT="res://assets/third_party/kenney/rpg_sounds/"
var players: Array[AudioStreamPlayer]=[]
var step_index=0
var played_count=0
var last_cue=""
var rain: AudioStreamPlayer
var bike: AudioStreamPlayer
const DEFAULTS={"Master":0.8,"Music":0.55,"Environment":0.65,"SFX":0.8}
var volumes=DEFAULTS.duplicate()
var settings_path="user://audio_settings.cfg"
var music: AudioStreamPlayer
var settings_open=false
var music_mode="__initial__"
var music_tween: Tween
func setup_buses():
 for key in DEFAULTS:
  if AudioServer.get_bus_index(key)<0:
   AudioServer.add_bus();AudioServer.set_bus_name(AudioServer.bus_count-1,key);AudioServer.set_bus_send(AudioServer.bus_count-1,"Master")
 load_settings()
func set_volume(key: String,value: float,save=true):
 if not DEFAULTS.has(key) or not is_finite(value):return
 volumes[key]=clampf(value,0,1);var index=AudioServer.get_bus_index(key)
 AudioServer.set_bus_volume_db(index,linear_to_db(maxf(.0001,volumes[key])));AudioServer.set_bus_mute(index,volumes[key]==0)
 if save:save_settings()
func save_settings() -> Error:
 var config=ConfigFile.new()
 for key in volumes:config.set_value("audio",key,volumes[key])
 return config.save(settings_path)
func load_settings():
 var config=ConfigFile.new();config.load(settings_path)
 for key in DEFAULTS:
  var v=config.get_value("audio",key,DEFAULTS[key])
  set_volume(key,float(v) if (v is float or v is int) and is_finite(float(v)) else DEFAULTS[key],false)
func show_settings(parent: Node):
 var dialog=preload("res://ui/audio_settings.gd").new();parent.add_child(dialog);dialog.popup_centered(Vector2i(550,390))
func _process(_delta):
 if not is_instance_valid(music):return
 var scene=get_tree().current_scene
 if not is_instance_valid(scene):return
 var path=scene.scene_file_path;var mode="menu"
 if "ch01" in path and not Chapter.state.is_empty():
  mode="city" if Chapter.state.place in ["street","garden"] else "night"
  if Chapter.modal() or Chapter.beat().id in ["knock1","call","reveal","final","end"]:mode=""
 elif "desktop" in path or "bedroom" in path:mode="night"
 elif "city" in path:mode="city"
 switch_music(mode)
func switch_music(mode: String):
 if mode==music_mode:return
 music_mode=mode
 if music_tween:music_tween.kill()
 music_tween=create_tween();music_tween.tween_property(music,"volume_db",-70.0,.4)
 music_tween.tween_callback(func():
  music.stop()
  if not mode.is_empty():
   var stream=load("res://assets/audio/music/"+mode+".wav").duplicate();stream.loop_mode=AudioStreamWAV.LOOP_FORWARD;stream.loop_end=stream.get_length()*stream.mix_rate;music.stream=stream;music.play())
 if not mode.is_empty():music_tween.tween_property(music,"volume_db",-17.0,1.2)

func _ready():
 setup_buses()
 music=AudioStreamPlayer.new();music.bus="Music";music.volume_db=-70;add_child(music)
 for i in range(4):
  var player=AudioStreamPlayer.new();player.bus="SFX";player.volume_db=-17;add_child(player);players.append(player)
 rain=loop_player("rain",-30);bike=loop_player("bike",-29);rain.bus="Environment";bike.bus="SFX"
func loop_player(cue: String,volume: float) -> AudioStreamPlayer:
 var p=AudioStreamPlayer.new();add_child(p);p.volume_db=volume
 var stream=load("res://assets/audio/generated/"+cue+".wav").duplicate();stream.loop_mode=AudioStreamWAV.LOOP_FORWARD;stream.loop_end=stream.get_length()*stream.mix_rate;p.stream=stream;return p
func ambience(outdoors: bool,riding: bool):
 if outdoors and not rain.playing:rain.play()
 elif not outdoors:rain.stop()
 if riding and not bike.playing:bike.play()
 elif not riding:bike.stop()
func play(cue: String):
 for player in players:
  if not player.playing:
   var path="res://assets/audio/generated/"+cue+".wav"
   player.stream=load(path if ResourceLoader.exists(path) else ROOT+cue+".ogg");player.volume_db=-29 if cue.begins_with("footstep") else -19;player.play();played_count+=1;last_cue=cue;return
func footstep():
 play("footstep%02d"%step_index);step_index=(step_index+1)%3
