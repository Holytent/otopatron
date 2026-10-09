const fs=require('node:fs');const path=require('node:path');const webpush=require('web-push');
const folder=path.resolve(__dirname,'../.cloudflare-state');fs.mkdirSync(folder,{recursive:true});
const filename=path.join(folder,'vapid-keys.json');
if(!fs.existsSync(filename)){
 const keys=webpush.generateVAPIDKeys();
 fs.writeFileSync(filename,JSON.stringify({VAPID_PUBLIC_KEY:keys.publicKey,VAPID_PRIVATE_KEY:keys.privateKey}),{mode:0o600});
}
console.log('Bildirim anahtarları yerel olarak hazır; özel anahtar ekrana yazılmadı.');
