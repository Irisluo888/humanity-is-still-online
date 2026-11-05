extends "res://scripts/desktop_third.gd"
func _ready() -> void:
 super._ready()
 if not WorldData.campaign: return
 WorldData.location="desktop"
 if not WorldData.notes.is_empty(): desktop_notes.text=WorldData.notes
 desktop_notes.text_changed.connect(func(): WorldData.notes=desktop_notes.text)
 tasks.add_child(small_button("保存",func():
  if Chapter.session_active:Chapter.save()
  else:WorldData.save_game(),60))
 # Calendar is a local-system widget; label it separately from game time.
 get_child(2).text="HOME / 07\n"+WorldData.objective()
func _process(delta: float) -> void:
 super._process(delta)
 if WorldData.campaign:
  clock.text=WorldData.time_text()+" · 离线"
func open_app(app: String) -> void:
 super.open_app(app)
 if WorldData.campaign and app in ["动态","消息"]: WorldData.mark_reviewed()
func build_orders(body: HBoxContainer) -> void:
 if not WorldData.campaign: super.build_orders(body); return
 var list=scroll_box(body,275,"c4cfd1")
 copy(list,"今日配送 / 第%d天" % WorldData.day,245)
 copy(list,"累计已送达收入：¥%.2f" % WorldData.income(),245)
 for i in range(WorldData.orders.size()):
  var index: int=i
  var item: Dictionary=WorldData.orders[i]
  list.add_child(small_button(item.id+"\n"+item.status,func(): selected_order=index; rebuild("接单"),245))
 selected_order=clampi(selected_order,0,WorldData.orders.size()-1)
 var order: Dictionary=WorldData.orders[selected_order]
 var details=scroll_box(body,505)
 copy(details,order.item+" / 七号住户",475)
 copy(details,"地址："+order.address,475)
 copy(details,"状态："+order.status+" · 配送费 ¥%.2f" % order.fee,475)
 copy(details,"取餐：热汤铺 → 送达：榆灯巷07号 → 返回住所",475)
 copy(details,"备注："+order.note,475)
 image(details,"thumb_2.png",Vector2(320,180))
 copy(details,"请在白天到现场完成取餐和送达。电脑只记录进度。",475,true)
 copy(details,WorldData.objective(),475)
