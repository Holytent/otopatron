# OtoPatron V1.9.33 kontrol raporu

## Yayın
- Canlı adres: https://otopatron.pages.dev/
- Yayın: https://b913d3c3.otopatron.pages.dev/
- Canlı HTML ve release.json birlikte 1.9.33 olarak doğrulandı: live-v1933.json.

## Eklenen oynanış
- Galeride en fazla üç mevcut alıcı yürüyerek gelir; figüre dokunmak mevcut pazarlığı açar. Alıcılar araç satışından sonra normal ziyaret temizliğine tabidir.
- Pazarda Araç kurtarma: oyun günü başına bir bakımsız araç; önceden görünen yıkama/onarım bütçesi, normal satın alma ve hazırlık masrafları. Görünür kir ve çizikler mevcut araç durumuyla değişir. Hedef %100 temizlik, tüm parçalar en az %95. Normal satış kârı gerçek maliyetlerden hesaplanır; ek ücretsiz ödül verilmez.
- Pazarda Rakip galerici Cem: 120 oyun dakikalık ayrı fırsat; normal ilanları veya oyuncunun araçlarını silmez. Günde bir ilanlı araç için normal takas sistemi üzerinden teklif.
- Müşteri görüşmesinde oynanabilir test sürüşü: dokunmatik yön düğmeleri ve fren, bilgisayarda sol/sağ ok ve boşluk. Virajlı kısa parkur ve bitiş alanında durma. Kontrol puanı araç durumuyla birlikte tek seferlik teklif sonucuna yansır; otomatik satış yok. İptal ücreti veya teklif değişikliği yok.
- Yeni animasyonlar arka planda durur. Galeri müşterileri kaydırma ve modal sırasında durur; bina her karede tekrar çizilmez.

## Kontroller
- gameplay-v1933.log: 49 kontrol, 0 başarısız. Eski kayıt, kesin alım/onarım masrafları, tekrar alım engeli, kapasite/bütçe sınırı, rakip süre aşımı, günlük tekrar engeli, kontrol girdileri, iptal, parkur bitişi, çift teklif engeli, 320x680 sürüş paneli ve gösterge sınırları.
- Yeni sayfalar arasında 360 ek geçiş: düğüm büyümesi yok, kaynak kullanımı sınırlı.
- deep-v1933.log: 117 kontrol, 0 başarısız; kayıt, bozuk veri, 200 ekonomi işlemi, alış/satış/para hesapları.
- expansion-v1933.log: 60 kontrol, 0 başarısız; personel, masraflar ve atomik takas.
- sales-v1933.log: 26 kontrol; satış ve tek seferlik sürüş sonucu.
- closeup-v1933.log: 27 kontrol, 0 başarısız; araç inceleme ve diyalog.
- layout-v1933.log: 0 taşma kaydı; 320x680, 432x768, 1280x800; dört dil. report.json boş.
- management-v1933.log: 120 geçiş, düğüm ve kaynak büyümesi 0.
- navigation-v1933.log: 240 geçiş, düğüm ve kaynak büyümesi 0.
- scroll-v1933.log: 30/60/120 FPS hesaplamasında tekerlek ve dokunma atalet kontrolü geçti.
- loading.test.cjs, launch-recovery.test.cjs, compressed-engine.test.cjs: tümü geçti; bir açılış paketi, gömülü logo, yeniden deneme, geç yanıt, gzip bütünlüğü ve parçalı indirme.
- Import ve export: betik/ayrıştırma hatası bulunmadı.
- Tarayıcıda 432x850 görünümünde giriş, sürüm paneli, pazar, kurtarma ekranı, bütçe satırları, alım ve müşteri diyalogu gözlemlendi. İlk görsel kontrolde sürüş durum etiketi dar kalıyordu; tam genişlik ve tek satır yapıldı, tekrar test edildi.

## Sınırlamalar
Fiziksel iPhone 11, iPhone 15 Pro Max ve Android cihazlarda ölçüm yapılmadı. Gerçek cihazdaki uzun kullanım, pil/ısınma ve ağ kesintilerinde kusursuz çalışma garanti edilmez. Bazı eski başsız denetim süreçlerinin kapanışında ObjectDB/kaynak uyarıları sürüyor; bunlar giderilmiş diye sunulmadı. Yeni sayfaların tekrarlı kullanım denetiminde kaynak birikimi görülmedi.

## Yedekler
- OtoPatron_Cloudflare_V1_9_33_Oynanis.zip
- OtoPatron_Godot_V1_9_33_Oynanis.zip
Özel anahtarlar ve oturum bilgileri dahil edilmedi.
