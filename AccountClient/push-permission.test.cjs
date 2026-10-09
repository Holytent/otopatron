const fs=require('node:fs'),vm=require('node:vm'),assert=require('node:assert/strict');
class El{constructor(tag){this.tag=tag;this.children=[];this.style={};this.textContent='';}append(...nodes){nodes.forEach(n=>{n.parent=this;this.children.push(n);});}remove(){this.parent.children=this.parent.children.filter(x=>x!==this);}setAttribute(){}focus(){}}
function setup({permission='default',stored={},standalone=true,fail=false}={}){
 const body=new El('body'),memory=new Map(Object.entries(stored));let requested=0,subscribed=0;const calls=[];
 const all=n=>[n,...n.children.flatMap(all)];
 const Notification={permission,requestPermission:async()=>{requested++;return permission==='denied'?'denied':'granted';}};
 const context={document:{body,hidden:false,createElement:t=>new El(t),getElementById:id=>all(body).find(x=>x.id===id),addEventListener(){}},navigator:{userAgent:'iPhone',standalone,serviceWorker:{ready:Promise.resolve({pushManager:{getSubscription:async()=>null,subscribe:async()=>{subscribed++;return{toJSON:()=>({endpoint:'mock'})};}}})}},Notification,localStorage:{getItem:k=>memory.get(k)||null,setItem:(k,v)=>memory.set(k,v),removeItem:k=>memory.delete(k)},crypto:{randomUUID:()=> 'x'},matchMedia:()=>({matches:standalone}),Uint8Array,atob,fetch:async(url)=>{calls.push(url);return{ok:!fail,json:async()=>({publicKey:'YQ==',ok:true})};}};
 context.window={Notification,PushManager:{}};vm.createContext(context);vm.runInContext(fs.readFileSync('otopatron_recovered/OtoPatron/web/safari/push-client.js','utf8'),context);
 return{api:context.window.otoPush,body,memory,calls,find:t=>all(body).find(x=>x.textContent===t),counts:()=>({requested,subscribed})};
}
(async()=>{
 let s=setup();s.api.offer();s.api.offer();assert.equal(s.body.children.length,1);assert.equal(s.counts().requested,0);s.find('İzin verme').onclick();assert.equal(s.body.children.length,0);s.api.offer();assert.equal(s.body.children.length,0);
 s=setup();s.api.offer();await s.find('İzin ver').onclick();assert.equal(s.body.children.length,0);assert.equal(s.memory.get('oto-push-enabled'),'1');assert.equal(s.counts().subscribed,1);assert(s.calls.some(x=>x.endsWith('/subscribe')));
 for(const opts of [{permission:'denied'},{standalone:false},{stored:{'oto-push-choice-v2':'allowed'}}]){s=setup(opts);s.api.offer();assert.equal(s.body.children.length,0);}
 s=setup({fail:true});s.api.offer();await s.find('İzin ver').onclick();assert.equal(s.body.children.length,1);assert.equal(s.memory.get('oto-push-enabled'),undefined);assert.equal(s.find('İzin ver').disabled,false);
 console.log('PASS: opt-in only, dismiss persistence, enrollment, denied/unsupported suppression, recoverable service failure');
})();
