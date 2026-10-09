# OtoPatron V1.9.20

## Değişiklikler

- Konuşmalarda kullanılan basit figürün yerine katmanlı SVG baş/gövde çizimleri eklendi. Altı müşteri/satıcı görünümü, isimden türetilen sabit seçimle kullanılıyor.
- Tefeci için ayrı bir yedinci görünüm, loş ofis, masa, lamba, evrak ve elde tutulan sopa sahnesi hazırlandı. Hem garajdaki tefeci panelinde hem borç teklifi penceresinde gösteriliyor.
- Göz kırpma, bakış, nefes, konuşma ağzı ve el hareketleri var. Animasyon zamanı görünmeyen, kaydırmada kırpılan veya modal arkasındaki karakterlerde duruyor.
- Bekleme çizimi 8, konuşma çizimi 16 yenileme/saniye ile sınırlandı. Doku ve stil kaynakları karakter örneği yaşadığı sürece korunuyor; her karede yeniden oluşturulmuyor.
- Yayın notları yalnızca karakter yenilemesi ve yeni tefeci sahnesini içeriyor.

## Kontroller

- Yedi görünümün dokuları, konuşma süresi, bekleme çizim sıklığı, ekran dışına çıkınca ve gizlenince durması doğrulandı.
- Borç teklifi penceresi 320×680 ve 432×768 boyutlarında açıldı.
- Genel arayüz denetimi: 144 ekran/dil/boyut birleşiminde sıfır raporlanan taşma.
- Hesap akışı, açılış, bildirim izni, müzik ve son web yükleme denetimleri geçti.
- Fiziksel iPhone üzerinde performans veya sıcaklık ölçümü yapılmadı.
- Yerel Godot çalıştırmalarında sandbox kaynaklı user:// shader önbelleği uyarısı görüldü. Bazı test kapanışlarında önceden de görülen kaynak-kullanım uyarısı oluştu; son odaklı karakter denetiminde kod veya assertion hatası görülmedi.
