import webpush from 'web-push';
import {messages,GAPS} from './reminders.js';
import {nextReminder,advanceReminder} from './spacing.js';
const headers=e=>({'Access-Control-Allow-Origin':e.ALLOWED_ORIGIN,'Access-Control-Allow-Methods':'GET,POST,OPTIONS','Access-Control-Allow-Headers':'Content-Type','Content-Type':'application/json','Vary':'Origin'});
const json=(env,data,status=200)=>new Response(JSON.stringify(data),{status,headers:headers(env)});
export default {
 async fetch(req,env){
  if(req.headers.get('Origin')!==env.ALLOWED_ORIGIN)return new Response('Forbidden',{status:403});
  if(req.method==='OPTIONS')return new Response(null,{headers:headers(env)});
  const path=new URL(req.url).pathname;
  if(path==='/key'&&req.method==='GET')return json(env,{publicKey:env.VAPID_PUBLIC_KEY});
  if(req.method!=='POST')return json(env,{error:'Method'},405);
  if(Number(req.headers.get('Content-Length'))>16000)return json(env,{error:'Size'},413);
  let body;try{const raw=await req.text();if(raw.length>16000)return json(env,{error:'Size'},413);body=JSON.parse(raw);}catch{return json(env,{error:'JSON'},400);}
  if(!/^[a-f0-9-]{36}$/.test(body.id||'')||!/^[a-f0-9-]{72}$/.test(body.token||''))return json(env,{error:'Identity'},400);
  const key='player:'+body.id;const existing=await env.PLAYERS.get(key,'json');
  if(existing&&existing.token!==body.token)return json(env,{error:'Forbidden'},403);
  if(path==='/unsubscribe'){await env.PLAYERS.delete(key);return json(env,{ok:true});}
  if(path==='/subscribe'){
   const sub=body.subscription;let url;try{url=new URL(sub.endpoint);}catch{return json(env,{error:'Endpoint'},400);}
   if(url.protocol!=='https:'||!['web.push.apple.com','fcm.googleapis.com','updates.push.services.mozilla.com'].some(host=>url.hostname===host||url.hostname.endsWith('.'+host)))return json(env,{error:'Provider'},400);
   if(!sub.keys?.p256dh||!sub.keys?.auth)return json(env,{error:'Keys'},400);
   await env.PLAYERS.put(key,JSON.stringify({...existing,token:body.token,subscription:sub,lastSeen:Date.now(),visible:true}),{expirationTtl:60*86400});return json(env,{ok:true});
  }
  if(path==='/presence'&&existing){
   const inquiry=body.visible ? existing.pendingInquiry||null : null;
   if(body.visible)existing.pendingInquiry=null;
   const listings=(body.listings||[]).slice(0,24).map(x=>({uid:Number(x.uid),name:String(x.name).slice(0,100),fair:!!x.fair}));
   const now=Date.now(), visible=!!body.visible;
   const changed=JSON.stringify(existing.listings)!==JSON.stringify(listings);
   const visibilityChanged=visible!==existing.visible;
   existing.listings=listings;
   // Heartbeats arrive frequently; avoid unnecessary KV writes.
   if(inquiry||visible!==existing.visible||changed||now-existing.lastSeen>=60000){
    existing.visible=visible;if(visible||visibilityChanged)existing.lastSeen=now;
    await env.PLAYERS.put(key,JSON.stringify(existing),{expirationTtl:60*86400});
   }
   return json(env,{ok:true,inquiry});
  }
  return json(env,{error:'Not subscribed'},404);
 },
 async scheduled(_event,env){
  webpush.setVapidDetails(env.VAPID_SUBJECT,env.VAPID_PUBLIC_KEY,env.VAPID_PRIVATE_KEY);
  let cursor;
  do{
   const list=await env.PLAYERS.list({prefix:'player:',cursor,limit:100});
   for(const entry of list.keys){
    const p=await env.PLAYERS.get(entry.name,'json');if(!p?.subscription)continue;
    const now=Date.now();
    if(now-p.lastSeen<GAPS[0]*60000)continue;
    const state=nextReminder(p,now,GAPS);
    if(now<state.dueAt)continue;
    const car=p.listings?.find(x=>x.fair && x.uid===p.pendingInquiry?.uid)||p.listings?.find(x=>x.fair);
    const inquiry=state.index===0&&car ? (p.pendingInquiry?.uid===car.uid?p.pendingInquiry:{id:crypto.randomUUID(),uid:car.uid,name:car.name}) : null;
    const payload={title:'OtoPatron',body:messages(car)[state.index],tag:`otopatron-${state.session}-${state.dueAt}`};
    try{
     // A short TTL prevents stale reminders stacking up after an offline period.
     const outgoing=webpush.generateRequestDetails(p.subscription,JSON.stringify(payload),{TTL:180,urgency:'normal'});
     const response=await fetch(outgoing.endpoint,{method:'POST',headers:outgoing.headers,body:outgoing.body});
     if(!response.ok)throw Object.assign(new Error('Push rejected'),{statusCode:response.status});
     if(inquiry)p.pendingInquiry=inquiry;
     p.spacedReminder=advanceReminder(state,now,GAPS);p.lastSent=now;
     delete p.reminderBatch;
     await env.PLAYERS.put(entry.name,JSON.stringify(p),{expirationTtl:60*86400});
    }catch(e){
     if(e.statusCode===404||e.statusCode===410)await env.PLAYERS.delete(entry.name);
     else {
      p.spacedReminder={...state,dueAt:now+60000};
      await env.PLAYERS.put(entry.name,JSON.stringify(p),{expirationTtl:60*86400});
      console.error(JSON.stringify({message:'Push delivery failed',status:e.statusCode||0}));
     }
    }
   }
   cursor=list.list_complete?null:list.cursor;
  }while(cursor);
 }
};
