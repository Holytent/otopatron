const fs=require('node:fs'),vm=require('node:vm'),assert=require('node:assert/strict');
class Element {
 constructor(tag){this.tag=tag;this.style={};this.children=[];this.events={};this.value='';}
 append(...nodes){for(const n of nodes){n.parent=this;this.children.push(n);}}
 remove(){if(this.parent)this.parent.children=this.parent.children.filter(n=>n!==this);}
 setAttribute(){} addEventListener(name,fn){this.events[name]=fn;}
 focus(options){this.focusOptions=options;}blur(){this.blurred=true;}setSelectionRange(){}
}
const body=new Element('body'),listeners=new Map(),commits=[];
const viewport={height:360,offsetTop:20,addEventListener:(name,fn)=>listeners.set(name,fn),removeEventListener:(name,fn)=>{if(listeners.get(name)===fn)listeners.delete(name);}};
const context={window:{visualViewport:viewport},innerHeight:800,document:{body,createElement:tag=>new Element(tag)}};
vm.createContext(context);vm.runInContext(fs.readFileSync('otopatron_recovered/OtoPatron/web/safari/mobile-editor.js','utf8'),context);
const editor=context.window.otoEditor;
editor.open('Test','Oyuncu adı',false,false,(value,ok)=>commits.push({value,ok}));
let backdrop=body.children[0],panel=backdrop.children[0],input=panel.children[1];
assert(backdrop.style.cssText.includes('100lvh'));assert(backdrop.style.cssText.includes('rgba(16,20,28,.88)'));
assert.equal(panel.style.maxHeight,'336px');assert.equal(panel.style.top,'32px');assert.equal(input.focusOptions.preventScroll,true);
let stopped=0;input.events.keydown({key:'a',stopPropagation(){stopped++;}});input.events.keyup({stopPropagation(){stopped++;}});assert.equal(stopped,2,'Typing is isolated from game keyboard');assert(panel.style.cssText.includes('#14283a'));
input.value='Yeni ad';panel.children[2].children[0].onclick();assert.equal(commits[0].value,'Yeni ad');assert.equal(commits[0].ok,true);assert.equal(body.children.length,0);assert.equal(listeners.size,0);
editor.open('100000','Fiyat',false,true,(value,ok)=>commits.push({value,ok}));
panel=body.children[0].children[0];assert.equal(panel.children[1].inputMode,'decimal');panel.children[2].children[1].onclick();assert.equal(commits[1].ok,false);
editor.open('A','Şehir',false,false,()=>{});editor.open('B','Bilgi',true,false,()=>{});assert.equal(body.children.length,1);assert.equal(listeners.size,2);
console.log('PASS: keyboard viewport fit, full backdrop, save/cancel, numeric input and editor cleanup');
