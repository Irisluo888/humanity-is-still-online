extends RefCounted
const INK=Color("493b58")
const MUTED=Color("8a7799")
const ACCENT=Color("bb568c")
static func style(color: Color,radius=16,padding=12) -> StyleBoxFlat:
 var s=StyleBoxFlat.new();s.bg_color=color;s.set_corner_radius_all(radius);s.border_color=Color("ffffff99");s.set_border_width_all(1)
 s.shadow_color=Color("80619a15");s.shadow_size=4;s.shadow_offset=Vector2(0,2)
 s.content_margin_left=padding;s.content_margin_right=padding;s.content_margin_top=padding;s.content_margin_bottom=padding
 return s
static func label(text: String,sz=17,color=INK) -> Label:
 var l=Label.new();l.text=text;l.add_theme_font_size_override("font_size",sz);l.add_theme_color_override("font_color",color);return l
static func button(text: String,fn: Callable) -> Button:
 var b=Button.new();b.text=text;b.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART if text.length()>20 else TextServer.AUTOWRAP_OFF;b.custom_minimum_size.y=32;b.add_theme_font_size_override("font_size",15)
 for state in ["normal","hover","pressed","focus","disabled"]:
  b.add_theme_stylebox_override(state,style(Color("e4d5ef") if state in ["hover","pressed"] else Color("ffffff66"),12,8))
  b.add_theme_color_override("font_color" if state=="normal" else "font_"+state+"_color",INK)
 b.add_theme_color_override("font_hover_pressed_color",INK)
 b.pressed.connect(fn);return b
static func avatar(id: String,extent=46) -> PanelContainer:
 var paths={"player":"refined/rider_uniform", "xiaoyu":"ch01/xiaoyu", "zhou":"ch01/zhou", "aqiang":"avatars/avatar_3", "laoma":"avatars/avatar_4", "chen":"ch01/chen", "lin":"ch01/lin"}
 var frame=PanelContainer.new();frame.custom_minimum_size=Vector2(extent,extent);frame.size_flags_vertical=Control.SIZE_SHRINK_BEGIN;frame.size_flags_horizontal=Control.SIZE_SHRINK_BEGIN
 frame.add_theme_stylebox_override("panel",style(Color("d8cde7"),12,3));frame.mouse_filter=Control.MOUSE_FILTER_IGNORE
 if paths.has(id):
  var atlas=load("res://assets/art/phone_portraits/"+id+".tres")
  var pic=TextureRect.new();pic.texture=atlas;pic.expand_mode=TextureRect.EXPAND_IGNORE_SIZE;pic.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED;pic.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST;pic.mouse_filter=Control.MOUSE_FILTER_IGNORE;frame.add_child(pic)
 else:
  var icon=preload("res://ui/phone/avatar_icon.gd").new();icon.notification=id=="system";frame.add_child(icon)
 return frame
static func wrap(text: String,sz=16,color=INK) -> Label:
 var l=label(text,sz,color);l.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;l.size_flags_horizontal=Control.SIZE_EXPAND_FILL;return l
