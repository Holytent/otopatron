# OtoPatron telefon bildirimleri

Bu servis oyun kapalıyken çalışır. Oyun ZIP'ini Pages'e yüklemek tek başına bildirimleri açmaz.
Ana ekran web uygulaması ve oyuncunun açık bildirim izni gerekir. iPhone: iOS 16.4 veya daha yeni.

## Kurulum
1. Bu klasörde Node.js/npm ile `npm install` çalıştır.
2. `npx wrangler login` ile Cloudflare hesabına giriş yap.
3. `npx wrangler kv namespace create PLAYERS` komutunun verdiği id'yi wrangler.toml içindeki REPLACE_WITH_KV_ID yerine koy.
4. `npm run keys` ile VAPID anahtarlarını üret. Özel anahtarı sohbetlere veya oyun dosyalarına koyma.
5. `npx wrangler secret put VAPID_PUBLIC_KEY` ve `npx wrangler secret put VAPID_PRIVATE_KEY` komutlarıyla anahtarları ayrı ayrı kaydet.
6. `npm run deploy` ile servisi yayınla. Verilen workers.dev adresini not et.
7. Oyunun web yayın klasöründeki push-client.js dosyasında `endpoint:''` yerine bu HTTPS adresini yaz (sonunda / olmadan).
8. Projedeki `tools/prepare_safari_web.py` aracını yayın klasörüne uygula; güncel klasörü ZIP yapıp mevcut otopatron Pages projesine Production olarak yükle.
9. Oyunda Ayarlar → Telefon bildirimleri → Bildirimleri yönet → Bildirimlere izin ver.

## Davranış
- Kapalı oyunda birer bildirim: 5, 10, 15, 20 ve 30. dakikalar; ardından aynı döngü tekrar eder. Aralar 5/5/5/5/10 dakikadır. Cron dakikalık olduğu için yaklaşık bir dakika gecikme olabilir.
- Eski beş mesajlık toplu gönderim kaldırıldı. Geciken cron çalışmaları kaçırılan mesajları peş peşe göndermez; sonraki aralık başarılı teslimat zamanından başlar.
- Web Push TTL 180 saniye: eski hatırlatmalar uzun çevrimdışı dönem boyunca biriktirilmez. Telefonun kendi teslimat/gruplama davranışı sunucudan kontrol edilemez.
- Makul fiyatlı aktif ilan varsa hatırlatma yerine müşteri ilgisi gönderilir. Dönüşte gerçek görüşme oluşur; satış otomatik yapılmaz.
- Oyun açıkken müşteri trafiği oyun içinde 20–30 saniye; kapalı oyunda bu sıklıkta telefon bildirimi gönderilmez.
- Müşteri bildiriminin bekleme süresi oyuna dönünce başlar; kapalıyken itibar kaybı olmaz.
- İzin reddedilirse veya servis bağlanmadıysa diğer oyun özellikleri çalışır. Bildirimler isteğe bağlıdır ve ayarlardan kapatılabilir.
- KV sadece abonelik, rastgele cihaz kimliği, zamanlar ve ilan özetini saklar. Kullanıcının oyun kaydı sunucuya gönderilmez. İnaktif cihaz bilgileri 60 günde silinir.

## Mevcut yayın durumu — 7 Ekim 2026
Servis yayınlandı: https://otopatron-notifications.ozkeskinr.workers.dev
KV PLAYERS bağlandı; VAPID anahtarları Cloudflare secrets içinde saklandı.
Güncel oyun https://otopatron.pages.dev adresine Production olarak yüklendi; push-client.js servise bağlı.
Sunucu herkese kendiliğinden bildirim göndermez. Her oyuncu ana ekran uygulamasında Ayarlar → Telefon bildirimleri bölümünden izin vermelidir.
Kullanıcı iPhone bildirimlerinin ulaştığını doğruladı. Yeni aralıklı düzen yerel zamanlama denemelerinde doğrulandı; gerçek cihazdaki uzun süreli teslimat ayrıca kullanıcı tarafından gözlenmelidir.
