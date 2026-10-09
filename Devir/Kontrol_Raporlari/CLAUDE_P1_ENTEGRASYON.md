# Claude P1 performans teslimi — 9 Ekim 2026

## Kaynak ve kapsam

Claude başlangıç SHA: f69cbc5. Teslimler: P1-1-audio-leak-fix.patch (c5185d4) ve P1-2-turntable-msaa-and-visibility-audit.patch (332779c). CRLF korunarak `git am --keep-cr` ile güncel d9cb63c üzerine uygulandı: d404ae2 ve 6fd4aa8. Aktif kaynakta aynı üç dosya kullanıldı.

- Fx ses durdurma kodu ortak yardımcıya çıkarıldı; denetim kapanmadan önce ses sunucusunun kaynak bırakması için 0,25 saniye bekliyor. Oyunda müzik sistemi veya ses seviyesi değiştirilmedi.
- Araç platformlarının 320×220 SubViewport'unda MSAA2 kapatıldı. Dünya, kamera, ölçek ve dönüş sistemi korunuyor.
- Lobi denetimine dokunma, gizleme, arka plan ve yeniden açılma kontrolleri eklendi. Kayıt ve ekonomi koduna dokunulmadı.
- Gerçek runtime render değişikliği nedeniyle yayın metadata'sı 1.9.42 yapıldı: b7b3284. Güncelleme notları sadece Performans iyileştirildi / Optimizasyon yapıldı.

## Codex Windows kontrolleri

Godot 4.7.2. APPDATA ayrı `build_tools/claude-p1-test-user`; denetimler ayrı süreçlerde sıralı çalıştırıldı.

| Kontrol | Sonuç |
| --- | --- |
| lobby headless | exit0, 56 kontrol / 0 başarısız; kapanış kaynak uyarısı yok |
| deep headless | exit0, 117 kontrol / 0 başarısız |
| gallery headless | exit0, GALLERY_AUDIT_COMPLETE |
| Web export | exit0; PCK 8.265.440 bayt |

## Claude'un Linux ölçümleri (Codex burada yeniden ölçmedi)

Xvfb/Mesa llvmpipe, aynı ortamda iki koşu. 1/3/5 araç dönme kare süreleri yaklaşık 20,6/42/63 ms'den 12,6/18,5/25 ms'ye; video belleği yaklaşık 1,8/5,0/8,3 MB'den 0,7/1,7/2,9 MB'ye. Bunlar fiziksel telefon FPS'i değildir. Claude lobi render kontrolü 4 koşu 56/0 ve diğer denetimleri raporladı.

## Sınırlamalar

Fiziksel iPhone/Android/tablet testi yok. MSAA kapatılması büyük ölçekte kenarları daha pürüzlü gösterebilir. Ses uyarısı sadece lobi denetiminin kapanışında giderildi; tüm diğer denetimlere ortak kapatma eklenmedi. Headless sahne görünürlük testi gerçek tarayıcı document.hidden kontrolü yerine geçmez.

## Yayın kontrolü

Önizleme: https://72c30d3e.otopatron.pages.dev/ . Tarayıcıda açılış, misafir menüsü ve üç dönen araç platformu görüldü; 390×844 ekranla yeniden açılış ve sergileme de kontrol edildi. Konsol warn/error kaydı yok. Canlı ana bağlantı 1.9.42: https://otopatron.pages.dev/ ; değişmez üretim https://a308ca79.otopatron.pages.dev/ .

9 Ekim 20:41 UTC canlı doğrulaması: HTML ve release.json 1.9.42; index-release-v1942.pck 8.265.440 bayt, SHA256 `4b1af54f76028811b0f475da9a84822e51115edba5ebb6131001e55e0afa446d`; launch-bundle-b171510f942e1b2b.js. PCK ve bundle yerel paketle birebir eşleşti. Kanıt: live-v1942.json.

Dar ekranda sayfa çalışırken viewport değiştirildiğinde oyun tuvali ilk anda eski ölçekte kaldı; aynı boyutta yeniden açıldığında doğru yerleşti. Bu gözlem sonraki arayüz paketine aktarılır, bu teslimin çözdüğü bir hata olarak sayılmaz. Gerçek tarayıcı sekme gizlenmesiyle document.hidden yolu ayrıca test edilmedi; lobi audit'i Game._web_hidden alanıyla davranışı test eder.
