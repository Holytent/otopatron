"""Original lightweight mono PCM music and effects; no external samples."""
from pathlib import Path
import wave,math,struct,random
SR=22050
OUT=Path(__file__).resolve().parent.parent/'audio'
def save(name,samples):
 peak=max(abs(x) for x in samples) or 1
 gain=min(1,.65/peak)
 with wave.open(str(OUT/(name+'.wav')),'wb') as w:
  w.setparams((1,2,SR,0,'NONE','not compressed'))
  w.writeframes(b''.join(struct.pack('<h',round(max(-1,min(1,x*gain))*32767)) for x in samples))
def melody(name,notes,gap,duration,gain=.25):
 out=[0.] * (round(SR*gap)*(len(notes)-1)+round(SR*duration)+2)
 for j,f in enumerate(notes):
  for i in range(int(SR*duration)):
   t=i/SR;env=min(1,t/.008)*math.exp(-6*t)*(min(1,(duration-t)/.025))
   out[j*round(gap*SR)+i]+=gain*env*(math.sin(2*math.pi*f*t)+.12*math.sin(4*math.pi*f*t))
 save(name,out)
melody('click',[640],.1,.09,.16)
melody('sale',[523.25,659.25,783.99,1046.5],.12,.65,.24)
melody('customer',[659.25,880],.14,.45,.22)
melody('notify',[659.25,880],.14,.45,.22)
melody('coin',[987.77,1318.51],.09,.4,.2)
melody('success',[523.25,783.99],.13,.45,.22)
melody('msg_in',[587.33,783.99],.07,.18,.14)
melody('msg_out',[523.25],.1,.12,.14)
rng=random.Random(198);out=[]
for i in range(int(SR*.65)):
 t=i/SR
 pulse=sum(math.exp(-80*max(0,t-a)) if t>=a else 0 for a in [0,.16,.32])
 out.append((rng.uniform(-1,1)*.15+math.sin(2*math.pi*185*t)*.12)*pulse*min(1,t/.003)*min(1,(.65-t)/.02))
save('repair',out)
# Eight bars at 80 BPM: warm electric keys and a sparse melody, no harsh drums.
duration=24;out=[0.] * (SR*duration)
chords=[[261.63,329.63,392,493.88],[220,261.63,329.63,392],[174.61,220,261.63,329.63],[196,246.94,293.66,392]]
def note(f,start,length,gain):
 for i in range(round(SR*length)):
  t=i/SR;en=min(1,t/.025)*math.exp(-1.5*t)*min(1,(length-t)/.15)
  out[(round(start*SR)+i)%len(out)]+=gain*en*(math.sin(2*math.pi*f*t)+.16*math.sin(4*math.pi*f*t))
for bar in range(8):
 chord=chords[bar%4]
 for f in chord: note(f,bar*3,3.6,.055)
 note(chord[0]/2,bar*3,2.8,.07)
 for beat,idx in [(0,2),(1.5,1),(2.25,3)]:note(chord[idx]*2,bar*3+beat,.7,.045)
save('ambient',out)
print('Gentle 24-second loop and nine effects generated')
