// Embedded fallback bounds server delays; no CacheStorage or streamed navigation.
const REVISION = '1.9.4';
const HOME = new URL('./', self.registration.scope).href;
const LAUNCH_HTML = '';
self.addEventListener('fetch', event => {
 const request=event.request,url=new URL(request.url);
 if(LAUNCH_HTML && request.method==='GET' && request.mode==='navigate' && url.origin===new URL(HOME).origin && (url.pathname===new URL(HOME).pathname || url.pathname==='/index.html')) {
  event.respondWith((async()=>{
   const abort=new AbortController();let timer;
   const fallback=()=>new Response(LAUNCH_HTML,{headers:{'Content-Type':'text/html; charset=utf-8','Cache-Control':'no-store'}});
   try {
    return await Promise.race([
     (async()=>{
      const response=await fetch(url.href,{cache:'no-store',redirect:'follow',signal:abort.signal});
      if(!response.ok)throw new Error('Opening unavailable');
      const html=await response.text();
      if(!html.includes('id="launch"'))throw new Error('Unexpected document');
      return new Response(html,{headers:{'Content-Type':'text/html; charset=utf-8','Cache-Control':'no-store'}});
     })(),
     new Promise(resolve=>{timer=setTimeout(()=>{abort.abort();resolve(fallback());},1500);})
    ]);
   }catch{return fallback();}finally{clearTimeout(timer);}
  })());
 }
});
self.addEventListener('install', event => event.waitUntil(self.skipWaiting()));
self.addEventListener('activate', event => event.waitUntil(self.clients.claim()));
self.addEventListener('message', event => {
 if(event.origin && event.origin !== self.location.origin)return;
 if(event.data === 'claim' || event.data === 'update')event.waitUntil(self.skipWaiting().then(()=>self.clients.claim()));
});
self.addEventListener('push', event => event.waitUntil((async()=>{
  const data=event.data?.json()||{};
  await self.registration.showNotification(data.title||'OtoPatron', {body:data.body||'Galerin seni bekliyor.',icon:'app-icon-v182.png',badge:'app-icon-v182.png',tag:data.tag||'otopatron',silent:false,renotify:true,data:{url:'./'}});
})()));
self.addEventListener('notificationclick', event=>{event.notification.close();event.waitUntil((async()=>{
 const windows=await self.clients.matchAll({type:'window',includeUncontrolled:true});
 for(const window of windows)if(window.url.startsWith(HOME)){await window.focus();return;}
 await self.clients.openWindow(HOME);
})());});
