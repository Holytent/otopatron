(() => {
  if (!('serviceWorker' in navigator) || !window.isSecureContext) return;
  // No reload loops during app resume; updates apply to the next document load.
  navigator.serviceWorker.register('index.service.worker.js',{scope:'./',updateViaCache:'none'})
    .then(r=>r.update()).catch(console.warn);
  // A restored page already contains the running game; do not cover it on resume.
})();
