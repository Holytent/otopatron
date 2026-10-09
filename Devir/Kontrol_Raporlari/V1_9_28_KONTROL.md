# V1.9.28 — Gece / Gündüz

- Galerim görünümü her açılışta ve sekme değişiminde açık; aç/kapat kontrolü kaldırıldı.
- RoadAnim oyun saati için Game.is_night kullanır: 20:00–07:00 gece, diğer saatler gündüz. Cihaz saati veya arayüz temasından bağımsızdır; galerinin gece/gündüz kuralıyla aynı.
- İki katmanlı şehir silueti, gündüz güneş, gece ay/yıldızlar, ışıklı pencereler, sokak lambaları ve hareket eden araçlara bağlı far ışıkları.
- Arka plan çizimi yalnızca aydınlatma evresi değişince yenilenir; farlar araçların tuttuğu düğümlerdir. Hareket ve kaydırma yenileme politikası korunur.

Kontroller: 19:59/20:00 ve 06:59/07:00 sınırları, far görünürlüğü, aynı evrede 100 güncellemede yeni arka plan değişimi olmaması başarılı. Altı araç ve 30/60/120 adım hareket denetimi geçti. Yönetimde 9 bağlantı ve geri dönüş, 120 geçiş, nesne/kaynak artışı 0. Açılış ve yol web testleri geçti. Dışa aktarımda betik veya derleme hatası raporlanmadı.

Fiziksel iPhone üzerinde yeni görsel ve ısınma ölçümü yapılmadı. Bu sürüm için tarayıcıda gece ekranı görsel kontrolü yapılmadı; gece davranışı Godot denetiminde sınır saatleriyle doğrulandı.
