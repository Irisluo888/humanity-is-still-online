from pathlib import Path
import wave,math,random,struct
out=Path('assets/audio/ch01');out.mkdir(parents=True,exist_ok=True)
r=random.Random(9)
for name,duration in [('knock',.65),('glass',.45),('phone',.8),('vibrate',.55),('muffled',.8)]:
 samples=[]
 for i in range(int(22050*duration)):
  t=i/22050
  if name=='knock':a=sum(math.exp(-(t-k)*40)*(math.sin(2*math.pi*95*(t-k))+r.uniform(-.4,.4)) if t>=k else 0 for k in [0,.22,.39])*.35
  elif name=='glass':a=r.uniform(-1,1)*math.exp(-t*12)*.45+math.sin(t*2*math.pi*2100)*math.exp(-t*25)*.15
  elif name=='phone':a=(math.sin(t*2*math.pi*660)+math.sin(t*2*math.pi*880))*.12*(1 if t%.4<.25 else 0)
  elif name=='vibrate':a=math.sin(t*2*math.pi*100)*.22*(1 if t%.2<.12 else 0)
  else:a=(math.sin(t*2*math.pi*150)*.15+math.sin(t*2*math.pi*300)*.07+r.uniform(-.04,.04))*math.sin(math.pi*t/duration)**2
  samples.append(struct.pack('<h',int(max(-1,min(1,a))*20000)))
 with wave.open(str(out/(name+'.wav')),'wb') as f:f.setparams((1,2,22050,0,'NONE','not compressed'));f.writeframes(b''.join(samples))
print('Five original synthesized effects; muffled is nonverbal, not a voice actor recording.')
