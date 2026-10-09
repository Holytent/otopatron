# OtoPatron V1.9.40 — Canlı galeri görünümü

Ana yayın: https://otopatron.pages.dev/

Son dağıtım: https://e5228597.otopatron.pages.dev/

Canlı ana HTML, release.json, oyun paketi ve açılış dosyasının SHA256 değerleri yerel son paketle eşleşti. Kanıt: build_tools/live-v1940.json.

## Değişiklikler

- Dış sahnedeki araç giriş ve çıkış rotası ileri hareket edecek şekilde düzeltildi. Hareket eden araçların burnu sağa bakıyor ve yol üzerindeki hareketleri sağa doğru. Araç vitrine yaklaşır, kısa süre durur ve ileri çıkar. Diğer yol araçları da ileri akar.
- Galeri içi ve önünde sergilenen araçlar sabit durur. Oyuncunun ilk üç aracı sergilenir; açık alan seçilen araç dışarıda önde gösterilir. Boş galeride üç örnek araç ve açık bir örnek vitrin açıklaması bulunur. Örnekler envantere, kapasiteye veya ekonomiye araç eklemez.
- Ziyaretçiler ve çalışanlar dört nokta arasında yürür; araçların yanında iki saniye durur. Yürüyüşte kol ve bacak hareketi, incelemede kol hareketi, temizlikçide süpürme hareketi var. Hareketler mevcut düğümlerin konumunu değiştirir; her karede bütün sahne tekrar çizilmez.
- Menüde tanıtım ziyaretçileri vardır. Oyun içi galeride gerçek bekleyen alıcılar gösterilir; alıcıya dokunma mevcut görüşme ekranına bağlıdır. Ücretli personel kayıtlı ekip sayısına göre görünür; görsel amaçlı ücretsiz personel işe alınmaz.
- Oyun içi Galerim sayfası da menüdeki dış/iç görünüm sistemini kullanır. Tabela, galeri tarzı, araçlar, personel ve gece/gündüz mevcut oyun verisine bağlıdır. Bakiye güncellemelerinde sahne düğümleri korunur; araç, alıcı veya galeri görünümü değişince yenilenir.
- Hesap/giriş ekranı koyu galeri teması, cam vitrin görseli ve okunaklı form alanlarıyla yenilendi. Giriş, kayıt, parola sıfırlama ve misafir seçenekleri korunur. Görsel sayfada gömülüdür; ek bir sunucu isteği gerektirmez.
- Yayın panosunda yalnız kullanıcının belirlediği kısa notlar: “Performans iyileştirildi.” ve “Optimizasyon yapıldı.”

## Kontroller

- Menü/galeri: 36 kontrol; ileri giriş/çıkış, sabit sergileme, yürüme ve duraklama, hareket eden uzuvlar, örnek envanter izolasyonu, canlı alıcı bağlantısı, gündüz geçişi ve tekrar görünüm değiştirmede düğüm sınırı.
- Kayıt/ekonomi: 117; personel/takas: 60; gece geçişi: 23; oynanış: 49; önceki düzeltmeler: 16; satış: 26; son oynanış özellikleri: 51. Toplam 378 kontrol, 0 başarısız.
- Dört dil ve üç ekran ölçüsünde sayfa yerleşim denetimi: 0 taşma.
- Hesap akışı ve yarış durumu testleri geçti. Misafir izolasyonu, geç gelen bulut yanıtları, kayıt çakışması, oturum/kayıt ve parola doğrulama davranışları kontrol edildi. Gerçek kullanıcı hesabıyla yeni bir giriş veya kayıt oluşturulmadı.
- Son web paketinde ilk açılış, bağlantı kurtarma ve sıkıştırılmış motor dosyası testleri geçti.
- 432×850 tarayıcı ölçüsünde yeni giriş görünümü, misafir devamı, bildirim seçimi, sürüm panosu, dış/iç menü sahneleri, yeni oyun ve oyun içi Galerim görünüm geçişi kontrol edildi. Test yayınının tarayıcı hata/uyarı kayıtları boştu.
- Son yayın paketi canlı dosya özetleriyle doğrulandı. Web/Godot yedekleri yenilendi; özel anahtarlar ve oturum bilgileri yedeklere eklenmedi.

## Sınırlamalar

Fiziksel iPhone 11, iPhone 15 Pro Max ve Android üzerinde ısı, bellek ve FPS ölçümü yapılamadı. Tarayıcı ölçüsü fiziksel cihaz testi değildir.

Bazı denetimlerin kapanışında önceden var olan 2 ObjectDB / 1 kaynak uyarısı devam ediyor. Denetimler çalışma sırasında betik hatası raporlamadı. Bu kapanış uyarılarının giderildiği iddia edilmiyor.
