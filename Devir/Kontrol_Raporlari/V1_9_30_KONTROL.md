# V1.9.30 — Pazarlık ve yakın inceleme

## Yayın
- https://otopatron.pages.dev/ canlı release.json ve HTML sürümü 1.9.30 doğrulandı.
- Yayın: https://8dde8f19.otopatron.pages.dev

## Değişiklikler
- Alıcı görünür kir/çizik veya kilometre hakkında konuşur; test sürüşünden sonra motor endişesi de ortaya çıkabilir.
- Dürüst açıklama, doğrulanabilir iyi durumu gösterme veya istenen fiyattan %2 indirim cevapları. Bir alıcıda bir cevap uygulanır; cevap tek başına satışı gerçekleştirmez.
- İyi durum açıklaması en fazla %1 teklif artışı sağlar; mevcut müşteri tavanı ve araba değeri sınırı gözetilir. Tekrarlama reddedilir.
- Araç detayından yakın inceleme: 1×/1.6×/2.2× büyütme, ön/orta/arka odak ve bakım sonrası görsel önizleme.
- Önizleme aracın parasını, durumunu veya kaydını değiştirmez. Mekanik puanlar ekspertiz yapılmamışsa gizli kalır.
- Mevcut araç görselleri kullanılır; yeni doku veya sürekli çalışan yakın inceleme animasyonu eklenmedi.

## Doğrulama
- Yeni özellikler: 27 kontrol, 0 başarısız.
- Önceki test sürüşü/satış geçmişi: 26 kontrol geçti.
- Genel ekonomi ve kayıt: 117 kontrol, 0 başarısız.
- Dört dil ve üç ekran boyutunda tarama: 0 taşma kaydı; küçük ekran pazarlık penceresi ayrıca doğrulandı.
- Web indirme/hata toparlanma/dosya bütünlüğü testi geçti.
- Önizleme tarayıcısında oyun açılışı, misafir giriş ve sürüm notları görüldü; son 5 hata/uyarı kaydı boş.
- Kaynak ve web ZIP yedekleri hazır.

## Sınırlamalar
- Fiziksel telefon testi/FPS/ısınma ölçümü yapılmadı.
- Headless ekran testleri çıkışında önceki sürümlerde görülen 2 ObjectDB/1 kaynak temizleme uyarısı devam ediyor. Çalışma sırasında script hatası bulunmadı; çıkış uyarılarının giderildiği iddia edilmiyor.
