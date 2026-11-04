from pathlib import Path
import zlib,struct,random,math
OUT=Path('assets/pixel_desktop'); OUT.mkdir(parents=True,exist_ok=True)
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
a=city(40,640,360)
# Window sill and domestic objects, deliberately different from reference composition.
a.rect(0,302,640,58,c('342f37'));a.rect(0,302,640,4,warm)
for x in range(0,640,32): a.line(x,313,x+25,313,c('66504a'))
a.rect(510,245,5,58,ink);a.rect(493,244,39,4,warm)
for y in range(224,244): a.rect(503-(y-224)//2,y,20+(y-224),1,c('b98d62'))
a.rect(50,276,45,26,blue);a.rect(53,278,38,21,slate);a.rect(95,281,8,14,slate);a.rect(98,284,3,8,ink)
for x in [590,601,611]:a.line(603,275,x,239,slate);a.rect(x-4,238,8,4,c('52655a'))
a.rect(591,275,24,27,c('8c6653'));a.save('wallpaper.png')
for i in range(4):
 a=city(70+i,160,88)
 if i==1:
  a.rect(20,57,110,22,blue);a.rect(23,59,105,3,warm)
 if i==2:
  a.rect(65,35,30,45,slate);a.rect(69,39,22,32,ink);a.rect(72,42,16,19,warm)
 if i==3:
  a.rect(55,57,54,25,c('715a50'));a.line(55,57,108,57,warm)
 a.save('thumb_%d.png'%i)
for i in range(8):
 a=Canvas(32,32,c('394a60'));hair=[ink,c('554345'),c('6f5141'),c('34313e')][i%4]
 # Rounded pixel silhouette, asymmetrical locks, face shading and shoulder contour.
 for y in range(3,32):
  for x in range(2,30):
   if ((x-16)/11)**2+((y-15)/13)**2<1:a.dot(x,y,hair)
   if ((x-16)/8)**2+((y-17)/10)**2<1 and y>10:a.dot(x,y,c('cfaa8b') if x>12 else c('ae856f'))
   if y>26 and abs(x-16)<(y-22)*2:a.dot(x,y,[slate,warm,c('6c687b'),c('6c817c')][i%4])
 for x in range(8,25):
  for y in range(6,13+(x+i)%4):a.dot(x,y,hair)
 if i%2==0:a.rect(6,14,4,14,hair)
 else:a.rect(23,13,3,11,hair)
 a.rect(11,17,3,2,ink);a.rect(20,17,3,2,ink);a.dot(12,17,white);a.dot(21,17,white)
 a.rect(16,24,3,1,c('8b5c51'));a.rect(14,27,5,2,c('cfaa8b'))
 a.save('avatar_%d.png'%i)
for i in range(6):
 a=Canvas(24,24,transparent)
 if i==0:
  a.rect(3,4,18,13,ink);a.rect(4,5,16,10,slate);a.line(6,20,11,15,slate)
  for x in [7,12,17]:a.rect(x,9,2,2,white)
 elif i==1:
  for x,y in [(5,16),(9,12),(13,8),(17,4)]:a.rect(x,y,3,20-y,warm)
 elif i==2:
  a.rect(2,5,20,14,slate)
  for x in range(9,16):a.line(x,8+(x-9)//2,x,16-(x-9)//2,white)
 elif i==3:
  a.rect(2,5,20,15,ink);a.rect(3,6,18,13,pale);a.line(3,6,12,13,slate);a.line(12,13,20,6,slate)
 elif i==4:
  a.rect(4,6,16,14,slate);a.rect(6,9,12,7,ink);a.rect(8,11,2,2,warm);a.rect(15,11,2,2,warm);a.line(12,2,12,6,pale)
 else:
  a.rect(3,7,18,14,warm);a.rect(5,9,14,10,c('886451'));a.line(12,7,12,21,white);a.rect(7,3,10,4,pale)
 a.save('app_%d.png'%i)
for name in ['close','minimize','status','notification']:
 a=Canvas(16,16,transparent)
 if name=='close':a.line(4,4,11,11,pale);a.line(11,4,4,11,pale)
 elif name=='minimize':a.rect(4,10,8,2,pale)
 else:a.rect(5,3,6,8,warm);a.rect(7,12,2,2,warm)
 a.save(name+'.png')
print('Generated 23 original PNG assets with standard library only')
