"""Original soft pad and electric-key loops; no third-party samples."""
import math,wave,struct
from pathlib import Path
out=Path('assets/audio/music');out.mkdir(exist_ok=True)
rate=22050;bar=4;duration=16
tracks={'menu':[[48,55,59,64],[45,52,55,59],[41,48,52,57],[43,50,55,59]],'city':[[50,57,60,65],[46,53,57,62],[48,55,58,64],[45,52,57,60]],'night':[[45,52,55,59],[41,48,52,57],[48,55,59,62],[43,50,53,57]]}
for name,chords in tracks.items():
 data=bytearray()
 for i in range(rate*duration):
  t=i/rate;k=int(t/bar);phase=t%bar;value=0
  # Smooth pads fade each chord in and out; both loop boundaries are zero.
  envelope=math.sin(math.pi*phase/bar)**2
  for note in chords[k]:
   freq=440*2**((note-69)/12);value+=.026*math.sin(2*math.pi*freq*t)*envelope
  beat=phase%1;note=chords[k][int(phase)%4]+12;freq=440*2**((note-69)/12)
  env=(1-math.exp(-beat*35))*math.exp(-beat*4)
  value+=.055*(math.sin(2*math.pi*freq*t)+.16*math.sin(2*math.pi*freq*2*t))*env
  data.extend(struct.pack('<h',int(max(-.9,min(.9,value*3.5))*32767)))
 with wave.open(str(out/(name+'.wav')),'wb') as w:w.setparams((1,2,rate,0,'NONE','not compressed'));w.writeframes(data)
