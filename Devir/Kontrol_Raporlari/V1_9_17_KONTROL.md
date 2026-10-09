# V1.9.17

- GarageStage her görünür önizlemede background Texture2D referansını tutar. Ortak cache girdisinin silinmesi çizim komutlarının kullandığı RID'yi erken serbest bırakmaz.
- Cache sınırı 2 olarak korunur. Aktif kartlar kendi görsellerini yaşatır; kartlar silinince referanslar da bırakılır.
- Focused native galeri denetimi: en az 5 GarageStage, tüm arka plan referansları/RID'ler geçerli; cache'den çıkarılmış bir görsel hâlâ aktif önizlemede tutuluyor. PASS.
- Ayarlar şehir kartı ve seçme düğmesi kaldırıldı. Game.set_city oyun başladıysa değiştirmez; yeni oyun ve kayıt yükleme şehri normal şekilde belirler.
- Native testte yeni oyunun şehir değerini değiştirme girişimi başarısız; seçilen şehir korunuyor. İsim kaydı, Kaydet/Geri dön, paket ücret/kapasite kontrolleri PASS.
- Web export ve loading/music kontrolleri PASS. Önceki müzik dosyasının ismi değişmedi; mevcut tarayıcı cache'i korunur.
- Bu iki küçük düzeltme için oyuncuya büyük yenilik panosu gösterilmez.
