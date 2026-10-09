# OtoPatron V1.9.31 — Dört yeni sistem

## Doğrulanmış yayın
- https://otopatron.pages.dev/ — release.json ve ana HTML 1.9.31.
- Yayın: https://03bc0729.otopatron.pages.dev

## Tamamlananlar
1. Alıcı görüşmesinden takas: gelen araç, ekspertiz, verilen değer ve alınan/ödenen nakit farkı gösterilir. Son onayda satış ve alış birlikte kaydedilir; ara kayıtlar engellenir. Dolu galeride araç sayısı değişmeden takas yapılabilir. Satış geçmişinde takas değeri ve gerçek nakit ayrıca gösterilir.
2. Oyun gününe göre beş araç kategorisinin talebi değişir. Gözde kategori alıcı ihtimalinde %25 ve ödeme isteğinde %3 artış sağlar; normal araç fiyatları doğrudan değiştirilmez.
3. Yönetim → Personel: temizlikçi (günlük 350 / giriş 1500), usta (700 / 3000), satış danışmanı (600 / 2500). Maaşlar günlük giderlere eklenir. Temizlikçi oyun saatinde bir kirli aracı %50 düşük yıkama bedeliyle temizler; gider aracın maliyetine yazılır. Usta onarım maliyetini %8, satış danışmanı alıcı ihtimalini %20 etkiler. Maaş borcu varken yeni işe alım engellenir.
4. Üç oyun gününde bir sınırlı spor araç ilanı; 20 dakika gerçek süre. Kalan süre gösterilir, yenilemeyle çoğaltılamaz, süresi dolmuş araç satın alınamaz. Mevcut spor araç modelleri kullanılır, yeni model/görsel eklendiği iddia edilmez.

## Kontroller
- Yeni sistemler: 60 kontrol / 0 başarısız; nakit farkı, çifte takas, dolu galeri, gece yarısı giderleri, eski kayıtlar, personel etkileri, nadir ilan süresi ve yeni ekranlar.
- Genel ekonomi/kayıt: 117 / 0 başarısız.
- Test sürüşü/satış geçmişi: 26 kontrol geçti.
- Yakın inceleme/cevaplı pazarlık: 27 / 0 başarısız.
- Toplam 230 özellik ve ekonomi kontrolü geçti.
- Dört dil / üç ekran boyutunda personel ve takas dahil düzen taraması: 0 taşma kaydı.
- Yönetim gezinmesi: 10 hedef ve geri bağlantıları; 120 geçişte node/resource büyümesi 0.
- Web yükleme/toparlanma/dosya bütünlüğü ve yol animasyonu kontrolleri geçti.
- Önizleme tarayıcısında açılış, misafir girişi, bildirim tercihi ve sürüm notları görüldü; son hata/uyarı kayıtları boş.
- Kaynak ve web ZIP yedekleri hazır.

## Sınırlamalar
- Fiziksel iPhone/Android kontrolü veya FPS/ısınma ölçümü yapılmadı.
- Bazı headless testlerin çıkışında önceden görülen 2 ObjectDB/1 kaynak temizleme uyarısı mevcut. Çalışma sırasında script/parse hatası bulunmadı. Çıkış uyarılarının düzeltildiği iddia edilmiyor.
