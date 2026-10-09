const fs=require('node:fs'),vm=require('node:vm'),assert=require('node:assert/strict');
(async()=>{
 const listeners={},stored=new Map(),waits=[];let activation=0,requested=[];
 const cache={put:async(key,response)=>stored.set(String(key),response.clone()),match:async key=>stored.get(String(key))?.clone()};
 const context={URL,Response,Headers,AbortController,setTimeout,clearTimeout,console,caches:{open:async()=>cache,keys:async()=>[],delete:async()=>true},self:{registration:{scope:'https://game.invalid/',navigationPreload:{disable:async()=>{}}},location:{origin:'https://game.invalid'},clients:{claim:async()=>{}},skipWaiting:async()=>activation++,addEventListener:(name,fn)=>listeners[name]=fn},fetch:async key=>{requested.push(typeof key==='string'?key:key.url);const response=new Response('<h1>OtoPatron</h1>',{headers:{'Content-Type':'text/html'}});Object.defineProperty(response,'redirected',{value:true});return response;}};
 vm.createContext(context);vm.runInContext(fs.readFileSync('otopatron_recovered/OtoPatron/web/safari/sw-safari.js','utf8').replace("const LAUNCH_HTML = '';", "const LAUNCH_HTML = '<h1>OtoPatron</h1>';"),context);
 listeners.install({waitUntil:p=>waits.push(p)});await Promise.all(waits);assert.equal(activation,1);assert.deepEqual(requested,[]);
 context.fetch=()=>new Promise(()=>{});
 let reply;listeners.fetch({request:{url:'https://game.invalid/',method:'GET',mode:'navigate'},respondWith:r=>reply=r});
 const began=Date.now();const opening=await reply;assert.equal(opening.redirected,false);assert((await opening.text()).includes('OtoPatron'));assert(Date.now()-began<2500,'Stalled fetch must fall back within 1.5 seconds');
 reply=undefined;listeners.fetch({request:{url:'https://game.invalid/engine.bin',method:'GET',mode:'cors'},respondWith:r=>reply=r});assert.equal(reply,undefined,'Engine downloads remain browser managed');
 listeners.activate({waitUntil:p=>waits.push(p)});await Promise.all(waits);
 class El{constructor(){this.style={};this.children=[];}append(...nodes){this.children.push(...nodes);for(const n of nodes)n.parent=this;}remove(){this.parent.children=this.parent.children.filter(n=>n!==this);}}
 const body=new El();const elements={launch:{style:{display:'flex'}},message:{},start:{},canvas:{addEventListener:(name,fn)=>listeners[name]=fn}};const timers=[];let now=10000,reloaded=0;
 const guard={window:{addEventListener:(name,fn)=>listeners[name]=fn},document:{body,createElement:()=>new El(),hidden:false,getElementById:id=>elements[id],addEventListener:(name,fn)=>listeners[name]=fn},location:{reload:()=>reloaded++},Date:{now:()=>now},setTimeout:(fn,ms)=>{timers.push({fn,ms});return timers.length;},clearTimeout(){}};
 vm.createContext(guard);vm.runInContext(fs.readFileSync('otopatron_recovered/OtoPatron/web/safari/startup-guard.js','utf8'),guard);
 guard.window.otoStartup.engineReady();assert.equal(elements.launch.style.display,'flex');guard.window.otoStartup.frame();assert.equal(elements.launch.style.display,'none');
 let prevented=false;listeners.webglcontextlost({preventDefault:()=>prevented=true});assert(prevented);assert.equal(elements.launch.style.display,'none');assert.equal(body.children.length,1);assert.equal(reloaded,0);listeners.webglcontextlost({preventDefault(){}});assert.equal(body.children.length,1);body.children[0].children[0].children[1].onclick();assert.equal(reloaded,1);
 listeners.webglcontextrestored();assert.equal(body.children.length,0);assert.equal(elements.launch.style.display,'none');guard.window.otoUpdates={save(){}};listeners.pageshow();now+=10000;assert.equal(elements.launch.style.display,'none');assert.equal(reloaded,1);guard.window.otoStartup.frame();assert.equal(elements.launch.style.display,'none');assert(!timers.some(t=>t.ms===9000));
 console.log('PASS: embedded opening without network/cache/redirect dependency, engine passthrough, first-frame guard and resume recovery');
})().catch(error=>{console.error(error);process.exitCode=1;});
