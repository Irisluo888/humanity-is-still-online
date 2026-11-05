extends AcceptDialog
var sliders: Dictionary={}
func _ready():
 LocalAudio.settings_open=true
 title="声音设置";ok_button_text="完成";confirmed.connect(queue_free);canceled.connect(queue_free)
 var box=VBoxContainer.new();box.add_theme_constant_override("separation",12);add_child(box)
 var heading=Label.new();heading.text="音量调整 · 自动保存";heading.add_theme_font_size_override("font_size",23);box.add_child(heading)
 var names={"Master":"总音量","Music":"背景音乐","Environment":"环境音（雨声）","SFX":"音效（脚步、消息、剧情）"}
 for key in names:
  var row=HBoxContainer.new();box.add_child(row)
  var label=Label.new();label.text=names[key];label.custom_minimum_size.x=235;row.add_child(label)
  var value=Label.new();value.custom_minimum_size.x=45
  var slider=HSlider.new();slider.min_value=0;slider.max_value=100;slider.step=1;slider.value=round(LocalAudio.volumes[key]*100);slider.custom_minimum_size=Vector2(190,28);row.add_child(slider);row.add_child(value);value.text=str(int(slider.value))+"%";sliders[key]=slider
  slider.value_changed.connect(func(v):value.text=str(int(v))+"%";LocalAudio.set_volume(key,v/100.0))
 var hint=Label.new();hint.text="拖动实时生效；设为0可静音。设置保存在本机。";box.add_child(hint)
 var reset=Button.new();reset.text="恢复推荐音量";box.add_child(reset)
 reset.pressed.connect(func():
  for key in sliders:sliders[key].value=LocalAudio.DEFAULTS[key]*100)

func _exit_tree():LocalAudio.settings_open=false
