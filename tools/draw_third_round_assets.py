from pathlib import Path
import zlib,struct,random,math
OUT=Path('assets/art/environment'); OUT.mkdir(parents=True,exist_ok=True)
class Canvas:
 def __init__(self,w,h,bg): self.w=w; self.h=h; self.p=[bg]*(w*h)
 def dot(self,x,y,c):
  if 0<=x<self.w and 0<=y<self.h:self.p[y*self.w+x]=c
 def rect(self,x,y,w,h,c):
  for j in range(y,y+h):
   for i in range(x,x+w):self.dot(i,j,c)
 def line(self,x,y,a,b,c):
  n=max(abs(a-x),abs(b-y),1)
  for i in range(n+1):self.dot(round(x+(a-x)*i/n),round(y+(b-y)*i/n),c)
 def save(self,name):
  def chunk(t,d):return struct.pack('>I',len(d))+t+d+struct.pack('>I',zlib.crc32(t+d)&0xffffffff)
  raw=b''.join(b'\0'+bytes(sum((list(v) for v in self.p[y*self.w:(y+1)*self.w]),[])) for y in range(self.h))
  (OUT/name).write_bytes(b'\x89PNG\r\n\x1a\n'+chunk(b'IHDR',struct.pack('>IIBBBBB',self.w,self.h,8,6,0,0,0))+chunk(b'IDAT',zlib.compress(raw))+chunk(b'IEND',b''))
def c(s):return tuple(bytes.fromhex(s))+(255,)
ink=c('1b2333'); blue=c('394a60'); slate=c('566a7d'); warm=c('cb9565'); pale=c('b8c3c6'); white=c('e1ded4'); transparent=(0,0,0,0)
def city(seed,w=320,h=180):
 r=random.Random(seed); a=Canvas(w,h,c('293b52'))
 for layer in range(3):
  for x in range(-5,w,35+layer*22):
   top=r.randint(12+layer*15,55+layer*15); width=r.randint(27,42)
   a.rect(x,top,width,h-top,[c('374b60'),c('2c3b50'),ink][layer])
   a.rect(x-1,top,width+2,2,slate)
   for xx in range(x+4,x+width-2,6):
    for yy in range(top+7,h-15,9):
     a.rect(xx,yy,2,4,warm if r.random()<.12 else blue)
   for yy in range(top+10,h,20):a.line(x,yy,x+width,yy,c('263246'))
 for i in range(w*h//180):
  x=r.randrange(w);y=r.randrange(h);a.line(x,y,x-1,y+3,c('60778a'))
 for x in range(w):
  y=int(h*.6+math.sin(x/w*3)*8);a.dot(x,y,ink);a.dot(x,y+1,ink)
 return a

def poly(a,pts,col):
 for y in range(max(0,min(p[1] for p in pts)),min(a.h,max(p[1] for p in pts)+1)):
  intersections=[]
  for k in range(len(pts)):
   x1,y1=pts[k];x2,y2=pts[(k+1)%len(pts)]
   if (y1<=y<y2) or (y2<=y<y1):intersections.append(round(x1+(y-y1)*(x2-x1)/(y2-y1)))
  intersections.sort()
  for k in range(0,len(intersections)-1,2):a.rect(intersections[k],y,intersections[k+1]-intersections[k]+1,1,col)
def ellipse(a,x,y,w,h,col):
 for yy in range(y,y+h):
  for xx in range(x,x+w):
   if ((xx-x-w/2)/(w/2))**2+((yy-y-h/2)/(h/2))**2<=1:a.dot(xx,yy,col)
def scene(seed):
 r=random.Random(seed);a=Canvas(640,360,c('263a50'))
 for y in range(180):
  for x in range(640):
   if (x+y)%4==0:a.dot(x,y,c('2b4055'))
 # Sparse distant roofline at the vanishing point.
 for x,w,top in [(212,23,78),(242,30,55),(278,18,92),(303,28,65),(345,35,87),(388,22,60)]:
  a.rect(x,top,w,160-top,c('354d62'))
  for xx in range(x+4,x+w,7):
   for yy in range(top+8,155,11):a.rect(xx,yy,2,3,c('687b84'))
 poly(a,[(0,231),(292,158),(365,158),(640,252),(640,360),(0,360)],c('25303e'))
 # Asymmetric old buildings with pitched roofs, masonry, shutters, air units.
 for side in [0,1]:
  buildings=[(0,20,125,243),(127,74,86,160),(215,116,53,93)] if side==0 else [(468,37,172,220),(401,94,65,103),(366,125,34,55)]
  for idx,(x,y,w,h) in enumerate(buildings):
   a.rect(x,y,w,h,c('263044') if idx==0 else c('344254'))
   poly(a,[(x-7,y),(x+w//2,y-22),(x+w+6,y+2)],ink)
   a.rect(x,y+3,w,3,c('506071'))
   for yy in range(y+15,y+h-5,16):
    a.line(x,yy,x+w,yy,c('3d4859'))
    for xx in range(x+(yy%32),x+w,26):a.line(xx,yy,xx,yy+5,c('3d4859'))
   gap=max(14,w//4)
   for xx in range(x+9,x+w-8,gap):
    for yy in range(y+17,y+h-24,31):
     a.rect(xx-2,yy-2,14,21,ink)
     lit=r.random()<.28
     a.rect(xx,yy,10,16,c('c68e61') if lit else c('425569'))
     a.line(xx+5,yy,xx+5,yy+16,ink);a.line(xx,yy+8,xx+10,yy+8,ink)
     a.rect(xx-3,yy+17,16,2,c('596572'))
   # Shop frontage and striped awning.
   if idx==0:
    a.rect(x+10,y+h-43,w-22,37,ink)
    for xx in range(x+14,x+w-18,20):a.rect(xx,y+h-39,16,28,c('a87959'))
    poly(a,[(x+3,y+h-49),(x+w-3,y+h-49),(x+w+6,y+h-39),(x-4,y+h-39)],c('59666c'))
    for xx in range(x+4,x+w,12):a.line(xx,y+h-48,xx+5,y+h-40,c('89908b'))
    a.rect(x+22,y+h-63,w-42,10,c('6f786f'))
    for xx in range(x+28,x+w-25,11):a.rect(xx,y+h-60,5,2,c('b5b5a0'))
   a.rect(x+w-19,y+50,13,10,c('79818a'))
   for yy in range(y+52,y+59,2):a.line(x+w-17,yy,x+w-8,yy,c('414e60'))
 # Perspective paving and gutter.
 for x in [-160,-30,90,190,400,500,650,800]:a.line(322,165,x,359,c('3c4b58'))
 for y in [199,226,263,315]:a.line(0,y,640,y,c('384956'))
 for i in range(100):
  x=r.randrange(640);y=r.randrange(207,353);a.line(x,y,x+r.randrange(2,15),y,c('566b76') if i%4 else c('997a60'))
 # Sagging electric wires.
 for off in [0,12]:
  for x in range(640):a.dot(x,int(88+off+math.sin(x/640*math.pi)*34),ink)
 # Street lamp and reflected light.
 a.rect(450,159,3,124,ink);a.line(451,160,436,160,slate);ellipse(a,431,158,13,5,warm)
 for y in range(278,340,4):a.rect(435-(y-278)//8,y,18+(y-278)//4,1,c('816b56'))
 # Bicycle wheels, frame and rear delivery crate.
 for x in [111,147]:
  ellipse(a,x,280,21,21,ink);ellipse(a,x+3,283,15,15,c('66767b'));ellipse(a,x+5,285,11,11,ink)
 a.line(121,290,135,271,warm);a.line(135,271,157,290,warm);a.line(121,290,157,290,warm)
 a.rect(141,256,21,17,c('8c6b53'));a.rect(143,258,17,2,c('d2a36d'));a.line(126,272,123,264,slate)
 # Localized rain instead of uniform tower noise.
 for i in range(420):
  x=r.randrange(640);y=r.randrange(350);a.line(x,y,x-1,y+3,c('5c7286'))
 return a
wall=scene(83)
# Foreground window frame and personal belongings.
wall.rect(0,0,9,360,ink);wall.rect(630,0,10,360,ink);wall.rect(0,330,640,30,c('493e3e'));wall.rect(0,330,640,3,c('8c6d56'))
for x in range(10,630,39):wall.line(x,343,x+28,343,c('665046'))
wall.rect(525,295,48,34,c('535e67'));wall.rect(528,298,42,2,c('929b9a'));wall.rect(534,292,30,4,c('b0aca0'))
wall.rect(573,304,9,15,c('939b98'));wall.rect(575,307,4,9,ink)
wall.rect(35,300,16,30,c('7b6558'))
for x,y in [(30,279),(48,275),(23,293),(58,290)]:
 wall.line(43,306,x,y,c('526d68'));ellipse(wall,x-7,y-3,13,6,c('61786c'))
wall.save('wallpaper.png')
for i in range(4):
 src=scene(83+i)
 # Different crops are not used; add distinct local subjects before downsampling.
 if i==1:
  src.rect(241,196,142,80,c('455969'));src.rect(245,200,134,8,warm)
  for x in range(248,376,23):src.rect(x,214,18,40,c('9d8366'))
 if i==2:
  src.rect(280,175,58,112,c('48565e'));src.rect(285,181,48,98,ink);src.rect(289,187,40,48,c('a18263'));src.rect(324,249,3,5,warm)
 if i==3:
  src.rect(256,218,100,58,c('7d5e49'));src.rect(258,220,96,4,warm);src.line(305,222,305,276,c('b29670'))
 dst=Canvas(320,180,ink)
 for y in range(180):
  for x in range(320):dst.dot(x,y,src.p[y*2*640+x*2])
 dst.save('thumb_%d.png'%i)
 if i<3:dst.save('video_%d.png'%i)
# Original avatar set: eight independently colored hair/clothing silhouettes.
for i in range(8):
 a=Canvas(32,32,c('4b596b'));hair=[c(v) for v in ['202638','624c45','86705a','343948','72575b','4b4844','9a8974','434e60']][i]
 ellipse(a,5,2,23,29,hair);ellipse(a,9,9,16,18,c('b78f78'));ellipse(a,11,10,13,16,c('d4ad8c'))
 for x in range(7,27):
  for y in range(5,11+((x+i*3)%7)//2):a.dot(x,y,hair)
 a.rect(11,17,3,2,ink);a.rect(21,17,2,2,ink);a.dot(12,17,white);a.dot(21,17,white);a.rect(17,24,3,1,c('926d63'))
 poly(a,[(7,31),(10,27),(14,26),(16,29),(21,26),(26,29),(28,31)],[slate,warm,c('667b6f'),c('7c6d7e'),c('8f7d63'),c('778b92'),c('75836d'),c('7f8898')][i])
 if i in [0,3,6]:a.rect(5,13,4,16,hair)
 if i==4:a.rect(9,16,16,1,slate)
 a.save('avatar_%d.png'%i)
# Isometric small room: cutaway, furniture and lived-in textiles.
a=Canvas(640,360,c('182331'))
poly(a,[(95,172),(330,70),(563,171),(330,286)],c('816b58'))
poly(a,[(95,55),(330,4),(330,140),(95,247)],c('465166'))
poly(a,[(330,4),(563,62),(563,247),(330,140)],c('343f54'))
poly(a,[(95,247),(330,140),(563,247),(330,354)],c('746251'))
for off in range(0,225,20):a.line(115+off,238-off//2,348+off,345-off//2,c('635349'))
# window on right wall, pale rain scene.
poly(a,[(378,40),(474,65),(474,153),(378,112)],ink)
poly(a,[(384,48),(467,69),(467,144),(384,108)],c('405c74'))
# Rain-night buildings inside the authored isometric window aperture.
for xx in range(385,467):
 top=49+(xx-384)*21//83
 bottom=107+(xx-384)*36//83
 roof=top+16+((xx-385)//12%3)*6
 for yy in range(roof,bottom):
  col=c('293c52') if (xx//12)%2 else c('344b61')
  if xx%12 in [4,5] and yy%11 in [3,4]:col=c('bd9168') if xx%5 else c('78909c')
  a.dot(xx,yy,col)
a.line(425,59,425,126,c('8b9399'));a.line(384,82,468,109,c('8b9399'))
for x,y in [(393,67),(445,93),(457,112),(405,91)]:a.line(x,y,x-2,y+10,c('7894a3'))
# wardrobe left wall
poly(a,[(113,111),(164,88),(164,223),(113,247)],c('322f38'))
poly(a,[(164,88),(188,99),(188,232),(164,223)],c('524b48'))
a.line(138,105,138,235,c('72645a'));a.rect(145,168,2,8,warm)
# bed at foreground right
poly(a,[(362,215),(454,175),(525,209),(433,254)],c('433a3c'))
poly(a,[(362,215),(433,254),(433,285),(362,246)],c('64504a'))
poly(a,[(433,254),(525,209),(525,239),(433,285)],c('3b3540'))
poly(a,[(366,210),(454,173),(524,205),(433,245)],c('657582'))
poly(a,[(373,211),(397,200),(458,227),(433,238)],c('99a3a2'))
for x in range(420,482,9):a.line(x,190,x+40,210,c('7d8b91'))
# desk and CRT on back corner
poly(a,[(224,170),(310,131),(379,164),(293,205)],c('a07b56'))
poly(a,[(224,170),(293,205),(293,215),(224,180)],c('604e45'))
a.rect(231,181,5,45,c('433c3e'));a.rect(355,178,5,43,c('433c3e'))
poly(a,[(283,126),(316,113),(339,124),(306,139)],c('b7b8a7'))
poly(a,[(283,126),(306,139),(306,176),(283,162)],c('8e9c99'))
poly(a,[(306,139),(339,124),(339,160),(306,176)],c('bec5b5'))
poly(a,[(310,142),(334,131),(334,156),(310,168)],c('4b7883'))
a.rect(311,147,2,15,c('8dafab'))
poly(a,[(289,186),(318,173),(336,180),(307,194)],c('9ca59b'))
for x in range(295,319,5):a.line(x,184,x+12,188,c('596770'))
# book shelf, books and pot
poly(a,[(468,158),(535,177),(535,183),(468,165)],c('8b7055'))
for x in range(476,525,8):a.rect(x,143+(x-476)//4,5,16,[slate,warm,c('707665')][x%3])
a.rect(211,258,31,19,c('977a59'));a.rect(212,259,28,2,c('c39d6c'))
# slippers and hanging practical rider jacket
ellipse(a,302,291,13,6,c('a88d75'));ellipse(a,320,299,13,6,c('a88d75'))
poly(a,[(199,125),(211,121),(219,132),(215,156),(201,161),(196,148)],c('9a7759'))
a.line(207,126,207,155,c('cfb58a'))
# small warm lamp and spill
ellipse(a,349,185,34,10,c('a17b54'));a.rect(360,161,2,25,warm)
poly(a,[(354,151),(366,156),(372,169),(347,162)],c('d5a674'))
# Material grain stays inside authored surfaces, not random full-screen noise.
r=random.Random(912)
material={c('746251'):c('7b6957'),c('465166'):c('4c576b'),c('343f54'):c('3b465a'),c('657582'):c('71808a'),c('816b58'):c('88715e')}
for y in range(360):
 for x in range(640):
  col=a.p[y*640+x]
  if col in material and (x*7+y*11)%29==0:a.dot(x,y,material[col])
# Woven mat beside bed, with original chevron stitch.
poly(a,[(280,260),(332,238),(395,267),(343,292)],c('515d66'))
for y in range(255,286,5):a.line(315,y,352,y+13,c('8b9391'))
# Chair with padded back and angled legs.
poly(a,[(257,204),(279,195),(295,203),(273,214)],c('536c79'))
poly(a,[(258,204),(273,214),(273,234),(258,224)],c('354958'))
a.line(262,227,252,249,ink);a.line(278,224,291,243,ink);a.line(272,231,274,251,ink)
# Books, paper, mug, keyboard highlights and computer cable.
poly(a,[(239,173),(251,167),(261,172),(249,178)],c('d1c4a2'))
a.rect(347,171,5,9,c('c0b8a4'));a.rect(351,173,3,4,c('b29e80'))
a.line(305,199,312,220,ink);a.line(312,220,333,230,ink)
# Layered bedding and folded clothing, not a single flat bed slab.
poly(a,[(432,185),(450,178),(493,198),(475,207)],c('a4aba8'))
a.line(439,187,478,204,c('c0c3b8'))
for off in range(0,35,4):a.line(452+off,211-off//2,463+off,225-off//2,c('536777'))
poly(a,[(473,232),(495,221),(506,226),(485,238)],c('786b72'))
# Shelf and original abstract landscape print on left wall.
poly(a,[(209,79),(264,55),(264,60),(209,84)],c('876d53'))
for x,y in [(214,66),(223,62),(232,58),(242,54)]:
 a.rect(x,y,5,13,[slate,warm,c('71846f')][x%3])
poly(a,[(278,41),(310,29),(310,70),(278,84)],c('8c775f'))
poly(a,[(281,43),(307,33),(307,67),(281,79)],c('637b85'))
a.line(282,64,294,47,c('a1ada6'));a.line(294,47,306,63,c('a1ada6'))
# Bedside plant, drawer handles and contact shadows.
poly(a,[(522,227),(539,219),(552,225),(536,233)],c('9b805f'))
poly(a,[(522,227),(536,233),(536,257),(522,251)],c('6f5848'))
a.rect(530,238,4,2,warm)
a.rect(534,208,7,15,c('857c66'))
for x,y in [(525,197),(545,195),(533,189)]:
 a.line(538,210,x,y,c('4d685f'));ellipse(a,x-5,y-2,10,5,c('66816e'))
a.save('bedroom.png')
# Adult woman, approximately 1:6.5 head/body ratio, home clothing.
a=Canvas(32,64,transparent)
ellipse(a,10,1,13,15,ink);ellipse(a,12,5,10,10,c('d4ad8c'));a.rect(10,1,13,5,ink);a.rect(10,5,3,13,ink)
poly(a,[(11,17),(21,17),(24,35),(9,35)],c('71808a'));a.rect(8,20,3,20,c('71808a'));a.rect(23,20,3,20,c('71808a'))
a.rect(8,39,3,4,c('d4ad8c'));a.rect(23,39,3,4,c('d4ad8c'));a.rect(11,35,5,22,c('3d495c'));a.rect(18,35,5,22,c('3d495c'));a.rect(9,57,7,4,c('a98c71'));a.rect(18,57,8,4,c('a98c71'));a.dot(16,10,ink);a.dot(21,10,ink)
a.save('rider_home.png')
# Reuse authored icon designs, enlarged using nearest neighbor via native PNG load in Godot.
print('Round2 authored scenery, thumbnails, video covers, avatars and rider generated')

import shutil
root=Path('assets/art')
for f in list(OUT.glob('*.png')):
 name=f.name
 dest='environment'
 if name.startswith('avatar_'):dest='avatars'
 elif name.startswith('thumb_'):dest='social'
 elif name.startswith('video_'):dest='video'
 elif name=='wallpaper.png':dest='backgrounds'
 elif name=='rider_home.png':dest='characters'
 if dest!='environment':shutil.move(str(f),str(root/dest/name))
# Additional individually composed scenes, not repeated city crops.
for i in range(4,8):
 a=Canvas(320,180,c('27364b'))
 if i==4: # Covered market, produce bins and weighing scale.
  for x in range(0,320,8):a.line(x,15,x+14,43,c('82908b') if x%16 else c('a68868'))
  a.rect(0,43,320,4,ink);a.rect(12,47,6,126,slate);a.rect(302,47,6,126,slate)
  for x in range(25,290,52):
   poly(a,[(x,105),(x+43,105),(x+48,148),(x-5,148)],c('82654c'))
   for xx in range(x+3,x+39,9):
    for yy in range(111,141,9):ellipse(a,xx,yy,8,6,c('8c9a6a') if x%2 else warm)
  a.rect(125,74,42,29,slate);a.rect(133,78,25,12,ink);a.line(145,85,153,82,warm)
 elif i==5: # Laundromat, umbrellas and warm doorway.
  a.rect(14,25,290,135,c('566473'))
  for x in [28,95,162]:
   a.rect(x,70,56,72,c('a6acaa'));ellipse(a,x+9,87,38,38,ink);ellipse(a,x+13,91,30,30,c('607e8b'))
   a.rect(x+7,77,16,3,warm)
  a.rect(238,44,50,116,ink);a.rect(243,49,40,105,c('a48263'))
  for x in [239,254,270]:a.line(x,123,x+7,151,slate)
 elif i==6: # Rider's scooter parked under shelter.
  a.rect(10,28,300,5,slate);a.rect(22,33,5,130,slate);a.rect(293,33,5,130,slate)
  for x in [82,222]:ellipse(a,x,122,35,35,ink);ellipse(a,x+7,129,21,21,c('829095'))
  poly(a,[(100,134),(137,98),(199,102),(234,139),(165,142)],c('778d92'))
  a.rect(118,72,66,39,c('ac8965'));a.rect(122,76,58,4,c('d1b18a'));a.line(150,77,150,110,c('d1b18a'))
  a.line(205,103,215,70,slate);a.line(215,70,235,70,slate);a.rect(137,107,57,7,ink)
 else: # Window plants and taped paper notice.
  a.rect(25,20,270,123,slate);a.rect(31,26,258,110,c('455c75'))
  a.line(160,27,160,136,ink);a.line(32,80,287,80,ink);a.rect(0,144,320,12,c('82674e'))
  for x in [43,115,230]:
   a.rect(x,117,28,27,c('99735b'))
   for xx,yy in [(x-5,95),(x+25,88),(x+12,77)]:a.line(x+14,118,xx,yy,c('668679'));ellipse(a,xx-9,yy-4,18,8,c('79947d'))
  a.rect(173,38,48,61,c('d0c4a5'));a.rect(180,34,10,10,c('b8b59c'))
  for yy in range(50,87,7):a.line(181,yy,212,yy,c('867e70'))
 # Material detail, contact shadows and authored object features.
 r=random.Random(300+i)
 for yy in range(45,170):
  for xx in range(15,305):
   col=a.p[yy*320+xx]
   if col==c('27364b') and (xx*3+yy*7)%59==0:a.dot(xx,yy,c('304257'))
   if col in [c('82654c'),c('aa8660'),c('ac8965')] and xx%7==0 and yy%9==0:a.dot(xx,yy,c('9c8060'))
 if i==4:
  for x in range(25,290,52):
   a.line(x+2,145,x+42,145,c('b39b73'));a.line(x+3,137,x+40,137,c('6b5543'))
   for xx in range(x+4,x+39,9):a.dot(xx,113,c('c2ba82'))
  a.line(130,89,160,89,c('b4bcb6'));a.rect(139,82,8,3,warm)
  for x in [21,76,132,188,244,300]:a.line(x,47,x,59,ink)
 elif i==5:
  for x in [28,95,162]:
   a.line(x+2,140,x+53,140,c('667a88'));a.rect(x+38,77,6,3,warm)
   ellipse(a,x+15,94,24,25,c('415f74'));a.line(x+21,96,x+16,111,c('9aafb1'))
  a.rect(245,48,35,4,c('cfac7a'));a.rect(250,60,23,28,c('d0c4a5'))
  for y in range(66,83,5):a.line(254,y,269,y,c('8a806b'))
  for y in range(154,179,5):a.line(225-y%9,y,287,y,c('697c86'))
 elif i==6:
  for x in [82,222]:
   a.line(x+17,126,x+17,152,slate);a.line(x+4,139,x+30,139,slate)
  a.line(111,132,135,108,c('a3b6b7'));a.line(169,140,203,140,c('536673'))
  a.rect(141,112,36,5,ink);a.rect(193,112,12,5,c('d1bd87'))
  a.rect(120,80,61,2,c('d1b18a'));a.rect(123,95,58,2,c('89694f'));a.rect(144,85,12,6,c('c4ab83'))
  for y in range(162,179,5):a.line(69,y,263,y,c('485e6e'))
  for x in range(35,285,13):a.line(x,35,x-1,39,c('647d8e'))
 elif i==7:
  for x in [43,115,230]:
   a.line(x+2,122,x+25,122,c('b5916e'));a.line(x+4,142,x+23,142,c('4b403b'))
  for x in [37,70,98,138,257,276]:a.line(x,35,x-3,46,c('7b949e'))
  for y in range(155,173,5):a.line(16,y,295,y,c('6f5947'))
 a.save('extra_%d.png'%i)
 shutil.move(str(OUT/('extra_%d.png'%i)),str(root/'social'/('thumb_%d.png'%i)))
# Sixth through eighth new portraits: distinct ages, hairstyles and accessories.
for i in range(8,12):
 a=Canvas(32,32,c('41556b'));hair=[c('342f38'),c('9c9788'),c('6f5350'),c('4b3e37')][i-8]
 ellipse(a,5,2,23,28,hair);ellipse(a,10,8,15,19,c('c9a184'))
 poly(a,[(6,31),(10,26),(23,26),(29,31)],[c('75877f'),warm,c('6d7c91'),c('89778a')][i-8])
 for x in range(8,26):
  for y in range(4,10+(x+i)%4):a.dot(x,y,hair)
 a.rect(12,16,3,2,ink);a.rect(21,16,2,2,ink);a.rect(17,23,3,1,c('916e63'))
 if i==9:a.line(10,16,25,16,slate);a.rect(10,15,7,5,slate);a.rect(19,15,7,5,slate)
 if i==10:a.rect(5,16,4,14,hair)
 a.save('extra_avatar_%d.png'%i);shutil.move(str(OUT/('extra_avatar_%d.png'%i)),str(root/'avatars'/('avatar_%d.png'%i)))
# Three additional video subjects: market, scooter, rainy window.
for i,source in [(3,4),(4,6),(5,7)]:shutil.copy2(root/'social'/('thumb_%d.png'%source),root/'video'/('video_%d.png'%i))
for i in range(6):shutil.copy2(Path('assets/pixel_desktop')/('app_%d.png'%i),root/'icons'/('app_%d.png'%i))
for name in ['close','minimize','status','notification']:shutil.copy2(Path('assets/pixel_desktop')/(name+'.png'),root/'icons'/(name+'.png'))
# Rider standing in practical uniform, helmet and delivery box. Natural 1:7 proportion.
a=Canvas(48,88,transparent)
a.rect(28,25,17,29,c('aa8660'));a.rect(30,28,13,3,c('d0b184'));a.line(36,29,36,53,c('d0b184'))
ellipse(a,13,2,16,16,ink);ellipse(a,15,7,12,12,c('d0aa8d'))
ellipse(a,11,0,20,12,c('8ca1a6'));a.rect(11,7,20,3,c('b1bfb8'));a.rect(13,12,3,8,ink)
a.dot(19,12,ink);a.dot(26,12,ink);a.rect(21,17,3,1,c('946f60'))
poly(a,[(14,22),(27,22),(32,49),(11,49)],c('67818c'));a.line(21,24,21,48,c('b6c5ba'));a.rect(14,32,6,2,c('d2b586'))
poly(a,[(11,24),(15,27),(12,52),(7,51)],c('67818c'));a.rect(7,51,5,6,c('d0aa8d'))
poly(a,[(27,23),(31,25),(35,49),(30,51)],c('566e7a'));a.rect(30,50,5,6,c('d0aa8d'))
a.rect(13,49,7,30,c('303c51'));a.rect(23,49,7,30,c('303c51'));a.line(18,52,18,77,c('45536a'));a.line(27,52,27,77,c('45536a'))
a.rect(10,79,10,6,c('acb7b2'));a.rect(23,79,11,6,c('acb7b2'));a.rect(10,84,10,2,ink);a.rect(23,84,11,2,ink)
# Tailored folds, helmet vents, chin strap, low ponytail and reflective trim.
a.rect(10,14,4,10,ink);a.rect(8,20,4,9,ink)
a.line(15,12,18,20,c('596d75'));a.line(27,12,24,20,c('596d75'))
a.line(17,2,24,2,c('c3cec4'));a.rect(17,4,3,1,c('596d75'));a.rect(24,4,3,1,c('596d75'))
a.dot(19,12,ink);a.dot(26,12,ink);a.dot(18,11,white)
a.line(13,27,17,24,c('93a6a7'));a.line(23,24,28,28,c('93a6a7'))
a.line(13,35,19,35,c('c3c9b7'));a.line(24,35,29,35,c('c3c9b7'))
a.line(14,40,17,42,c('455e6d'));a.line(23,44,28,42,c('455e6d'))
a.rect(14,43,5,1,c('9caca9'));a.rect(24,43,4,1,c('9caca9'))
a.line(15,51,17,64,c('536174'));a.line(24,61,28,66,c('536174'))
a.line(11,81,18,81,white);a.line(24,81,31,81,white)
for yy in [32,40,48]:a.line(30,yy,42,yy,c('97734f'))
a.rect(31,37,9,5,c('c3a678'));a.rect(34,38,3,2,c('7a664e'))
a.save('rider_uniform.png');shutil.move(str(OUT/'rider_uniform.png'),str(root/'characters'/'rider_uniform.png'))
# Individual furniture sprite: delivery crate and helmet for the apartment.
a=Canvas(64,48,transparent)
poly(a,[(4,17),(29,6),(55,18),(30,31)],c('b89770'));poly(a,[(4,17),(30,31),(30,46),(4,32)],c('8a6c50'));poly(a,[(30,31),(55,18),(55,34),(30,46)],c('705941'))
a.line(17,11,43,25,c('d4ba90'));ellipse(a,31,0,24,18,c('8ca1a6'));a.rect(32,10,24,4,c('b8c6bc'))
a.save('delivery_gear.png');shutil.move(str(OUT/'delivery_gear.png'),str(root/'furniture'/'delivery_gear.png'))
print('Unified assets complete')

# Distinct original notification bell and power-status glyph, replacing duplicated early glyphs.
for name in ['notification','status']:
 a=Canvas(16,16,transparent)
 if name=='notification':
  poly(a,[(5,4),(10,4),(12,11),(3,11)],warm);a.rect(7,2,2,2,pale);a.rect(6,12,4,2,warm);a.line(5,5,4,10,white)
 else:
  a.rect(3,4,9,9,slate);a.rect(5,2,2,3,pale);a.rect(9,2,2,3,pale);a.line(8,7,6,10,warm);a.line(6,10,9,10,warm)
 a.save(name+'.png');shutil.move(str(OUT/(name+'.png')),str(root/'icons'/(name+'.png')))
