# OtoPatron V1.9.38 — Canlı açılış

Yayın: https://otopatron.pages.dev/
Son dağıtım: https://98cbcee2.otopatron.pages.dev/
Ana HTML ve release.json sürümü 1.9.38 olarak doğrulandı (live-v1938.json).

## Tamamlananlar
- İlk HTML yükleme ekranında gece aydınlatılmış galeri ve transform ile hareketli araç; görseller gömülü, ek ağ isteği yok.
- Menüde Dış görünüm / Galeri içi / Şehir görünümü. Kısa kamera yaklaşması.
- Kayıtlı tabelayı, dış galeri dekorunu, araçları ve oyun saatine göre gece/gündüz görünümünü kullanır. Örnek sahne yeni oyuncular için gösterilir.
- Galeri içi araçlar, çalışanlar ve bekleyen müşteri figürleri. Temizlikçi süpürge hareketi.
- Haritada Galerim, Araç pazarı, Banka binaları ilgili sayfalara gider. Yeni oyuncu kurulumu tamamladığında seçilen hedefe yönlendirilir.
- Galerine dön, Yeni oyun ve Ayarlar düğmeleri ayrıldı. Menüye özgü koyu çevre tasarımı.
- Menüde oyun saati ve simülasyon giderleri ilerlemez. Kayıt önizlemesi dosyayı değiştirmez.
- Sabit sahne çizimi korunur, araç ve figür konumları hareket ettirilir; kamera tween'i değiştirilirken önceki tween sonlandırılır. Görünmeyen sahne animasyonu durur.
- Kayıt formatı, ses dosyası, para ve personel kuralları korunur.
- Güncelleme notları kullanıcının izin verdiği iki kısa ifadeyle sınırlı.

## Kontroller
V1.9.38: 22 yeni menü, 117 kayıt/ekonomi, 60 personel/takas, 23 gece geçişi, 49 oynanış ve 16 önceki düzeltme kontrolü; toplam 287, 0 başarısız.
Yerleşim denetimi yeni menü dahil 4 dil / 3 ekran ölçüsünde 0 taşma raporladı (layout-v1937-final.log; son müşteri figürü eklemesi ayrıca lobby-v1938.log ile doğrulandı).
Açılış, bağlantı kurtarma ve motor sıkıştırma testleri geçti. Godot web paketi dışa aktarıldı.

## Sınırlar
Fiziksel iPhone ve Android akıcılık/ısı/bellek ölçümü yapılamadı; tüm cihazlarda kusursuz çalıştığı iddia edilmedi.
Headless kapanışında önceden var olan 2 ObjectDB / 1 kaynak uyarısı bazı denetimlerde sürüyor; giderildiği iddia edilmedi.
Yedekler özel anahtar ve oturum bilgisi içermez.
