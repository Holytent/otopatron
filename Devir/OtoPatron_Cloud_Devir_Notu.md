# OtoPatron — Cloud geliştirme devir notu
Tarih: 9 Ekim 2026. Bu belge, mevcut kaynaklar ve build_tools kontrol raporlarına göre hazırlanmıştır.

## 1. Yayın ile geliştirme sürümünü ayır
- Son doğrulanmış ana yayın **1.9.41**: https://otopatron.pages.dev/ . Değişmez yayın https://93a7de4e.otopatron.pages.dev/ . Kontrol_Raporlari/live-v1941.json yayın kanıtıdır.
- Gerçek Kenney GLB modelleri ve Claude sınıf eşleme patch'i yeniden export edilip yayınlandı; tarayıcıda menü ve platformlar görüntülendi. Fiziksel telefon performansı ölçülmedi.
- Oyun kodu commit'i 6f0308ed71da0ade7368975e88ebe8fd3525e1c8; cloud/galeri-iyilestirme dalı. PR #1 hâlâ açık, main daha eski olabilir. Dalı güncellemeden işe başlama.
- Güncel eksikler, yeni araçlar, görünüm ve oynanış paketleri için Claude_Gelistirme_Plani.md esas alınır. İlk paket taşınabilir layout_audit çıktısıdır.
## 2. Oyun ve teknik yapı
OtoPatron, Ramazan ÖZKESKİN ve Sudenur GÜVEZ imzalı mobil araç galerisi simülatörüdür. Godot 4.7.2 / GDScript, GL Compatibility, 540×960 referans alanı, telefon ve bilgisayar düzeni. Web yayını Cloudflare Pages, proje otopatron, production branch main. Oyun HTML/JavaScript ile yeniden yazılmış değildir.

Kaynak ZIP'inde:
- OtoPatron/project.godot: Godot'ta içe aktarılacak proje.
- OtoPatron/scenes/main.tscn: giriş sahnesi.
- scripts/autoload/game.gd: oyun, para, zaman, araç, ekip, kayıt işlemleri.
- scripts/autoload/account_bridge.gd: Godot/web hesap bağlantısı.
- scripts/autoload/loc.gd ve scripts/data/strings.gd: yerelleştirme.
- scripts/autoload/mobile_scroll.gd, mobile_input.gd: kaydırma/yazı girişi.
- scripts/ui/main.gd, ui.gd: gezinme, cüzdan ve ortak arayüz.
- scripts/ui/lobby_scene.gd, road_anim.gd, car_turntable.gd: galeri/şehir/sergileme.
- scripts/ui/screen_*.gd: sayfalar; playable_drive.gd sürüş.
- scripts/dev/*_audit.gd: mevcut denetimler.
- web/safari/: HTML kabuk, yükleyici, ses, hesap, izin, güncelleme ve mobil editör yardımcıları.
- AccountClient/accounts.js: düzenlenebilir hesap JavaScript kaynağı. Projedeki web/safari/accounts.js derlenmiş çıktıdır; kaynak değişince yeniden bundle et.
- Devir/Kontrol_Raporlari/: geçmiş sürümlerin sonuçları ve test kanıtları.

Hesap sistemi Supabase; misafir cihaz kaydı, oturum, giriş/kayıt, şifre sıfırlama ve bulut kayıt çakışması yönetimi vardır. Bildirimler ayrı Cloudflare Worker hizmetini kullanır. Bu kaynak ZIP'i üretim hesabı yetkisi veya bildirim servisinin gizli anahtarlarını içermez.

Kayıt sürümü SAVE_VERSION=7; user://save.dat, sağlam yedek user://save.bak, ayarlar user://settings.cfg. Web tarafında Godot'un kalıcı dosya sistemi ve hesap köprüsü kullanılır. Anahtarları veya domain'i keyfi değiştirmek kayıt erişimini bozabilir. Yazımlar geçici dosya + sağlam yedek ile korunur. Kaydı silerek hata çözme.

ZIP'teki export_presets.cfg taşınabilirlik için yerel bilgisayara özgü özel web template yolundan arındırıldı. Aynı Godot sürümünün resmi export template'ini kur. Standart template motor baytları farklıysa eski sıkıştırılmış motor parçalarını kopyalama; yeni motorun parçalarını ve hashlerini yeniden üret. Önce kaynak import, sonra export, HTML/helper/bundle/manifest/PCK boyutu ve SHA256 denetimi gerekir.

## 3. Önceki sürümlerde yapılan işler
Aşağıdaki liste geçmiş raporların özeti; eski ara tasarımlar tekrar uygulanacak gereksinimler değildir.

### Kararlılık, kayıt ve açılış
- Kullanıcının uygulama açıkken yükleme ekranına dönme şikâyeti araştırıldı. Safari geri dönüşündeki eksik heartbeat'in canlı oyunun üstüne yükleyici koyması engellendi; gerçek WebGL context loss koruması korundu. Telefonda bütün yeniden yüklemelerin tek nedeni doğrulanmış değildir.
- Kredi taksitlerindeki küsurat toplamları, bozuk kayıt reddi, sağlam yedek, eski eksik istatistik alanları ve ekspertizden sonra anında kayıt düzeltildi.
- Hesaptan çıkarken bekleyen kayıtlar yönetildi; iptal edilmiş girişin geç yanıtı engellendi. Bulut kaydı çakışınca yerel oyun sessizce silinmez.
- Güncellemeden önce cihaz kaydı ve bulut kaydı beklenir; bağlantı gecikirse cihaz yedeği korunur.
- Motor indirmesi 39.514.754 bayttan 10.249.047 bayta indirildi: sıkıştırılmış/parçalı akış, dosya bütünlüğü, desteklemeyen tarayıcıya fallback.
- Dokuz yardımcı script içerik hash'li tek açılış paketine alındı, logo HTML içine gömüldü, geçici ağ hatasında üç deneme ve daha uzun bekleme sağlandı. Geç yanıt ikinci motor başlatamaz.
- Gizli yükleme alanının animasyonu durdurma hatası düzeltildi. Web sekmesi gizliyken gereksiz animasyonlar durur.
- Eski kayıtlardaki Gül/Barış/Ayşe gibi bozuk Türkçe isimleri onarma eklendi; doğru Türkçe ve diğer diller korunur.

### Ses, bildirim ve güncelleme
- Ses takılması şikâyetleri için eski galeri müziğine dönüş ve web ses yaşam döngüsü düzenlemeleri yapıldı; arka planda ses durur. Fiziksel iPhone ses sorununun kesin çözümü ölçülmedi.
- İkinci el fırsat bildirimi HUD ile içerik arasında gerçek satıra taşındı; eski bildirim yenisiyle değiştirilir, paranın üstünü kapatmaz.
- İzin ver / İzin verme seçimi eklendi; mevcut OS izni korunur, reddedilen sistem izni zorla değiştirilemez.
- Güncelleme düğmesi alt gezinmeden ayrıldı, UTF-8 bozulması düzeltildi; otomatik zorunlu yeniden yükleme yerine kullanıcı işlemiyle güncelleme.
- Kullanıcının son kuralı: güncelleme panosuna yalnız kısa ve doğru önemli notlar. İzinli ifadeler: “Performans iyileştirildi.”, “Yeni araçlar eklendi.”, “Çimler biçildi.”, “Optimizasyon yapıldı.” Yapılmayan bir değişikliği yazma. Son sürümlerde yalnız performans/optimizasyon ifadeleri kullanıldı.

### Araçlar, karakterler, ekonomi
- 54 kurgu model ve farklı gövde görselleri; kir, çizik, yıkama ve onarım sonrası görünür farklar geliştirildi.
- Araç yakın inceleme 1×/1.6×/2.2×, ön/orta/arka odak, bakım önizlemesi. Önizleme para/durum değiştirmez; ekspertiz yapılmamış mekanik bilgi gizli kalır.
- Altı konuşan müşteri/satıcı figürü; tefeci için yedinci figür, masa/lamba/evrak/sopa sahnesi. Nefes, göz kırpma, konuşma ve el hareketi. Görünmezken durur.
- Satış geçmişi: son 100 satışın alış, bakım, satış ve net kârı. Eski kayıtların olmayan ayrıntıları uydurulmaz.
- Pazarlıkta kir/çizik/km hakkında cevaplar; her alıcıya tek cevap ve teklif tavanı. Test sürüşü sonucu tek sefer uygulanır, iptal işlem üretmez.
- Oynanabilir test sürüşü: yön ve fren, virajlı parkur, bitişte durma; üstten araç burnu yol yönüne bakacak şekilde düzeltildi.
- Araç kurtarma, rakip galerici Cem, günlük talep değişimi, sınırlı spor araç ilanı, atomik takas ve haftalık açık artırma. Haftalık Cem/Selin teklifleri, kapasite/bakiye/gece/çift teslim kontrolleri.
- Araç yönetiminde tamir ve benzeri işlemler sonrası kaydırma/ilan taslağı korunur. Yazı alanı yalnız kısa dokunma ile açılır; kaydırırken klavye açılmaz.
- Elmas paketleri zorlaştırıldı: 5/15/40 için 100.000/320.000/900.000 TL.
- Temizlikçi, mekanik, satış personeli ve güvenlik sayısı galeri kapasitesiyle büyür: 5/8/12/16/20 araç için rol başına 1/2/3/4/5 kontenjan.
- Günlük kişi başı ücretler: temizlikçi650, mekanik1200, satış1100, güvenlik900 TL. Otomatik günlük tahsilat; yetersiz bakiye fatura borcuna gider.
- Personel iş yaptıkça ekip deneyimi kazanır; ustalık1–5. Temizlik/onarım indirimleri sınırlıdır, satış garantisi yoktur.
- Hırsız alarmı kırmızı uyarı, güvenlik kademesi/sayısına bağlı otomatik müdahale; ayrıca müdahale bedeli alınmaz. Başarısız müdahalede zarar olabilir.
- İşletme 07.00–23.00 açık. 23.00'te zaman durur, ücretsiz Uyu ile ertesi gün07.00. Uyku bedeli yoktur; normal günlük giderler yine tahsil edilir, çift fatura engellenir.

### Sayfa düzeni ve canlı galeri
- Ana Sayfa yalnız gün özeti ve küçük şehir animasyonu. Galerim araç/gerçek alıcı/ilan/satış işlemleri için ayrı sayfa.
- Beş alt sekme: Ana Sayfa, Galerim, Pazar, Beceriler, Yönetim.
- Müşteri siparişleri kullanıcı isteğiyle kaldırıldı; eski veri korunur, erişim düğmesi yok. Yeniden ekleme.
- Dekor/geliştirme, yatırım ve sokak olayları ayrı düzenlendi; sokak olayları dekor içinde değildir.
- Şehir yalnız yeni oyunda seçilir; oyun başladıktan sonra değiştirme engellenir.
- Galeri önizleme arka planının cache'den erken silinip görünmeme hatası düzeltildi. Tabela ortalama/ad kaydı düzenlendi.
- Galerim görünümü açık kalır. Ana Sayfa ve galeri aydınlatması cihaz saatine değil oyun saatine bağlıdır.
- Menü Dış görünüm / Galeri içi / Şehir; kayıtlı tabela, dekor, ekip, araçlar, saat. Menüde zaman/maaş ilerlemez.
- Oyun içi sahnede gerçek alıcılar dokunulabilir; menüde tanıtım figürleri. Sahne araç/ekip/alıcı yapısı değişirse yenilenir, her bakiye değişiminde kurulmaz.
- Hava: yağmur, kar, sis; açık alandaki araçlar yağışlı açık saatlerde kirlenir, cam vitrin korunur.
- Yürüme, araç inceleme, temizlik ve satış teslim sahneleri; aynı işlem animasyondan ikinci kez ödeme üretmez.
- Kaydırma atalet/yumuşatma, sınırlı görsel önbellek ve ekran dışı animasyon durdurma. Hedef FPS gerçek cihazda ölçülen FPS değildir.

## 4. Yerel 1.9.41 değişiklikleri — hâlâ aday
- Global palet: gece mavisi101e30, paneller172d42/20394d, turkuaz087d83/59ddce, altınedc16b, açık metineef4f8. Menü, giriş, yeni oyun ve HTML editör uyumu.
- GALERİ SİMÜLATÖR beyaz; giriş hero görselinde ayrıntılı mevcut SVG araçları.
- Şehir listesi yalnız isim, plaka ön eki ve bozuk konum simgesi yok.
- HTML isim editörü klavye olaylarını Godot'a sızdırmaz; Kaydet ana formu günceller, Vazgeç orijinal adı geri getirir.
- Yeni hoş geldin metni başlangıç sermayesi/ilk araç/masraf-kâr akışını anlatır.
- Cüzdan nakit yazısı18, düğme yüksekliği34; elmas tam sayı, + yok. 105 elmas denetimi geçti.
- “Örnek vitrin” etiketi dış/iç/menu/live kaldırıldı. “Şehirden bir kesit” kaldırıldı. İçteki koyu resepsiyon bloğu kaldırıldı.
- Dış trafik sürekli ileri, sergi araçları sabit. Cam içi araçların yeri güncellendi; son konumun tarayıcı görsel kontrolü gerekli.
- 360 platformlar önce elle çizilmiş basit kutu gövdelerle yapıldı; kullanıcı hatalı olduğunu söyledi. Bunları son kaynakta Kenney Car Kit GLB gerçek modelleri + SubViewport/Camera3D/ışık/dairesel platform ile değiştirdik.
- Lisans: Kenney Car Kit3.1 CC0, https://kenney.nl/assets/car-kit . art/cars3d/License.txt var. Mena Free Racing Car/PROMETEO yalnız araştırıldı; indirilip oyuna eklenmiş değildir.
- Sergileme gövde türüne göre genel modele eşlenir; 54 modele ayrı özgün 3B model yapıldığı iddia edilmez. Renk/durum uyumu ve tür eşlemesi ayrıca kontrol edilmeli.
- Her araç için320×220 viewport, en çok3 sergi, dönüş yaklaşık30fps örneklemesi; görünür lobi ilerledikçe UPDATE_ONCE. Gerçek mobil maliyeti ölçülmedi.

## 5. Kontroller ve açık sınırlar
V1.9.40 raporu: toplam378 kontrol,0 başarısız; dört dil/üç ekran ölçüsü yerleşim taraması0 taşma; tarayıcıda giriş/misafir/menu/galeri kontrolü. Sonraki V41 arayüz adayında390 kontrol,0 başarısız. Bu toplam yeni GLB değişikliği öncesine aittir.
Son GLB kaynak değişikliğinde yalnız48 lobi denetimi tekrar geçti (lobby-v1941-models.log). Headless test 3B görselin iyi göründüğünü kanıtlamaz. Parse sırasında bulunup düzeltilen Environment sabit hatası vardı; önceki hatalı denetim tamamlanmış sayılmaz.
Bazı headless süreç kapanışlarında önceki2 ObjectDB/1 kaynak uyarısı sürüyor. Fiziksel iPhone/Android FPS, bellek, pil/ısı ve ses ölçülmedi. Gerçek kullanıcıyla giriş/kayıt/e-posta/bildirim uçtan uca yapılmadı. Bütün cihazlarda kusursuz çalışma sözü verilmedi.

## 6. Devralanın ilk işi
1. Projeyi import et; yeni modellerin gerçek tarayıcı görünümünü test et: tekerlekler bağlı, gövde doğru, araç zemine oturmuş, platformda kırpılmadan360 dönüyor, diğer araçla çakışmıyor.
2. Küçük ekranda kameralı3B maliyetini gözle/ölçümle kontrol et; ekran dışındayken render yapmasın. Gerekirse çözünürlük/MSAA azalt; yanlış kutu modeline dönme.
3. Hem dış hem iç galeri, boş ve dolu envanter, gündüz/gece, isim/şehir formu, mobil klavye, bakiye/elmas, kaydırma ve eski kayıtları tekrar kontrol et.
4. Godot testlerini ayrı süreçlerle sıralı çalıştır. Birden çok audit flag'i bütün grupları çalıştırmaz: main.gd elif zinciri yalnız ilkini seçer. Test kayıtlarını production kaydıyla karıştırma.
5. Yeni web export'u doğru motor/helper/bundle/hash ile oluştur; yalnız önizleme branch'ine dağıt. İki geliştirici aynı anda main yayın yapmasın.
6. Değişen dosya listesi, test sonuçları ve önizleme ekran görüntüsüyle geri teslim et. Ana yayına birleşmiş/denetlenmiş tek sürüm alınsın.

## 7. İki taraftan çalışma
Bu bilgisayar/sohbet ile Cloud otomatik olarak aynı dosyaları paylaşmaz. ZIP bir anlık kopyadır. Git deposu varsa Cloud ayrı cloud/galeri-iyilestirme branch'inde çalışsın, küçük commit/PR versin; bu sohbet kaynakları burada inceleyip birleştirsin. Git yoksa changed-files ZIP + unified diff + çalışma raporu versin. Her teslimat başladığı sürümü/kaynak özetini belirtmeli. ZIP'in tamamını eski bir kopyanın üstüne körlemesine yazma.
İlk Cloud kapsamı 3B sergileme/galeri görselleri ve bunların testi olsun. Ekonomi, kayıt formatı, hesabın RLS politikaları, ses ve yayın yükleyicisi gerekmedikçe değişmesin. Gerekli değişikliği raporla. Ana yayın sorumlusu bu sohbet/yerel çalışma olsun; Cloud preview/PR teslim etsin.
