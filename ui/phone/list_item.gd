extends Button
const P=preload("res://ui/phone/palette.gd")
func setup(id: String,title: String,preview: String,time_text="",unread=0):
 custom_minimum_size.y=76;size_flags_horizontal=SIZE_EXPAND_FILL
 add_theme_stylebox_override("normal",P.style(Color("ffffff55"),14,0));add_theme_stylebox_override("hover",P.style(Color("ffffffaa"),14,0));add_theme_stylebox_override("pressed",P.style(Color("e6d1ea"),14,0))
 var row=HBoxContainer.new();row.set_anchors_and_offsets_preset(PRESET_FULL_RECT);row.offset_left=10;row.offset_right=-10;row.offset_top=11;row.offset_bottom=-11;row.add_theme_constant_override("separation",10);add_child(row)
 row.add_child(P.avatar(id,48));var col=VBoxContainer.new();col.size_flags_horizontal=SIZE_EXPAND_FILL;row.add_child(col)
 var name_label=P.label(title,17);name_label.text_overrun_behavior=TextServer.OVERRUN_TRIM_ELLIPSIS;col.add_child(name_label)
 var snippet=P.label(preview,13,P.MUTED);snippet.text_overrun_behavior=TextServer.OVERRUN_TRIM_ELLIPSIS;col.add_child(snippet)
 var end=VBoxContainer.new();row.add_child(end);end.add_child(P.label(time_text,11,P.MUTED))
 if unread>0:
  var badge=P.label(str(unread) if unread<100 else "99+",12,Color.WHITE);badge.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;badge.size_flags_horizontal=SIZE_SHRINK_END;badge.custom_minimum_size=Vector2(22,22);badge.add_theme_stylebox_override("normal",P.style(Color("d9668b"),11,2));end.add_child(badge)
 else:end.add_child(P.label("›",20,P.MUTED))
 ignore_children(row)
func ignore_children(node):
 if node is Control:node.mouse_filter=Control.MOUSE_FILTER_IGNORE
 for child in node.get_children():ignore_children(child)
func arrival():
 modulate=Color("eecce8");create_tween().tween_property(self,"modulate",Color.WHITE,.45)
