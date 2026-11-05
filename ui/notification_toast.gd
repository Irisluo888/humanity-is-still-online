extends PanelContainer
signal requested(target: String)
var title: Label
var body: Label
var target=""
var lifetime=0.0
var audio: AudioStreamPlayer
var allow_display: Callable
var shake_time=0.0
var resting_position=Vector2.ZERO
var status: Label
func _ready() -> void:
 custom_minimum_size=Vector2(330,150);size=Vector2(330,150);z_index=100
 pivot_offset=Vector2(165,75)
 var style=StyleBoxFlat.new();style.bg_color=Color("263b4a");style.border_color=Color("97a3ad");style.set_border_width_all(4)
 style.corner_radius_top_left=12;style.corner_radius_top_right=12;style.corner_radius_bottom_left=12;style.corner_radius_bottom_right=12
 for side in ["left","right","top","bottom"]:style.set("content_margin_"+side,8)
 add_theme_stylebox_override("panel",style)
 var box=VBoxContainer.new();box.add_theme_constant_override("separation",6);add_child(box)
 status=Label.new();status.text="▰  手机 · 新消息                      ▮▮▮";status.add_theme_font_size_override("font_size",13);status.modulate=Color("a4b9c1");box.add_child(status)
 box.add_child(HSeparator.new())
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
 title.text=n.title;body.text=n.text.left(60);target=n.target;lifetime=7.0;shake_time=0.65;resting_position=position;show()
 audio.play()
func _process(delta: float) -> void:
 if shake_time>0:
  shake_time=maxf(0,shake_time-delta);rotation=sin(shake_time*75)*0.025*(shake_time/0.65)
  if shake_time==0:rotation=0
 if lifetime>0:
  lifetime-=delta
  if lifetime<=0:hide()
