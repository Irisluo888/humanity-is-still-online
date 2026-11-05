extends Control
var mode="bike"
var elapsed=0.0
func _ready():
 mouse_filter=MOUSE_FILTER_IGNORE
 texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
func _process(delta):
 elapsed+=delta;queue_redraw()
func rect(x,y,w,h,color):draw_rect(Rect2(x,y,w,h),Color(color))
func poly(points,color):draw_colored_polygon(PackedVector2Array(points),Color(color))
func _draw():
 draw_set_transform(Vector2.ZERO,0,Vector2(3,3))
 rect(0,0,200,96,"111d2c");rect(2,2,196,92,"475766");rect(4,4,192,88,"253746")
 if mode=="bike":
  draw_texture_rect(preload("res://assets/art/ch01/delivery_scooter.png"),Rect2(18+sin(elapsed*35)*maxf(0,1-elapsed/2),4,130,85),false)
  rect(143,15,40,19,"17232c");rect(147,19,30,11,"6d302d")
  for x in range(147,178,6):rect(x,21,3,7,"d59058" if int(elapsed*6)%2==0 else "4c3936")
  draw_line(Vector2(126,61),Vector2(151,70),Color("bb9b6a"),2)
  draw_line(Vector2(159,72),Vector2(183,61),Color("748593"),2)
  if elapsed<2.5 and int(elapsed*12)%2==0:
   for off in [Vector2(-5,-9),Vector2(5,-5),Vector2(0,7)]:draw_line(Vector2(154,70)+off,Vector2(154,70)+off*1.7,Color("efc779"),2)
 else:
  # Light shirt cuff and the same dark-red cuff stain as the elevator character.
  var gap=lerpf(31,7,clampf(elapsed/1.3,0,1))
  rect(5,5,91-gap,86,"879397");rect(104+gap,5,91-gap,86,"7c898f")
  for x in range(10,190,7):
   if x<96-gap or x>104+gap:rect(x,8,1,80,"94a0a0")
  rect(94-gap,5,3,86,"26333d");rect(103+gap,5,3,86,"26333d")
  poly([Vector2(145,91),Vector2(134,69),Vector2(119,60),Vector2(107,48),Vector2(98,43),Vector2(91,46),Vector2(91,54),Vector2(103,63),Vector2(104,72),Vector2(115,80),Vector2(123,91)],"745d56")
  poly([Vector2(140,91),Vector2(130,72),Vector2(115,64),Vector2(105,51),Vector2(98,47),Vector2(95,49),Vector2(97,53),Vector2(109,61),Vector2(108,70),Vector2(119,77),Vector2(129,91)],"c09b82")
  rect(99,49,4,2,"dfb99a");rect(107,59,5,2,"94725f")
  poly([Vector2(123,77),Vector2(142,69),Vector2(164,91),Vector2(131,91)],"c2c3b5")
  draw_line(Vector2(126,79),Vector2(145,72),Color("e0dcc5"),3)
  rect(135,80,5,3,"724a43");rect(138,83,4,5,"69463f");rect(146,87,2,3,"7d4d42")
  if elapsed>1.3:
   draw_line(Vector2(101,47),Vector2(103,60),Color("4c3231"),2)
   for y in [25,32]:draw_line(Vector2(96,y),Vector2(91,y-4),Color("d4be8f"),1)
 draw_set_transform(Vector2.ZERO)
