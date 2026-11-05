extends Node
const ROOT="res://assets/third_party/kenney/rpg_sounds/"
var players: Array[AudioStreamPlayer]=[]
var step_index=0
var played_count=0
var last_cue=""
func _ready():
 for i in range(4):
  var player=AudioStreamPlayer.new();player.volume_db=-17;add_child(player);players.append(player)
func play(cue: String):
 for player in players:
  if not player.playing:
   player.stream=load(ROOT+cue+".ogg");player.play();played_count+=1;last_cue=cue;return
func footstep():
 play("footstep%02d"%step_index);step_index=(step_index+1)%3
