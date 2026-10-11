# 11 Ekim 2026 — Yanlış yükleme sonrası geri dönüş

Kullanıcı OtoPatron Cloudflare projesine yanlışlıkla başka içerik yüklediğini bildirdi ve geri dönüş istedi. Pages API ana üretimde e1ebbc5f-6f3e-4f45-acee-253eeeed1511 bulunduğunu doğruladı. Son doğrulanmış1.9.43 üretim yayını f53169f7-be74-494c-a953-b7cc477fdc41 hâlâ başarılı durumdaydı.

Cloudflare Pages rollback API ile11Ekim12:06UTC/15:06Türkiye civarı eski sağlam hedefe dönüldü. Sonraki proje GET yanıtında canonical_deployment.id hedefle eşleşti. Kanıt build_tools/rollback-v1943-20261011.json. Yeni paket dağıtımı veya1.9.44yayını yapılmadı. Oyun verisine, kayıt deposuna veya kaynaklara müdahale edilmedi.

Uzak içerik tekrar hash kontrolü ağ hatasıyla tamamlanamadı. AnaURL tarayıcıdaV1.9.35gösterdi; değişmez43adresi bağlantı zaman aşımına uğradı. Bu nedenle kontrol düzlemi geri dönüşü doğrulandı, güncel public içerik doğrulaması henüz tamamlanmadı. Önbellek olası nedenlerden biridir; kesin kök neden iddia edilmiyor.

Kullanıcı için OtoPatron-1.9.43-Cloudflare.zip hazırlandı:76dosya,32.001.543byte;index.htmlZIPkökünde. ZIP bütünlüğü, HTML/release1.9.43 ve PCK daha önce doğrulanmış canlı SHA256ile eşleşti. SHA256 c65d4ad48a0f7d16173f74bd8ddaf2468bd374ce899b8117365796186794f60b. Ana oyun URL'si https://otopatron.pages.dev/ ; sabit43URL https://f53169f7.otopatron.pages.dev/ .
