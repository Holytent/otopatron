# OtoPatron — Claude geliştirme planı

9 Ekim 2026. Kullanıcı yeni geliştirmeleri Claude'un yapmasını istedi. Claude kod ve görsel geliştirmeleri üretir; Codex görevleri hazırlar, teslimleri inceler, kontrol ve yayın entegrasyonunu takip eder. Aynı dosyalar iki tarafta eşzamanlı değiştirilmez.

## Başlangıç ve doğrulanmış durum

- Canlı sürüm **1.9.41**: https://otopatron.pages.dev/
- Değişmez yayın: https://93a7de4e.otopatron.pages.dev/
- Bu yayının oyun kodu: `6f0308ed71da0ade7368975e88ebe8fd3525e1c8`; dal `cloud/galeri-iyilestirme`. PR #1 açık; main bu koddan geride olabilir. Önce güncel dalı fetch et ve başlangıç commit'ini bildir.
- Canlı HTML, release.json, PCK ve açılış bundle hashleri yerel paketle eşleşti. Tarayıcıda açılış, misafir menüsü ve 3B platformlar görüntülendi. Kanıt: `Kontrol_Raporlari/live-v1941.json`.
- Patch sonrası lobi 50/0, kayıt-ekonomi 117/0, galeri denetimi tamamlandı. Ayrıntı ve sınırlamalar `Kontrol_Raporlari/CLAUDE_PATCH_ENTEGRASYON.md`.
- Fiziksel iPhone/Android performansı, bellek ve ses bu yayında ölçülmedi. Bütün cihazlar sorunsuz iddiası yok.

## Kaynakta bulunan eksikler ve riskler

1. **Doğrulanmış taşınabilirlik sorunu:** `scripts/dev/layout_audit.gd:4` çıktı yolunda kişiye özel `C:/Users/ozkes/...` kullanıyor. Linux/başka Windows ortamında uygun değil.
2. **Doğrulanmış kaynak uyarısı:** lobi denetimi kapanışında 2 ObjectDB instance / 1 resource uyarısı var. Kaynağını bul; önce logdaki durumu yeniden üret.
3. **Ölçülmemiş render maliyeti:** her CarTurntable ayrı 320×220 SubViewport, dünya ve MSAA2 kullanıyor. Önce 1/3/5 araçla kare süresi ve bellek ölç. Ortak viewport veya kalite kademesi bir çözüm adayıdır; ölçmeden daha hızlı ilan etme.
4. **Doğrulanmış görsel çeşitlilik sınırı:** 54 katalog modeli 8 genel GLB ailesine eşleniyor. 54 özgün 3B model yok. Sınıflar farklılaşsa da her katalog modeli kendine özgü gövdeye sahip değil.
5. **Doğrulanması gereken kullanım riskleri:** tamir sonrası kaydırma konumu, ilan taslağı, klavyenin yalnız dokununca açılması, tekrar girişte eski kayıt ve bulut çakışması, Safari arka plan dönüşü. Eski düzeltmeleri bozuk varsayma; yalnız yeniden üretilen sorunu hata olarak raporla.

## Geliştirme paketleri — sırayla

### P0 — Kontrollerin taşınabilir olması

İlk teslim yalnız `layout_audit.gd` çıktı yolunu taşınabilir yapar. Ortam değişkeni veya Godot komut satırı seçeneğiyle çıktı dizini; güvenli varsayılan `user://` altında denetim klasörü. Klasör oluşturma hatasını raporla. Test kaydı kullanıcı kaydından ayrı olsun. İlgili audit'i ayrı süreçte çalıştır; çalıştıramadıysan açıkça belirt. Çıktı yollarında kişisel bilgisayar bilgisi bulunmasın.

### P1 — Akıcılık ve kararlılık

Lobi kapanışındaki kaynak uyarısını araştır. Galeri render bütçesini ölç, gereksiz viewport/yeniden çizim maliyetini azalt. Arka planda ve görünmez sahnede render durmalı; sahneye dönünce düzgün sürmeli. Ekrana dokunmak trafiği durdurmamalı. Küçük ekran kaydırma ve klavyeyi yeniden kontrol et. Önce/sonra ölçümleri aynı ortamda ver; fiziksel cihaz yoksa ayrı yaz.

### P2 — Araçlar ve sergileme

İlk küçük pakette mevcut katalogdaki en az 3 araca ayırt edilebilir gövde/renk/jant görünümü sağla. Sonraki pakette hatchback, sedan, SUV, spor ve ticari gruplarındaki boşluklara yeni kurgu araçlar ekle. Mevcut ID'leri değiştirme; yeni ID'ler ekle. Fiyat, km, kondisyon ve sınıf dengesi mevcut kurallarla tutarlı olsun. Yeni modellerin lisansı depoda bulunsun; ücretli varlık alma.

Galeri içindeki platform ölçeği, tekerleklerin zemine oturması, dönüş merkezi, bütün dönüş açılarında kırpılmama ve araçlar arası mesafe için görüntü sun. Dış görünüşte sergi araçları cam vitrin içinde, yol araçları ileri yönde olmalı. Aynı ID'nin pazar, yakın inceleme ve galeri görüntüsü tutarlı olsun. Gerçek model bulunmazsa genel gövde kullanıldığını bildir.

### P3 — Galeri görünümü

Gece mavisi/turkuaz/altın paleti koruyarak zemin, platform ışıkları, tabela, gece aydınlatması ve personel çalışma hareketlerini geliştir. Dekor için mevcut satın alma ve kayıt mekanizmasını kullan; yeniden ödeme veya ücretsiz sınırsız kazanım üretme. Ana Sayfa özet olarak kalsın. Küçük ekranda içerik ve düğmeler rahat görünmeli. Örnek vitrin/Şehirden bir kesit yazısını ve koyu masa bloğunu geri ekleme.

### P4 — Daha güçlü oynanış

Önce mevcut rakip, açık artırma ve pazarlık sistemlerini incele; bulunan özellikleri tekrar yazma. Haftalık galeri hedefleri, rakiple satış yarışı ve araç koleksiyonu/başarıları için küçük paketler üret. Bunlar yemek siparişi benzeri teslim görevlerine dönüşmesin. Ödül tek kez verilsin; aynı gün tekrar açma, çift dokunma, yükleme ve gece geçişi ödülü çoğaltmasın. Kayıt alanları eski SAVE_VERSION7 kayıtlarına güvenli varsayılanlarla eklenmeli. Büyük ekonomi değişikliği ayrı değerlendirilir.

## Her paketin tamamlanma ölçütü

- Bir paket, bir ayrı commit veya patch; başlangıç commit SHA, değişen dosyalar, kısa Türkçe sonuç.
- İlgili Godot audit'leri ayrı süreçlerde; yeni iş için gerektiğinde regresyon denetimi. Yapılmayan test yapılmış sayılmaz.
- Oyuncu kayıtlarından ayrı test verisi. Eski kayıtlar, para/araç işlemleri, günlük giderler ve 07–23 ücretsiz uyku korunur.
- Görsel paketlerde küçük ve büyük ekran önce/sonra görüntüleri; araç dönüşünün birkaç açısı. Başsız test görsel kanıt değildir.
- Kullanıcının mevcut seçimleri: müşteri siparişleri yok; şehir yalnız başlangıçta seçilir; elmas tam sayı; nakit kompakt; sahip adı görünür; tabelalar ortalı.
- Üretim yetkisi ve gizli bilgi isteme. PR/patch/önizleme teslim et; canlı yayına doğrudan dağıtım yapma. Codex kontrolünden sonra yayın süreci yürütülür.
- Güncelleme panosunda yalnız gerçekten yapılan işe uyan izinli ifadeler: Performans iyileştirildi. Yeni araçlar eklendi. Çimler biçildi. Optimizasyon yapıldı.

## Kısa görev istemi

Güncel cloud/galeri-iyilestirme dalından başla. otopatron-dev skill'ini kullan. CLAUDE.md ve bu plandaki mevcut paket bölümünü oku. P0 tamamlandı; tekrar yapma. P1 tamamlandı, Windows kontrolleri geçti ve 1.9.42 yayımlandı; CLAUDE_P1_ENTEGRASYON.md raporunu oku. Sıradaki paket P2 ilk araç görünümü teslimi. Codex her teslimi kontrol edip entegre eder; ardından güncel SHA ile sıradaki küçük paketi gönderir. Kodları küçük paketlerde geliştir; rapor kısa olsun, tüm depoyu gereksiz yere okumadan ilgili dosyaları kullan.

## Kullanıcının büyütme ve takip talimatı — 9 Ekim 2026

Kullanıcı oyunun daha kaliteli bir galeri oyunu hâline gelmesini, arayüz ve görünümün geliştirilmesini, yeni araçlar ve oynanışın genişletilmesini, işin Codex tarafından takip edilmesini ve yayımlanan her güncellemenin bağlantısıyla bildirilmesini istedi. Bu planın P2–P4 paketleri sırayla yürütülecek; hepsi tek büyük değişiklikte kodlanmayacak.

1. P1: mevcut performans teslimini tamamla; çalışırken yeni görevle kesilme.
2. P2 ilk teslim: en az üç ayırt edilebilir araç görünümü, platforma doğru oturma ve tutarlı sergileme. Sonraki ayrı teslim: eksik araç sınıflarında yeni kurgu modelleri ve dengeli katalog genişlemesi.
3. P3 küçük teslimler: galeri zemin/platform/ışık/tabela; personelin görünür çalışma hareketleri; menü, düğme ve bilgi hiyerarşisinin bütünlüğü. Gece mavisi/turkuaz/altın korunur. Mevcut ses ayarı ve sessize alma davranışı korunur; ses geri bildirimi düzenlenirse ayrı küçük teslimde, tarayıcıda kullanıcı etkileşimi sonrasında çalışacak şekilde kontrol edilir.
4. P4 küçük teslimler: mevcut sistemlere bağlı haftalık hedefler, rakiple satış yarışı ve koleksiyon/başarı ilerlemesi. Mevcut benzer özellikleri önce incele; ödül tekrarını ve kayıt kaybını engelle.

Her teslimde önceki tamamlanan işler yeniden yapılmaz. Claude kodu ve görselleri üretir; Codex inceleme, test, kaynak entegrasyonu ve yayın doğrulamasını yürütür. GitHub'a her kabul edilen paket için ayrı commit ve kısa kontrol raporu eklenir. İşin durumu `Devir/Gelistirme_Takibi.md` içinde güncellenir. Oyuncuya yalnız gerçekten yayımlanmış yeni sürüm ve doğrulanmış bağlantı gönderilir.

Kullanım limiti dolarsa sayfada görünen yenilenme saatine göre devam planlanır. Limit kalkınca yarım kalan görev son tamamlanan adımdan sürdürülür. Kalan token bilinmiyorsa tahmin edilmez. Plan bitince yeni kapsam kullanıcıyla belirlenir.


10 Ekim güncel durum: P2 ilk görünüm kabul edildi ve 1.9.43 canlı yayımlandı. Windows lobi62/0, deep117/0, closeup27/0; galeri tamamlandı. Sonraki ayrı küçük iş P2 katalog genişlemesi. Yeni girdilerin ID/kayıt/ekonomi uyumluluğu korunmalı; yeni sanat, lisans ve CarLook tablosu tutarlı olmalı. P3 için dar sahnede küçük araçlar/personel örtüşmesi ve açık sayfada viewport ölçüsü güncellemesi gözlemleri duruyor. Ayrıntı CLAUDE_P2_ENTEGRASYON.md.
