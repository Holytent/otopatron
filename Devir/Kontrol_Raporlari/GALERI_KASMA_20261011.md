# 11 Ekim 2026 — Kullanıcı galeri takılma bildirimi

Kullanıcı yerel1.9.44 içinde Galeri içi geçişinde kasmanın sürdüğünü ve eski araçları gördüğünü bildirdi. Performans düzelmiş kabul edilmiyor; bu kontrol FPS ölçümü yapmadı.

Gerçek açık tarayıcıda kapasite0/5 ve Galeri içi üç örnek araç görüldü. Kod `lobby_scene.gd` boş galeride `karya_nova`, `ravena_koru`, `valtorre_solis` kullanıyor. Bunlar yeni katalogdaki Corso/Vento/Duty değildir. Corso ve Duty seviye5, Vento seviye9'da pazara uygun olur (`car_db.gd`, `Game.gen_listing`). Catalog audit yüksek seviyede57modelin üretilebildiğini kontrol ediyor; anlık günlük ilan listesi tüm katalog değildir.

Claude57araç teslimi yalnız2B SVG'leri yeniledi.3B gövdeler aynı varlıklardan geliyor; Vento gövde/şerit düzeltmesi ayrıca yarım. Önizlemede2B çizimlerin görünmesi kapsamlı görsel/performance kabulü değildir.

`LobbyScene._animate` görünür galeri içinde üç platformun açısını sürekli güncelliyor. `CarTurntable.set_angle` değişen açı tick'i için SubViewport.UPDATE_ONCE istiyor. Üç3B görünümün yeniden çizim maliyeti araştırılacak adaydır; ölçülmüş kök neden değildir. Claude kalan düzeltmesi ardından galeri açılış gecikmesi ve kararlı frame time/FPS ölçümü, düşük maliyetli döndürme ve boş galeri örneklerinin kullanıcıya açıklanması P3 öncesi ele alınacak. Oyuncu verisi korunmalı; fiziksel cihaz ölçümü yapılmadı.

Mevcut19:01tek takip otomasyonu bu bulguyla güncellendi. Limit beklerken Claude'a yeni mesaj gönderilmedi. Canlı1.9.43 değişmedi; uzak yayın erişim engeli sürüyor.
