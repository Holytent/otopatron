# V1.9.13 — Yazı ve görüntü keskinliği

- Mobil canvas piksel oranı tavanı 1.25 yerine 2; 3x ekranlarda doğal çözünürlük kullanılmaz. Kare sınırı 30 olarak korunur.
- Küçük etiketler en az 16; sarmalanan açıklamalar en az 17. Düğmeler 19. Açıklama rengi #4c5666.
- Araç SVG raster boyutu 640×320 → 960×480; galeri 640×420 → 960×630. Görsel tasarımlar değişmez; örnekleme çözünürlüğü artırılır.
- Araç texture önbelleği 20 → 12. Çözünürlük nedeniyle toplam bellek eski sürümden yine yüksek olabilir. Telefonda ısı/bellek ölçümü yapılmadı.
- Pack 6,809,972 byte. Önceki yaklaşık 6.2 MB'dan artış yaklaşık 0.6 MB; engine değişmez.
- Otomatik yükleme ve bildirim izin kontrolleri PASS. Kaydetme ve hesap akışı korunur.
- Native arayüz kontrolü: 432×768, 320×680, 1280×800; dört dil ve 12 ekran. Son sonuç layout-v1913-final.log içinde.
- Native görsel incelemede eğitim açıklamaları daha büyük ve koyu; kaydırma ile alt kartlar erişilebilir.
- iPhone 11 / iPhone 15 Pro Max gerçek cihaz keskinliği ve ısınma sonucu kullanıcının deneyimiyle doğrulanmalı.
