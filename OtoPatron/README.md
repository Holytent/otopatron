# OtoPatron — Galeri Simülatörü · V1.7

Yapımcılar: **Ramazan ÖZKESKİN – Sudenur GÜVEZ**

## V1.7 — İşletme düzeni ve hareket

- İşletmem ekranında Araçlar / Müşteriler / Hesap sekmeleri. Üstte işletme adı, şehir, stok kapasitesi ve günlük gider bağlantısı. Araç yönetimi ilk sekmede, müşteri işlemleri ve canlı geri sayım ikinci sekmede. Hesap sekmesinde işletme satın alma fiyatı, kira/faturalar, gün raporu, banka/kredi ve zaman ilerletme bulunur. Garaj geliştirme alt Garaj sekmesindedir.
- Zaman ilerletme seçenekleri ayrı panelde; ücret gösterilir ve işlemden önce onay istenir. Seçenek paneli kapanarak onay paneline geçer.
- Açılıştaki rastgele hızlar ve aynı şeride giren ek araç kaldırıldı. İki ayrı şerit, şerit başına eşit hız ve sabit araç aralığı kullanılır. Açık renkli şehir/yol, hareketli şerit çizgileri ve farklı gövdeler bulunur. Ekran dışındaki çizim kırpılır.
- Araç kartlarının görsel alanı büyütüldü; SVG araçlarda doğrusal filtreleme açık. Mevcut 54 araç ve 1280×640 SVG kaynakları korunur.
- Ekran ve mesaj geçişlerinde kısa yakınlaşma/solma; kapasite göstergesinde dolum. Satıcı ve alıcı karakterlerinde göz kırpma, metnin yazılma süresiyle eşleşen ağız ve el hareketleri. Konuşma bittikten sonra ağız durur.
- Müşteri bekleme sayaçları her canlı oyun tikinde yenilenir. Müşteri sayısı değiştiğinde ekran açık görüşmeyi bölmeden yenilenir. Müşteri kartı açık ve koyu temaya uyarlanmıştır.

## Açma

ZIP'i tamamen çıkarın. Godot standart 4.7.2 sürümünde İçe Aktar → OtoPatron/project.godot → Düzenle → F5. Güncellenen mevcut projede Godot'u kapatıp yeniden açın. Bu paket Godot kaynak projesidir, APK veya IPA değildir.

## Kontrol kapsamı

Godot içe aktarımı ve masaüstü ekran görüntülemesi yapıldı: açılış, boş/dolu işletme, hesap, zaman paneli, müşteriler, görüşme ve koyu tema. Otomatik test paketi çalıştırılmadı. Gerçek cihaz performansı ve uzun oyun oturumları ölçülmedi.

## Önceki sistemler

## V1.6

### Araçlar

54 özgün araç görseli yeniden üretildi. Kaporta ve camlar aynı koordinatlarda; tekerlekler tek zemin hizasında; far, kapı ve trimler gövde tipine bağlı. Önceki modellere ortak eklenmiş, kaporta dışına taşan çizgiler kaldırıldı. Kavisli konturlar, gövde tipleri ve 1280×640 SVG görseller korunur. Dosyalar `tools/gen_showroom.py` ile yeniden üretilebilir. Gerçek marka tasarımları kopyalanmaz.

### Telefon ve animasyonlar

- Satıcıyı Ara: hareketli telefon ve yayılan halkalar, zil, satıcı/model bilgisi, bağlantı süresi, Aramayı İptal Et. Yaklaşık 2,4 saniye sonra görüşme bağlanır.
- Gelen müşteri: çalan telefon, isim/model, kalan cevap süresi, Cevapla/Reddet. Cevapla müşteri görüşmesine açar. Reddet veya zaman aşımı mevcut müşteri/itibar kurallarıyla işler.
- Zil çağrı ekranı kapanırken durur, ses efektleri ayarının seviyesini kullanır; mobilde titreşim tercihi uygulanır.
- Satıcı görüşmesinde de hareketli yüz, sabra bağlı ifade, baloncuk girişleri ve yazının kademeli çıkması bulunur.
- Mevcut bir görüşme veya pencere varsa yeni arama görüşmeyi kapatmaz; bekleyen alıcı bildirimi ve Garaj sekmesindeki sayaç kullanılır.

### Banka ve kredi

Kredi kaldırılmamıştır. **Ana Sayfa → Galerim kartı → Banka / Kredi** veya Yatırım Merkezi'nin üst düğmesi.

Seviye 1–5: ₺200.000; 6–10: ₺750.000; 11–15: ₺1.000.000; 16–19: ₺1.500.000; 20+: ₺2.000.000. Kredi Kullanımı eğitimi daha yüksek limit açabilir. Başlangıçtan itibaren banka erişilebilir. Mevcut kredinin en az %40'ı ödenmeden ek kredi alınamaz. Vadeler, günlük taksitler ve erken kapatma kuralları değişmedi.

### Açma ve durum

Godot standart 4.7.2 → İçe Aktar → OtoPatron/project.godot → Düzenle → F5. Masaüstü projeye güncelleme uygulandıysa Godot'u kapatıp yeniden açın.

Godot içe aktarımı ve ekran görüntüleme yapıldı: yeni araç gövdeleri, banka erişimi, kredi ekranı, giden/gelen arama ve cevap sonrası satıcı/alıcı görüşmeleri. Son ekran görüntüleme kaydında script hatası görünmedi. Bu turda otomatik test paketi çalıştırılmadı. Gerçek telefon performansı ve uzun dönem ekonomi dengesi ölçülmedi. Kaynak proje paketidir; APK/IPA değildir.

## Önceki sürümün sistemleri

## Yeni özellikler

- Açılış: mavi gece sahnesi kaldırıldı; temaya uyan açık yol, kırmızı çizgi ve daha görünür hareketli araçlar.
- İşletme hesabında işletmenin satın alma fiyatı veya sahip olunan işletmenin ödenmiş fiyatı görünür.
- Eğitim başlığı **Eğitim Merkezi**, giriş metni beceri geliştirmeye yöneliktir.
- Mağaza: 1/2/3 elmas veya nakit görseli, aralarında boşluk, daha küçük alan, hareketli facet parıltısı. Paketler ve onay sistemi aynı kalır.
- Pazar: marka/model arama (Enter ile uygula), artan fiyat/azalan yıl/fırsat oranına göre sıralama; piyasa altı ilan etiketi. Araç türü ve satıcı kaynağı ayrı filtrelerdir.
- **Garaj alt sekmesi**: İşletmem ekranından ayrı, gerçek stok/kapsam gösteren animasyonlu garaj. 5/8/12/16/20/24 kapasite geliştirmeleri seviyeye ve ücrete bağlı. Yıpranmış başlangıçtan büyüyen ve cam cepheli lüks görünüme geçilir. Kepenk hareketi, ışık ve geçiş parıltısı vardır. Galerime Gir düğmesi işletme/müşteri yönetimine açılır.
- Müşteri görüşmesi: hareketli karakter, sabra bağlı yüz ifadesi, baloncuk geçişleri, yazının kademeli çıkması ve mevcut mesaj sesleri.
- İtibar: satıcı pazarlık tabanında en çok %4 avantaj; kabul şansı en çok +20 yüzde puan; alıcı bütçesinde en çok %5 katkı; müşteri geliş ihtimaline katkı. Satış ve kaçırılan müşteri kuralları devam eder. Başlangıç satın alma tabanı ₺100.000 korunur.
- **Açık/koyu tema**: ayarlardan anında değiştirilir ve sonraki açılış için kaydedilir. Zemin/kart/yazı/ikon/buton durumları birlikte değişir.

## Sokak olayları: tefeci ve hırsızlık

Tamamen kurgusal oyun mekanikleridir. Ayarlardan yeni olaylar açılır/kapanır; mevcut borcu kapatmak yükümlülüğü silinmez.

### Tefeci

Garajdaki Sokak Olayları kartından incelenir. Tek aktif borç:
- Avans: min(₺200.000, ₺50.000 + seviye × ₺5.000).
- Toplam faiz: %35 − itibar × %0,15; böylece %20–35.
- Vade: 7 oyun günü, gün başında otomatik tahsil.
- Kabul etmek itibarı 2 düşürür. Eksik ödemede kalan borca sonraki gün %5 eklenir ve itibar 5 düşer; kalan borç ekranda görünür.
- Erken ödeme gösterilen borcun tamamıyla yapılır. Tüm ödeme/avans/güvenlik işlemleri ücret onayı ister.
- Günlük hesap özetinde tefeci tahsilatı ayrı satırdır.

### Hırsızlık

Seviye 3 sonrası yeni oyun gününde %12 ihtimalle şüpheli hareket; olaylar arasında en az 3 oyun günü. Ücretsiz polis müdahalesi %65 başarı, her güvenlik kademesi +10 yüzde puan (en çok %95). Başarısızlıkta nakdin %3'ü, en çok ₺15.000 kayıp. Ücretli güvenlik (₺2.000 + seviye × ₺200) kaybı önler. Müdahale başarıyla biterse itibar +1.

Güvenlik 3 kademedir; kademe ücreti ₺15.000 × yeni kademe. Borçlar, olay ve güvenlik kayıt dosyasında tutulur. Kapalı oyunda gün/borç ilerlemez.

## Çalıştırma ve durum

Godot standart 4.7.2: ZIP'i çıkar → İçe Aktar → OtoPatron/project.godot → Düzenle → F5. Mevcut masaüstü proje güncellendiyse Godot'u kapatıp yeniden aç.

Godot içe aktarımı ve grafik sürücüsüyle açık/koyu ekran görüntüleme yapıldı. Açılış, mağaza, garaj başlangıç/lüks, işletme fiyatı, müşteri görüşmesi, sokak olayı ve koyu tema ekranları incelendi. Otomatik test paketi çalıştırılmadı; gerçek telefon performansı ve uzun dönem ekonomi dengesi ölçülmedi. Bu paket kaynak projedir, APK/IPA değildir.

## V1.4 arayüz yenilemesi

- Beyaz, kırmızı ve antrasit tema; açık zemin üzerinde koyu metin, kırmızı ana işlemler ve seçili durumlarda beyaz yazı.
- Ana sayfadaki bina/galeri çizimi kaldırıldı. “Galerim” kartı gerçek araç kapasitesini, müşteri ve ilan sayılarını gösterir ve işletmeye açılır. Pazar, eğitim, mağaza ve günlük hediye kartları tek ekranda görünür.
- Yuvarlak profil fotoğrafları; atlas fotoğrafını değiştirmeden yerel çizim koordinatlarıyla dairesel maske.
- Akademi: altı beceri kartı, ilerleme çubuğu, detay penceresinde 10 kademeli beceri yolu. Aktif eğitimde büyük geri sayım, ilerleme çubuğu ve hızlandırma. Aynı anda tek eğitim, seviye şartları, ücretler ve gerçek süreler korunur.
- Mağazada elmas/nakit paket görselleri, paket başlıkları ve net ücret düğmeleri; satın alma onayı devam eder.
- 54 model. Yeni Nova, Aven, Vera, Koru, Solis ve Work; farklı kompakt, station wagon, fastback, köşeli SUV, roadster ve ticari van siluetleri. Eski modellerin bazı gövdeleri de çeşitlendirildi.
- Ekranlar Godot 4.7.2 ile görüntülendi: açılış, ana sayfa, akademi, eğitim detayı/geri sayım, mağaza, profil, pazar ve ayarlar. Bu turda otomatik test paketi çalıştırılmadı; telefon performansı ölçülmedi.

## Açma

ZIP'i çıkarın. Godot 4.7.2 standart sürümünde İçe Aktar → `OtoPatron/project.godot` → Düzenle → F6 değil **F5** ile projeyi çalıştırın. Masaüstündeki proje güncellendiyse Godot'u kapatıp yeniden açın. `.godot` klasörü dağıtıma dahil değildir; ilk açılışta yeniden oluşur.

## Önceki sürümdeki oyun sistemleri

- Açılışta okunabilir koyu kelime işareti, özgün amber/teal amblem ve hareketli araçlar. Dil ve titreşim düğmelerinde seçili durum kontrastı düzeltildi.
- Yeni galeri oluştururken 81 şehir ve 8 insan portresi arasından seçim.
- Araç pazarı: otomobil / spor / SUV / kamyonet-van / kamyon-TIR kategorileri; sahibinden ve galerici filtresi ayrı. Seviye kilitleri devam eder.
- 48 özgün model (V1.3): Cargo, Haul, Titan, Pulse, Sprint ve Canyon eklendi. SVG çizimleri yeniden düzenlendi; coupe/SUV alt siluetleri ve kamyon gövdesi eklendi. Gerçek marka logoları yoktur.
- Yeni pazar ilanlarında ve eski pazar kayıtlarında satın alma/pazarlık alt sınırı ₺100.000. Model açılma seviyesi arttıkça fiyat tabanı artar. Araç değeri oyuncunun seviye atlamasıyla kendiliğinden şişmez. Oyuncu kendi ilanında istediği fiyatı elle girebilir.
- Garaj görüntüsü gerçek kapasiteye bağlıdır: 5 → 8 → 12 → 16 → 20 → 24. Pencereler, cephe ve premium saçak gelişir; ana sayfadaki geliştirme düğmesi işletmeye gider. Geliştirme ücret ve seviye şartına bağlıdır ve onay ister.
- Zaman ilerletme onayı: oyun dakikası ve işlem ücreti gösterilir. Gün değişirse kira/fatura/kredi tahsilatlarının ayrıca gerçekleşeceği belirtilir. İptal hiçbir ödeme yapmaz.
- Müşteri sıklığı seviye, ilan fiyatı ve talebe bağlıdır. İlk uygun fiyatlı ilan kısa bekleme sonrası ilk ilgiyi alır; aşırı fiyatlı ilan alıcıyı uzaklaştırır. İlanlarım ekranında iç zamanlayıcı notları kaldırıldı.
- Satıcı pazarlığı biraz daha zor; alıcılar arasında düşük bütçeli, normal ve cömert kişilikler bulunur. Gelen teklif satış değildir; görüşme ve satış onayı devam eder.
- Mağaza paket sunumu düzenlendi; satın alma işlemleri onaylı oyun içi takastır.
- Yeni birikimlerde günlük %0,4 oyun faizi: 7 günde %2,8, 14 günde %5,6, 30 günde %12. Vade sonu toplam, mevcut yatırımların anaparası/faizi ve kalan oyun günü gösterilir. Eski mevduatların sözleşme faizi korunur.
- Gün sonu raporunda her yatırımın günlük değer değişimi, toplam değer değişimi ve gerçekleşen satış/faiz sonucu gösterilir. Değer artışı satışa kadar nakit sayılmaz. İşlem komisyonu alış ve satışta %1.

## Mağaza

Tamamen oyun içi takas; gerçek ödeme veya mağaza içi satın alma bağlantısı değildir.

| Oyun parasıyla | Elmasla |
|---|---|
| ₺40.000 → 5 elmas | 10 elmas → ₺15.000 |
| ₺125.000 → 15 elmas | 25 elmas → ₺40.000 |
| ₺350.000 → 40 elmas | 60 elmas → ₺100.000 |

Satın almalar ücret onayı ister. Elmaslar ayrıca satış ve eğitim bitişlerinden kazanılır.

## Günlük hediyeler

Gerçek takvimde günde bir kez. Yedi günlük seri boyunca para, elmas ve XP ödülleri artar. Yedinci ardışık girişte bir Karya Pico hediyesi verilir. Araç galeride yer yoksa depoya; ikisi de doluysa nakit karşılığına dönüşür. Yedinci gün sonrası yeni seri başlar. Kaçırılan gerçek gün seriyi yeniden başlatır.

## İşletme, kira ve vergiler

İşletme hesabı **İşletmem ekranının üst bölümüne** taşındı. Günlük toplam, mülk durumu, gider ayrıntıları ve işletmeyi satın alma düğmesi burada.

- Kiracı günlük kira öder. Seviye ve kapasite büyüdükçe kira/fatura/personel giderleri artar.
- İşletmeyi satın alma bedeli: ₺450.000 + kapasite × ₺25.000 + seviye × ₺5.000.
- Sahip olduktan sonra kira kalkar; bakım gideri başlar. Kapasite geliştirmesi ayrıdır.
- Kira, elektrik/su, personel, ilan hizmeti, bakım ve kredi taksitleri gün başında otomatik tahsil edilir.
- Her **30 oyun gününde**, pozitif net dönem kârından **%12** vergi. Satış ve gerçekleşmiş yatırım sonuçları ile vadeli faiz hesaba katılır; dönem zararından vergi alınmaz.
- Her **365 oyun gününde**, sahip olunan işletmenin satın alma bedelinden **%1,5** mülk vergisi.
- Bunlar kurgusal oyun ekonomisi kurallarıdır.
- Gün başında açılan hesap özeti dünkü para giriş/çıkışlarını, bugünkü kira/fatura/kredi/vergi kesintilerini ve kalan bakiyeyi gösterir.

## İflas ve otomatik yeni başlangıç

**Nakit bakiye sıfır veya altına düştüğünde**, elde araç veya yatırım olsa bile iflas gerçekleşir. Sonuç ekranı açılır; on saniye sonra otomatik yeni işletme başlar. Oyuncu hemen “Yeni başlangıç” da seçebilir.

Araçlar, yatırımlar, mülk, kredi, seviyeler ve eğitim sıfırlanır. Başlangıç ₺300.000, 3 elmas ve 5 araçlık kapasitedir. Oyuncu adı, şehir, profil fotoğrafı ve aynı gün ikinci ödül alınmasını önleyen günlük hediye geçmişi korunur.

## Korunan sistemler

81 şehir, dört dil (TR/EN/AR/FR), 50 oyuncu seviyesi, seviye kasaları, kredi vadeleri, pazarlık/sabır, tamir, ilan bilgileri, gerçek süreli müşteri gelişleri ve gerçek süreli eğitimler korunur.

Eğitim süreleri: 15 / 30 / 40 / 50 / 60 / 75 / 90 / 105 / 120 / 150 gerçek dakika. Aynı anda tek eğitim; pahalı para veya elmas hızlandırması. Oyun saatini ilerletmek eğitim süresini bitirmez.

Eski kayıtlar üçüncü kayıt sürümüne taşınır. Eski işletmeler kiracı olarak başlar; sonraki gün yeni gider düzeni uygulanır. Günlük ödüller ve eğitimler cihaz saatine dayanır; sunucu doğrulaması yoktur.

## Dosyalar ve durum

- `scripts/data/business_ledger.gd`: seviye ve mülk durumuna göre gider formülleri.
- `scripts/ui/screen_shop.gd`: oyun içi mağaza.
- `scripts/ui/screen_bankruptcy.gd`: iflas sonucu ve yeniden başlangıç.
- `scripts/ui/screen_training.gd`, `screen_finance.gd`: yeni akademi/yatırım düzeni.
- `scripts/ui/avatar_badge.gd`, `art/portraits.png`: portre atlası ve dairesel fotoğraflar.
- `scripts/ui/showroom_view.gd`: galeri görünümü.
- `tools/gen_showroom.py`: 54 özgün SVG araç görseli.

Bu güncellemede otomatik test paketi çalıştırılmadı. Godot 4.7.2 içe aktarımı ve ekran görüntüleme yapıldı; açılış, yeni galeri, ayarlar, ana sayfa, pazar, mağaza, ilanlar, işletme, manuel fiyat girişi, birikim, ücret onayı ve günlük yatırım özeti incelendi. Uzun süreli ekonomi dengesi ve gerçek Android/iOS cihaz performansı ayrıca değerlendirilmelidir. Bu paket Godot kaynak projesidir.

## Portre varlığının kaynağı

Imagegen becerisi ve yerleşik imagegen aracıyla üretildi. Projede kaydedilen varlık: `art/portraits.png`. İlgili üretim isteği: “One 4-column, 2-row photo atlas of eight distinct fictional adult people, four women and four men, ages 25–50, natural studio portraits, centered heads and shoulders, no names, no text, no celebrity likeness, no gutter; production game avatar contact sheet.”
