extends Control
var notification=false
func _ready():mouse_filter=MOUSE_FILTER_IGNORE
func _draw():
 var k=minf(size.x,size.y)/40.0
 draw_set_transform(Vector2.ZERO,0,Vector2(k,k))
 if notification:
  draw_arc(Vector2(20,19),10,PI,TAU,24,Color("89779f"),2,true)
  draw_line(Vector2(10,19),Vector2(8,29),Color("89779f"),2,true);draw_line(Vector2(30,19),Vector2(32,29),Color("89779f"),2,true)
  draw_line(Vector2(8,29),Vector2(32,29),Color("89779f"),2,true);draw_circle(Vector2(20,33),2,Color("bb568c"));draw_circle(Vector2(20,7),2,Color("bb568c"))
 else:
  draw_circle(Vector2(14,18),10,Color("f5ecf8"));draw_circle(Vector2(27,23),10,Color("e3b3d3"))
  draw_arc(Vector2(14,18),10,PI,TAU,24,Color("89779f"),2,true);draw_arc(Vector2(27,23),10,PI,TAU,24,Color("89779f"),2,true)
  draw_line(Vector2(6,18),Vector2(22,18),Color("a7a9c0"),3,true);draw_line(Vector2(19,23),Vector2(35,23),Color("a7a9c0"),3,true)
  draw_line(Vector2(14,9),Vector2(14,14),Color.WHITE,2);draw_line(Vector2(27,14),Vector2(27,19),Color.WHITE,2)
