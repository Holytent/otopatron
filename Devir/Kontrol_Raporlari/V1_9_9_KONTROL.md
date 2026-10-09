# OtoPatron V1.9.9

- Tabela adı LineEdit/mobile editor kaydetme sonrasında flags.gallery_name alanına kaydedilir. Canlı etiket oyunun fontunu kullanır, uzun isimlerde küçülür. Maksimum 24 karakter.
- Özgün kod çizimi: sekiz 640×420 SVG galeri görünümü; klasik/modern/lüks/prestij ve gündüz/gece. Cam, döşeme, bitkiler, bayraklar ve gece ışıkları. Gerçek araçlar en fazla üç küçük önizleme olarak çizilir; boş galeride satın alınmış olmayan araç gösterilmez.
- Paket önizlemesinde örnek araçlar gösterilir. Paketler 0/200.000/500.000/1.000.000 oyun parası ve minimum 5/8/12/18 kapasite. Daha büyük kapasite düşmez. Tek sefer ödeme, satın alma onayı ve bakiye kontrolü.
- Eski parça dekor satın alımları korunur ve ücretsiz yeniden seçilebilir. Yeni paketler eski ücretli dekorlardan ayrı kapasite satın alımlarıdır.
- Galeri modalı telefon boyutuna göre sınırlı, içerik kaydırılabilir; kapat düğmesi sabit. Genel modallar ekran genişliğine sığar.
- Arka plan görselleri bellekte yeniden kullanılır, sahne 10 Hz yenilenir. Telefon için önceki 30 FPS sınırı korunur. Bu düzenleme tüm oyunun grafiklerini veya araç modellerini değiştirmez.
- LAYOUT_AUDIT_COMPLETE 0: 144 ekran ve galeri modalı. GALLERY_AUDIT_COMPLETE: gerçek isim alanı, kaydedilmiş ad, paket fiyatları, kapasite ve tekrar satın alma kontrolleri geçti. Hesap/klavye/açılış/yükleme testleri geçti.
- Cloudflare Production: 2f134181, sabit adreste release.json 1.9.9 doğrulandı. Fiziksel iPhone kalite ve performans değerlendirmesi kullanıcı cihazında yapılmalıdır.
