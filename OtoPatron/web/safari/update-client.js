(() => {
  const current='1.9.41';let banner;
  async function check(){
    if(document.hidden||banner)return;
    try{const r=await fetch('release.json',{cache:'no-store'});if(!r.ok)return;const release=await r.json();if(!release.version||release.version===current)return;
      banner=document.createElement('button');banner.textContent=`Güncelleme hazır · ${release.version}`;
      banner.style.cssText='position:fixed;bottom:calc(100px + env(safe-area-inset-bottom));left:10%;width:80%;padding:12px;min-height:44px;margin:0;border:1px solid white;border-radius:12px;background:#25252e;color:white;font:600 15px system-ui;z-index:12000';
      banner.onclick=()=>{banner.disabled=true;banner.textContent='Oyun kaydediliyor…';if(window.otoUpdates?.save)window.otoUpdates.save();else location.reload();};document.body.append(banner);
    }catch{}
  }
  setTimeout(check,10000);setInterval(check,60000);document.addEventListener('visibilitychange',check);
})();
