# V1.9.3 açılış onarımı

- Beyaz ekran simgeye dokunur dokunmaz oluşuyor; gerçek iPhone kayıtlarına erişim yok, kesin cihaz kök nedeni doğrulanamadı.
- İlk incelemede index.offline dosyası doğrudan bulunamadı. Sonraki kontrol index.offline.html çıktısını ve Cloudflare'ın /index.offline yolunu 200 ile bu belgeye eşlediğini doğruladı. Dolayısıyla önceki 404/aktivasyon engeli varsayımı doğrulanmadı. Güncelleyici artık yalnız gerçek açılış belgesini gerektiriyor.
- Ana belge için 8 saniyeli ağ denemesi + temizlenmiş kayıtlı açılış belgesi eklendi. Navigation yanıtındaki redirect metadata yeni Response ile kaldırılır.
- Açılış katmanı DOM'dan kaldırılmaz; engine ve ilk çalışan sahne hazır olduğunda gizlenir.
- WebGL context kaybı ve görünür uygulamanın 9 saniye boyunca sahne sinyali vermemesi kurtarma ekranı gösterir. Yeniden Aç önce kayıt ister; motor çalışmıyorsa JS 2.5 saniye sonra yeniden yükler.
- Canvas boyutu değişmediyse width/height tekrar atanmaz; gereksiz çizim tamponu sıfırlanmaz.
- Onarım sayfasındaki eski simge yolu ve cache başlığı düzeltildi. Onarım yalnız indirilen dosya önbelleklerini temizler, IndexedDB kayıtlarına dokunmaz.
- Test: worker install/activation, redirect temizliği, offline belge fallback, ilk sahne bekleme, grafik context kaybı ve donmuş dönüş kurtarması geçti.
- Web export ve JS syntax kontrolleri başarılı.
- Production: 97bb8c17.otopatron.pages.dev; ana adresteki release.json 1.9.3. Yayındaki tarayıcıda açılış hesabına ulaşıldı, console error listesi boş.
