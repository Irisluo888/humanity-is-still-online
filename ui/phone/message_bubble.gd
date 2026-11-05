extends VBoxContainer
const P=preload("res://ui/phone/palette.gd")
func setup(message: Dictionary,contact: Dictionary):
 size_flags_horizontal=SIZE_EXPAND_FILL
 var stamp=P.label("%02d:%02d"%[(int(message.sent_at)%1440)/60,int(message.sent_at)%60],11,P.MUTED);stamp.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;add_child(stamp)
 var row=HBoxContainer.new();row.add_theme_constant_override("separation",8);add_child(row)
 var own=message.sender_id=="player";var spacer=Control.new();spacer.custom_minimum_size.x=25
 if own:row.add_child(spacer)
 else:row.add_child(P.avatar(message.sender_id,36))
 var col=VBoxContainer.new();col.size_flags_horizontal=SIZE_EXPAND_FILL;row.add_child(col)
 var name_label=P.label(contact.name,12,P.MUTED);name_label.horizontal_alignment=HORIZONTAL_ALIGNMENT_RIGHT if own else HORIZONTAL_ALIGNMENT_LEFT;col.add_child(name_label)
 var panel=PanelContainer.new();panel.add_theme_stylebox_override("panel",P.style(Color("f1d8ec") if own else Color("fffdf8ee"),16,11));col.add_child(panel)
 var contents=VBoxContainer.new();panel.add_child(contents);contents.add_child(P.wrap(message.text,16))
 for attachment in message.get("attachments",[]):
  if not str(attachment).begins_with("res://assets/"):continue
  var resource=load(attachment)
  if resource is Texture2D:
   var pic=TextureRect.new();pic.texture=resource;pic.expand_mode=TextureRect.EXPAND_IGNORE_SIZE;pic.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED;pic.custom_minimum_size.y=120;contents.add_child(pic)
  elif resource is AudioStream:
   var audio=AudioStreamPlayer.new();audio.stream=resource;audio.bus="SFX";audio.volume_db=-18;add_child(audio)
   var play=P.button("播放语音",func():audio.stop() if audio.playing else audio.play());contents.add_child(play)
   audio.finished.connect(func():play.text="播放语音")
   play.pressed.connect(func():play.text="停止语音" if audio.playing else "播放语音")
 if own:row.add_child(P.avatar("player",36))
 else:row.add_child(spacer)
func arrival():
 modulate.a=0;create_tween().tween_property(self,"modulate:a",1.0,.3)
