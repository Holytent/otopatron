# OtoPatron
Mobil araç galerisi simülatörü — Godot 4.7.2, GDScript, GL Compatibility.

## Başlangıç
`OtoPatron/project.godot` dosyasını Godot ile içe aktarın. Aynı sürümün resmi export template'ini kurun.
Önce [devir notunu](Devir/OtoPatron_Cloud_Devir_Notu.md) okuyun. [Claude promptu](Devir/OtoPatron_Cloud_Prompt.txt) ve geçmiş kontrol raporları Devir klasöründe.

## Durum
Son doğrulanmış ana yayın **1.9.40**: https://otopatron.pages.dev/ . Bu depo **1.9.41 geliştirme adayıdır**; yayınlandığı anlamına gelmez.
Gerçek GLB sergileme modellerinin tarayıcı görsel testi ve yeniden web export'u bekliyor. Son lobi denetimi48 kontrol/0 başarısız; eski süreç kapanışı kaynak uyarıları sürüyor. Fiziksel telefon testi yapılmadı.

## Klasörler
- OtoPatron: düzenlenebilir oyun, görseller, web yardımcıları ve Godot denetimleri.
- AccountClient: hesap istemcisinin kaynakları/bağımlılık kilidi/testleri.
- NotificationService: bildirim Worker kaynakları; gizli anahtarlar ayrı yapılandırılır.
- Devir: durum, kontrol raporları, prompt.

## Ortak çalışma
Claude ayrı `cloud/galeri-iyilestirme` branch'inde çalışmalı; PR veya değişiklik paketi teslim etmeli. Ana yayına birleştirme bu yerel çalışma tarafından yapılır. Üretim yetkisi/gizli anahtar/oyuncu kaydı bu depoya eklenmez.

Kenney Car Kit modelleri CC0 lisanslıdır; `OtoPatron/art/cars3d/License.txt` dosyasına bakın. Bu lisans tüm oyun kaynaklarına verilen bir açık kaynak lisansı değildir.
