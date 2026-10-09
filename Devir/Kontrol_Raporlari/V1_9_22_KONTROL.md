# OtoPatron V1.9.22 — 8 Ekim sabah raporu

## Yayın

**Tamamlandı ve ana adreste doğrulandı:** https://otopatron.pages.dev/

Sürüm: **V1.9.22**. Yayın önizlemesi: https://e03eff39.otopatron.pages.dev/

## Bu gece düzeltilenler

- Aynı aracın iki kez satın alınması ve geçersiz alış/satış tutarları engellendi.
- Buluttan yüklenen seviye ödülleri ve hediye kasalarının tekrar alınması düzeltildi.
- Kredi boyunca ödenen toplam tutar, teklif edilen tutarla eşitlendi. Kapatılmış kredinin tekrar tahsil edilmesi engellendi.
- Tam bakiye ile tefeci borcu ödeme ve mağaza paketi alma sınırları düzeltildi.
- Satılabilir araç, yatırım, mevduat veya başka kurtarma imkânı olan oyuncunun yalnızca nakdi sıfır diye iflasa düşmesi engellendi. Bu düzeltme, otomatik ilerleme sıfırlama riskini azaltır; telefondaki bütün yeniden yüklemelerin nedeni olarak doğrulanmış değildir.
- Geçersiz kayıtlar yüklenmeden reddediliyor. Sağlam yedek korunuyor; eksik eski istatistik alanları tamamlanıyor.
- Ekspertiz ücreti ve sonucu işlemden hemen sonra kaydediliyor.
- Hesap çıkışı, devam eden ve sırada bekleyen bulut kayıtlarını bekliyor. Vazgeçilmiş bir giriş işleminin geç gelen yanıtı oyunu değiştiremiyor. Başka cihazdaki kayıt çakışması yerel ilerlemeyi silmiyor.
- Hesap bağlantısında sınırsız bekleme yerine bağlantı zaman sınırı eklendi. Güncelleme düğmesi, cihaz kaydından sonra bulut kaydını bekliyor; bağlantı uzarsa cihaz kaydı korunuyor.
- Bozuk görünen sekiz metin düzeltildi. Görünür metin taramasında bozuk kodlama bulunmadı.
- Açılışta oyun motorunun indirme boyutu **39.514.754 bayttan 10.249.047 bayta** düştü (yaklaşık %74 azalma). Oyun paketi ayrıca yaklaşık 7,57 MB. Müzik isteğe bağlı, ayrı yükleniyor.
- İndirme ilerlemeye devam ederken toplam süre yüzünden gereksiz “yeniden dene” gösterilmesi düzeltildi. Yeni sıkıştırmayı desteklemeyen tarayıcılar normal dosyalardan açılıyor.
- Güncelleme panelinde yalnızca üç önemli değişiklik gösteriliyor.

## Gerçekleştirilen kontroller

| Kontrol | Sonuç |
|---|---|
| Oyun, para, araç, kayıt ve ekonomi | **117 kontrol, 0 başarısız** |
| Uzun işlem denemesi | **200 alış-satış**, her işlemde JSON kayıt dönüşümü; bakiye, kâr ve sayılar tutarlı |
| Kredi vadeleri | 3, 6, 12, 24 ve 36 ayın bütün taksitleri; teklif ve toplam ödeme eşit |
| Ekran düzeni | **144 kombinasyon:** 12 ekran × 4 dil × 3 boyut; raporlanan taşma/kesilme yok |
| Uzun sayfa gezintisi | **240 geçiş:** düğüm artışı 0, kaynak artışı 0; araç görsel önbelleği 8 sınırında |
| Araçlar | 54 modelin görselleri; 8 gövde biçimi; kir, yıkama ve kaporta onarımı |
| Galeri | İsim, kayıt, paket fiyatı, kapasite, satın alınmış seçeneğin tekrar kullanımı |
| Müşteri siparişleri | Kabul, araç koşulları, bütçe, tek ödeme, kayıt/yükleme, süre sonu ve dört dil |
| Karakterler | 7 figür, konuşma, bekleme; görünmeyen/örtülen figürün durması |
| Hesap akışları | Deneme bağlantısıyla kayıt, şifre sınırı, giriş, misafir, oturumdan devam, çıkış ve kayıt çakışması |
| Web kontrolleri | 9 otomatik kontrol grubu geçti: hesap akışı, hesap yarışları, açılış, sıkıştırılmış motor, yükleme, izin, ses, yazı girişi, bildirim zamanları |
| Yayındaki servisler | Hesap sağlık ve bildirim anahtarı uçları HTTP 200 |
| Tarayıcıda deneme yayını | Oyun motoru açıldı; hesap, izin seçimi, güncelleme paneli ve menü görüldü |
| Ana yayın | release.json ve HTML V1.9.22; sıkıştırılmış dosya HTTP 200 ve açılmış içerik doğru |

Bildirimlerin 5/5/5/5/10 dakika aralıkları ve eski galeri müziği korundu. Bildirim testi sırasında kullanılan 503 yanıtı, başarısız gönderimden sonra tekrar denemeyi sınayan yapay durumdur; yayındaki servisin hatası değildir.

## Kontrollerin sınırı

Fiziksel iPhone 11 veya iPhone 15 Pro Max üzerinde sıcaklık, pil tüketimi ve Safari ölçümü yapılmadı. Ekran boyutu denemeleri fiziksel cihaz testi yerine geçmez. Gerçek yeni hesap oluşturulmadı, doğrulama e-postası veya deneme bildirimi oyunculara gönderilmedi; hesap akışları kontrollü deneme bağlantısıyla, servis erişimi ise yayında sınandı.

Bu denemeler geçti; bütün cihazlarda hiçbir hata olmayacağı sözü verilemez. Telefonda işletim sisteminin görüntü sürecini yeniden başlatması gibi durumların cihaz üzerinde ayrıca görülmesi gerekir.

## Yedekler ve kanıtlar

- `OtoPatron_Cloudflare_V1_9_22_Kapsamli_Kontrol.zip`: yayın dosyaları.
- `OtoPatron_Godot_V1_9_22_Kapsamli_Kontrol.zip`: düzenlenebilir proje ve hesap kontrolleri.
- `build_tools/deep-audit-results.json`, `navigation-audit.json`, `layout_audit/report.json`, `live-v1922.json`: kontrol çıktıları.

Özel anahtarlar ve oturum bilgileri paylaşım yedeklerine eklenmedi. Kontroller ayrı kayıt dosyalarıyla yapıldı; oyuncu kayıtları değiştirilmedi.

Sıkıştırma için tarayıcı özelliği belge kaynağı: https://developer.mozilla.org/en-US/docs/Web/API/DecompressionStream
