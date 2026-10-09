# V1.9.2 mobil düzeltme

- Ekspertiz/bakım düğmeleri SHRINK_END kullandığında kırpma ve ellipsis kapalı; metin genişliği minimum boyuta katılır. Önceki kontrol yalnız ekran dışına taşmayı ölçtüğü için boş düğmeleri yakalamıyordu.
- Fiyat düğmeleri için metin genişliği + boşluk kontrolü eklendi.
- Üst bütçedeki FF0B tam genişlikli artı kaldırıldı; elmas çizilen Ico ile gösterilir. Metinlerdeki desteklenmeyen elmas simgesi dört dilde kelimeyle değiştirilir.
- Klavye formu görsel viewport içinde, karartma ise tam layout viewport boyunda; önceki formun altındaki açık alan böyle kapanır. 18 px giriş yazısı ve preventScroll odaklama kullanılır.
- Düzenleme formunda açılış/iptal/kayıt sırasında viewport dinleyicileri temizlenir.
- Oyuncu adı alanı artık Bilgi yerine doğru alan adını gösterir.
- 3 boyut, 4 dil, 12 ekran = 144 ekran kontrolü. Taşma ve kırpılmış fiyat raporu boş. İnceleme işleminde bakiye farkı ücretle aynı ve bilinen parça durumu güncelleniyor.
- Godot OpenGL ekran görüntüsünde İncele · ₺660 düğmesi ve elmas simgesi doğrulandı.
- JS form testleri: klavye boyuna uyum, tam karartma, Kaydet/Vazgeç, sayısal giriş ve tekrar açma temizliği geçti.
- Hesap akışı testleri geçti. Web dışa aktarımı başarılı.
- Gerçek iPhone klavyesi uzaktan kontrol edilemedi; görüntü kullanıcı cihazında ayrıca doğrulanmalı.
