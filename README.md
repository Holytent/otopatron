# OtoPatron
Mobil araç galerisi simülatörü — Godot 4.7.2, GDScript, GL Compatibility.

## Başlangıç
`OtoPatron/project.godot` dosyasını Godot ile içe aktarın. Aynı sürümün resmi export template'ini kurun.
Önce [devir notunu](Devir/OtoPatron_Cloud_Devir_Notu.md) okuyun. [Claude promptu](Devir/OtoPatron_Cloud_Prompt.txt) ve geçmiş kontrol raporları Devir klasöründe.

## Durum
Son doğrulanmış ana yayın **1.9.41**: https://otopatron.pages.dev/ . Canlı paket hashleri ve tarayıcı görünümü kontrol edildi. Fiziksel telefon performansı ölçülmedi.
Güncel kaynak dalı cloud/galeri-iyilestirme; PR #1 açık. Claude için [geliştirme planı](Devir/Claude_Gelistirme_Plani.md) esas alınır.

## Klasörler
- OtoPatron: düzenlenebilir oyun, görseller, web yardımcıları ve Godot denetimleri.
- AccountClient: hesap istemcisinin kaynakları/bağımlılık kilidi/testleri.
- NotificationService: bildirim Worker kaynakları; gizli anahtarlar ayrı yapılandırılır.
- Devir: durum, kontrol raporları, prompt.

## Ortak çalışma
Claude ayrı `cloud/galeri-iyilestirme` branch'inde çalışmalı; PR veya değişiklik paketi teslim etmeli. Ana yayına birleştirme bu yerel çalışma tarafından yapılır. Üretim yetkisi/gizli anahtar/oyuncu kaydı bu depoya eklenmez.

Kenney Car Kit modelleri CC0 lisanslıdır; `OtoPatron/art/cars3d/License.txt` dosyasına bakın. Bu lisans tüm oyun kaynaklarına verilen bir açık kaynak lisansı değildir.
