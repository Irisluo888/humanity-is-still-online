extends VBoxContainer
var initial_thread=""
var conversation: Control
var list: VBoxContainer
const Kit=preload("res://ui/kit.gd")
const GROUPS=[["rider_group","night_group"],["xiaoyu","xiaoyu_late"],["zhou_warning"]]
func _ready():
 size_flags_horizontal=SIZE_EXPAND_FILL;size_flags_vertical=SIZE_EXPAND_FILL
 MessageManager.changed.connect(refresh_list)
 if initial_thread.is_empty():show_list()
 else:open_thread(initial_thread)
func clear():
 for node in get_children():remove_child(node);node.queue_free()
 list=null;conversation=null
func show_list():
 clear()
 var scroll=ScrollContainer.new();scroll.custom_minimum_size=Vector2(450,375);scroll.size_flags_vertical=SIZE_EXPAND_FILL;add_child(scroll)
 list=VBoxContainer.new();list.size_flags_horizontal=SIZE_EXPAND_FILL;list.add_theme_constant_override("separation",8);scroll.add_child(list);refresh_list()
func refresh_list():
 if not is_instance_valid(list):return
 for node in list.get_children():list.remove_child(node);node.queue_free()
 var entries=[]
 for group in GROUPS:
  var selected=group[0];var last={};var unread=0
  for id in group:
   unread+=MessageManager.get_unread_count(id)
   var messages=MessageManager.get_thread_messages(id)
   if not messages.is_empty() and (last.is_empty() or messages.back().get("display_order",0)>last.get("display_order",0)):last=messages.back();selected=id
  entries.append({"group":group,"selected":selected,"last":last,"unread":unread,"rank":last.get("display_order",0)})
 entries.sort_custom(func(a,b):return a.rank>b.rank)
 for entry in entries:
  var selected=entry.selected;var last=entry.last;var unread=entry.unread
  var meta=MessageManager.catalog.threads[entry.group[0]]
  var button=Button.new();button.custom_minimum_size=Vector2(450,85);button.alignment=HORIZONTAL_ALIGNMENT_LEFT;list.add_child(button);button.set_meta("thread_id",selected);button.set_meta("unread",unread)
  for state in ["normal","hover","pressed","focus"]:
   var row_style=StyleBoxFlat.new();row_style.bg_color=Color("30495a" if state in ["hover","focus"] else "202c38");row_style.border_color=Color("6f8998");row_style.set_border_width_all(1);button.add_theme_stylebox_override(state,row_style)
  button.pressed.connect(open_thread.bind(selected))
  var row=HBoxContainer.new();row.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT);row.offset_left=10;row.offset_top=8;row.offset_right=-10;row.offset_bottom=-8;row.mouse_filter=Control.MOUSE_FILTER_IGNORE;button.add_child(row)
  var avatar=TextureRect.new();avatar.texture=load(meta.icon);avatar.custom_minimum_size=Vector2(48,58);avatar.expand_mode=TextureRect.EXPAND_IGNORE_SIZE;avatar.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED;avatar.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST;avatar.mouse_filter=Control.MOUSE_FILTER_IGNORE;row.add_child(avatar)
  var col=VBoxContainer.new();col.mouse_filter=Control.MOUSE_FILTER_IGNORE;col.size_flags_horizontal=SIZE_EXPAND_FILL;row.add_child(col)
  col.add_child(Kit.label(meta.name,20))
  var preview=Kit.label(last.get("text","暂无消息"),16);preview.custom_minimum_size.x=285;preview.clip_text=true;col.add_child(preview)
  if unread>0:
   var badge=Label.new();badge.text=str(unread);badge.vertical_alignment=VERTICAL_ALIGNMENT_CENTER;badge.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;badge.custom_minimum_size=Vector2(28,28)
   var style=StyleBoxFlat.new();style.bg_color=Color("b94e50");style.set_corner_radius_all(14);badge.add_theme_stylebox_override("normal",style);row.add_child(badge)
func open_thread(id: String):
 clear();add_child(Kit.button("‹ 消息列表 · "+MessageManager.catalog.threads[id].name,show_list))
 for group in GROUPS:
  if id not in group:continue
  var history=HBoxContainer.new();add_child(history)
  for other in group:
   if other!=id and not MessageManager.get_thread_messages(other).is_empty():history.add_child(Kit.button("查看"+MessageManager.catalog.threads[other].name,open_thread.bind(other)))
 var pane=preload("res://ui/message_panel.gd").new();pane.auto_select=false;pane.thread_id=id;pane.custom_minimum_size=Vector2(450,300);add_child(pane);pane.selector.hide();conversation=pane
