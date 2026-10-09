(() => {
  let cleanup;
  window.otoEditor = {open(value, title, multiline, numeric, commit) {
    cleanup?.();
    const viewport=window.visualViewport;
    const backdrop=document.createElement('section');
    backdrop.style.cssText='position:fixed;inset:0;height:100lvh;min-height:100%;z-index:16000;background:rgba(16,20,28,.88);backdrop-filter:blur(6px);touch-action:none;overscroll-behavior:none';
    const panel=document.createElement('div');panel.setAttribute('role','dialog');panel.setAttribute('aria-modal','true');
    panel.style.cssText='position:absolute;left:50%;transform:translateX(-50%);width:calc(100% - 32px);max-width:440px;padding:18px;border-radius:18px;background:#14283a;color:#eef3f8;overflow:auto;box-sizing:border-box;font:16px system-ui;touch-action:pan-y;overscroll-behavior:contain';
    const heading=document.createElement('h2'); heading.textContent=title;heading.style.cssText='margin:0 0 14px;font:700 20px system-ui';
    const input=document.createElement(multiline?'textarea':'input');
    input.value=value;input.setAttribute('aria-label',title);input.autocomplete='off';input.setAttribute('autocorrect','off');input.spellcheck=false;input.name='oto-editor';input.style.cssText='display:block;width:100%;min-height:48px;padding:12px;margin:0;border:2px solid #087d83;border-radius:10px;font:18px system-ui;background:#21364a;color:#eef3f8;box-sizing:border-box';
    if(multiline)input.rows=3;
    if(numeric){input.type='text';input.inputMode='decimal';}
    const actions=document.createElement('div');actions.style.cssText='display:grid;grid-template-columns:1fr 1fr;gap:10px;margin-top:14px';
    const done=document.createElement('button');done.textContent='Kaydet';
    const cancel=document.createElement('button');cancel.textContent='Vazgeç';
    for(const button of [done,cancel]){button.type='button';button.style.cssText='width:100%;min-height:46px;margin:0;padding:10px;border:1px solid #087d83;border-radius:10px;font:600 16px system-ui;cursor:pointer';}
    done.style.background='#087d83';done.style.color='white';cancel.style.background='#21364a';cancel.style.color='white';
    const fit=()=>{panel.style.top=((viewport?.offsetTop||0)+12)+'px';panel.style.maxHeight=Math.max(100,(viewport?.height||innerHeight)-24)+'px';};
    const remove=()=>{viewport?.removeEventListener('resize',fit);viewport?.removeEventListener('scroll',fit);input.blur();backdrop.remove();cleanup=null;};
    const close=ok=>{const text=input.value;remove();commit(text,ok);};cleanup=remove;
    done.onclick=()=>close(true);cancel.onclick=()=>close(false);
    input.addEventListener('keydown',event=>{event.stopPropagation();if(event.key==='Escape')close(false);if(event.key==='Enter'&&!multiline){event.preventDefault();close(true);}});
    for(const type of ['keyup','keypress'])input.addEventListener(type,event=>event.stopPropagation());
    actions.append(done,cancel);panel.append(heading,input,actions);backdrop.append(panel);document.body.append(backdrop);
    viewport?.addEventListener('resize',fit);viewport?.addEventListener('scroll',fit);fit();
    input.focus({preventScroll:true});input.setSelectionRange(input.value.length,input.value.length);
  }};
})();
