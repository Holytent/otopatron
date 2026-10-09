const fs=require('node:fs'),vm=require('node:vm'),assert=require('node:assert/strict');
class Element {
  constructor(tag){this.tag=tag;this.children=[];this.style={};this.dataset={};this.textContent='';this.value='';}
  append(...nodes){for(const node of nodes){node.parent=this;this.children.push(node);}}
  remove(){if(this.parent)this.parent.children=this.parent.children.filter(x=>x!==this);}
  setAttribute(){}
  querySelector(selector){return all(this).find(x=>selector==='[data-message]'&&x.dataset.message==='true')||null;}
}
function all(node){return [node,...node.children.flatMap(all)];}
const settle=async()=>{for(let i=0;i<8;i++)await new Promise(r=>setImmediate(r));};
async function scenario(session,record){
 const body=new Element('body'),events=[],writes=[];let authListener;
 const client={auth:{onAuthStateChange(fn){authListener=fn;},getSession:async()=>({data:{session}}),signOut:async()=>{session=null;authListener('SIGNED_OUT');},signInWithPassword:async()=>({data:{session:{user:{email:'test@example.invalid'}}}}),signUp:async()=>({data:{session:null}}),resetPasswordForEmail:async()=>({}),updateUser:async()=>({})},from:()=>({select:()=>({maybeSingle:async()=>({data:record})})}),rpc:async(name,args)=>{writes.push(args);return {data:args.p_revision+1};}};
 const context={createClient:()=>client,location:{origin:'https://example.invalid'},fetch:async()=>({json:async()=>({url:'mock',publishableKey:'public'})}),document:{body,createElement:tag=>new Element(tag),addEventListener(){}},window:{},queueMicrotask,setTimeout:()=>1,clearTimeout(){},confirm:()=>false};
 context.window.visualViewport=null;vm.createContext(context);
 vm.runInContext(fs.readFileSync(__dirname+'/accounts.js','utf8').replace(/^import[^\n]+\n/,''),context);
 const api=context.window.otoAccount;api.bind(value=>events.push(JSON.parse(value)));api.start();await settle();
 const click=async(text)=>{const b=all(body).find(x=>x.tag==='button'&&x.textContent===text);assert(b,'Missing button '+text);await b.onclick();await settle();};
 return {body,events,writes,api,click,find:text=>all(body).some(x=>x.textContent===text)};
}
(async()=>{
 let s=await scenario(null,null);assert(s.find('Giriş yap'));assert.equal(s.events.length,0);await s.click('Misafir olarak devam et');assert.equal(s.events[0].type,'gate_done');assert.equal(s.body.children.length,0);
 s=await scenario(null,null);await s.click('Şifremi unuttum');assert(s.find('Giriş ekranına dön'));await s.click('Giriş ekranına dön');assert(s.find('Giriş yap'));
 s=await scenario({user:{email:'test@example.invalid'}},{revision:8,snapshot:{version:1,cars:[],money:300000}});assert(s.find('Devam et'));assert.equal(s.events.length,0);await s.click('Devam et');assert.deepEqual(s.events.map(x=>x.type),['load','gate_done']);assert.equal(s.body.children.length,0);s.api.queue(JSON.stringify({version:1,cars:[],money:300001}));await s.api.flush();assert.equal(s.writes[0].p_revision,8);
 s=await scenario({user:{email:'test@example.invalid'}},null);await s.click('Misafir olarak devam et');s.api.queue('{}');await s.api.flush();assert.equal(s.writes.length,0);
 s=await scenario(null,null);await s.click('Yeni hesap oluştur');let fields=all(s.body).filter(n=>n.tag==='input');fields.find(n=>n.type==='email').value='audit@example.invalid';fields.find(n=>n.type==='password').value='short';await s.click('Kayıt ol');assert(all(s.body).some(n=>n.textContent==='En az 10 karakterli şifre kullan.'));fields.find(n=>n.type==='password').value='audit_password_123';await s.click('Kayıt ol');assert(all(s.body).some(n=>n.textContent.includes('doğrulama bağlantısına')));
 s=await scenario(null,null);fields=all(s.body).filter(n=>n.tag==='input');fields.find(n=>n.type==='email').value='audit@example.invalid';fields.find(n=>n.type==='password').value='audit_password_123';await s.click('Giriş yap');assert(s.events.some(e=>e.type==='save_request'));assert(s.events.some(e=>e.type==='gate_done'));
 console.log('PASS: guest opening, reset navigation, persisted-session Continue, cloud revision, guest isolation, registration validation and login');
})().catch(e=>{console.error(e);process.exitCode=1;});
