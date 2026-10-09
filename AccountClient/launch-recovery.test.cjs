const fs=require('fs'),vm=require('vm'),assert=require('assert/strict');
const folder=process.argv[2];
const html=fs.readFileSync(folder+'/index.html','utf8'), source=html.match(/<script>([\s\S]+?)<\/script>/)[1];
const deps=JSON.parse(source.match(/const dependencies = (\[[^;]+\]);/)[1]);
assert.equal(deps.length,1);assert(deps[0].startsWith('launch-bundle-'));
assert(/class="logo"><img src="data:image\/png;base64,/.test(html));
new vm.Script(fs.readFileSync(folder+'/'+deps[0],'utf8'));
function setup(failures){let appended=0,starts=0,reloads=0;const timers=new Map();let next=0;
 const elements={start:{},message:{},progress:{style:{}},canvas:{focus(){},getBoundingClientRect:()=>({width:390,height:844})}};
 const context={window:{devicePixelRatio:2,addEventListener(){},visualViewport:{addEventListener(){}},otoStartup:{engineReady(){}}},matchMedia:()=>({matches:true}),document:{getElementById:id=>elements[id],createElement:()=>({remove(){}}),head:{appendChild:s=>{appended++; if(appended<=failures)s.onerror();else s.onload();}}},navigator:{},location:{reload(){reloads++;}},console:{error(){}},setTimeout:(fn,ms)=>{const id=++next;timers.set(id,{fn,ms});return id;},clearTimeout:id=>timers.delete(id),Engine:class{static getMissingFeatures(){return []}async startGame(){starts++;}}};
 vm.createContext(context);vm.runInContext(source,context);
 return {elements,timers,run:()=>elements.start.onclick(),get appended(){return appended},get starts(){return starts},get reloads(){return reloads}};
}
(async()=>{
 let t=setup(2);await t.run();assert.equal(t.appended,3);assert.equal(t.starts,1);assert.equal(t.timers.size,0);
 t=setup(3);await t.run();assert.equal(t.starts,0);assert.equal(t.elements.start.disabled,false);assert.equal(t.elements.start.textContent,'TEKRAR DENE');assert.equal(t.timers.size,0);t.elements.start.onclick();assert.equal(t.reloads,1);
 const elements={start:{},message:{},progress:{style:{}},canvas:{getBoundingClientRect:()=>({width:390,height:844})}};const pending=[],timers=[];let executed=0;
 const slow={matchMedia:()=>({matches:true}),window:{devicePixelRatio:2,addEventListener(){},visualViewport:{addEventListener(){}}},document:{getElementById:id=>elements[id],createElement:()=>({remove(){}}),head:{appendChild:s=>pending.push(s)}},navigator:{},location:{reload(){}},console:{error(){}},setTimeout:(fn,ms)=>{timers.push({fn,ms});return timers.length},clearTimeout(){},Engine:class{static getMissingFeatures(){return []}async startGame(){executed++;}}};
 vm.createContext(slow);vm.runInContext(source,slow);const running=elements.start.onclick();assert.equal(pending.length,1);assert.equal(timers[0].ms,120000);assert(!timers.some(t=>t.ms===25000));timers[0].fn();pending[0].onload();await running;assert.equal(executed,0);assert.equal(elements.start.disabled,false);
 console.log('PASS: one ordered bundle compiles, embedded logo, two failures recover once, exhausted retries recover UI, slow connection gets 120s, late completion cannot start engine');
})().catch(e=>{console.error(e);process.exitCode=1});
