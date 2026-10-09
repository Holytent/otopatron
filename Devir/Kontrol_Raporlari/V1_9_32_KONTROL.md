# V1.9.32 — Açılış bağlantı hatası

## Bulgular
Kullanıcı ekranındaki “Bağlantı gecikti. Yeniden dene.” tam olarak yardımcı script yükleyicisinin 25 saniye sınırından geliyor. Canlı V1.9.31 dosyaları denetimde HTTP 200 ve 35–99 ms yanıt verdi; telefondaki ağ gecikmesinin kesin kaynağı ölçülemedi. Logo ayrı indirme olduğu için aynı anda boş kalabiliyordu.

## Düzeltme
- Dokuz yardımcı/engine scripti aynı yürütme sırasını koruyan tek içerik imzalı harici pakete alındı (528124 bayt, aktarımda sunucu sıkıştırması uygulanabilir).
- Logo HTML içine gömüldü; başka dosya isteğine bağlı değil.
- Ağ hatalarında en fazla üç script denemesi; yavaş yüklemede 25 saniyelik erken iptal yerine 120 saniye sınırı.
- Motor akışının veri bekleme sınırı da 120 saniye. Motorun tamamının iki kopyası bellekte tutulmuyor; gzip/chunk akışı korunuyor.
- Yeni dosya adı eski yardımcı cache sürümlerini aşar. Oyun kaydı silinmedi/değiştirilmedi.

## Doğrulama
- launch-recovery: tek paket derlenmesi, gömülü logo, iki başarısız indirmeden toparlanma, son hata sonrası düğme geri dönüşü, uzun bekleme ve geç yanıtın ikinci motor açmaması geçti.
- loading: ilk arayüz ağdan bağımsız, hatalı dosya toparlanması, 10 motor parçası ve SHA256 bütünlüğü geçti.
- compressed-engine: gzip/asıl motor eşitliği ve bozuk gzip reddi geçti.
- startup: ağ kesintisinde gömülü açılış ve mevcut PWA davranışları geçti.
- Önizleme tarayıcısında motor açıldı, hesap giriş ekranına ulaşıldı; son 5 hata/uyarı kaydı boş.
- Ana HTML ve release.json 1.9.32, tek bağımlılık paketi ve gömülü logo doğrulandı.
- Yayın: https://f49063ba.otopatron.pages.dev ; ana bağlantı: https://otopatron.pages.dev/
- Web ve kaynak ZIP yedekleri hazır.

## Sınırlama
Fiziksel iPhone’da bu sürüm denenmedi. Bağlantının tamamen kesilmesini veya CDN’e erişilememesini uygulama düzeltmesi ortadan kaldırmaz; bu sürüm erken iptali ve geçici ağ hatalarına karşı kırılgan açılışı giderir. Telefonun ağ koşullarının kesin nedeni doğrulanmadı.
