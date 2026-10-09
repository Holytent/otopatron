# V1.9.7 — telefon performansı ve galeri

## Değişiklikler
- Bildirim panelindeki zaman/sıklık paragrafı ve settings push_hint zaman açıklaması kaldırıldı; gönderim politikası değişmedi.
- Mobil/web FPS üst sınırı 30. Dokunmatik canvas piksel oranı en fazla 1.25.
- 1280×640 araç SVG çıktıları 640×320 oldu. Native test gerçek texture genişliğini 640 doğruluyor. Piksel sayısı dörtte bire düştü.
- CarDB.texture LRU cache en fazla 20 görsel tutuyor. İlk açılış tüm araç modellerini gereksiz yüklemek yerine 6 tanesini hazırlıyor.
- document.hidden JS sorgusu her frame yerine saniyede en fazla 4 kez. Dekoratif redraw en fazla 20/s.
- SW root navigasyonunda en fazla 1.5 saniye boyunca güncel HTML alınır. Başlık veya gövde takılırsa gömülü son açılış HTML'si yeni Response ile sunulur. CacheStorage ve redirect metadata bağımlılığı yok. Engine/PCK/API istekleri müdahalesiz. Böylece eski gömülü sayfa yeni sürümün pack dosyasını kaybetmeden çevrimiçi güncellenebilir.
- Klasik/modern/lüks tabela, zemin ve dekor, 24 karakter tabela adı. Klasik ücretsiz; modern tabela/zemin ₺5.000, modern dekor ₺10.000; lüks tabela/zemin ₺15.000, lüks dekor ₺30.000. Alınan seçenek tekrar seçilince ücret kesilmiyor. Flags içinde yerel/bulut snapshot ile saklanır. Kozmetik, güvenlik veya satış avantajı sağlamaz.

## Kontroller
- Native 144 ekran + kişiselleştirme overlay: LAYOUT_AUDIT_COMPLETE 0.
- Galeri seçimi, ödeme, tekrar seçerken ücret kesilmemesi, yetersiz bakiye, snapshot ve tabela adı testleri geçti.
- Başlangıç: sonsuza kadar bekleyen fetch durumunda 1.5s fallback, redirects false, engine passthrough, ilk-frame/resume korumaları geçti.
- Account, mobile editor ve web_v197 loading testleri geçti. Script/parse hatası yok.
- Kalıcı root HTTP 200, release.json 1.9.7; browser hesabına giriş kapısı açıldı ve error log boş.
- Production https://be6ef75f.otopatron.pages.dev; https://otopatron.pages.dev/ aynı kalıyor.
- Fiziksel iPhone 11'de sıcaklık veya frametime ölçümü yapılmadı. Kullanıcının cihaz sonucu bekleniyor. Sunucuya ilk kez bağlanamayan/worker güncellemesi henüz ulaşmamış cihaz için mevcut worker değişikliğinin başarı iddiası yapılamaz.
