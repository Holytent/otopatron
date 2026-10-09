# OtoPatron V1.9.19

## Oyuncuya gelen yenilikler
- 54 mevcut modelin SVG çizimleri yenilendi. Sekiz gövde silüeti, farklı boya ve jant seçenekleri kullanıldı. Model sayısı artırılmadı.
- Araç kartları ve garaj görünümünde temizlik puanı kir izlerine; kaporta puanı çiziklere bağlı. Yıkama kiri, kaporta onarımı çizikleri giderir. Motor durumu çizimden anlaşılmaz.
- Garajda müşteri siparişleri: mevcut seviyeye uygun 3 teklif, tek aktif sipariş, 3 oyun günü süre, bütçe ve hizmet bedeli.
- Teslim koşulları: uygun araç sınıfı, piyasa değeri bütçe içinde, temizlik >=80, tüm parçalar incelenmiş ve >=70.
- Teslim ekranı satış/hizmet bedeli/toplam gelir/net kazancı gösterir ve onay ister. Satış mevcut finalize_sale üzerinden tamamlanır; hizmet bedeli aynı kayıt işleminde verilir.
- Kaydedilmiş siparişler flags içinde korunur; tekrarlı teslim ve mükerrer ödeme engellenir. İptal veya süresi biten sipariş için para cezası yok.

## Kontroller
- Araç denetimi: 54 görsel yüklendi; 8 silüet görüntülendi; gerçek yıkama ve kaporta onarımı kontrol edildi.
- Sipariş denetimi: kabul, aynı anda tek aktif sipariş, bütçe/temizlik/ekspertiz/kaporta koşulları, satış ve tek ödeme, kayıt-yükleme, süre bitimi, 4 dil ve 320x680/432x768 pencere boyutları geçti.
- Genel ekran denetimi: 144 ekran/dil/boyut birleşimi, sıfır raporlanan taşma.
- Açılış, hesap akışı, bildirim izni, müzik ve web yükleme denetimleri geçti.
- Fiziksel iPhone üzerinde bu sürüm test edilmedi. Masaüstü Godot görsel kontrolleri telefonun gerçek sıcaklığını veya Safari performansını ölçmez.
- Sandbox user:// shader-cache uyarısı görüldü; kod ayrıştırma ve assertion hatası kalmadı.
