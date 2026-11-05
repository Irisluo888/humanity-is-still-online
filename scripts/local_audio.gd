extends Node
const ROOT="res://assets/third_party/kenney/rpg_sounds/"
var players: Array[AudioStreamPlayer]=[]
var step_index=0
var played_count=0
var last_cue=""
var rain: AudioStreamPlayer
var bike: AudioStreamPlayer
func _ready():
 for i in range(4):
  var player=AudioStreamPlayer.new();player.volume_db=-17;add_child(player);players.append(player)
 rain=loop_player("rain",-30);bike=loop_player("bike",-29)
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
