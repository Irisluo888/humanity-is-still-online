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
 for group in GROUPS:
  var selected=group[0];var last={};var unread=0
  for id in group:
   unread+=MessageManager.get_unread_count(id)
   var messages=MessageManager.get_thread_messages(id)
   if not messages.is_empty() and (last.is_empty() or messages.back().ordinal>last.ordinal):last=messages.back();selected=id
  var meta=MessageManager.catalog.threads[group[0]]
  var button=Button.new();button.custom_minimum_size=Vector2(450,85);button.alignment=HORIZONTAL_ALIGNMENT_LEFT;list.add_child(button)
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
