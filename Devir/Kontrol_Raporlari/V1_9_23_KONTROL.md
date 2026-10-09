# OtoPatron V1.9.23 — Akıcı başlangıç animasyonu

Yayın: https://otopatron.pages.dev/

Araçların 20 Hz yeniden çizim sınırı kaldırıldı. Altı araç ayrı, önceden yüklenen görseller olarak her karede konum değiştiriyor. Yol, çizgiler ve şehir arka planı sabit çizimde tutuluyor. Mobil/web ana menüde 60 FPS hedefi kullanılıyor; menüden çıkınca, gizlenince veya iletişim penceresi açılınca 30 FPS sınırına dönülüyor. Uzun beklemeden dönüşte büyük konum sıçraması engelleniyor.

Kontroller: 30/60/120 FPS zaman adımlarında her karede hareket, aynı hız, gizlenince durma, dönüşte sıçrama sınırı ve 320/432/540/1280 genişlikler geçti. Açılış ve sıkıştırılmış motor testleri geçti. Ana yayında HTML ve release.json 1.9.23 doğrulandı. Fiziksel iPhone üzerinde gerçek FPS veya ısınma ölçülmedi.
