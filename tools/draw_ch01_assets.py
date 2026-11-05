from pathlib import Path
import ast,random,math,struct,zlib
src=ast.parse(Path('tools/draw_third_round_assets.py').read_text(encoding='utf-8'))
exec(compile(ast.Module(body=[n for n in src.body if isinstance(n,(ast.ClassDef,ast.FunctionDef)) and n.name in ['Canvas','c','poly','ellipse']],type_ignores=[]),'primitives','exec'))
OUT=Path('assets/art/ch01');OUT.mkdir(parents=True,exist_ok=True)
ink=c('202b3b');rim=c('6e8089');warm=c('c3986a');skin=c('c29c7f');r=random.Random(1404)
for name,base in [('paving','54616b'),('road','354552'),('wood','786450'),('plaster','5b6576'),('tile','82918e'),('grass','455e54')]:
 a=Canvas(64,64,c(base))
 for i in range(400):
  x=r.randrange(64);y=r.randrange(64);p=a.p[y*64+x];delta=r.choice([-9,7]);a.dot(x,y,tuple(max(0,min(255,v+delta)) for v in p[:3])+(255,))
 for y in range(0,64,16):
  a.line(0,y,63,y,ink)
  for x in range((y//16%2)*16,64,32):a.line(x,y,x,y+16,ink)
 a.save(name+'.png')
# Every surface has structural details, not flat color placeholders.
for name in ['facade','storefront','shelf','fridge','door','elevator','counter','bed','wardrobe','desk']:
 a=Canvas(96,96,c('49576a'));a.rect(2,2,92,92,c('687680'))
 if name in ['facade','storefront']:
  for y in range(4,96,8):
   a.line(0,y,95,y,c('4b596b'))
   for x in range(y%16,96,16):a.line(x,y,x,y+8,c('4b596b'))
  for x in [10,58]:
   for y in [12,49]:
    a.rect(x-3,y-3,31,33,ink);a.rect(x,y,25,26,warm if x==58 else c('657e8c'));a.line(x+12,y,x+12,y+26,ink);a.line(x,y+12,x+25,y+12,ink);a.rect(x-4,y+27,33,3,rim)
  if name=='storefront':
   a.rect(0,3,96,18,c('486d6e'))
   for x in range(5,93,12):a.rect(x,8,7,2,c('c6ba91'));a.rect(x+2,6,2,10,c('c6ba91'))
   for x in range(0,96,8):a.rect(x,25,4,8,c('a5a493'))
 elif name in ['shelf','fridge']:
  a.rect(4,3,88,90,ink)
  for y in [9,37,65]:
   a.rect(7,y,82,23,c('667c82') if name=='fridge' else c('695e53'))
   for x in range(12,85,12):
    a.rect(x,y+5,7,14,[warm,c('82977e'),c('a28a80')][x%3]);a.rect(x+1,y+3,5,3,c('bac3b5'));a.rect(x+1,y+9,5,4,c('d1c6a7'))
   a.rect(6,y+24,84,3,c('a29a87'))
  if name=='fridge':a.line(49,4,49,91,rim);a.rect(43,40,3,17,c('d5d6bf'))
 elif name in ['door','wardrobe','elevator']:
  a.rect(6,4,84,92,ink);a.rect(11,9,74,86,c('777f83') if name=='elevator' else c('655a53'))
  for x in range(15,84,7):a.line(x,12,x,92,c('596673') if name=='elevator' else c('75675c'))
  a.line(48,9,48,94,ink);a.rect(77,52,3,12,warm)
  if name=='door':a.rect(21,30,24,15,c('c8bf9b'));a.line(24,35,41,35,ink);a.line(24,39,40,39,ink)
 elif name=='desk':
  a.rect(5,6,85,77,c('7b6958'));a.rect(17,8,56,43,ink);a.rect(21,12,48,33,c('69888a'));a.rect(34,53,23,5,rim)
  for y in range(65,81,4):
   for x in range(20,70,5):a.rect(x,y,3,2,c('c1b797'))
  a.rect(77,66,6,11,c('c2ba9f'))
 elif name=='bed':
  a.rect(7,5,83,90,c('59545a'));a.rect(12,10,73,81,c('657a85'));a.rect(19,15,59,19,c('c3beb0'))
  for y in range(40,90,7):a.line(14,y,82,y+2,c('879495'))
  for x in range(19,80,12):a.line(x,39,x-3,89,c('536c7b'))
 else:
  a.rect(5,3,86,90,c('89745b'))
  for y in range(7,96,8):a.line(5,y,90,y,c('a18b6d'))
  a.rect(49,22,35,40,ink);a.rect(53,26,27,24,c('5f8c86'));a.rect(12,64,23,20,c('c6b99b'))
 a.save(name+'.png')
# Natural-proportion adult sprites; individual silhouettes and shared shirt-man resource.
for name,hair,coat,pants,kind in [('zhou','777b78','687d80','344858','old'),('xiaoyu','302d35','aa815d','3d4859','woman'),('man','292e37','c2bfae','464453','man'),('chen','3e3539','8b7772','4d4b58','apron'),('lin','34303b','777c90','4d5265','woman')]:
 a=Canvas(48,96,(0,0,0,0))
 ellipse(a,8,88,34,5,c('27313b'))
 poly(a,[(15,46),(32,46),(33,66),(29,88),(24,88),(24,64),(21,88),(15,88)],c(pants))
 poly(a,[(13,28),(20,24),(29,24),(36,30),(37,53),(31,55),(30,47),(16,48),(14,57),(9,54)],c(coat))
 a.rect(17,11,15,18,skin);a.rect(16,7,17,8,c(hair));a.rect(15,13,4,9,c(hair));a.rect(30,12,4,8,c(hair))
 a.rect(19,17,2,2,ink);a.rect(28,17,2,2,ink);a.line(22,25,27,25,c('795b53'))
 a.line(22,31,23,46,c('c3bba1'));a.rect(10,50,5,7,skin);a.rect(33,49,5,7,skin)
 a.rect(13,86,9,5,c('a1aaa5'));a.rect(25,86,11,5,c('a1aaa5'));a.line(12,91,22,91,ink);a.line(25,91,37,91,ink)
 if kind=='old':
  a.rect(17,5,18,5,c('6c7c80'));a.rect(13,9,23,3,c('a9b2a8'));a.rect(19,37,11,6,c('a7a88f'));a.line(21,21,28,21,c('9b806c'))
 if kind=='man':
  a.line(18,17,32,17,ink);a.rect(17,16,6,5,rim);a.rect(26,16,6,5,rim);a.rect(34,44,4,6,c('8f5650'));a.rect(35,57,11,17,c('60574e'));a.rect(38,53,5,4,ink)
 if kind=='apron':a.rect(18,32,13,23,c('a3ac96'));a.rect(20,43,9,6,c('6d8b81'));a.rect(18,30,3,4,c('a3ac96'))
 if kind=='woman':poly(a,[(31,11),(38,15),(39,27),(33,24)],c(hair))
 a.save(name+'.png')
 if kind=='man':
  a.rect(35,53,13,24,(0,0,0,0));a.save('man_attack.png')
# Props with meaningful silhouettes and contour detail.
for name in ['tree','bench','bike','lamp','rack','bin','extinguisher','bags','flowers','blood','briefcase','glass','water']:
 a=Canvas(64,96,(0,0,0,0))
 if name=='water':
  a.rect(26,36,14,6,c('c8c7b0'));a.rect(24,42,18,39,c('88a9b1'));a.rect(27,45,3,30,c('b8d0ce'));a.rect(23,55,20,15,c('dad0b2'));a.rect(27,59,12,5,c('6f9395'));a.rect(25,81,16,3,ink)
 elif name=='briefcase':
  a.rect(8,64,47,23,c('5d5149'));a.rect(10,66,43,18,c('83705a'));a.rect(25,58,15,6,ink);a.line(10,73,53,73,c('ac9270'));a.rect(30,72,3,8,c('b4ab8d'))
 elif name=='glass':
  for x,y in [(8,72),(26,78),(44,67),(50,85)]:poly(a,[(x,y),(x+8,y-4),(x+12,y+3)],c('9fbbbe'))
 elif name=='tree':
  a.rect(28,43,8,47,c('786653'))
  for x,y,w,h in [(10,18,40,35),(1,34,36,25),(28,32,34,30),(18,6,27,30)]:ellipse(a,x,y,w,h,c('536d60'))
  for i in range(150):
   x=r.randrange(64);y=r.randrange(60)
   if a.p[y*64+x][3]:a.dot(x,y,c('7a8b70') if i%3==0 else c('405d52'))
 elif name=='bench':
  for y in [43,49,55,67]:a.rect(4,y,54,4,c('9b8064'));a.line(5,y,58,y,c('b49b76'))
  for x in [10,50]:a.rect(x,45,3,43,ink);a.rect(x-4,86,12,3,rim)
 elif name=='bike':
  for x in [5,43]:ellipse(a,x,64,17,23,ink);ellipse(a,x+3,68,11,15,rim);ellipse(a,x+5,70,7,11,ink)
  a.line(13,76,30,55,c('859b8e'));a.line(30,55,51,76,c('859b8e'));a.line(13,76,37,76,c('859b8e'));a.line(37,76,27,49,c('859b8e'));a.rect(19,47,14,4,ink);a.rect(4,40,17,22,c('aa8a64'));a.rect(6,43,13,3,c('cfb184'))
 elif name=='lamp':a.rect(31,19,3,73,rim);a.rect(14,15,21,4,ink);ellipse(a,11,17,14,7,warm);a.rect(26,91,13,3,ink)
 elif name=='extinguisher':a.rect(24,40,17,42,c('a65851'));ellipse(a,24,35,17,10,c('c17761'));a.rect(29,28,5,9,rim);a.rect(27,25,16,4,ink);a.line(41,29,45,55,ink);a.rect(27,53,11,14,c('c9c2a1'));a.rect(24,81,18,4,ink)
 elif name=='blood':
  for i in range(23):ellipse(a,r.randrange(6,54),r.randrange(68,88),r.randrange(2,13),r.randrange(2,6),c('70454b'))
 elif name=='flowers':
  a.rect(7,71,50,13,c('7d6c59'))
  for x in range(12,57,8):a.line(x,72,x+2,56,c('69806b'));ellipse(a,x,52,6,6,c('bd9b76'))
 elif name=='bags':
  for x,y in [(6,60),(25,66),(41,57)]:poly(a,[(x,y),(x+15,y-2),(x+18,y+25),(x-2,y+25)],c('c4b38d'));a.rect(x+4,y+4,8,9,c('dcd0ad'));a.line(x+3,y,x+10,y-6,ink)
 else:
  a.rect(5,42,54,40,c('657d7e'));a.rect(9,46,46,27,ink)
  if name=='rack':
   for x in [13,29,43]:a.rect(x,48,12,20,c('b3a586'));a.rect(x+2,51,6,8,c('d4c8a6'))
  else:
   for x in range(12,54,6):a.line(x,50,x,78,rim)
  a.rect(3,39,58,5,rim);a.rect(9,82,4,8,ink);a.rect(51,82,4,8,ink)
 a.save(name+'.png')
print('CH01 original local PNG assets generated')
