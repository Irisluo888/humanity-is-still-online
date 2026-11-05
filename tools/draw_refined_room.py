from pathlib import Path
import ast, math, random, struct, zlib
# Reuse only the project's local drawing primitives, never execute its asset writes.
source=ast.parse(Path('tools/draw_third_round_assets.py').read_text(encoding='utf-8'))
primitives=ast.Module(body=[n for n in source.body if isinstance(n,(ast.ClassDef,ast.FunctionDef)) and n.name in ('Canvas','c','poly','ellipse')],type_ignores=[])
OUT=Path('assets/art/refined'); OUT.mkdir(parents=True,exist_ok=True)
exec(compile(primitives,'local_pixel_primitives','exec'))
ink=c('202735'); edge=c('394354'); wood=c('806750'); gold=c('bd986c'); cream=c('d3c3a2'); blue=c('536c80'); skin=c('c69c80'); hair=c('292b38')
a=Canvas(640,360,c('17232e'))
def P(u,v,z=0):return (round(320+u-v),round(104+(u+v)/2-z))
def face(points,color):poly(a,[P(*p) for p in points],color)
def line(p,q,color):a.line(*P(*p),*P(*q),color)
def block(u,v,w,d,h,z=0,top='877158',left='655546',right='514941'):
 face([(u,v,z+h),(u+w,v,z+h),(u+w,v+d,z+h),(u,v+d,z+h)],c(top))
 face([(u,v+d,z),(u+w,v+d,z),(u+w,v+d,z+h),(u,v+d,z+h)],c(left))
 face([(u+w,v,z),(u+w,v+d,z),(u+w,v+d,z+h),(u+w,v,z+h)],c(right))
 line((u,v+d,z+h),(u+w,v+d,z+h),gold)
def top_line(u,v,w,d,z,color):line((u,v,z),(u+w,v+d,z),color)
# Cutaway walls and floor: one consistent 2:1 isometric grid.
face([(0,0,0),(0,220,0),(0,220,92),(0,0,92)],c('454856'))
face([(0,0,0),(220,0,0),(220,0,92),(0,0,92)],c('354452'))
face([(0,0,0),(220,0,0),(220,220,0),(0,220,0)],c('716355'))
for v in range(0,220,11):
 line((0,v,0),(220,v,0),c('4d4845'))
 line((0,v+1,0),(220,v+1,0),c('89745b'))
 for u in range((v%22)*2,220,44):line((u,v,0),(u,min(v+11,220),0),c('514b47'))
 for u in range(8,210,39):line((u,v+5,0),(u+17,v+5,0),c('7e6c56'))
# Worn plaster, skirting and window city seen through glass.
for z in [1,4]:
 line((0,0,z),(0,220,z),wood);line((0,0,z),(220,0,z),wood)
r=random.Random(42)
for i in range(400):
 u=r.randrange(3,217);z=r.randrange(8,90)
 x,y=P(0,u,z);a.dot(x,y,c('4d4f5b'))
 x,y=P(u,0,z);a.dot(x,y,c('3d4c58'))
face([(96,0,36),(205,0,36),(205,0,88),(96,0,88)],ink)
face([(100,0,40),(201,0,40),(201,0,84),(100,0,84)],c('263e53'))
for u,width,height in [(102,18,29),(123,24,38),(151,16,25),(172,26,35)]:
 face([(u,0,41),(u+width,0,41),(u+width,0,41+height),(u,0,41+height)],c('354b60'))
 for xx in range(u+3,u+width-2,6):
  for zz in range(45,41+height-3,8):
   face([(xx,0,zz),(xx+2,0,zz),(xx+2,0,zz+4),(xx,0,zz+4)],gold if (xx+zz)%4==0 else blue)
for u in range(104,200,9):line((u,0,79),(u-3,0,72),c('6e8693'))
for u in [98,149,203]:line((u,0,37),(u,0,86),c('98a09b'));line((u+2,0,37),(u+2,0,86),ink)
line((98,0,61),(203,0,61),ink)
block(94,0,113,7,3,34,top='8c8270')
# Window blind roll and pull chain.
block(94,0,113,5,4,86,top='8c9393',left='687780')
for z in range(50,85,3):x,y=P(210,0,z);a.dot(x,y,cream)
# Wardrobe with open hanging compartment and folded clothes.
block(4,164,39,51,76,top='655d55',left='45434a',right='343640')
face([(6,215,8),(40,215,8),(40,215,72),(6,215,72)],c('292d37'))
for z in [8,29,70]:line((6,215,z),(40,215,z),wood)
line((8,216,64),(38,216,64),c('929999'))
for u,col in [(12,'667a83'),(23,'9a765d'),(32,'586573')]:
 face([(u-4,216,58),(u,216,62),(u+5,216,58),(u+6,216,35),(u-4,216,35)],c(col))
 line((u,216,61),(u,216,38),c('89918e'))
for z,col in [(12,'6d7682'),(17,'918477'),(22,'596a76')]:
 face([(11,216,z),(34,216,z),(34,216,z+4),(11,216,z+4)],c(col))
# Narrow sliding door with grooves.
face([(30,217,4),(43,217,4),(43,217,74),(30,217,74)],c('756557'))
for u in [32,35,38,41]:line((u,217,6),(u,217,72),c('8b7863'))
line((32,218,37),(32,218,45),cream)
# Bed: legs, frame, mattress, rumpled quilt, pillow and folded blanket.
for u,v in [(133,20),(205,20),(133,143),(205,143)]:block(u,v,4,4,12,top='685448')
block(130,17,82,133,17,8,top='584e48',left='4b4140',right='3b3840')
block(130,17,82,5,42,8,top='806852')
for u in range(137,207,12):line((u,23,29),(u,23,47),gold)
block(133,24,76,121,8,25,top='a4a398',left='7d898e',right='657985')
face([(134,55,34),(207,55,34),(209,145,34),(132,145,34)],c('586d7b'))
for u in range(139,207,7):
 line((u,60,35),(u-3,102,35),c('748794'));line((u-3,102,35),(u+2,138,35),c('485f70'))
for v in [72,91,112,133]:line((134,v,35),(207,v+4,35),c('647b87'))
block(146,29,49,21,4,34,top='b5b7ac',left='939e9d',right='7a8e96')
for u in [149,190]:line((u,33,39),(u+2,45,39),cream)
face([(133,123,36),(208,123,36),(208,143,36),(133,143,36)],c('8a7774'))
for v in range(126,143,4):line((134,v,37),(207,v,37),c('a49083'))
# Desk with actual leg structure and drawer bank.
for u,v in [(15,102),(95,102),(15,151),(95,151)]:block(u,v,4,4,41,top='7c6854')
block(15,102,84,54,4,41,top='998063',left='6d594b',right='5e5149')
for v in range(105,156,7):line((19,v,46),(94,v,46),c('a68c69'))
block(72,106,23,43,29,9,top='79644f',left='685644',right='534b43')
for z in [18,28,38]:
 line((74,150,z),(94,150,z),ink);line((82,151,z+4),(88,151,z+4),gold)
# CRT, keyboard and mouse; all share furniture projection.
block(30,109,37,22,25,46,top='b6b09a',left='9e9f90',right='6d817f')
face([(34,132,50),(63,132,50),(63,132,67),(34,132,67)],ink)
face([(36,133,52),(61,133,52),(61,133,65),(36,133,65)],c('426a75'))
for z in [55,58,61]:line((39,134,z),(54,134,z),c('90b8ae'))
line((39,134,63),(58,134,63),cream)
x,y=P(63,133,48);a.dot(x,y,c('d6b67a'))
block(27,138,37,12,2,46,top='a5a69b',left='737f81')
for u in range(30,62,4):
 for v in range(140,148,3):line((u,v,49),(u+2,v,49),c('596f77'))
block(70,138,17,14,1,46,top='455b69')
block(74,142,6,8,3,47,top='b5b9af')
line((77,142,51),(77,144,51),ink)
line((77,138,48),(74,125,46),ink)
# Desktop notebook, pen mug, paper slips and trailing cables.
block(17,123,10,15,1,46,top='c7b99a')
for v in range(125,135,3):line((19,v,48),(25,v,48),c('8c8170'))
block(86,111,7,7,9,46,top='c4ae88',left='987d61')
for u in [87,89,91]:line((u,114,53),(u-1,114,62),blue)
line((50,110,45),(50,106,17),ink);line((50,106,17),(65,103,3),ink)
# Chair, wheeled base and cloth draped over seat.
block(45,166,27,23,4,23,top='667a83',left='455c6b')
block(45,186,27,4,25,25,top='7c8c90',left='4f6777')
line((58,176,24),(58,176,5),ink)
for du,dv in [(-14,0),(14,0),(0,-14),(0,14)]:
 line((58,176,5),(58+du,176+dv,2),edge);block(56+du,174+dv,4,4,3,top='252d37')
# Wall shelves with books, radio, jars, hanging headphones and original framed print.
for z in [56,78]:
 block(0,64,13,63,3,z,top='967b5d',left='66584a')
 for v in [72,115]:line((0,v,z-10),(12,v,z),ink)
 for v in range(70,119,7):
  block(2,v,8,5,10+(v%3)*2,z+3,top='a29b83',left=['607789','9d7e65','778779'][v%3],right='45525c')
block(2,119,8,12,7,59,top='92968b',left='3d4c5d')
# Small wall pinboard, personal original receipts (no brands).
face([(0,137,52),(0,159,52),(0,159,76),(0,137,76)],c('9e8060'))
for v,z in [(140,69),(150,64),(143,56)]:
 face([(0,v,z),(0,v+7,z),(0,v+7,z+7),(0,v,z+7)],cream)
# Woven floor rug and slippers.
face([(98,159,1),(168,159,1),(168,208,1),(98,208,1)],c('52606a'))
for v in range(162,208,4):line((100,v,2),(166,v,2),c('778287'))
for u in [106,157]:line((u,161,2),(u,207,2),c('b09b7e'))
for u,v in [(105,187),(113,192)]:block(u,v,6,12,3,2,top='a18d79',left='685951')
# Box by wardrobe, taped seam and stitched delivery bag.
block(61,205,29,26,23,top='9d7c56',left='7b624c',right='5d5147')
line((75,206,24),(75,230,24),cream)
for z in [6,17]:line((64,232,z),(86,232,z),gold)
# Bedside crate with a ceramic cup, folded towel and leafy plant.
block(166,3,25,16,19,top='937b62',left='685949',right='574d45')
block(171,6,9,8,9,20,top='9c8d70',left='87745d')
for u,v,z in [(168,5,42),(181,6,40),(174,9,47),(186,10,36)]:
 line((176,10,28),(u,v,z),c('526c60'))
 x,y=P(u,v,z);ellipse(a,x-4,y-2,8,4,c('718775'))
# Radiator under the back wall, pipe and drying cloth.
block(24,2,43,6,25,3,top='8b9291',left='687a82',right='4b606f')
for u in range(27,65,5):line((u,9,5),(u,9,26),c('9aa39e'))
line((23,4,7),(16,4,7),wood);line((16,4,7),(16,4,1),wood)
face([(33,9,27),(50,9,27),(50,9,14),(33,9,14)],c('a99b8c'))
for u in [36,41,46]:line((u,10,16),(u,10,25),cream)
# Laundry basket woven in perspective, with rumpled clothes.
block(91,34,22,22,18,top='8d806c',left='6b635b',right='55545a')
for z in range(3,18,4):line((92,57,z),(112,57,z),gold)
for u in range(94,113,4):line((u,57,1),(u,57,18),c('9a8b75'))
face([(92,36,20),(101,34,23),(105,41,22),(111,40,20),(109,52,20),(94,52,21)],c('788491'))
# Helmet resting on the delivery box, with visor, vents and chin strap.
x,y=P(75,218,25)
ellipse(a,x-9,y-12,19,13,c('879b9f'));a.line(x-8,y-3,x+10,y-3,cream)
a.line(x-6,y-10,x+4,y-11,c('b7c1b7'));a.rect(x-3,y-9,3,1,ink);a.rect(x+3,y-8,3,1,ink)
a.line(x-7,y-1,x-2,y+4,ink);a.line(x-2,y+4,x+5,y-1,ink)
# Desk lamp: narrow stem, shade and warm illuminated tabletop.
line((90,126,46),(90,126,73),ink);line((90,126,73),(82,128,78),gold)
block(77,124,12,10,5,73,top='bd9a68',left='d0aa70',right='977755')
# Warm light is baked and quantized, restricted to surfaces and avoiding sky/background.
for y in range(80,285):
 for x in range(110,355):
  d=((x-237)/104)**2+((y-166)/80)**2
  if d<1 and a.p[y*640+x][3] and a.p[y*640+x]!=c('17232e'):
   strength=(1-d)*.24
   old=a.p[y*640+x]; target=(227,170,103)
   a.p[y*640+x]=tuple(min(255,round((old[k]*(1-strength)+target[k]*strength)/4)*4) for k in range(3))+(255,)
# Subtle material dithering only, preserving object edges.
for y in range(360):
 for x in range(640):
  col=a.p[y*640+x]
  if col in [c('716355'),c('586d7b'),c('998063')] and (x+3*y)%13==0:
   a.dot(x,y,tuple(min(255,v+5) for v in col[:3])+(255,))
a.save('bedroom.png')
# Same adult woman in uniform and home clothes, 48x96, shared head, body and garment proportions.
for uniform in [True,False]:
 a=Canvas(48,96,(0,0,0,0))
 def pp(points,col):poly(a,points,c(col))
 if uniform:
  pp([(28,29),(42,31),(44,57),(29,59)],'8a7158')
  a.rect(30,34,12,3,gold);a.line(37,35,38,55,cream);a.line(30,53,42,55,ink)
 # Asymmetric low ponytail silhouette.
 pp([(18,7),(29,7),(32,12),(30,22),(27,26),(15,24),(12,17),(14,10)],'252938')
 pp([(15,20),(12,25),(11,34),(15,31),(18,22)],'34313e')
 pp([(18,13),(28,13),(29,20),(26,25),(21,24),(18,21)],'c8a087')
 a.line(27,17,28,20,c('a57868'));a.rect(22,24,4,4,skin)
 a.line(19,15,22,14,hair);a.line(25,14,28,15,hair)
 a.dot(21,17,ink);a.dot(27,17,ink);a.line(23,22,25,22,c('906a61'))
 pp([(16,11),(28,10),(29,13),(22,13),(18,17),(16,20)],'35313e')
 jacket='657f89' if uniform else '8c7c79';shadow='435b6b' if uniform else '665e6b';light='91a5a4' if uniform else 'ab9990'
 pp([(18,27),(22,28),(26,27),(31,30),(32,40),(29,50),(31,57),(16,57),(17,48),(15,34)],shadow)
 pp([(19,29),(23,31),(27,28),(29,32),(28,49),(30,54),(18,54),(20,44)],jacket)
 pp([(15,31),(19,33),(17,45),(14,55),(10,54),(11,45)],jacket)
 pp([(30,31),(33,35),(34,48),(37,54),(33,57),(29,47)],shadow)
 a.rect(11,54,3,6,skin);a.rect(33,56,3,5,skin)
 a.line(13,44,16,46,c(light));a.line(29,38,31,42,c(light))
 a.line(21,31,23,52,c(light));a.line(18,50,22,48,c(shadow));a.line(25,49,28,51,c(shadow))
 if uniform:
  a.line(17,38,28,38,cream);a.rect(17,34,4,2,gold)
  a.line(16,31,19,52,ink);a.line(29,30,27,48,ink)
  pp([(13,10),(16,5),(26,4),(31,7),(33,13),(14,14)],'758c94')
  a.line(16,8,28,7,c('a8b6af'));a.line(14,13,32,13,cream)
  a.rect(19,6,4,1,ink);a.rect(26,7,3,1,ink)
  a.line(16,15,20,25,edge);a.line(29,15,26,25,edge)
 # Narrow hips, distinct knees, weight shifted to the right leg.
 pp([(17,55),(24,56),(23,72),(21,87),(16,87),(16,72)],'384455')
 pp([(24,56),(30,55),(30,70),(33,87),(27,88),(25,74)],'2d3647')
 a.line(19,59,19,70,c('637082'));a.line(19,73,18,84,c('4f5e73'))
 a.line(27,60,28,70,c('4f5e73'));a.line(28,75,30,85,c('596a7c'))
 pp([(16,86),(21,86),(22,91),(12,91),(12,89)],'a7afa7' if uniform else 'a78f78')
 pp([(27,87),(33,86),(37,90),(36,92),(27,92)],'a7afa7' if uniform else 'a78f78')
 a.line(12,92,22,92,ink);a.line(27,93,37,93,ink)
 for x,y in [(16,88),(18,89),(29,89),(31,90)]:a.rect(x,y,2,1,cream)
 a.save('rider_uniform.png' if uniform else 'rider_home.png')
print('Generated three refined original PNGs; prior assets preserved.')
