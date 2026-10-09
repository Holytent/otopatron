const fs=require('node:fs'),vm=require('node:vm'),assert=require('node:assert/strict'),crypto=require('node:crypto');
const folder=process.argv[2]||'web_v194';
(async()=>{
 const html=fs.readFileSync(folder+'/index.html','utf8');
 assert(!/<script src=/.test(html),'No parser-blocking external scripts');
 assert(!html.includes('$GODOT'),'Export placeholders replaced');
 const source=html.match(/<script>([\s\S]+?)<\/script>/)[1];
 const elements={start:{},message:{},progress:{style:{}},canvas:{width:0,height:0,getBoundingClientRect:()=>({width:390,height:844})}};
 let scripts=0;const timers=[];
 const context={matchMedia:()=>({matches:true}),window:{devicePixelRatio:3,addEventListener(){},visualViewport:{addEventListener(){}}},document:{getElementById:id=>elements[id],createElement:()=>({remove(){}}),head:{appendChild:s=>{scripts++;s.onerror();}}},navigator:{},location:{reload(){}},console:{error(){}},setTimeout:(fn,ms)=>{timers.push({fn,ms});return timers.length;},clearTimeout(){}};
 vm.createContext(context);vm.runInContext(source,context);
 assert.equal(scripts,0,'UI ready before network');assert.equal(typeof elements.start.onclick,'function');
 await elements.start.onclick();assert.equal(elements.start.disabled,false);assert(elements.message.textContent.includes('indirilemedi'));assert.equal(elements.start.textContent,'TEKRAR DENE');
 const loader=fs.readFileSync(folder+'/engine-loader.js','utf8');const parts=JSON.parse(loader.match(/const parts = (\[[^;]+\]);/)[1]);
 assert.equal(parts.length,10);const expected=Buffer.concat(parts.map(name=>fs.readFileSync(folder+'/'+name)));
 assert(parts.every(name=>name.includes('-4m-')),'New chunk layout must not reuse old immutable 20 MiB URLs');
 assert(parts.every(name=>fs.statSync(folder+'/'+name).size<=4*1024*1024));
 const calls=[];const engine={window:{fetch:async url=>{calls.push(String(url));return new Response(fs.readFileSync(folder+'/'+new URL(url).pathname.slice(1)));}},document:{baseURI:'https://game.invalid/'},URL,Request,Response,ReadableStream,AbortController,setTimeout,clearTimeout};
 vm.createContext(engine);vm.runInContext(loader,engine);const response=await engine.window.fetch('index.wasm');
 const actual=Buffer.from(await response.arrayBuffer());assert.equal(actual.length,39514754);assert.equal(crypto.createHash('sha256').update(actual).digest('hex'),crypto.createHash('sha256').update(expected).digest('hex'));assert.equal(calls.length,10);
 engine.window.fetch=async()=>new Response('other');
 // The same loader must propagate an HTTP error, never yield HTML as engine bytes.
 engine.window.fetch=async()=>new Response('',{status:503});vm.runInContext(loader,engine);
 await assert.rejects(async()=>{const r=await engine.window.fetch('index.wasm');await r.arrayBuffer();},/503/);
 console.log('PASS: initial UI without network, failed dependency recovery, 10 bounded engine parts, exact engine byte hash and HTTP failure');
})().catch(error=>{console.error(error);process.exitCode=1;});
