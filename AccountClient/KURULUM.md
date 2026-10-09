# OtoPatron hesap bağlantısı

## Supabase projesi

1. Projenin URL'sini ve **Publishable key** anahtarını kullan. Secret / service_role anahtarı web uygulamasına konulmaz.
2. SQL Editor'de `account-schema.sql` dosyasının tamamını çalıştır. SQL önce erişimi kapatır, yalnız kişinin kendi kaydını okuyacağı politikayı ve kimlik kontrollü kayıt fonksiyonunu oluşturur.
3. Authentication → URL Configuration:
   - Site URL: `https://otopatron.pages.dev`
   - Redirect URLs: `https://otopatron.pages.dev/`
4. Authentication → Sign In / Providers → Email:
   - Email açık.
   - Confirm email açık.
   - En az 10 karakter şifre.
5. Authentication → Email → SMTP Settings: herkesin kayıt olabilmesi için gerçek bir SMTP göndericisi bağla. Varsayılan Supabase SMTP yalnız proje ekibindeki e-postalara gönderir. Gönderici bilgilerini Supabase paneline gir; SMTP şifresini sohbet veya yayın paketine ekleme.
6. Onay ve şifre sıfırlama e-posta şablonlarında `{{ .ConfirmationURL }}` bağlantısını koru. Projenin yönlendirme adresi oyunun sabit adresidir.

## Bağlantı dosyası

`otopatron_recovered/OtoPatron/web/safari/account-config.json`:

```json
{"url":"https://PROJE.supabase.co","publishableKey":"sb_publishable_..."}
```

Bu dosya açık istemci yapılandırmasıdır; ayrıcalıklı anahtarlar içermez.

## Yayın

- JavaScript kaynak: `accounts.js`.
- Bağımlılıklar sürüm kilitli: `package-lock.json`.
- Derleme: `node node_modules/esbuild/bin/esbuild accounts.js --bundle --minify --format=iife --platform=browser --outfile=../otopatron_recovered/OtoPatron/web/safari/accounts.js`.
- Güncel accounts.js ve account-config.json yayın klasörüne kopyalanır; `tools/prepare_safari_web.py` çalıştırılır.
- Aynı Cloudflare Pages projesi `otopatron`, Production `main` kullanılır.

## İşleyiş

- Oturum Supabase istemcisinin yerel saklamasıyla kalır, gerektiğinde yenilenir. Şifre oyun kayıt dosyasına yazılmaz.
- Hesap bağlanmadan misafir kayıtları cihazda tutulur.
- Girişte hesaptaki kayıt ile cihazdaki kayıt arasında açık seçim yapılır; cihazdan buluta aktarma ayrıca onaylanır.
- Bulut kaydı yüklenmeden önce cihaz kaydı `.device_backup` dosyasına kopyalanır.
- Yerel oyun kaydı anında sürer; bulut yazımı yaklaşık 20 saniye toplu gönderilir. Bağlantı koparsa yerel kayıt korunur.
- Kayıt sürümü uyuşmazlığında yazım durur; güncel bulut kaydı seçilir. Sunucu kaydı sessizce ezilmez.
- Bu kayıt kişisel ilerleme yedeğidir. Rekabetçi sıralama/gerçek satın alma eklenirse ekonomik işlemler ayrıca sunucuda doğrulanmalıdır.

Hesap, doğrulama, şifre sıfırlama ve iki cihazlı kayıt akışı henüz gerçek kullanıcıyla denenmedi.
