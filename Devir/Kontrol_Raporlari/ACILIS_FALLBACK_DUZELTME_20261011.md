# 11 Ekim 2026 — Eski1.9.35 yedek açılış düzeltmesi

Kullanıcı1.9.43ZIP yükledikten sonra Cloudflare üretimce90a683 ekranını ve oyundaV1.9.35 görünümünü paylaştı. Kök neden yerel yayın paketinde doğrulandı: web_v1943/sw-safari.js içine gömülü LAUNCH_HTML hâlâ1.9.35, eski1935PCK ve eski launch bundle içeriyordu. Ağ yanıtı1500ms'yi aşınca bu eski sayfa dönüyordu. Bu yalnız sürüm etiketi hatası değildi. Önceki paketleme1.9.42'den worker'ı güncellemeden kopyalıyordu;1.9.44deaynıhatayıdevralmıştı.

tools/sync_web_fallback.py mevcut index.html'i worker'ın yedek belgesine eşliyor, sürüm ve oyun varlıklarını doğruluyor, worker revision'ını güncelliyor. Yerel package_v1943.py ve package_v1944.py bu adımı çağırıyor. Her iki hazır paket onarıldı. Oyun PCK ve bundle değişmedi; bu dağıtım paketleme düzeltmesidir, Claude'a ait oyun geliştirmesi değildir.

build_tools/check_release_fallback.cjs gerçekworkerfetchhandler'ını izole ortamda çalıştırdı:43ve44içinağhatası,ağzaman aşımı,başarılıağ olmaküzere6kontrol geçti. Her yanıt güncel HTML/PCK/bundleileeşleşti (satırsonlarınormalize). Gerçekyereltarayıcıda8943adresindeV1.9.43açılışıgörüldü. Önceki1.9.43PCK SHA256eşleşmesikorundu. Fizikselcihazperformansıölçülmedi; galeri kasması bu düzeltmenin kapsamında değil.

Düzeltilmiş ZIP: OtoPatron-1.9.43-Cloudflare-Duzeltilmis.zip;76dosya,32.006.066byte; SHA256592ee7ec3a0fbec7e400bcd39032511991657be1ca0d99fbf3997f4196f8cfcb. ÖnceverilenZIPbağlantısındaki dosyada düzeltilmişpaketle değiştirildi.
