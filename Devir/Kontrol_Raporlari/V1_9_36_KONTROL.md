# OtoPatron V1.9.36

Yayın: https://otopatron.pages.dev/ — dağıtım https://4584bbf0.otopatron.pages.dev/
Ana sayfa ve release.json 1.9.36 sürümünü sunuyor; live-v1936.json ile doğrulandı.

## Güncelleme
- Her görev için personel kontenjanı: araç kapasitesi 5/8/12/16/20 için 1/2/3/4/5. Güvenlik için aynı sınır. Eski yüksek seviyeli güvenlik korunur.
- Günlük kişi başı maaşlar: temizlikçi 650 TL, mekanik 1200 TL, satış 1100 TL, güvenlik 900 TL.
- Personel işe giriş ücretleri: 3000 / 5500 / 5000 TL. Güvenlik alım bedelleri önceki kademeli sistemle korunur. Maaşlar günlük faturaya dahil ve otomatik tahsil edilir; yetersiz bakiye mevcut ödenmemiş fatura sistemine gider.
- Birden fazla temizlikçi açık oyun saati başına kişi başına bir araçla ilgilenir. Mekanik başına %8 indirim (en fazla %24); satış personeli başına %20 ilgi artışı. Figür sayıları çalışan sayısını yansıtır.
- 07.00–23.00 açık. 23.00 sonrası zaman durur, müşteri bekleme süreleri gece korunur; ücretsiz uyuma düğmesi görünür.
- Uyu işlemi ertesi gün 07.00'ye geçirir. Ek bekleme/uyuma bedeli yok; normal günlük faturalar tahsil edilir. Düğmeye tekrar basmak ikinci gün faturası oluşturmaz. Eski gece yarısı kayıtları aynı gün 07.00'ye ulaşır.
- Oyun kayıt formatı korunur; eski true/false personel kayıtları kişi sayısına uyarlanır.

## Doğrulama
23 yeni gece/personel kontrolü, 117 kayıt/ekonomi, 60 personel/takas, 49 oynanış, 16 önceki düzeltme kontrolü geçti. Toplam 265 kontrol, 0 başarısız.
Yerleşim raporu boş: LAYOUT_AUDIT_COMPLETE 0.
Açılış, bağlantı kurtarma ve sıkıştırılmış motor testleri geçti. Web dışa aktarma tamamlandı.

## Sınırlar
Fiziksel iPhone/Android doğrulaması yapılamadı. Headless kapanışındaki önceki 2 ObjectDB / 1 kaynak uyarısı devam ediyor. Bu uyarıların düzeltildiği iddia edilmedi.
