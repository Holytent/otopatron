const fs=require('node:fs'),vm=require('node:vm'),assert=require('node:assert/strict');
(async()=>{
 const settle=async()=>{for(let i=0;i<8;i++)await Promise.resolve();};
 const listeners={};let audio,plays=0,pauses=0;
 class Audio{constructor(src){audio=this;this.src=src;this.paused=true;}async play(){plays++;this.paused=false;}pause(){pauses++;this.paused=true;}}
 const c={Audio,Math,Number,document:{hidden:false,addEventListener:(n,f)=>listeners[n]=f},window:{addEventListener:(n,f)=>listeners[n]=f}};
 vm.createContext(c);vm.runInContext(fs.readFileSync('otopatron_recovered/OtoPatron/web/safari/music-client.js','utf8'),c);
 assert.equal(audio.preload,'none');assert(audio.loop);assert.equal(plays,0);
 c.window.otoMusic.start();assert.equal(plays,0);c.window.otoMusic.volume(.6);await settle();assert.equal(plays,1);
 for(let i=0;i<20;i++)c.window.otoMusic.volume(.6);assert.equal(plays,1);
 c.document.hidden=true;listeners.visibilitychange();assert(audio.paused);
 c.document.hidden=false;listeners.visibilitychange();await settle();assert.equal(plays,2);
 c.window.otoMusic.volume(0);assert(audio.paused);assert(audio.muted);listeners.pointerdown();assert.equal(plays,2);
 c.window.otoMusic.volume(.6);await settle();listeners.pagehide();assert(audio.paused);assert(pauses>=3);
 c.window.otoMusic.stop();listeners.pointerdown();assert.equal(plays,3);
 console.log('PASS: old-music source, no preload/autoplay, no restarts during volume polling, mute, background pause and gesture resume');
})().catch(e=>{console.error(e);process.exitCode=1;});
