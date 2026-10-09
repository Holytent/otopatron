"""Original side-profile vehicle art. Every part shares one geometry coordinate system."""
from pathlib import Path
import re,json,math
root=Path(__file__).resolve().parent.parent
src=(root/'scripts/data/car_db.gd').read_text(encoding='utf-8')
models=json.loads(src.split('const MODELS: Array = ',1)[1].split('const CLASS_KEYS',1)[0].strip().rstrip(',').replace(',\n]', '\n]'))
# body contour and glazing polygons: rear to front, wheels at y=232.
shapes={
'sedan': ([(44,226),(48,181),(130,172),(201,112),(367,112),(441,165),(542,177),(578,197),(577,226)], [[(163,164),(213,123),(294,123),(294,164)],[(305,123),(362,123),(415,164),(305,164)]],(148,472),39),
'hatch': ([(62,226),(64,156),(127,101),(331,101),(404,162),(495,174),(544,191),(554,224)], [[(99,158),(147,114),(253,114),(253,158)],[(264,114),(323,114),(378,158),(264,158)]],(146,446),39),
'fastback': ([(44,226),(52,190),(124,176),(214,125),(278,106),(360,106),(453,170),(550,184),(582,204),(580,226)], [[(164,166),(225,130),(278,119),(300,119),(300,166)],[(312,119),(354,119),(427,166),(312,166)]],(147,472),40),
'wagon': ([(49,226),(51,123),(91,106),(353,106),(425,164),(538,177),(577,196),(576,226)], [[(73,121),(171,121),(171,164),(67,164)],[(183,120),(294,120),(294,164),(183,164)],[(307,120),(348,120),(401,164),(307,164)]],(146,470),40),
'suv': ([(44,228),(46,147),(102,139),(155,91),(377,91),(450,149),(547,163),(581,193),(580,228)], [[(119,140),(170,106),(276,106),(276,148)],[(289,106),(369,106),(423,148),(289,148)]],(147,472),46),
'box_suv': ([(51,228),(52,124),(118,124),(151,82),(380,82),(442,142),(545,152),(581,184),(580,228)], [[(125,126),(163,96),(270,96),(270,140),(117,140)],[(283,96),(371,96),(415,140),(283,140)]],(146,472),46),
'coupe': ([(43,224),(54,199),(144,184),(237,132),(296,120),(360,120),(448,175),(550,189),(584,208),(581,224)], [[(190,173),(246,141),(298,132),(320,132),(320,173)],[(331,132),(354,132),(419,173),(331,173)]],(144,474),39),
'roadster': ([(45,225),(56,198),(151,183),(251,175),(307,176),(344,161),(377,116),(398,116),(448,173),(551,185),(586,207),(580,225)], [[(357,163),(383,129),(394,129),(427,167)]],(147,474),39),
'pickup': ([(42,227),(43,146),(241,146),(271,94),(368,94),(432,148),(544,162),(582,192),(579,227)], [[(263,141),(282,108),(319,108),(319,145)],[(330,108),(361,108),(406,145),(330,145)]],(143,475),45),
'van': ([(46,228),(47,99),(75,78),(350,78),(402,111),(457,160),(547,171),(580,197),(579,228)], [[(248,97),(336,97),(336,153),(248,153)],[(350,95),(391,124),(419,153),(350,153)]],(147,474),43),
'workvan': ([(47,228),(48,100),(79,83),(340,83),(392,116),(455,162),(544,173),(580,198),(578,228)], [[(350,104),(385,130),(417,153),(350,153)]],(146,473),43),
'micro': ([(69,226),(70,147),(132,91),(315,91),(383,158),(481,171),(528,192),(542,226)], [[(102,147),(148,104),(246,104),(246,151)],[(258,104),(308,104),(359,151),(258,151)]],(145,433),38),
 'truck': ([(39,226),(40,57),(363,57),(364,152),(405,94),(481,94),(537,163),(583,180),(590,226)], [[(418,107),(474,107),(508,150),(413,150)]],(110,314,494),43),
}
def rounded(points, radius=6):
 def cuts(j):
  before=points[(j-1)%len(points)];here=points[j];after=points[(j+1)%len(points)]
  def toward(other):
   length=math.dist(here,other);ratio=min(radius,length*.22)/max(length,.001)
   return (here[0]+(other[0]-here[0])*ratio,here[1]+(other[1]-here[1])*ratio)
  return toward(before),here,toward(after)
 start=cuts(0)[2];out=f'M{start[0]:.2f} {start[1]:.2f}'
 for j in list(range(1,len(points)))+[0]:
  a,b,c=cuts(j);out+=f' L{a[0]:.2f} {a[1]:.2f} Q{b[0]} {b[1]} {c[0]:.2f} {c[1]:.2f}'
 return out+' Z'
def tint(hexcode, ratio):
 vals=[int(hexcode[j:j+2],16) for j in (1,3,5)]
 return '#'+''.join(f'{round(v+(255-v)*ratio):02x}' for v in vals)
colors=['#c94446','#4d7794','#e5d2a0','#394958','#7e9181','#abacae','#a55f45','#657c7c']
for i,m in enumerate(models):
 cid=m['id'];kind=m.get('body','passenger')
 shape={'passenger':['sedan','hatch','fastback','wagon'][i%4], 'sport':'coupe','suv':'box_suv' if i%2 else 'suv','pickup':'van' if i%3==0 else 'pickup','truck':'truck'}.get(kind,'sedan')
 fixed={'karya_nova':'micro','tivora_aven':'wagon','orvan_vera':'fastback','ravena_koru':'box_suv','valtorre_solis':'coupe','brenor_work':'workvan','karya_pico':'hatch','aldora_brix':'hatch','lavin_station':'wagon'}
 shape=fixed.get(cid,shape);body,windows,axles,radius=shapes[shape];paint=colors[i%len(colors)]
 if cid=='karya_nova':paint='#c87836'
 # Small model variation is an affine transform of ALL components, never individual points.
 scale=.97+(i%3)*.015
 parts=[]
 parts.append(f'<path d="{rounded(body)}" fill="url(#paint)" stroke="#394049" stroke-width="1.4" stroke-linejoin="round"/>')
 for window in windows:parts.append(f'<path d="{rounded(window,3)}" fill="url(#glass)" stroke="#45505a" stroke-width="2" stroke-linejoin="round"/>')
 # Door handles, side trim and lights follow the actual contour.
 bottom=min(x for x,y in body);front=max(x for x,y in body)
 parts.append(f'<path d="M{bottom+13} 215 H{front-12}" stroke="#313a43" stroke-width="6"/>')
 if shape!='truck':
  parts.append('<path d="M309 173 V213" stroke="#3d4851" stroke-width="1.2" opacity=".8"/>')
  parts.append('<path d="M284 177 H298" stroke="#dde3e9" stroke-width="3" stroke-linecap="round"/>')
 if shape not in ('roadster','truck','pickup'):parts.append('<path d="M207 178 H221" stroke="#dde3e9" stroke-width="3" stroke-linecap="round"/>')
 parts.append(f'<path d="M{front-45} 190 L{front-13} 198" stroke="#e2eef5" stroke-width="7" stroke-linecap="round"/>')
 parts.append(f'<path d="M{bottom+5} 184 H{bottom+21}" stroke="#eb6664" stroke-width="5" stroke-linecap="round"/>')
 for x in axles:
  parts.append(f'<circle cx="{x}" cy="232" r="{radius+4}" fill="#1c2229"/><circle cx="{x}" cy="232" r="{radius*.74}" fill="url(#rim)" stroke="#506071" stroke-width="2"/>')
  for spoke in range(6):
   a=math.tau*spoke/6;xx=x+math.cos(a)*radius*.6;yy=232+math.sin(a)*radius*.6
   parts.append(f'<path d="M{x} 232 L{xx:.2f} {yy:.2f}" stroke="#dce4ec" stroke-width="3.5"/>')
  parts.append(f'<circle cx="{x}" cy="232" r="7" fill="#607181"/>')
 svg=f'''<svg xmlns="http://www.w3.org/2000/svg" width="1280" height="640" viewBox="0 0 640 320"><defs>
 <linearGradient id="paint" x1="0" y1="0" x2="0" y2="1"><stop stop-color="{tint(paint,.25)}"/><stop offset=".3" stop-color="{paint}"/><stop offset=".5" stop-color="{paint}"/><stop offset="1" stop-color="#363b43"/></linearGradient>
 <linearGradient id="glass" x2="0" y2="1"><stop stop-color="#91a9b9"/><stop offset=".2" stop-color="#3b5161"/><stop offset="1" stop-color="#1d2b36"/></linearGradient>
 <linearGradient id="rim" x2="1" y2="1"><stop stop-color="#e3e9ee"/><stop offset="1" stop-color="#4c6072"/></linearGradient></defs>
 <ellipse cx="315" cy="275" rx="266" ry="8" fill="#29343f" opacity=".15"/>
 <g transform="translate({320*(1-scale):.2f},0) scale({scale:.3f},1)">{''.join(parts)}</g></svg>'''
 (root/'art/cars'/f'{cid}.svg').write_text(svg,encoding='utf-8')
print(f'{len(models)} aligned SVG vehicles generated')
