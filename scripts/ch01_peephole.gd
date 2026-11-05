extends Control
const ZHOU=preload("res://assets/art/ch01/zhou.png")
var revealed=false
var stage=0
func _ready() -> void:mouse_filter=MOUSE_FILTER_IGNORE;texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST;queue_redraw()
func _draw() -> void:
 draw_set_transform(Vector2.ZERO)
 draw_rect(Rect2(0,0,700,550),Color("121823"))
 draw_rect(Rect2(90,40,520,460),Color("3e4658" if stage>=4 or revealed else "283141"))
 for x in range(90,610,16):
  draw_line(Vector2(x,40),Vector2(350+(x-350)*2,500),Color("495268"),1)
 draw_rect(Rect2(140,120,110,290),Color("232a37"))
 draw_rect(Rect2(450,120,90,290),Color("29303d"))
 draw_rect(Rect2(335,75,40,12),Color("ab9870"))
 # Original anonymous raincoat silhouette, deliberately no face until reveal.
 draw_polygon(PackedVector2Array([Vector2(290,230),Vector2(310,180),Vector2(340,155),Vector2(372,155),Vector2(400,190),Vector2(413,240),Vector2(430,445),Vector2(280,445)]),PackedColorArray([Color("182733")]))
 draw_rect(Rect2(316,445,24,50),Color("17202a"));draw_rect(Rect2(368,445,24,50),Color("17202a"))
 if stage>=4 or revealed:draw_rect(Rect2(295,345,10,25),Color("804e4c"))
 if revealed:
  draw_texture_rect_region(ZHOU,Rect2(326,190,60,72),Rect2(13,3,24,27))
 # Dark circular peephole rim; four-corner occlusion is intentional.
 for i in range(96):
  var a=TAU*i/96.0;var b=TAU*(i+1)/96.0
  var center=Vector2(350,275)
  draw_polygon(PackedVector2Array([center+Vector2(cos(a),sin(a))*250,center+Vector2(cos(b),sin(b))*250,center+Vector2(cos(b),sin(b))*700,center+Vector2(cos(a),sin(a))*700]),PackedColorArray([Color("111722")]))
