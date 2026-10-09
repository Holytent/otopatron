# OtoPatron V1.9.29 kontrolü

## Yayın
- Ana bağlantı: https://otopatron.pages.dev/
- Yayın: https://dc50a54b.otopatron.pages.dev/
- release.json ve ana HTML V1.9.29: doğrulandı (live-v1929.json).

## Eklenenler
- Alıcı görüşmesinde dört saniyelik araç/akan yol animasyonu; 10 dakika oyun zamanı.
- Motor, lastik, kaporta ve temizlik puanı teklifi en fazla +%3 / -%7 etkiler. Her alıcıda bir kez uygulanır. Teklif, alıcının yeni tavanını aşamaz.
- Görüşme kapanırsa bekleyen animasyon satış veya teklif değişikliği yapmaz; artık bulunmayan ziyaret reddedilir.
- Galerim → Satış geçmişi: son 100 kayıt; alış, bakım/ekspertiz, satış, varsa ek gelir ve net kâr.
- Normal, toptancı ve depodan satışlar kaydedilir. Eski satışların ayrıntıları geriye dönük uydurulmaz; yeni kayıtlar bu sürümle başlar.
- Mevcut ziyaretleri oyun yeniden açıldığında temizleme davranışı korunur.

## Kontroller
- Yeni özellik denetimi: 26 kontrol geçti (sales-v1929.log).
- Genel ekonomi/kayıt denetimi: 117 kontrol, 0 başarısız (deep-v1929.log).
- Dört dil, telefon ve bilgisayar ölçüleri ekran denetimi: 0 taşma kaydı (layout-v1929.log).
- Web açılışı, hatalı indirmeden toparlanma, motor dosya bütünlüğü ve yol animasyonu testleri geçti.
- Önizleme tarayıcısında açılış, misafir girişi ve yeni sürüm notları görüldü; alınan son 5 uyarı/hata kaydı boş.
- Derleme ve web dışa aktarımı tamamlandı; kaynak ve web ZIP yedekleri üretildi.

## Sınırlamalar
- Fiziksel iPhone/Android üzerinde bu sürüm denenmedi; gerçek FPS veya ısınma ölçülmedi.
- Headless ekran testlerinin çıkışında önceki sürümlerde de görülen 2 ObjectDB/1 kaynak temizleme uyarısı mevcut. Test sırasında script hatası bulunmadı; bu çıkış uyarıları giderilmiş olarak raporlanmıyor.
