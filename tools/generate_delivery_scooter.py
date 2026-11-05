"""Original local pixel scooter; standard library only, no reference image pixels."""
from pathlib import Path
import struct,zlib,math
W,H=96,64
pixels=[(0,0,0,0)]*(W*H)
def rgb(h):return tuple(bytes.fromhex(h))+(255,)
def dot(x,y,c):
 if 0<=x<W and 0<=y<H:pixels[y*W+x]=rgb(c)
def rect(x,y,w,h,c):
 for yy in range(y,y+h):
  for xx in range(x,x+w):dot(xx,yy,c)
def line(x,y,u,v,c,width=1):
 n=max(abs(u-x),abs(v-y),1)
 for t in range(n+1):rect(round(x+(u-x)*t/n),round(y+(v-y)*t/n),width,width,c)
def circle(x,y,r,c):
 for yy in range(y-r,y+r+1):
  for xx in range(x-r,x+r+1):
   if (xx-x)**2+(yy-y)**2<=r*r:dot(xx,yy,c)
for x in (23,73):
 circle(x,49,11,'17232e');circle(x,49,8,'435360');circle(x,49,5,'233440')
 for a in range(0,360,60):line(x,49,x+round(math.cos(math.radians(a))*7),49+round(math.sin(math.radians(a))*7),'7d8e94')
 circle(x,49,2,'bdc3b9');line(x-6,40,x+5,40,'97a6a3',2)
# delivery box, rack, seat, battery housing, footboard and front fairing
rect(9,11,26,23,'253743');rect(11,13,22,18,'ae8961');rect(12,14,20,3,'d0b084')
rect(14,20,17,2,'c0a27b');rect(12,27,20,3,'896c53');rect(24,14,3,16,'d2b99a')
rect(8,33,28,3,'75868c');line(16,36,24,45,'566d78',3)
rect(24,34,22,5,'263543');rect(28,35,15,2,'82918c')
rect(27,39,17,12,'526c76');rect(30,40,10,8,'314854');rect(32,42,6,2,'9ca98d')
line(27,49,57,49,'1d303e',4);line(29,48,57,48,'82918c',2)
line(58,47,63,27,'3a5967',6);line(62,28,69,38,'80908b',4)
line(65,35,73,49,'9aabac',3);rect(60,23,11,6,'30434e');rect(68,24,5,4,'e3cc92')
line(60,24,58,17,'a7b2ab',2);line(53,17,63,17,'253743',3)
line(57,17,54,11,'81969e');rect(49,8,7,4,'a7b8b8')
rect(13,38,5,3,'b47457');rect(41,40,3,4,'8ba4a4')
# restrained material dithering
for y in range(14,30):
 for x in range(12,32):
  if (x+y)%9==0 and x<23:dot(x,y,'b99c74')
raw=b''.join(b'\x00'+bytes(v for p in pixels[y*W:(y+1)*W] for v in p) for y in range(H))
def chunk(t,d):return struct.pack('>I',len(d))+t+d+struct.pack('>I',zlib.crc32(t+d)&0xffffffff)
out=b'\x89PNG\r\n\x1a\n'+chunk(b'IHDR',struct.pack('>IIBBBBB',W,H,8,6,0,0,0))+chunk(b'IDAT',zlib.compress(raw))+chunk(b'IEND',b'')
Path('assets/art/ch01/delivery_scooter.png').write_bytes(out)
