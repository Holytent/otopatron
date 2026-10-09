# OtoPatron V1.9.4 açılış düzeltmesi

## Sorun ve doğrulama sınırı
Kullanıcının iPhone ana ekran uygulaması beyaz kalıyor; Safari bağlantısında da siyah, yüklenen sayfa görülüyor. Önceki V1.9.3 desktop açılışından geçse de gerçek cihazı düzeltmemiş. Cihaz Web Inspector erişimi yok; kesin iOS kök nedeni henüz doğrulanmadı.

## Değişiklikler
- Başlangıç HTML'sinde hiçbir harici script etiketi yok. Görünür başlangıç ve düğmenin kurulması ağ bağımlılığından önce tamamlanıyor. Motor ve hesap yardımcıları tıklanınca sırayla yükleniyor; her dosyada 25 saniye sınır ve görünür tekrar deneme var.
- Service worker yalnız push/notificationclick için tutuldu. fetch olayı, HTML yanıtı yeniden oluşturma, CacheStorage okuma/yazma ve kurulurken ağ bekleme kaldırıldı. Bildirim aboneliği korunuyor. Oyun verilerinin saklandığı IndexedDB ve hesap oturumuna dokunulmadı.
- Çevrimdışı açılış artık özel SW cache garantisi vermiyor; indirme için internet gerekli. HTTP tarayıcı önbelleği çalışmaya devam ediyor.
- Motor 4 MiB parçalarla okunuyor. ReadableStream.pull tüketicinin hızına göre okuyor; eski start döngüsü gibi sınırsız kuyruğa almıyor. Her indirme/okuma için duraklama sınırı var.
- Canlı test ilk pakette eski immutable URL çakışmasını yakaladı: aynı WASM hash'iyle farklı parça boyutunun adları çakışıyordu. 4m ad alanı eklendi, regresyon testinde zorunlu kılındı. O ilk canlı test başarılı açılış değildi.
- Dinamik yardımcı adları da içerik hash'i taşıyor; eski worker yeni hesap/game kombinasyonuna eski yardımcısını veremiyor.
- Root/HTML, manifest ve SW no-store. Kalıcı ana adres ve manifest id/scope değişmedi.

## Kontroller
- Godot Web export: SCRIPT ERROR / Parse Error yok. Sandbox user:// uyarısı var.
- startup.test.cjs: push-only install/claim, fetch handler olmaması, ilk frame/graphics lost/resume koruması geçti.
- loading.test.cjs: ilk UI ağsız hazır, dosya hatası görünür tekrar deneme, 10 parçanın tam WASM SHA256 eşitliği ve HTTP hata aktarımı geçti.
- accounts-flow.test.cjs ve mobile-editor.test.cjs geçti.
- Gerçek iPhone sonucu kullanıcı tarafından tekrar kontrol edilmeli; masaüstü tarayıcı kontrolü iPhone doğrulaması sayılmaz.

## Son canlı yayın
- Production main: https://aa08dfa3.otopatron.pages.dev, kalıcı adres https://otopatron.pages.dev/.
- SW revision: c80e9498127de95d.
- check_live_v194.cjs: kalıcı adresten HTML + içerik hash'li loader + on parçanın SHA256 ve 39.514.754 byte toplamı geçti.
- Tarayıcıda önce oyun splash'i, sonra “OtoPatron’a hoş geldin” hesap kapısı görüldü.
- İlk denemenin CompileError kaydı tarayıcı logunda geçmiş olarak kalır; yeni parça isimleriyle giriş ekranına ulaşan sonraki çalıştırmanın hatası değildir.
