# OtoPatron V1.9.1

- Kalıcı yayın: https://otopatron.pages.dev/
- Son yayın: 590c8aeb.otopatron.pages.dev (Production/main).
- Açılış hesabı motor hazır olduktan sonra gösterilir; açık oturumda Devam et, giriş/kayıt ve misafir seçeneği vardır.
- Otomatik hesap geri yüklemesinin sahne açılışıyla yarışması kaldırıldı.
- Profil adları satıra yayılır; avatar seçimi ortalanır.
- Masaüstü yerleşimi 540 mantıksal piksele sınırlandı; telefonlarda içerik genişliği korunur.
- Yeni ekran kurulmadan eski ekran/chrome kapsayıcıdan çıkarılır.
- Kısa düğme metinleri ve elmas alanı kırpılmaz; uzun düğmeler taşmaz.
- Açılış yardımcıları içerik özetiyle adlandırılır. Önceki service worker yeni oyun ile eski hesap/güncelleme dosyasını karıştıramaz.
- Uygulamaya dönünce açılış katmanı tekrar gösterilmez.
- Bildirim simgesi bu sürümdeki uygulama simgesine bağlandı.

## Kontroller

- Godot gerçek OpenGL çalıştırmasında 432×768, 320×680, 1280×800 pencere boyutları.
- Türkçe, İngilizce, Arapça, Fransızca; 10 ana ekran + üst panel + alt menü: 120 ekran geçişi, yatay taşma raporu boş.
- Görsel inceleme: ana sayfa, profil, beceriler; build_tools/layout_audit görüntüleri.
- Yerel sahte servis testleri: misafir, şifre sıfırlamadan geri dönüş, açık oturumdan Devam et, bulut kayıt sürümü, misafir kaydının hesaba yazılmaması.
- Web dışa aktarımı başarılı; JavaScript sözdizimi kontrolleri başarılı.
- Eski önbellekle yayındaki tarayıcıda hesap açılışı hatası yeniden üretildi; tüm yardımcı script adreslerine içerik özeti eklendi.
- Gerçek iPhone cihazına doğrudan erişim yok; cihaz sonucu kullanıcı tarafından ayrıca doğrulanmalı.
