extends VBoxContainer
# One component used by test, phone and desktop. No private copy of history/read flags.
var thread_id="rider_group"
var selector: OptionButton
var transcript: VBoxContainer
var scroll: ScrollContainer
var typing_label: Label
var reply_row: VBoxContainer
var pending_refresh=false
var follow_bottom=true
var last_count=-1
var muted=false
var layout_generation=0
var layout_busy=false
var notification_audio: AudioStreamPlayer
const Kit=preload("res://ui/kit.gd")
func _ready() -> void:
 if MessageManager.get_unread_count(thread_id)==0 and MessageManager.pending(thread_id).is_empty():
  for id in MessageManager.catalog.threads:
   if MessageManager.get_unread_count(id)>0 or (not MessageManager.pending(id).is_empty() and MessageManager.pending(id).get("delivered",false)):
    thread_id=id;break
 size_flags_horizontal=SIZE_EXPAND_FILL;size_flags_vertical=SIZE_EXPAND_FILL
 add_theme_constant_override("separation",8)
 selector=OptionButton.new();selector.custom_minimum_size.y=36;add_child(selector)
 selector.item_selected.connect(func(i):thread_id=selector.get_item_metadata(i);follow_bottom=true;MessageManager.begin_thread(thread_id);refresh())
 scroll=ScrollContainer.new();scroll.custom_minimum_size=Vector2(0,260);scroll.size_flags_vertical=SIZE_EXPAND_FILL;scroll.size_flags_horizontal=SIZE_EXPAND_FILL;add_child(scroll)
 transcript=VBoxContainer.new();transcript.size_flags_horizontal=SIZE_EXPAND_FILL;transcript.add_theme_constant_override("separation",12);scroll.add_child(transcript)
 scroll.get_v_scroll_bar().value_changed.connect(func(_v):
  if layout_busy:return
  follow_bottom=scroll.scroll_vertical>=scroll.get_v_scroll_bar().max_value-scroll.size.y-35
  if follow_bottom and is_visible_in_tree():MessageManager.mark_read(thread_id))
 typing_label=Kit.label("",16);typing_label.add_theme_color_override("font_color",Color("9ab6bb"));add_child(typing_label)
 reply_row=VBoxContainer.new();add_child(reply_row)
 visibility_changed.connect(func():
  if is_visible_in_tree():request_refresh())
 MessageManager.changed.connect(request_refresh)
 MessageManager.message_revealed.connect(on_reveal)
 notification_audio=AudioStreamPlayer.new();notification_audio.stream=preload("res://assets/audio/ch01/vibrate.wav");notification_audio.volume_db=-22;add_child(notification_audio)
 MessageManager.begin_thread(thread_id);refresh()
func request_refresh() -> void:
 if pending_refresh:return
 pending_refresh=true;refresh.call_deferred()
func _process(_delta: float) -> void:
 if not is_instance_valid(typing_label):return
 var who=MessageManager.typing_sender(thread_id)
 typing_label.text=who+" 正在输入……" if not who.is_empty() else ""
func refresh() -> void:
 pending_refresh=false
 if not is_inside_tree() or not is_instance_valid(selector):return
 var old_scroll=scroll.scroll_vertical;var should_follow=follow_bottom
 layout_busy=true;layout_generation+=1;var generation=layout_generation
 selector.clear()
 var index=0
 for id in MessageManager.catalog.threads:
  if id.begins_with("legacy_")!=(MessageManager.profile=="legacy"):continue
  var count=MessageManager.get_unread_count(id)
  selector.add_item(MessageManager.catalog.threads[id].name+("  · 未读%d"%count if count else ""));selector.set_item_metadata(index,id)
  if id==thread_id:selector.select(index)
  index+=1
 for child in transcript.get_children():transcript.remove_child(child);child.queue_free()
 var messages=MessageManager.get_thread_messages(thread_id)
 for message in messages:add_bubble(message)
 for child in reply_row.get_children():reply_row.remove_child(child);child.queue_free()
 var reply=MessageManager.waiting_reply(thread_id)
 if not reply.is_empty():
  reply_row.add_child(Kit.label("选择回复",16))
  for choice in reply.choices:
   var key: String=choice.id;var id: String=reply.id
   reply_row.add_child(Kit.button(choice.text,func():MessageManager.choose_reply(id,key)))
 if should_follow:
  for message in messages:
   if is_visible_in_tree():MessageManager.mark_read(thread_id,[message.id])
  settle_scroll(generation,0,true)
 else:settle_scroll(generation,old_scroll,false)
 last_count=messages.size()
func settle_scroll(generation: int,value: int,follow: bool) -> void:
 await get_tree().process_frame
 await get_tree().process_frame
 if not is_inside_tree() or generation!=layout_generation:return
 scroll.scroll_vertical=int(scroll.get_v_scroll_bar().max_value) if follow else value
 follow_bottom=follow;layout_busy=false
func add_bubble(message: Dictionary) -> void:
 var own=message.sender_id=="player"
 var row=HBoxContainer.new();row.size_flags_horizontal=SIZE_EXPAND_FILL;transcript.add_child(row)
 var spacer=Control.new();spacer.size_flags_horizontal=SIZE_EXPAND_FILL
 if own:row.add_child(spacer)
 var icon=TextureRect.new();icon.custom_minimum_size=Vector2(34,52);icon.expand_mode=TextureRect.EXPAND_IGNORE_SIZE;icon.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED;icon.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
 icon.texture=load(MessageManager.catalog.contacts[message.sender_id].avatar)
 if not own:row.add_child(icon)
 var bubble=PanelContainer.new();bubble.size_flags_horizontal=SIZE_EXPAND_FILL
 var style=StyleBoxFlat.new();style.bg_color=Color("405b63" if own else "2f3e50");style.border_color=Color("71858d");style.set_border_width_all(1)
 for side in ["left","right","top","bottom"]:style.set("content_margin_"+side,8)
 bubble.add_theme_stylebox_override("panel",style);row.add_child(bubble)
 var col=VBoxContainer.new();bubble.add_child(col)
 var title=Kit.label(MessageManager.catalog.contacts[message.sender_id].name+" · "+MessageManager.format_time(int(message.sent_at)),13);title.add_theme_color_override("font_color",Color("bdc7c7"));col.add_child(title)
 var text=Kit.label(message.text,18);text.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;text.custom_minimum_size.x=120;text.size_flags_horizontal=SIZE_EXPAND_FILL;col.add_child(text)
 for attachment in message.attachments:
  if not str(attachment).begins_with("res://assets/"):continue
  var image=TextureRect.new();image.texture=load(attachment);image.custom_minimum_size=Vector2(100,100);image.expand_mode=TextureRect.EXPAND_IGNORE_SIZE;image.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED;col.add_child(image)
 if own:row.add_child(icon)
 else:row.add_child(spacer)
func on_reveal(message: Dictionary) -> void:
 if message.thread_id!=thread_id or muted or not is_visible_in_tree():return
 notification_audio.play()
