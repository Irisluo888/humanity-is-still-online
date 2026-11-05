extends Control
# Original vector enamel heart and silver orbit; decorative, no input capture.
func _ready():
 custom_minimum_size=Vector2(82,42);mouse_filter=MOUSE_FILTER_IGNORE
func _draw():
 var points=PackedVector2Array()
 for i in range(65):
  var t=TAU*i/64.0
  points.append(Vector2(40+pow(sin(t),3)*17,21-(13*cos(t)-5*cos(2*t)-2*cos(3*t)-cos(4*t))*1.1))
 for radius in [5,3,1]:draw_polyline(points,Color(1,.8,.94,.09),radius*2,true)
 draw_colored_polygon(points,Color("ecd4ef"));draw_polyline(points,Color("fff8ff"),1.5,true)
 draw_arc(Vector2(40,22),26,-.45,2.6,40,Color("b5a7c6"),1,true)
 draw_arc(Vector2(37,19),28,2.7,5.9,40,Color("ffffff99"),1,true)
 for origin in [Vector2(12,10),Vector2(70,28)]:
  draw_line(origin-Vector2(4,0),origin+Vector2(4,0),Color.WHITE,1,true);draw_line(origin-Vector2(0,5),origin+Vector2(0,5),Color.WHITE,1,true)
