# OtoPatron V1.9.35 kontrol raporu

## Yayın
- Ana bağlantı: https://otopatron.pages.dev/
- Yayın: https://d42d7335.otopatron.pages.dev/
- Ana HTML ve release.json sürümünün 1.9.35 olduğu doğrulandı; kanıt live-v1935.json.

## Yapılan değişiklikler
- Test sürüşünde yukarıya bakan üstten araç çizimi.
- Araç yönetimindeki yeniden çizimlerde kaydırma konumu ve ilan taslağı korunuyor.
- Web yazı düzenleyicisi yalnızca kısa dokunma bırakıldığında açılıyor; kaydırma sırasında açılmıyor.
- Ana sayfa trafiği dokunma sırasında devam ediyor.
- Elmas paketleri: 5 / 15 / 40 elmas için 100.000 / 320.000 / 900.000 TL.
- Personel ücretleri ve günlük giderleri artırıldı; galeride çalışan figürleri eklendi.
- Hırsız alarmı cüzdanın altında kırmızı şerit olarak gösteriliyor. Satın alınan güvenlik kademesine göre otomatik müdahale ediyor; müdahale ücreti yok. Başarısız müdahalede mevcut hırsızlık zararı oluşabilir.
- Güncelleme notları yalnızca Performans iyileştirildi ve Optimizasyon yapıldı.

## Kontroller
- Özel düzeltme denetimi: 16 kontrol, 0 başarısız.
- Derin kayıt/ekonomi: 117 kontrol, 0 başarısız.
- Personel/takas: 60 kontrol, 0 başarısız.
- Oynanış: 49 kontrol, 0 başarısız; 360 sayfa geçişi.
- Toplam: 242 kontrol, 0 başarısız.
- 30/60/120 FPS kaydırma hesapları geçti.
- Yerleşim denetimi: LAYOUT_AUDIT_COMPLETE 0; rapor boş.
- Açılış, yeniden deneme, sıkıştırılmış motor ve mobil HTML düzenleyici testleri geçti.
- Godot içe aktarma ve web dışa aktarma tamamlandı.

## Sınırlamalar
- Fiziksel iPhone 11, iPhone 15 Pro Max ve Android cihaz kontrolü yapılamadı. Gerçek cihazdaki dokunma, akıcılık, bellek ve ses davranışı için garanti verilmedi.
- Headless kapanışında önceden var olan 2 ObjectDB ve 1 kaynak kullanım uyarısı sürüyor; bunların giderildiği iddia edilmedi.
- Yedekler oluşturuldu; özel anahtarlar ve oturum bilgileri dahil edilmedi.
