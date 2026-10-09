import assert from 'node:assert/strict';
import worker from './src/worker.js';
import webpush from 'web-push';
import {GAPS,messages} from './src/reminders.js';
let now=10_000_000,stored={token:'a'.repeat(72),lastSeen:now,subscription:{},listings:[{uid:42,name:'Sedan',fair:true}],sent:3};
const id='a'.repeat(36),key='player:'+id;
const env={ALLOWED_ORIGIN:'https://otopatron.pages.dev',PLAYERS:{get:async()=>structuredClone(stored),put:async(_k,v)=>{stored=JSON.parse(v)},delete:async()=>{stored=null},list:async()=>({keys:[{name:key}],list_complete:true})}};
const oldNow=Date.now,oldFetch=globalThis.fetch,oldVapid=webpush.setVapidDetails,oldGenerate=webpush.generateRequestDetails;
const received=[];let fail=false;
Date.now=()=>now;
webpush.setVapidDetails=()=>{};
webpush.generateRequestDetails=(_sub,payload)=>({endpoint:'https://example.invalid',headers:{},body:payload});
globalThis.fetch=async(_url,opts)=>{if(fail){fail=false;return new Response('',{status:503})}received.push(JSON.parse(opts.body));return new Response('',{status:201})};
try{
 const start=now;
 assert.deepEqual(GAPS,[5,5,5,5,10]);
 await worker.scheduled({},env);assert.equal(received.length,0);
 for(const [index,minute] of [5,10,15,20,30].entries()){
  now=start+minute*60000-1;await worker.scheduled({},env);assert.equal(received.length,index);
  now++;await worker.scheduled({},env);assert.equal(received.length,index+1);
  await worker.scheduled({},env);assert.equal(received.length,index+1);
 }
 assert.equal(new Set(received.map(x=>x.tag)).size,5);
 assert.equal(new Set(received.map(x=>x.body)).size,5);
 assert.match(received[0].body,/Sedan/);assert.equal(stored.pendingInquiry.uid,42);
 now+=5*60000;fail=true;await worker.scheduled({},env);assert.equal(received.length,5);
 await worker.scheduled({},env);assert.equal(received.length,5);
 now+=60000;await worker.scheduled({},env);assert.equal(received.length,6);
 now+=60*60000;await worker.scheduled({},env);assert.equal(received.length,7);
 await worker.scheduled({},env);assert.equal(received.length,7);
 assert.equal(stored.spacedReminder.dueAt,now+5*60000);
 async function presence(visible){return worker.fetch(new Request(env.ALLOWED_ORIGIN+'/presence',{method:'POST',headers:{Origin:env.ALLOWED_ORIGIN},body:JSON.stringify({id,token:stored.token,visible,listings:stored.listings})}),env)}
 const lastSeen=stored.lastSeen;
 const hidden=await (await presence(false)).json();assert.equal(hidden.inquiry,null);assert.equal(stored.lastSeen,now);assert.ok(stored.pendingInquiry);
 const closedAt=stored.lastSeen;
 now+=60000;await presence(false);assert.equal(stored.lastSeen,closedAt);
 const active=await (await presence(true)).json();assert.equal(active.inquiry.uid,42);assert.equal(stored.lastSeen,now);assert.equal(stored.pendingInquiry,null);
 await worker.scheduled({},env);assert.equal(received.length,7);
 now+=5*60000;await worker.scheduled({},env);assert.equal(received.length,8);
 assert.ok(messages(null).every(x=>!x.includes('müşteri ilgileniyor')));
 // Existing five-message batches must migrate without another immediate burst.
 stored.lastSeen=now-3600000;stored.lastSent=now;delete stored.spacedReminder;
 stored.reminderBatch={next:2};await worker.scheduled({},env);assert.equal(received.length,8);
 now+=5*60000;await worker.scheduled({},env);assert.equal(received.length,9);
 assert.equal(stored.reminderBatch,undefined);
 console.log('PASS: single messages at 5/10/15/20/30 minutes, retries, late-tick suppression, presence and legacy migration');
}finally{Date.now=oldNow;globalThis.fetch=oldFetch;webpush.setVapidDetails=oldVapid;webpush.generateRequestDetails=oldGenerate}
