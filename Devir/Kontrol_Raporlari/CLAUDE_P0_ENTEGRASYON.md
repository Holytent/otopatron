# Claude P0 teslim kontrolü — 9 Ekim 2026

- Claude başlangıç commit'i: `1b73739`. Teslim commit'i: `320ffdfc64a8d55b3b6a28aecbfa8fcf190fcee9`.
- Teslim: `P0-layout-audit-portable-output.patch`; yalnız `OtoPatron/scripts/dev/layout_audit.gd`, +41/-7.
- Yerel uygulanan commit: `54c6adc75ff223985fb5d39d267d58ff54a33089`. Git am satır sonu farklılığı nedeniyle önce başarısız oldu; aynı patch `git apply --ignore-space-change` ile uygulanıp am tamamlandı. İçerik kapsamı korunmuştur.
- Aktif Godot kaynağına aynı dosya kopyalandı. Kayıt, ekonomi veya oyuncu arayüzü değiştirilmedi.

## Codex'in Windows'ta çalıştırdığı kontroller

Godot 4.7.2, headless; APPDATA oyuncu klasöründen ayrı `build_tools/claude-p0-test-user` dizinine yönlendirildi. Kontroller ayrı süreçlerde sıralı çalıştı.

1. `--layout-audit --audit-out=user://audit/cli-output`: exit 0, `LAYOUT_AUDIT_COMPLETE 0 findings`; report.json içeriği `[]`.
2. Çıktı klasörünün üst dizini mevcut bir test dosyası olduğunda: beklenen exit 1 ve `LAYOUT_AUDIT_FAILED output folder could not be created`.
3. Test kullanıcı dizininde save.dat/save.bak/settings.cfg oluşmadı. Oyuncunun gerçek kayıt dizini kullanılmadı.

Kapanışta mevcut 2 ObjectDB / 1 resource uyarısı hâlâ var. P0 bu uyarıyı çözmüyor; P1 görevidir.

## Ayrı tutulan kanıtlar

Claude Linux'ta varsayılan, ortam değişkeni, CLI ve hatalı klasör senaryolarını; ayrıca Xvfb/Mesa ile 25 PNG üretimini raporladı. Bunlar Claude'un beyanıdır; Codex bu Linux çalıştırmalarını tekrarlamadı. Windows'ta varsayılan ve ortam değişkeni senaryoları ayrıca çalıştırılmadı. Headless kontrol görsel doğrulama değildir; fiziksel telefon testi yapılmadı.

## Yayın

Bu teslim sadece geliştirme denetimini etkiler. Oyun sürümü yükseltilmedi ve yeni üretim dağıtımı yapılmadı. Mevcut doğrulanmış canlı oyun 1.9.41: https://otopatron.pages.dev/

Sonraki küçük paket: P1 kaynak uyarısının kaynağı ve 1/3/5 araçla render ölçümü, kanıtlanan maliyetin azaltılması. P0 tekrar yapılmayacak.
