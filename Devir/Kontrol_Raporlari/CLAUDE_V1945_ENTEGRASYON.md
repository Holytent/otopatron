# 1.9.45 entegrasyon — 14 Ekim 2026

Kullanıcı tamamlanan Claude tesliminin ana yayına alınmasını açıkça istedi. P4-P5-gallery-weekly.bundle indirildi ve git bundle verify geçti; başlangıç4618da9, uç4b90f9e54d838ff47d2f6b7cbed8d88b3533030b.

## Kaynak ve kontroller

Önceki P3b ile yeni galeri/haftalık hedef değişiklikleri ayrı commitlerle entegre edildi:28021ed,e3047a6,2bbb9fc,cc51f42,dfc7b81. Sürüm metadata573dcd4. Aktif otopatron_recovered/OtoPatron kaynağı değişen20 dosyayla eşleştirildi. Oyun özellikleri Claude tesliminden alındı.

Windows Godot4.7.2; APPDATA build_tools/p45-test-user; her audit ayrı süreçte. weekly33/0,lobby68/0,catalog28/0,fix16/0,closeup27/0,deep120/0,sales26 tamamlandı; tüm çıkışlar0. Closeup ve sales kapanışında mevcut kaynak/ObjectDB uyarısı sürüyor. Kanıt build_tools/p45-*.log.

Web export başarılı; PCK8786620 bayt, launch-bundle-0fab5efa99be7130.js. sync_web_fallback.py uygulandı. Ağ başarısı/hatası/zamanaşımı üç fallback testi güncel HTML/PCK/bundle ile geçti.

Önizleme https://2d62a965.otopatron.pages.dev/ . HTML1.9.45, release.json, PCK ve bundle SHA256 yerelle eşleşti; build_tools/preview-v1945.json. Gerçek IAB414x896 ve1440x900 temiz açılış, misafir test kaydı, Galerim ve Galeri içi incelendi; başlık ortalı, üç örnek araç ve alt menü göründü. Kanıt build_tools/v1945-mobile-gallery.jpg ve v1945-desktop-gallery.jpg.

## Açık sınırlar

Canlı viewport değişiminde boş/yanlış ölçekli görünüm yeniden gözlendi; yenileyince temiz açılış doğru. Bu önceki sorun çözülmedi. Fiziksel iPhone11/16Pro performansı ölçülmedi; kasma tamamen giderildi iddiası yok. Başsız testler FPS kanıtı değildir. Bu yayın tamamlanmış galeri çizim yükü azaltımı ve haftalık hedef paketidir; tüm cihaz kabulü değildir.

## Yayın

Ana üretim yüklemesi başlatıldı. Canlı dosya eşleşmesi ayrıca kaydedilecek. Ana adres https://otopatron.pages.dev/ değişmiyor.
