// Read only as fast as WebAssembly consumes; no second full engine buffer in a SW.
(() => {
 const originalFetch=window.fetch.bind(window);
 const engineURL=new URL('index.wasm',document.baseURI);
 const parts = ["engine-part.bin"];
 window.fetch=function(input,options){
  const url=new URL(input instanceof Request?input.url:String(input),document.baseURI);
  if(url.origin!==engineURL.origin||url.pathname!==engineURL.pathname)return originalFetch(input,options);
  let compressed=false;try{if(typeof DecompressionStream!=="undefined"){new DecompressionStream("gzip");compressed=true;}}catch{}
  const abort=new AbortController();let reader=null,index=0,total=0;
  const signal=options?.signal||(input instanceof Request?input.signal:null);
  const cancelled=()=>abort.abort();
  if(signal?.aborted)abort.abort();signal?.addEventListener('abort',cancelled,{once:true});
  function timed(operation){return new Promise((resolve,reject)=>{
   const timer=setTimeout(()=>{abort.abort();reject(new Error('İndirme durdu. İnternet bağlantını kontrol edip yeniden dene.'));},120000);
   operation.then(v=>{clearTimeout(timer);resolve(v);},e=>{clearTimeout(timer);reject(e);});
  });}
  const stream=new ReadableStream({
   async pull(output){
    try{
     while(true){
      if(!reader){
       if(index>=parts.length){signal?.removeEventListener('abort',cancelled);output.close();return;}
       const response=await timed(originalFetch(new URL(parts[index++]+(compressed?".gz":""),document.baseURI),{signal:abort.signal}));
       if(!response.ok||!response.body)throw new Error('Oyun dosyası indirilemedi: '+response.status);
       reader=(compressed?response.body.pipeThrough(new DecompressionStream("gzip")):response.body).getReader();
      }
      const result=await timed(reader.read());
      if(result.done){reader.releaseLock();reader=null;continue;}
      total+=result.value.byteLength;
      output.enqueue(result.value);return;
     }
    }catch(error){abort.abort();signal?.removeEventListener('abort',cancelled);output.error(error);}
   },
   cancel(){abort.abort();signal?.removeEventListener('abort',cancelled);return reader?.cancel();}
  });
  return Promise.resolve(new Response(stream,{headers:{'Content-Type':'application/wasm','Content-Length':'39514754'}}));
 };
})();
