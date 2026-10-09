# V1.9.16 — Eski müzik ve mobil çalışma yükü

- ambient.wav birebir V1.9.7 kaynak yedeğinden geri alındı: 43.63634375 saniye, 2,792,770 byte.
- Web müziği HTMLAudioElement üzerinden, oyun motorunun uzun ses örneğinden ayrı oynar. WAV web oyun paketinden çıkarıldı. Native sürüm WAV player kullanır.
- Müzik preload=none; kullanıcı etkileşimi olmadan zorlanmaz. Kullanıcının iOS izin/otomatik oynatma kısıtları korunur. Gizli sayfada/pagehide durur; tekrar görünür olduğunda ve kullanıcı hareketinde denenir. Sesi kapatma işlevi muted+pause kullanır. Safari ses yüksekliği slider desteği cihaz/sürüm davranışına bağlıdır.
- Canvas mobil toplam piksel sınırı 1,200,000; oran en fazla 2. Masaüstü oranı korunur.
- Araç texture cache 12 → 8, galeri arka plan cache en fazla 2. GPU bitmap hacmi azaltılır; engine/GPU toplam bellek ölçümü yapılmadı.
- Pack 8,713,492 → 6,596,648 byte. Eski müzik ayrı 2,792,770 byte dosyadır; toplam transfer azalması iddia edilmez, isteğe bağlı müzik yüküne ayrılır.
- Node music, loading, accounts, startup testleri PASS. Native eski müzik ve diğer 8 ses stream kontrolü PASS.
- Masaüstü native ekran kontrolü: layout-v1916.log. Fiziksel iPhone çökmesi yeniden üretilemedi; neden kesinleşmedi. Bellek yükü ve uzun ses oynatma yolu olası etken olarak düzenlendi.
- DevTools/performance trace aracı mevcut değildi. Lighthouse/CPU/ısı ölçümü iddia edilmez.
