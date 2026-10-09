# V1.9.14

- Ana ekran açık galeri kartı, gerçek galeri adı ve GarageStage görüntüsüyle yenilendi. Aksiyonlar kaydırma alanında korunur.
- Bildirim alanı artık HUD ile içerik arasında gerçek VBox satırı. Tek mesaj; eski mesaj çıkarılır. Otomatik test HUD ve içerikle çakışmadığını doğrular.
- Güncelleme metnindeki UTF-8 bozulması giderildi; düğme alt gezinmenin üzerine konumlandı. Güncelleme yalnızca oyuncunun düğmeye basmasıyla yapılır.
- Startup guard: Safari geri dönüşünde eksik kalp atışı artık canlı oyunun üzerine yükleme ekranı getirmez. Gerçek webglcontextlost koruması sürer; restored olunca kapak kapanır.
- 48 saniyelik orijinal mono lounge müzik. WAV PCM kullanılır; uygulama arka planda müzik ve efektler durdurulur, müzik geri dönüşte yeniden başlatılır. Fiziksel iPhone ses takılması ölçülmedi.
- Bildirim seçimi yeni izin kutusunda İzin ver / İzin verme. Var olan sistem izni korunur. Reddedilmiş OS izni uygulama tarafından değiştirilemez; desteklenmeyen tarayıcıda sistem penceresi zorlanmaz.
- Statik galeri çizimi sürekli 10 Hz yenilenmez; hareketli güvenlik/theft ve gün/gece değişimleri yenilenir.
- 144 native ekran kontrolü LAYOUT_AUDIT_COMPLETE 0; galeri adı / Kaydet / Geri dön kontrolü PASS. Home görseli son 280 yükseklikle incelendi.
- Node startup, accounts, loading, notification permission ve spaced reminders kontrolleri PASS. Audio: 9 mono stream / 48 saniye döngü PASS.
- Gerçek cihaz çökmesinin kesin nedeni kanıtlanmış değildir; yanlış resume kapağı ve gereksiz statik çizim düzeltildi. Kullanıcı iPhone üzerinde doğrulamalı.
