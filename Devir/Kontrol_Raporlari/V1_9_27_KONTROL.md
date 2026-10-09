# V1.9.27 — Sade Galeri ve Kaydırma

- Galerim kompakt başlık/kapasite, isteğe bağlı galeri görünümü, İlanlarım, Araçlar ve Alıcılar olarak sadeleştirildi. Hesap sekmesi kaldırıldı; gider ve bekleme işlemleri Yönetim > Galeri giderleri sayfasında. Eski summary bağlantısı yeni sayfaya yönlenir.
- Ana Sayfa özetinin altına 6 önbellekli araçtan oluşan küçük şehir animasyonu eklendi. Tam yol çizimi her karede yapılmaz. Animasyon ekran dışında, diyalog arkasında ve Ana Sayfa kaydırılırken durur.
- Yenileme hızını ana ekran yöneticisi belirler: aktif kaydırma/görünür hafif animasyon 60, durağan sayfa 30, gizli web sayfası 15 hedefi. Bu değerler hedef/sınırdır; cihazda ölçülen FPS değildir.
- Fare/tekerlek kaydırması hedefe yumuşak yaklaşır, dokunma sürüklemesi ve bırakma ivmesi korunur; silinen sayfa hareketi durdurur.
- Galeri sahnelerinin ekran dışındaki ve diyalog arkasındaki periyodik çizimleri durduruldu; dekor önizlemeleri için güvenlik figürü animasyon yenilemesi gereksiz yere çalışmaz.

## Kontroller
- 16 ekran + 3 yatırım alt bölümü x 4 dil x 3 genişlik = 228 düzen taraması, 0 taşma raporu. Kırpılmış yol alanına girip çıkan araçların kasıtlı dış konumları hariç tutuldu.
- Kaydırma: 30/60/120 adımda hedefe varma, hedefi aşmama, dokunma sürüklemesi/ivme ve serbest bırakılan sayfanın hareketi kesmesi başarılı.
- Yol: 6 araç, 30/60/120 adımda hareket/hız, gizli durma, dönüş sıçrama sınırı, 4 genişlik başarılı.
- Yönetim: 9 bağlantı ve geri dönüş, 5 sekme, 120 geçiş, nesne artışı 0, kaynak artışı 0.
- Kayıt ve ekonomi: 117 kontrol, 0 başarısızlık.
- Açılış/motor testleri geçti. Önizleme tarayıcısında Ana Sayfa araçları iki görüntüde farklı konumlarda; sade Galerim görüldü; konsolda hata/uyarı yok.

## Sınırlar
Fiziksel iPhone FPS/ısınma ölçümü ve performans izi alınamadı; uygun DevTools izleme aracı yoktu. Düzen ve kaydırma denetimi süreç kapanışında 2 nesne/1 kaynak uyarısı verdi; ayrı tekrarlı gezinme denetiminde birikim bulunmadı.
