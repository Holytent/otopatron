(() => {
 const audio=new Audio('gallery-music-v1916.wav');audio.loop=true;audio.preload='none';
 let wanted=false,volume=0,playing=false;
 async function resume(){if(!wanted||volume<=.01||document.hidden||playing||!audio.paused)return;playing=true;try{await audio.play();}catch{}finally{playing=false;}}
 function setVolume(value){volume=Math.max(0,Math.min(1,Number(value)||0));audio.volume=volume*.55;audio.muted=volume<=.01;if(!wanted||volume<=.01||document.hidden)audio.pause();else if(audio.paused)resume();}
 window.otoMusic={start(){wanted=true;resume();},volume:setVolume,stop(){wanted=false;audio.pause();}};
 // Safari starts sound after an explicit player gesture; failure does not block play.
 document.addEventListener('pointerdown',resume,{passive:true});document.addEventListener('keydown',resume);
 document.addEventListener('visibilitychange',()=>{if(document.hidden)audio.pause();else resume();});
 window.addEventListener('pagehide',()=>audio.pause());
})();
