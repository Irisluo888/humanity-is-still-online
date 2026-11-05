extends PanelContainer
var state: Label
var message: Label
var buttons: VBoxContainer
func _ready() -> void:
 var style = StyleBoxFlat.new()
 style.bg_color = Color("243243")
 style.border_color = Color("748a99")
 style.set_border_width_all(1); style.set_content_margin_all(10)
 add_theme_stylebox_override("panel",style)
 var column = VBoxContainer.new(); column.add_theme_constant_override("separation",6); add_child(column)
 state=Label.new(); state.add_theme_font_size_override("font_size",16); column.add_child(state)
 buttons=VBoxContainer.new(); column.add_child(buttons)
 for item in ["food","water","medicine"]:
  var id: String = item
  var button=Button.new(); button.text="使用"+WorldData.item_name(id)
  button.pressed.connect(func(): WorldData.use_item(id)); buttons.add_child(button)
 var save=Button.new(); save.text="保存游戏（本地）"
 save.pressed.connect(func(): WorldData.save_game()); buttons.add_child(save)
 message=Label.new(); message.custom_minimum_size.x=224
 message.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART; message.add_theme_font_size_override("font_size",14)
 column.add_child(message)
 WorldData.changed.connect(refresh)
 refresh()
func refresh() -> void:
 state.text=WorldData.time_text()+"\n体力 %d / 身体 %d\n饭团 %d · 水 %d · 急救包 %d" % [WorldData.stamina,WorldData.health,WorldData.inventory.food,WorldData.inventory.water,WorldData.inventory.medicine]
 for i in range(3): buttons.get_child(i).disabled=int(WorldData.inventory[["food","water","medicine"][i]])<=0
 message.text=WorldData.notice
