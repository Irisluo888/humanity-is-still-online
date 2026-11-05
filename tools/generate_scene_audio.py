"""Original procedural sound effects. Python standard library, deterministic seed."""
import math,random,wave,struct
from pathlib import Path
root=Path('assets/audio/generated');root.mkdir(parents=True,exist_ok=True)
rate=22050
for name,duration in [('rain',8),('bike',4),('finger_clamp',.6),('heavy_impact',.7),('glass_break',1.4),('door_impact',.5)]:
 rng=random.Random(name);values=[];smooth=0
 for i in range(int(rate*duration)):
  t=i/rate;n=rng.uniform(-1,1);smooth=.94*smooth+.06*n
  if name=='rain':v=.18*n+.25*smooth
  elif name=='bike':v=.16*math.sin(2*math.pi*110*t)+.035*math.sin(2*math.pi*440*t)+.025*n
  elif name=='glass_break':v=(.25*n*math.exp(-t*18)+sum(.09*math.sin(2*math.pi*f*t)*math.exp(-t*d) for f,d in [(1793,4),(2701,6),(4139,8)]))
  else:
   f=65 if name=='heavy_impact' else (130 if name=='door_impact' else 420)
   v=.55*math.sin(2*math.pi*f*t)*math.exp(-t*18)+.3*n*math.exp(-t*40)
  values.append(struct.pack('<h',int(max(-1,min(1,v))*32767)))
 with wave.open(str(root/(name+'.wav')),'wb') as w:w.setparams((1,2,rate,0,'NONE','not compressed'));w.writeframes(b''.join(values))
