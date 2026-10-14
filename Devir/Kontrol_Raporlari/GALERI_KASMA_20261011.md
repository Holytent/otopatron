# 11 Ekim 2026 — Kullanıcı galeri takılma bildirimi

Kullanıcı yerel1.9.44 içinde Galeri içi geçişinde kasmanın sürdüğünü ve eski araçları gördüğünü bildirdi. Performans düzelmiş kabul edilmiyor; bu kontrol FPS ölçümü yapmadı.

Gerçek açık tarayıcıda kapasite0/5 ve Galeri içi üç örnek araç görüldü. Kod `lobby_scene.gd` boş galeride `karya_nova`, `ravena_koru`, `valtorre_solis` kullanıyor. Bunlar yeni katalogdaki Corso/Vento/Duty değildir. Corso ve Duty seviye5, Vento seviye9'da pazara uygun olur (`car_db.gd`, `Game.gen_listing`). Catalog audit yüksek seviyede57modelin üretilebildiğini kontrol ediyor; anlık günlük ilan listesi tüm katalog değildir.

Claude57araç teslimi yalnız2B SVG'leri yeniledi.3B gövdeler aynı varlıklardan geliyor; Vento gövde/şerit düzeltmesi ayrıca yarım. Önizlemede2B çizimlerin görünmesi kapsamlı görsel/performance kabulü değildir.

`LobbyScene._animate` görünür galeri içinde üç platformun açısını sürekli güncelliyor. `CarTurntable.set_angle` değişen açı tick'i için SubViewport.UPDATE_ONCE istiyor. Üç3B görünümün yeniden çizim maliyeti araştırılacak adaydır; ölçülmüş kök neden değildir. Claude kalan düzeltmesi ardından galeri açılış gecikmesi ve kararlı frame time/FPS ölçümü, düşük maliyetli döndürme ve boş galeri örneklerinin kullanıcıya açıklanması P3 öncesi ele alınacak. Oyuncu verisi korunmalı; fiziksel cihaz ölçümü yapılmadı.

Mevcut19:01tek takip otomasyonu bu bulguyla güncellendi. Limit beklerken Claude'a yeni mesaj gönderilmedi. Canlı1.9.43 değişmedi; uzak yayın erişim engeli sürüyor.

## 16:46 sonrası fiziksel cihaz bildirimi ve mobil hizalama

Kullanıcı canlı 1.9.43 açılışının mobil veride yüklendiğini, ancak Galeri içi seçilince ciddi durma/kasma yaşandığını bildirdi. Bu, yalnızca bağlantı hatası olarak kapatılamaz. Kullanıcı cihazları iPhone 11 ve iPhone 16 Pro olarak belirtti; hangi cihazda hangi ölçümün alındığı henüz ayrı doğrulanmadı. Tüm cihazlara uyumluluk istiyor: bu iki iPhone öncelikli kabul hedefi; ayrıca Android ve masaüstünde farklı ekran boyutları kontrol edilmeli. Tüm cihazlarda sorunsuzluk test edilmeden garanti edilmemeli.

Kullanıcının C:/Users/ozkes/Desktop/2.jpeg görüntüsünde Galerim kartının üstündeki OTOPATRON başlığı sola hizalı. Kullanıcı telefonda ortalanmasını istedi. Kart başlığı ile sahne içindeki tabela ayrı kontrol edilmeli; kart başlığı kartın kullanılabilir genişliği içinde ortalanmalı. Dar/geniş ekran ve Safari üst/alt çubukları açıkken taşma, alt navigasyon ve kaydırma kontrol edilmeli. Ekran görüntüsü görsel kanıttır; FPS ölçümü değildir.

Claude mevcut yarım teslimini üretirken kesilmemeli. Sonraki galeri performans/UI düzeltmesinde bu ek bölüm okutulmalı; ID, fiyat ve oyuncu kayıtları korunmalı. Fiziksel iPhone kabulü kullanıcı geri bildirimiyle ayrıca doğrulanmalı.
