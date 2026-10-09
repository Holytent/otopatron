(() => {
 const config={endpoint:'https://otopatron-notifications.ozkeskinr.workers.dev'}; // Fill after deploying notification service.
 const key='oto-push-client-v1';
 let identity;
 try{identity=JSON.parse(localStorage.getItem(key));}catch{}
 if(!identity){identity={id:crypto.randomUUID(),token:crypto.randomUUID()+crypto.randomUUID()};localStorage.setItem(key,JSON.stringify(identity));}
 let state={listings:[]}, pending=[], active=false;
 const choiceKey='oto-push-choice-v2';
 function supported(){return 'Notification' in window&&'PushManager' in window&&'serviceWorker' in navigator&&(!/iPhone|iPad|iPod/.test(navigator.userAgent)||navigator.standalone||matchMedia('(display-mode: standalone)').matches);}
 async function enablePush(){
  if(!supported())throw new Error('Bu açılışta telefon bildirimleri desteklenmiyor.');
  const permission=await Notification.requestPermission();
  if(permission!=='granted'){localStorage.setItem(choiceKey,'declined');throw new Error('Bildirim izni verilmedi. Oyuna devam edebilirsin.');}
  const r=await fetch(config.endpoint+'/key');if(!r.ok)throw new Error('Bildirim servisine bağlanılamadı. Tekrar dene.');
  const {publicKey}=await r.json();const padded=publicKey.replace(/-/g,'+').replace(/_/g,'/');
  const bytes=Uint8Array.from(atob(padded),c=>c.charCodeAt(0));
  const reg=await navigator.serviceWorker.ready;
  const subscription=await reg.pushManager.getSubscription()||await reg.pushManager.subscribe({userVisibleOnly:true,applicationServerKey:bytes});
  await request('/subscribe',{subscription:subscription.toJSON()});active=true;
  localStorage.setItem('oto-push-enabled','1');localStorage.setItem(choiceKey,'allowed');await presence(state);
 }
 function offer(){
  if(!supported()||active||localStorage.getItem(choiceKey)||Notification.permission==='denied'||document.getElementById('oto-push-offer'))return;
  const box=document.createElement('section');box.id='oto-push-offer';box.style.cssText='position:fixed;inset:0;z-index:16000;background:#0008;display:grid;place-items:center;padding:20px;box-sizing:border-box;font:16px system-ui';
  const card=document.createElement('div');card.setAttribute('role','dialog');card.setAttribute('aria-modal','true');card.style.cssText='width:100%;max-width:340px;box-sizing:border-box;background:white;color:#25252e;border-radius:20px;padding:24px;box-shadow:0 12px 40px #0003';
  const title=document.createElement('h2');title.textContent='Galerinden haber al';title.style.cssText='font-size:21px;margin:0 0 12px';
  const note=document.createElement('p');note.textContent='Yeni fırsatları ve galerine dönüş hatırlatmalarını telefonuna gönderelim mi? Seçimini Ayarlar bölümünden değiştirebilirsin.';note.setAttribute('role','status');
  const yes=document.createElement('button');yes.textContent='İzin ver';const no=document.createElement('button');no.textContent='İzin verme';
  for(const b of [yes,no]){b.type='button';b.style.cssText='width:100%;min-height:46px;margin-top:10px;border-radius:12px;border:1px solid #bc263b;font:600 16px system-ui;background:white;color:#bc263b';}
  yes.style.background='#bc263b';yes.style.color='white';
  yes.onclick=async()=>{yes.disabled=true;try{await enablePush();box.remove();}catch(e){note.textContent=e.message;yes.disabled=false;}};
  no.onclick=()=>{localStorage.setItem(choiceKey,'declined');box.remove();};
  card.append(title,note,yes,no);box.append(card);document.body.append(box);yes.focus();
 }
 async function request(path,data){const r=await fetch(config.endpoint+path,{method:'POST',headers:{'Content-Type':'application/json'},body:JSON.stringify({...identity,...data})});if(!r.ok)throw new Error('Bildirim servisine bağlanılamadı.');return r.json();}
 async function presence(next){state=next;if(!config.endpoint||!active)return;try{const r=await request('/presence',{...state,visible:!document.hidden});if(r.inquiry&&localStorage.getItem('oto-push-last-inquiry')!==r.inquiry.id){pending.push(r.inquiry);localStorage.setItem('oto-push-last-inquiry',r.inquiry.id);}}catch{}}
 function openSettings(){
  const box=document.createElement('div');box.style.cssText='position:fixed;inset:0;z-index:10001;background:#f7f5f5;color:#25252e;padding:32px 20px;overflow:auto;font:16px system-ui';
  const h=document.createElement('h2');h.textContent='Telefon bildirimleri';
  const status=document.createElement('p');
  const enable=document.createElement('button');enable.textContent='BİLDİRİMLERE İZİN VER';enable.disabled=!config.endpoint;
  if(!config.endpoint)status.textContent='Bildirim servisi henüz bağlanmadı. Diğer oyun özellikleri çalışır; telefon bildirimi gönderilmez.';
  enable.onclick=async()=>{try{
   await enablePush();status.textContent='Bildirimler açık.';
  }catch(e){status.textContent=e.message;}};
  const disable=document.createElement('button');disable.textContent='BİLDİRİMLERİ KAPAT';disable.onclick=async()=>{try{if(config.endpoint)await request('/unsubscribe',{});const reg=await navigator.serviceWorker.ready;await(await reg.pushManager.getSubscription())?.unsubscribe();active=false;localStorage.removeItem('oto-push-enabled');status.textContent='Bildirimler kapalı.';}catch(e){status.textContent=e.message;}};
  const close=document.createElement('button');close.textContent='OYUNA DÖN';close.onclick=()=>box.remove();box.append(h,status,enable,disable,close);document.body.append(box);
 }
 active=localStorage.getItem('oto-push-enabled')==='1'&&supported()&&Notification.permission==='granted';
 document.addEventListener('visibilitychange',()=>presence(state));
 window.otoPush={presence,openSettings,offer,take:()=>JSON.stringify(pending.splice(0))};
 // Restore server registration if it expired, without requesting permission again.
 if(active&&supported()&&Notification.permission==='granted')enablePush().catch(()=>{});
})();
