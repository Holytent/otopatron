# OtoPatron V1.9.8

- Kapalı oyunda 30 dakika arayla beş ayrı mesaj. Eski üç/gün sınırı kaldırıldı.
- Farklı etiketler mesajların birbirini değiştirmesini önler. Beş mesaj tek grup halinde gönderilir; cihaz teslimatı sıralayabilir veya gruplayabilir.
- Müşteri mesajı yalnız makul fiyatlı ilan varsa hazırlanır; bir gerçek müşteri kaydı oyuna dönüşte alınır. Diğer metinler yeni fırsatları incelemeye davettir.
- Başarısız teslimatta grubun kalan mesajları yeniden denenir. Süreler cron nedeniyle yaklaşık bir dakika sapabilir.
- Yeni özgün 24 saniyelik galeri müziği, satış/müşteri/tamir/düğme ve mesaj efektleri. Mono 22.05 kHz, sıkıştırılmış oyun içi sesler.
- Sıkıştırılmış müziğin döngü sınırı byte sayısı yerine örnek sayısından hesaplanır. Arka planda müzik duraklatılır.
- Bildirimlerde silent:false ve renotify:true. Özel ses dosyası standart Web Push seçeneklerinde yok; sistem sesi iPhone sürümü ve ayarlarına bağlıdır.
- Node: hesap, klavye, açılış, yükleme ve bildirim zamanlama testleri geçti. Godot arayüz denetimi: LAYOUT_AUDIT_COMPLETE 0.
- Gerçek iPhone'da ses ve 30 dakika teslimatı bu bilgisayardan doğrulanamadı.
