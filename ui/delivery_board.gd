extends PanelContainer
var list: VBoxContainer
var details: VBoxContainer
var selected_id:=""
var refresh_pending:=false
func _ready() -> void:
 custom_minimum_size=Vector2(850,470)
 var style=StyleBoxFlat.new(); style.bg_color=Color("27384a"); style.set_content_margin_all(12)
 style.set_border_width_all(1); style.border_color=Color("a4b1b5"); add_theme_stylebox_override("panel",style)
 var row=HBoxContainer.new(); row.add_theme_constant_override("separation",16); add_child(row)
 var left_scroll=ScrollContainer.new(); left_scroll.custom_minimum_size=Vector2(320,430); row.add_child(left_scroll)
 left_scroll.horizontal_scroll_mode=ScrollContainer.SCROLL_MODE_DISABLED
 list=VBoxContainer.new();list.size_flags_horizontal=Control.SIZE_EXPAND_FILL;left_scroll.add_child(list)
 var right_scroll=ScrollContainer.new();right_scroll.custom_minimum_size=Vector2(460,430);row.add_child(right_scroll)
 right_scroll.horizontal_scroll_mode=ScrollContainer.SCROLL_MODE_DISABLED
 details=VBoxContainer.new();details.size_flags_horizontal=Control.SIZE_EXPAND_FILL;details.add_theme_constant_override("separation",10);right_scroll.add_child(details)
 WorldData.changed.connect(schedule)
 refresh()
func schedule() -> void:
 if refresh_pending: return
 refresh_pending=true; call_deferred("refresh")
func text(parent: Node,value: String,width: float=440) -> void:
 var label=Label.new();label.text=value;label.custom_minimum_size.x=width;label.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
 label.add_theme_font_size_override("font_size",16);label.add_theme_color_override("font_color",Color("e0e3dd"));parent.add_child(label)
func button(parent: Node,value: String,action: Callable) -> void:
 var b=Button.new();b.text=value;b.custom_minimum_size.y=32;b.pressed.connect(action);parent.add_child(b)
func clear(node: Node) -> void:
 for child in node.get_children():node.remove_child(child);child.queue_free()
func refresh() -> void:
 refresh_pending=false
 if not is_instance_valid(list): return
 clear(list);clear(details)
 text(list,"今日订单 / 第%d天" % WorldData.day,300)
 text(list,"累计收入 ¥%.2f" % WorldData.income(),300)
 for order in WorldData.orders:
  if not WorldData.today(order): continue
  var id: String=order.id
  button(list,("▶ " if WorldData.active_order_id==id else "")+order.item+" / "+order.status,func():selected_id=id;refresh())
 if selected_id.is_empty() or WorldData.order_by_id(selected_id).is_empty() or not WorldData.today(WorldData.order_by_id(selected_id)): selected_id=WorldData.active_order_id
 var selected=WorldData.order_by_id(selected_id)
 if selected.is_empty(): text(details,"暂无今日订单。");return
 var route=WorldData.route_for(selected)
 text(details,selected.item+" / "+str(WorldData.people[selected.person_id]))
 text(details,selected.id+" · "+selected.status+" · ¥%.2f" % float(selected.fee))
 text(details,"取餐："+route.pickup_name+"\n送达："+selected.address)
 text(details,"备注："+selected.note)
 var day_open=WorldData.period=="day"
 if day_open and selected.status=="可接单": button(details,"接取并追踪此单",func():WorldData.accept_order(selected_id))
 if day_open and selected.status in ["待取餐","配送中"]: button(details,"追踪此单",func():WorldData.focus_order(selected_id))
 if day_open and selected.status in ["可接单","待取餐"] and selected.get("route_key","soup")!="soup": button(details,"取消此加单（未取餐）",func():WorldData.cancel_order(selected_id))
 text(details,"基础配送自动接取。加单可选；取餐后需完成配送。\n已接单全部处理后，才能收工回家。")
 text(details,"当前目标："+WorldData.objective())
 text(details,"历史记录",440)
 for order in WorldData.orders:
  if order.status in ["已送达","已取消","已结束"]: text(details,order.item+" / "+order.status+" / ¥%.2f" % (float(order.fee) if order.status=="已送达" else 0.0))
