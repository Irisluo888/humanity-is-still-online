extends PanelContainer
signal requested(target: String)
var title: Label
var body: Label
var target=""
var lifetime=0.0
var audio: AudioStreamPlayer
var allow_display: Callable
func _ready() -> void:
 custom_minimum_size=Vector2(330,90);size=Vector2(330,90)
 var style=StyleBoxFlat.new();style.bg_color=Color("34495a");style.border_color=Color("a1a58a");style.set_border_width_all(2)
 for side in ["left","right","top","bottom"]:style.set("content_margin_"+side,8)
 add_theme_stylebox_override("panel",style)
 var box=VBoxContainer.new();add_child(box)
 title=Label.new();title.add_theme_font_size_override("font_size",18);box.add_child(title)
 body=Label.new();body.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;body.custom_minimum_size.x=300;body.add_theme_font_size_override("font_size",15);box.add_child(body)
 var button=Button.new();button.text="查看";button.pressed.connect(func():requested.emit(target);hide());box.add_child(button)
 audio=AudioStreamPlayer.new();audio.stream=preload("res://assets/audio/ch01/vibrate.wav");audio.volume_db=-27;add_child(audio)
 MessageManager.notification_posted.connect(on_notification);hide()
 restore_pending.call_deferred()
func restore_pending() -> void:
 var pending=MessageManager.get_notifications()
 pending.reverse()
 for n in pending:
  if not n.read and not n.get("presented",false):
   on_notification(n);break
func on_notification(n: Dictionary) -> void:
 if not is_inside_tree():return
 if allow_display.is_valid() and not allow_display.call():audio.play();hide();return
 if MessageManager.notifications.has(n.id):MessageManager.notifications[n.id]["presented"]=true
 title.text=n.title;body.text=n.text.left(60);target=n.target;lifetime=4.5;show()
 audio.play()
func _process(delta: float) -> void:
 if lifetime>0:
  lifetime-=delta
  if lifetime<=0:hide()
