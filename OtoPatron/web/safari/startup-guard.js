(() => {
  let engineReady=false, sceneReady=false, lastFrame=Date.now(), resumeTimer, runtimePanel;
  const launch=()=>document.getElementById('launch');
  function recover(text){
    if(sceneReady){
      if(runtimePanel)return;
      runtimePanel=document.createElement('section');runtimePanel.id='oto-runtime-recovery';
      runtimePanel.style.cssText='position:fixed;inset:0;z-index:10002;background:#0009;display:grid;place-items:center;padding:24px;box-sizing:border-box;font:16px system-ui';
      const card=document.createElement('div');card.style.cssText='background:white;color:#222630;padding:24px;border-radius:18px;max-width:360px';
      const message=document.createElement('p');message.textContent='Oyun görüntüsü kesildi. Yeniden bağlanması bekleniyor; oyun kendiliğinden yeniden başlatılmayacak.';
      const retry=document.createElement('button');retry.textContent='Kaydedip yeniden aç';retry.style.cssText='width:100%;min-height:48px;border:0;border-radius:12px;background:#bc263b;color:white;font:600 16px system-ui';
      retry.onclick=()=>{retry.disabled=true;if(window.otoUpdates?.save)window.otoUpdates.save();else location.reload();};
      card.append(message,retry);runtimePanel.append(card);document.body.append(runtimePanel);return;
    }
    const cover=launch();if(!cover)return;
    cover.style.display='flex';
    const message=document.getElementById('message');if(message)message.textContent=text;
    const start=document.getElementById('start');
    if(start){start.disabled=false;start.textContent='YENİDEN AÇ';start.onclick=()=>{start.disabled=true;start.textContent='AÇILIYOR…';if(window.otoUpdates?.save){try{window.otoUpdates.save();}catch{location.reload();}}else location.reload();};}
  }
  let contextLost=false;
  function hide(){if(engineReady&&sceneReady&&!contextLost){const cover=launch();if(cover)cover.style.display='none';}}
  window.otoStartup={engineReady(){engineReady=true;hide();setTimeout(()=>{if(!sceneReady)recover('Oyun ekranı hazırlanamadı. Kaydını koruyarak yeniden açabilirsin.');},15000);},frame(){lastFrame=Date.now();if(!sceneReady)sceneReady=true;hide();}};
  const canvas=document.getElementById('canvas');
  canvas?.addEventListener('webglcontextlost',event=>{event.preventDefault();contextLost=true;recover('Oyun ekranı bağlantısını kaybetti. Kaydını koruyarak yeniden aç.');});
  canvas?.addEventListener('webglcontextrestored',()=>{contextLost=false;runtimePanel?.remove();runtimePanel=null;hide();});
  function resumed(){
    if(document.hidden||!engineReady)return;
    lastFrame=Date.now();clearTimeout(resumeTimer);
    // Safari can temporarily throttle a live game after returning to the app.
    // A missing heartbeat alone is not evidence of a lost rendering context.
    hide();
  }
  window.addEventListener('pageshow',resumed);document.addEventListener('visibilitychange',resumed);
})();
