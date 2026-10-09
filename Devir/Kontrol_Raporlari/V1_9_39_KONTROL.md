# OtoPatron V1.9.39 — Canlı satış ve haftalık açık artırma

Ana yayın: https://otopatron.pages.dev/
Son dağıtım: https://30c7d359.otopatron.pages.dev/

Ana HTML, release.json, paket SHA256 özeti ve açılış dosyası yerel son paketle karşılaştırıldı; eşleşti. Kanıt: build_tools/live-v1939.json.

## Tamamlananlar

- Müşteri pazarlığında araca yaklaşma ve inceleme sahnesi. Karşı teklif, anlaşma ve ayrılma tepkileri mevcut pazarlık kurallarına bağlı.
- Satış sonuçlarında anahtar teslimi, müşterinin araca binmesi ve araçla ayrılış sahnesi. Animasyon ekonomi işlemini tekrar etmez. Hesap dökümü kaydırılabilir, devam düğmesi ayrı kalır.
- Temizlikçi, mekanik ve satış ekibi gerçek işler yaptıkça deneyim kazanır; ekip ustalığı 1–5, XP 0–400. Temizlik kapasitesi 3 ve 5. seviyelerde artar. Tamir indirimi en fazla %32, yıkama indirimi en fazla %70. Satış ekibi ilgiyi artırır; satış garantisi vermez.
- Ekip deneyimi kayıtla korunur ve rol bazında ortaktır. Yeni personel ekip deneyimini paylaşır. Son çalışan ayrılırsa o görevin deneyimi sıfırlanır. Ücretler önceki günlük maaş sisteminde kalır.
- Günlük hava verisine bağlı yağmur, kar ve sis görünümü; hava ana sayfada güncel gösterilir. Yağış parçacıkları 24 retained node ile sınırlı. Görünmeyen sahneler animasyon çalıştırmaz.
- Ek sergileme seçeneği: araç yönetiminde cam vitrin / açık alan. Yalnız açık alandaki araçlar yağışlı açık saatlerde 2 puan kirlenir. Aynı saat tekrar işlenmez, uyurken ilerlemez. Galeri sahnesinde açık alan aracı önde gösterilir.
- Pazarın üstünde haftalık açık artırma. Her 7 oyun gününde yeni özel araç. Cem ve Selin sabit haftalık bütçeleriyle teklif artırır. Teklif para çekmez; kazanan aracı teslim alırken ödeme yapar. Tek araç iki kez teslim alınamaz. Kapasite, gece ve yetersiz bakiye denetlenir. Son teklifler ve lider ekranda görünür; kayıtla korunur.
- Teklif sonrası açık artırma kaydırma konumu korunur. Eksik iç içe açık artırma kaydı güvenli biçimde yeniden oluşturulur.
- Açılış motoru, eski müzik, bildirim hizmeti ve kayıt formatı korunur. Yayın notları kullanıcının izin verdiği iki kısa ifadeyle sınırlıdır.

## Kontroller

- Yeni özellikler: 51 kontrol, 0 başarısız (life-v1939.log).
- Kayıt/ekonomi: 117; personel/takas: 60; gece geçişi: 23; oynanış: 49; önceki düzeltmeler: 16; menü: 22; satış: 26. Toplam 364 kontrol.
- Yeni açık artırma sayfası dahil dört dil ve üç ekran ölçüsünde yerleşim denetimi: 0 taşma (layout-v1939.log, layout_audit/report.json).
- Açılış, bağlantı kurtarma ve motor sıkıştırma testleri geçti; son paket yeniden test edildi.
- Test yayınında 432×850 tarayıcı görünümünde açılış, misafir giriş, yeni oyun, hava bilgisi, pazar, açık artırma ve rakip teklifleri kontrol edildi. Bildirim izni testte reddedildi. Deneme oyununda teklif sonrası bakiye değişmedi ve Cem/Selin yanıtları görüldü. Görsel kanıt: otopatron-v1939-acik-artirma.png.
- Görsel kontrolde bulunan teklif sonrası yukarı sıçrama düzeltilip yeni denetime eklendi; ardından son paket ana yayına yüklendi. Görsel kanıt bu düzeltme öncesindeki test yayınının aynı açık artırma arayüzünü gösterir.
- Paylaşılabilir web ve Godot yedekleri son paketle yenilendi; özel anahtarlar ve oturum bilgileri dahil edilmedi.

## Sınırlamalar

Fiziksel iPhone 11, iPhone 15 Pro Max ve Android üzerinde ısı, bellek ve FPS ölçümü yapılamadı. Tarayıcı ölçüsü fiziksel cihaz doğrulaması değildir.

Bazı eski denetimlerin kapanışında önceden var olan 2 ObjectDB / 1 kaynak uyarısı devam ediyor; giderildiği iddia edilmedi. Yeni özellik, kayıt ve yerleşim denetimleri betik hatası raporlamadı.

## Sonraki fikirler

Galeri açılış töreni ve ilk büyük satış kutlaması; araç koleksiyon albümü; şehirde galeri itibarı ve rakip sıralaması. Bu üç fikir henüz uygulanmadı.
