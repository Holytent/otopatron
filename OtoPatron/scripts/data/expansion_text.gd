class_name ExpansionText
extends RefCounted
const TEXT: Dictionary = {
	"team_title": {"tr": "Personel", "en": "Staff", "ar": "الموظفون", "fr": "Personnel"},
	"team_info": {"tr": "Maaşlar oyun günü sonunda giderlere eklenir. Oyun kapalıyken iş yapılmaz. İşe alırken giriş bedeli ve en az bir günlük maaş bütçede bulunmalı.", "en": "Wages join daily bills. No work while offline. Hiring requires the fee plus one day of wages.", "ar": "تضاف الأجور للفواتير اليومية. لا عمل أثناء إغلاق اللعبة. يلزم رسم التوظيف وأجر يوم.", "fr": "Salaires dans les frais quotidiens. Aucun travail hors ligne. Prévoir les frais et un jour de salaire."},
	"team_total": {"tr": "Toplam günlük maaş", "en": "Total daily wages", "ar": "إجمالي الأجور اليومية", "fr": "Salaires par jour"},
	"team_wage": {"tr": "Günlük maaş", "en": "Daily wage", "ar": "الأجر اليومي", "fr": "Salaire quotidien"},
	"team_cleaner": {"tr": "Temizlikçi", "en": "Cleaner", "ar": "عامل النظافة", "fr": "Agent de nettoyage"},
	"team_mechanic": {"tr": "Usta", "en": "Mechanic", "ar": "الميكانيكي", "fr": "Mécanicien"},
	"team_sales": {"tr": "Satış danışmanı", "en": "Sales adviser", "ar": "مستشار المبيعات", "fr": "Conseiller commercial"},
	"team_help_cleaner": {"tr": "Her oyun saatinde bir kirli aracı yıkar. Yıkama ücreti %50 azalır; bakım giderine eklenir.", "en": "Washes one dirty vehicle each game hour. Washing costs 50% less, recorded as preparation.", "ar": "يغسل سيارة كل ساعة لعب. تنخفض تكلفة الغسيل 50٪ وتُسجّل كتجهيز.", "fr": "Lave une voiture par heure de jeu. Coût réduit de 50 %, ajouté aux frais du véhicule."},
	"team_help_mechanic": {"tr": "Araç onarım masraflarını %8 düşürür. Onarımı sen seçersin.", "en": "Reduces repair costs by 8%. You choose repairs.", "ar": "يخفض تكلفة الإصلاح 8٪. أنت تختار الإصلاح.", "fr": "Réduit les réparations de 8 %. Vous choisissez les travaux."},
	"team_help_sales": {"tr": "İlandaki araçların alıcı bulma ihtimalini %20 artırır. Satış garantisi vermez.", "en": "Raises inquiry chances by 20%, without guaranteeing a sale.", "ar": "يزيد احتمال الاستفسارات 20٪ دون ضمان البيع.", "fr": "Augmente les chances de visite de 20 %, sans garantir une vente."},
	"team_active": {"tr": "Çalışıyor", "en": "Employed", "ar": "يعمل", "fr": "En poste"},
	"team_dismiss": {"tr": "İşten çıkar", "en": "Dismiss", "ar": "إنهاء العمل", "fr": "Licencier"},
	"team_hire": {"tr": "İşe al · {0}", "en": "Hire · {0}", "ar": "توظيف · {0}", "fr": "Recruter · {0}"},
	"team_debt": {"tr": "Önce ödenmemiş giderlerini kapat.", "en": "Pay outstanding bills first.", "ar": "سدّد الفواتير المستحقة أولاً.", "fr": "Réglez les factures en attente."},
	"bill_team": {"tr": "İşe alınan personel maaşları", "en": "Hired staff wages", "ar": "أجور الموظفين", "fr": "Salaires du personnel recruté"},
	"trend_title": {"tr": "Bugünün pazar talebi", "en": "Today’s market demand", "ar": "طلب السوق اليوم", "fr": "Demande du jour"},
	"trend_info": {"tr": "{0} bugün daha çok aranıyor. Alıcı ihtimali artar; teklifler biraz güçlenir. Talep her oyun günü değişir.", "en": "{0} is in demand today. More inquiries and slightly better offers. Changes each game day.", "ar": "الطلب مرتفع اليوم على {0}. استفسارات أكثر وعروض أفضل قليلاً. يتغير يومياً.", "fr": "{0} recherchés aujourd’hui : davantage de visites et offres légèrement meilleures. Change chaque jour de jeu."},
	"rare_title": {"tr": "Nadir araç fırsatı", "en": "Rare vehicle opportunity", "ar": "فرصة سيارة نادرة", "fr": "Occasion rare"},
	"rare_time": {"tr": "Kalan süre: {0} dk · gerçek zaman", "en": "Time left: {0} min · real time", "ar": "المتبقي: {0} دقيقة · وقت فعلي", "fr": "Temps restant : {0} min · temps réel"},
	"rare_expired": {"tr": "İlanın süresi doldu.", "en": "Listing expired.", "ar": "انتهت مدة الإعلان.", "fr": "Annonce expirée."},
	"trade_title": {"tr": "Araç takası", "en": "Vehicle trade-in", "ar": "مقايضة السيارات", "fr": "Reprise de véhicule"},
	"trade_open": {"tr": "Takas teklifini gör", "en": "View trade-in offer", "ar": "عرض المقايضة", "fr": "Voir la reprise"},
	"trade_incoming": {"tr": "Alıcının teklif ettiği araç", "en": "Buyer’s trade-in vehicle", "ar": "السيارة المعروضة للمقايضة", "fr": "Véhicule proposé par l’acheteur"},
	"trade_credit": {"tr": "Takas aracına verilen değer", "en": "Trade-in credit", "ar": "قيمة سيارة المقايضة", "fr": "Valeur de reprise"},
	"trade_sale": {"tr": "Senin aracın için teklif", "en": "Offer for your vehicle", "ar": "العرض لسيارتك", "fr": "Offre pour votre véhicule"},
	"trade_cash": {"tr": "Nakit farkı", "en": "Cash difference", "ar": "فرق النقد", "fr": "Différence en espèces"},
	"trade_receive": {"tr": "Alacağın nakit", "en": "Cash you receive", "ar": "النقد المستلم", "fr": "Somme reçue"},
	"trade_pay": {"tr": "Ödeyeceğin nakit", "en": "Cash you pay", "ar": "النقد المدفوع", "fr": "Somme à payer"},
	"trade_hint": {"tr": "Aracı ekspertizle kontrol edebilirsin; ücret bütçenden düşer. Takas kabul edilirse senin aracın satılır, bu araç galerine gelir.", "en": "Inspection fees come from your budget. Accepting sells your vehicle and adds this one to your gallery.", "ar": "تُخصم رسوم الفحص من رصيدك. القبول يبيع سيارتك ويضيف هذه إلى المعرض.", "fr": "L’expertise est payante. Accepter vend votre véhicule et ajoute celui-ci à la galerie."},
	"trade_accept": {"tr": "Takası kabul et", "en": "Accept trade-in", "ar": "قبول المقايضة", "fr": "Accepter la reprise"},
	"trade_back": {"tr": "Pazarlığa dön", "en": "Back to negotiation", "ar": "العودة للتفاوض", "fr": "Retour à la négociation"},
	"trade_confirm": {"tr": "Ekrandaki araç ve nakit farkıyla takası tamamlayalım mı?", "en": "Complete the trade-in with the displayed vehicle and cash difference?", "ar": "إتمام المقايضة بالسيارة والفرق المعروضين؟", "fr": "Confirmer avec le véhicule et la différence affichés ?"},
	"trade_failed": {"tr": "Takas tamamlanamadı. Araç, bütçe veya alıcı değişmiş olabilir.", "en": "Trade-in unavailable. Vehicle, budget or buyer may have changed.", "ar": "تعذر إتمام المقايضة. ربما تغيّر الرصيد أو السيارة أو المشتري.", "fr": "Reprise impossible : véhicule, budget ou acheteur modifié."},
	"trade_done": {"tr": "Takas tamamlandı. Yeni aracın galerinde.", "en": "Trade-in complete. New vehicle added.", "ar": "تمت المقايضة وأضيفت السيارة.", "fr": "Reprise terminée. Véhicule ajouté."},

	"buyer_choose": {"tr": "Nasıl cevap verelim?", "en": "Choose your response", "ar": "اختر ردك", "fr": "Choisir une réponse"},
	"buyer_concern_clean": {"tr": "Araç kirli görünüyor. Temizlik masrafını da düşünmeliyim.", "en": "It looks dirty. I need to consider cleaning costs.", "ar": "السيارة متسخة. يجب احتساب تكلفة التنظيف.", "fr": "Elle est sale. Je dois prévoir le nettoyage."},
	"buyer_concern_body": {"tr": "Kaportadaki çizikler dikkatimi çekti. Fiyatta bunu hesaba katalım.", "en": "I noticed body scratches. Let’s consider them in the price.", "ar": "لاحظت خدوشاً. لنأخذها في الحسبان عند التسعير.", "fr": "J’ai remarqué des rayures. Tenons-en compte dans le prix."},
	"buyer_concern_engine": {"tr": "Sürüşte motorun durumu beni düşündürdü. Bakım masrafı çıkabilir.", "en": "The engine concerned me during the drive. It may need maintenance.", "ar": "أقلقتني حالة المحرك أثناء القيادة. قد يحتاج صيانة.", "fr": "L’état du moteur pendant l’essai m’inquiète."},
	"buyer_concern_mileage": {"tr": "Kilometreyi de hesaba katıyorum. Bu fiyatı neden istediğini anlatır mısın?", "en": "I’m considering the mileage. Could you explain your price?", "ar": "أضع المسافة المقطوعة في الحسبان. لماذا تطلب هذا السعر؟", "fr": "Je tiens compte du kilométrage. Pouvez-vous expliquer le prix ?"},
	"buyer_answer_honest": {"tr": "Durumunu açıkça anlatalım", "en": "Explain the condition honestly", "ar": "اشرح الحالة بصدق", "fr": "Expliquer honnêtement son état"},
	"buyer_answer_care": {"tr": "Temizliğini / iyi durumunu gösterelim", "en": "Show its cleanliness / good condition", "ar": "أظهر النظافة والحالة الجيدة", "fr": "Montrer sa propreté et son bon état"},
	"buyer_answer_discount": {"tr": "İstediğim fiyattan %2 indireyim", "en": "Lower my asking price by 2%", "ar": "اخفض سعري بنسبة 2٪", "fr": "Baisser mon prix de 2 %"},
	"buyer_reply_honest": {"tr": "Açık konuşman güzel. Teklifleri değerlendirmeye devam edelim.", "en": "I appreciate the honesty. Let’s continue negotiating.", "ar": "أقدّر صراحتك. لنواصل التفاوض.", "fr": "J’apprécie votre franchise. Continuons la négociation."},
	"buyer_reply_care": {"tr": "Gösterdiğin iyi durumu dikkate aldım. Teklifimi biraz artırdım.", "en": "I’ve considered its good condition and raised my offer slightly.", "ar": "أخذت حالتها الجيدة في الحسبان ورفعت عرضي قليلاً.", "fr": "J’ai tenu compte de son état et augmenté mon offre."},
	"buyer_reply_discount": {"tr": "İndirimini değerlendirebilirim. Yeni fiyatını gönder, konuşalım.", "en": "I’ll consider the discount. Send your new price.", "ar": "سأدرس التخفيض. أرسل السعر الجديد.", "fr": "Je peux envisager cette remise. Envoyez le nouveau prix."},
	"closeup_title": {"tr": "Aracı yakından incele", "en": "Inspect vehicle closely", "ar": "فحص السيارة عن قرب", "fr": "Examiner le véhicule"},
	"closeup_back": {"tr": "Araç detayına dön", "en": "Back to vehicle details", "ar": "العودة لتفاصيل السيارة", "fr": "Retour aux détails"},
	"closeup_rear": {"tr": "Arka", "en": "Rear", "ar": "الخلف", "fr": "Arrière"},
	"closeup_all": {"tr": "Orta", "en": "Middle", "ar": "الوسط", "fr": "Centre"},
	"closeup_front": {"tr": "Ön", "en": "Front", "ar": "الأمام", "fr": "Avant"},
	"closeup_current": {"tr": "Mevcut durumu göster", "en": "Show current condition", "ar": "عرض الحالة الحالية", "fr": "Voir l’état actuel"},
	"closeup_preview": {"tr": "Bakım sonrası önizleme", "en": "Preview after preparation", "ar": "معاينة بعد التجهيز", "fr": "Aperçu après préparation"},
	"closeup_preview_hint": {"tr": "Önizleme: yıkama ve kaporta onarımı sonrası görünüm. Araç değişmedi; ücret kesilmedi.", "en": "Preview of washing and body repair. No changes or charges applied.", "ar": "معاينة بعد الغسيل وإصلاح الهيكل. لا تغيير ولا رسوم.", "fr": "Aperçu après lavage et réparation. Aucun changement ni frais."},
	"closeup_hint": {"tr": "Yakınlaştırıp kir ve çizikleri incele. Mekanik durum için ekspertiz gerekir.", "en": "Zoom in to inspect dirt and scratches. Mechanical condition requires inspection.", "ar": "كبّر لرؤية الأوساخ والخدوش. الحالة الميكانيكية تتطلب فحصاً.", "fr": "Zoomez pour voir saleté et rayures. L’état mécanique nécessite une expertise."},

	"history_title": {"tr": "Satış geçmişi", "en": "Sales history", "ar": "سجل المبيعات", "fr": "Historique des ventes"},
	"history_dealer": {"tr": "Toptancı", "en": "Dealer", "ar": "تاجر", "fr": "Grossiste"},
	"history_info": {"tr": "Son 100 satış. Net kâr: satış + ek gelir − alış − bakım ve ekspertiz.", "en": "Last 100 sales. Net profit: sale + bonus − purchase − preparation costs.", "ar": "آخر 100 عملية بيع. الربح: البيع والمكافأة ناقص الشراء والتجهيز.", "fr": "100 dernières ventes. Bénéfice : vente + prime − achat − préparation."},
	"history_empty": {"tr": "Bu güncellemeden sonraki satışların burada görünecek.", "en": "Sales made after this update will appear here.", "ar": "ستظهر هنا المبيعات بعد هذا التحديث.", "fr": "Les ventes après cette mise à jour apparaîtront ici."},
	"history_date": {"tr": "Gün {0} · {1}", "en": "Day {0} · {1}", "ar": "اليوم {0} · {1}", "fr": "Jour {0} · {1}"},
	"history_bought": {"tr": "Alış bedeli", "en": "Purchase price", "ar": "سعر الشراء", "fr": "Prix d’achat"},
	"history_cost": {"tr": "Bakım ve ekspertiz", "en": "Preparation and inspection", "ar": "التجهيز والفحص", "fr": "Préparation et expertise"},
	"history_price": {"tr": "Satış bedeli", "en": "Sale price", "ar": "سعر البيع", "fr": "Prix de vente"},
	"history_bonus": {"tr": "Ek gelir", "en": "Bonus income", "ar": "دخل إضافي", "fr": "Prime"},
	"history_profit": {"tr": "Net kâr", "en": "Net profit", "ar": "صافي الربح", "fr": "Bénéfice net"},
	"drive_start": {"tr": "Test sürüşü · 10 dk", "en": "Test drive · 10 min", "ar": "قيادة تجريبية · 10 دقائق", "fr": "Essai routier · 10 min"},
	"drive_done": {"tr": "Test sürüşü tamamlandı", "en": "Test drive completed", "ar": "اكتملت القيادة التجريبية", "fr": "Essai terminé"},
	"drive_result": {"tr": "Sürüş puanı: {0}/100. Yeni teklif: {1} ({2}).", "en": "Drive score: {0}/100. New offer: {1} ({2}).", "ar": "نتيجة القيادة: {0}/100. العرض الجديد: {1} ({2}).", "fr": "Note : {0}/100. Nouvelle offre : {1} ({2})."},

"gallery_buyers": {"tr": "Alıcılar", "en": "Buyers", "ar": "المشترون", "fr": "Acheteurs"},
"gallery_show_scene": {"tr": "Galeri görünümü", "en": "Gallery view", "ar": "عرض المعرض", "fr": "Voir la galerie"},
"gallery_hide_scene": {"tr": "Görünümü kapat", "en": "Hide view", "ar": "إخفاء العرض", "fr": "Masquer la vue"},
"gallery_expenses": {"tr": "Galeri giderleri", "en": "Gallery expenses", "ar": "مصروفات المعرض", "fr": "Frais de galerie"},
"home_city_scene": {"tr": "Şehirden bir kesit", "en": "Around the city", "ar": "مشهد من المدينة", "fr": "Au fil de la ville"},
"management_title": {"tr": "Yönetim", "en": "Manage", "ar": "الإدارة", "fr": "Gestion"},
"management_gallery": {"tr": "Galeri yönetimi", "en": "Dealership", "ar": "إدارة المعرض", "fr": "Galerie"},
"management_money": {"tr": "Para ve yatırımlar", "en": "Money and investments", "ar": "الأموال والاستثمارات", "fr": "Argent et placements"},
"management_player": {"tr": "Hesap ve ayarlar", "en": "Account and settings", "ar": "الحساب والإعدادات", "fr": "Compte et réglages"},
"management_back": {"tr": "Yönetime dön", "en": "Back to management", "ar": "العودة للإدارة", "fr": "Retour à la gestion"},
"finance_back": {"tr": "Yatırım özetine dön", "en": "Investment overview", "ar": "ملخص الاستثمار", "fr": "Résumé des placements"},
"finance_hint_market": {"tr": "Döviz, altın ve endeks işlemleri.", "en": "Trade currency, gold and index.", "ar": "تداول العملات والذهب والمؤشر.", "fr": "Devises, or et indice."},
"finance_hint_savings": {"tr": "Vadeli hesabını aç ve takip et.", "en": "Open and track deposits.", "ar": "افتح وتابع الودائع.", "fr": "Ouvrir et suivre les dépôts."},
"finance_hint_holdings": {"tr": "Sahip olduğun yatırımları görüntüle.", "en": "View your holdings.", "ar": "عرض استثماراتك.", "fr": "Consulter vos placements."},
"street_disabled": {"tr": "Sokak olayları ayarlarda kapalı.", "en": "Street events are disabled in settings.", "ar": "أحداث الشارع معطلة في الإعدادات.", "fr": "Événements de rue désactivés dans les réglages."},
"nav_garage": {"tr": "Galerim", "en": "My dealership", "ar": "معرضي", "fr": "Ma galerie"},
"garage_title": {"tr": "Galerim", "en": "My dealership", "ar": "معرضي", "fr": "Ma galerie"},
"nav_workshop": {"tr": "Galeri yönetimi", "en": "Dealership management", "ar": "إدارة المعرض", "fr": "Gestion de la galerie"},
"home_summary": {"tr": "Bugünün özeti", "en": "Today’s overview", "ar": "ملخص اليوم", "fr": "Résumé du jour"},
"home_income": {"tr": "Bugünkü nakit girişleri", "en": "Today’s cash inflow", "ar": "التدفقات النقدية اليوم", "fr": "Entrées du jour"},
"home_expenses": {"tr": "Bugünkü giderler", "en": "Today’s expenses", "ar": "مصروفات اليوم", "fr": "Dépenses du jour"},
"home_cash_change": {"tr": "Günlük nakit farkı", "en": "Daily cash change", "ar": "تغير النقد اليومي", "fr": "Variation de trésorerie"},
"home_open_gallery": {"tr": "Galerime git", "en": "Open my dealership", "ar": "افتح معرضي", "fr": "Ouvrir ma galerie"},
"home_market_news": {"tr": "Piyasadan haberler", "en": "Market news", "ar": "أخبار السوق", "fr": "Actualités du marché"},
"gallery_manage": {"tr": "Dekor ve geliştirme", "en": "Decor and upgrades", "ar": "الديكور والترقيات", "fr": "Décoration et améliorations"},
"gallery_back": {"tr": "Galerime dön", "en": "Back to my dealership", "ar": "العودة إلى معرضي", "fr": "Retour à ma galerie"},
"release_title": {"tr": "Güncelleme bildirimi · v{0}", "en": "Update notice · v{0}", "ar": "إشعار التحديث · v{0}", "fr": "Mise à jour · v{0}"},
"release_intro": {"tr": "OtoPatron’da neler değişti?", "en": "What's new in OtoPatron?", "ar": "ما الجديد في اللعبة؟", "fr": "Quoi de neuf dans OtoPatron ?"},
"release_ack": {"tr": "Tamam, oyuna geç", "en": "Continue to the game", "ar": "متابعة إلى اللعبة", "fr": "Continuer vers le jeu"},
"release_notes": {"tr": "Son güncellemede neler değişti?", "en": "Latest update notes", "ar": "تفاصيل آخر تحديث", "fr": "Notes de la dernière mise à jour"},
"buyer_offer_margin": {"tr": "Müşteri teklifinde net araç kârı: {0}", "en": "Net vehicle profit at buyer offer: {0}", "ar": "صافي ربح السيارة بعرض العميل: {0}", "fr": "Bénéfice net avec l'offre du client : {0}"},
"loss_sale_title": {"tr": "Zararına satış", "en": "Sale at a loss", "ar": "بيع بخسارة", "fr": "Vente à perte"},
"loss_sale_body": {"tr": "Bu satışta alış ve hazırlık giderlerinden sonra {0} zarar edeceksin. Yine de satmak istiyor musun?", "en": "This sale loses {0} after purchase and preparation costs. Sell anyway?", "ar": "ستخسر {0} بعد تكلفة الشراء والتجهيز. هل تريد البيع؟", "fr": "Cette vente entraîne une perte de {0} après achat et préparation. Vendre quand même ?"},
"deal_margin": {"tr": "Bu fiyatta net araç kârı: {0}", "en": "Net vehicle profit at this price: {0}", "ar": "صافي ربح السيارة بهذا السعر: {0}", "fr": "Bénéfice net du véhicule à ce prix : {0}"},"deal_margin_label": {"tr": "Önerilen ilanda net araç kârı", "en": "Net vehicle profit at suggested price", "ar": "صافي ربح السيارة بالسعر المقترح", "fr": "Bénéfice net au prix conseillé"},"reputation_hint": {"tr": "İtibar, satıcı indirimi ve müşteri bütçesini artırır; aramalar sıklaşır. Başarılı satış +3, temiz araç +1. Cevapsız müşteri −1. Görüşürken bekleyen müşterilerin süresi durur.", "en": "Reputation improves seller discounts, buyer budgets and call frequency. Profitable sale +3, clean car +1, missed buyer −1. Other buyers wait while you negotiate.", "ar": "السمعة تحسن الخصومات وميزانية المشترين وتكرار الاتصالات. بيع مربح +3، سيارة نظيفة +1، اتصال فائت −1. يتوقف انتظار الآخرين أثناء التفاوض.", "fr": "La réputation améliore les remises, budgets et appels. Vente rentable +3, voiture propre +1, client manqué −1. Les autres clients attendent pendant la négociation."},
  "academy_intro": {
    "tr": "10 kademe, sırayla tek eğitim. Süre gerçek zamanla akar ve oyun kapalıyken devam eder. Oyun saatini ilerletmek eğitimi bitirmez.",
    "en": "10 sequential tiers, one course at a time. Real time continues offline. Advancing game time does not finish training.",
    "ar": "10 مراحل متتالية، تدريب واحد فقط. الوقت الحقيقي يستمر خارج اللعبة؛ تقديم وقت اللعبة لا ينهي التدريب.",
    "fr": "10 paliers successifs, une formation à la fois. Le temps réel continue hors ligne ; avancer le jeu ne termine pas la formation."
  },
  "skip_quarter": {
    "tr": "15 dakika hızlandır",
    "en": "Skip 15 minutes",
    "ar": "تسريع 15 دقيقة",
    "fr": "Accélérer de 15 minutes"
  },
  "finish_training": {
    "tr": "Eğitimi tamamla",
    "en": "Complete training",
    "ar": "إكمال التدريب",
    "fr": "Terminer la formation"
  },
  "skip_confirm": {
    "tr": "Bu hızlandırma için {0} harcanacak. Onaylıyor musun?",
    "en": "This acceleration costs {0}. Confirm?",
    "ar": "التسريع يكلف {0}. تأكيد؟",
    "fr": "Cette accélération coûte {0}. Confirmer ?"
  },
  "course_next": {
    "tr": "Eğitim kademesi",
    "en": "Course tier",
    "ar": "مرحلة التدريب",
    "fr": "Palier"
  },
  "course_duration": {
    "tr": "Gerçek süre",
    "en": "Real duration",
    "ar": "المدة الحقيقية",
    "fr": "Durée réelle"
  },
  "course_unlock": {
    "tr": "Gerekli oyuncu seviyesi",
    "en": "Required player level",
    "ar": "مستوى اللاعب المطلوب",
    "fr": "Niveau requis"
  },
  "course_effect": {
    "tr": "Beceri etkisi",
    "en": "Skill effect",
    "ar": "تأثير المهارة",
    "fr": "Effet"
  },
  "err_gems": {
    "tr": "Yeterli elmasın yok.",
    "en": "Not enough diamonds.",
    "ar": "الماس غير كافٍ.",
    "fr": "Diamants insuffisants."
  },
  "upgrade_locked": {
    "tr": "Seviye, bütçe veya devam eden eğitim koşulu uygun değil.",
    "en": "Level, budget or active course requirement is not met.",
    "ar": "شرط المستوى أو الرصيد أو التدريب النشط غير مستوفى.",
    "fr": "Condition de niveau, budget ou formation active non satisfaite."
  },
  "play_gift": {
    "tr": "30 dakika aktif oyun ödülü: +25 XP. Günlük en fazla iki kez.",
    "en": "30-minute active play reward: +25 XP. Maximum twice daily.",
    "ar": "مكافأة 30 دقيقة نشطة: +25 خبرة. مرتان يومياً كحد أقصى.",
    "fr": "30 minutes de jeu actif : +25 XP. Deux fois par jour maximum."
  },
  "visitor_missed": {
    "tr": "{0} görüşme beklerken ayrıldı. İtibar −1.",
    "en": "{0} left while waiting. Reputation −1.",
    "ar": "غادر {0} أثناء الانتظار. السمعة −1.",
    "fr": "{0} est parti après avoir attendu. Réputation −1."
  },
  "my_listings": {
    "tr": "İlanlarım",
    "en": "My listings",
    "ar": "إعلاناتي",
    "fr": "Mes annonces"
  },
  "listings_hint": {
    "tr": "İlanlarını yönet, fiyatını güncelle ve ilgilenen müşterilerle görüş.",
    "en": "Manage listings, update prices and meet buyers.",
    "ar": "إدارة الإعلانات والأسعار ومقابلة المشترين.",
    "fr": "Gérez les annonces, les prix et les acheteurs."
  },
  "listing_development": {
    "tr": "İlan vitrini",
    "en": "Listing showcase",
    "ar": "واجهة الإعلانات",
    "fr": "Vitrine"
  },
  "upgrade_listing": {
    "tr": "Vitrini geliştir",
    "en": "Upgrade showcase",
    "ar": "ترقية الواجهة",
    "fr": "Améliorer la vitrine"
  },
  "buyer_waiting": {
    "tr": "Müşteri bekliyor",
    "en": "Buyer waiting",
    "ar": "المشتري ينتظر",
    "fr": "Acheteur en attente"
  },
  "manage_listing": {
    "tr": "İlanı düzenle",
    "en": "Edit listing",
    "ar": "تعديل الإعلان",
    "fr": "Modifier"
  },
  "empty_listings": {
    "tr": "Aktif ilanın yok. İşletmendeki bir aracı hazırlayıp ilana koy.",
    "en": "No active listings. Prepare and list a car from your business.",
    "ar": "لا توجد إعلانات نشطة. جهز سيارة وانشر إعلانها.",
    "fr": "Aucune annonce active. Préparez une voiture et publiez-la."
  },
  "next_buyer": {
    "tr": "Sonraki müşteri kontrolü: {0} sn",
    "en": "Next buyer check: {0}s",
    "ar": "فحص العميل التالي: {0} ث",
    "fr": "Prochaine visite : {0}s"
  },
  "finance_title": {
    "tr": "Yatırım Merkezi",
    "en": "Investment Center",
    "ar": "مركز الاستثمار",
    "fr": "Centre d’investissement"
  },
  "finance_hint": {
    "tr": "Oyun içi simülasyon: fiyatlar her oyun günü değişir. Alış ve satışta %1 işlem farkı uygulanır. Kâr ve zarar mümkündür.",
    "en": "Game simulation: prices change each game day. Buying and selling each incur a 1% spread. Gains and losses are possible.",
    "ar": "محاكاة داخل اللعبة: الأسعار تتغير كل يوم لعب. فرق 1٪ للشراء والبيع. يمكن الربح أو الخسارة.",
    "fr": "Simulation : prix variables chaque jour de jeu. Écart de 1 % à l’achat et à la vente. Gains et pertes possibles."
  },
  "asset_usd": {
    "tr": "Dolar",
    "en": "Dollar",
    "ar": "دولار",
    "fr": "Dollar"
  },
  "asset_eur": {
    "tr": "Euro",
    "en": "Euro",
    "ar": "يورو",
    "fr": "Euro"
  },
  "asset_gold": {
    "tr": "Altın · gram",
    "en": "Gold · gram",
    "ar": "ذهب · غرام",
    "fr": "Or · gramme"
  },
  "asset_index": {
    "tr": "OtoBorsa · endeks payı",
    "en": "OtoMarket · index share",
    "ar": "سوق السيارات · حصة مؤشر",
    "fr": "OtoBourse · part indicielle"
  },
  "unit_price": {
    "tr": "Birim fiyat",
    "en": "Unit price",
    "ar": "سعر الوحدة",
    "fr": "Prix unitaire"
  },
  "holding": {
    "tr": "Portföy",
    "en": "Holdings",
    "ar": "المحفظة",
    "fr": "Portefeuille"
  },
  "unrealized": {
    "tr": "Tahmini net kâr / zarar",
    "en": "Estimated net gain / loss",
    "ar": "الربح / الخسارة المقدرة",
    "fr": "Gain / perte net estimé"
  },
  "buy_asset": {
    "tr": "Al",
    "en": "Buy",
    "ar": "شراء",
    "fr": "Acheter"
  },
  "sell_asset": {
    "tr": "Sat",
    "en": "Sell",
    "ar": "بيع",
    "fr": "Vendre"
  },
  "no_asset": {
    "tr": "Bu miktarda varlığın yok.",
    "en": "Insufficient holdings.",
    "ar": "الحصة غير كافية.",
    "fr": "Avoirs insuffisants."
  },
  "deposit_title": {
    "tr": "Vadeli birikim",
    "en": "Term savings",
    "ar": "ادخار لأجل",
    "fr": "Épargne à terme"
  },
  "deposit_hint": {
    "tr": "Günlük %0,4 oyun faizi. 7 günde %2,8; 14 günde %5,6; 30 günde %12. Vade dolunca anapara ve faiz otomatik hesaba geçer.",
    "en": "Game rate: 0.4% daily. 7 days: 2.8%; 14: 5.6%; 30: 12%. Principal and interest return automatically.",
    "ar": "فائدة اللعبة 0.4٪ يومياً. 7 أيام: 2.8٪، 14: 5.6٪، 30: 12٪. الدفع تلقائي.",
    "fr": "Taux du jeu : 0,4% par jour. 7 jours : 2,8%; 14 : 5,6%; 30 : 12%. Retour automatique."
  },
  "deposit_error": {
    "tr": "Bütçe yetersiz veya hesap sınırı dolu. En az ₺10.000 gerekir.",
    "en": "Insufficient funds or account limit reached. Minimum ₺10,000.",
    "ar": "الرصيد غير كافٍ أو حد الحسابات ممتلئ. الحد الأدنى ₺10,000.",
    "fr": "Fonds insuffisants ou limite atteinte. Minimum ₺10 000."
  },
  "days_term": {
    "tr": "{0} oyun günü",
    "en": "{0} game days",
    "ar": "{0} أيام لعب",
    "fr": "{0} jours de jeu"
  },
  "open_deposit": {
    "tr": "Birikim hesabı aç",
    "en": "Open savings account",
    "ar": "فتح حساب ادخار",
    "fr": "Ouvrir un compte"
  },
  "maturity": {
    "tr": "Vade bitimine",
    "en": "Until maturity",
    "ar": "حتى الاستحقاق",
    "fr": "Échéance dans"
  },
  "interest": {
    "tr": "Toplam faiz",
    "en": "Total interest",
    "ar": "إجمالي الفائدة",
    "fr": "Intérêt total"
  },
  "withdraw_deposit": {
    "tr": "Erken çek",
    "en": "Withdraw early",
    "ar": "سحب مبكر",
    "fr": "Retrait anticipé"
  },
  "withdraw_hint": {
    "tr": "Vade öncesi çekimde faiz alınmaz ve anaparadan %1 kesilir.",
    "en": "Early withdrawal earns no interest and deducts 1% of principal.",
    "ar": "السحب المبكر يلغي الفائدة ويخصم 1٪ من الأصل.",
    "fr": "Le retrait anticipé annule les intérêts et coûte 1 % du capital."
  },
  "deposit_paid": {
    "tr": "Vadeli birikim ödendi: {0}.",
    "en": "Term savings paid out: {0}.",
    "ar": "تم دفع الادخار: {0}.",
    "fr": "Épargne versée : {0}."
  },
  "daily_crate": {
    "tr": "Günlük hediye kasası",
    "en": "Daily gift crate",
    "ar": "صندوق الهدية اليومية",
    "fr": "Caisse cadeau quotidienne"
  },
  "daily_hint": {
    "tr": "Her gerçek takvim gününde bir kasa: para, 1 elmas ve XP. 7. ardışık gün 2 elmas.",
    "en": "One crate per real calendar day: cash, 1 diamond and XP. Day 7 of a streak grants 2 diamonds.",
    "ar": "صندوق كل يوم حقيقي: مال وماسة وخبرة. اليوم السابع المتتالي يمنح ماستين.",
    "fr": "Une caisse par jour réel : argent, 1 diamant et XP. Le 7e jour consécutif donne 2 diamants."
  },
  "daily_streak": {
    "tr": "Giriş serisi",
    "en": "Login streak",
    "ar": "سلسلة الدخول",
    "fr": "Série de connexions"
  },
  "claim_daily": {
    "tr": "Kasayı aç",
    "en": "Open crate",
    "ar": "فتح الصندوق",
    "fr": "Ouvrir la caisse"
  },
  "claimed_daily": {
    "tr": "Bugünkü kasa alındı",
    "en": "Today’s crate claimed",
    "ar": "تم استلام صندوق اليوم",
    "fr": "Caisse du jour reçue"
  },
  "gem_exchange": {
    "tr": "10 ♦ → ₺15.000",
    "en": "10 ♦ → ₺15,000",
    "ar": "10 ♦ → ₺15,000",
    "fr": "10 ♦ → ₺15 000"
  },
  "gem_repair": {
    "tr": "Elmasla tam hazırlık · {0} ♦",
    "en": "Full prep with diamonds · {0} ♦",
    "ar": "تجهيز كامل بالماس · {0} ♦",
    "fr": "Préparation complète · {0} ♦"
  },
  "listing_name": {
    "tr": "İlan başlığı",
    "en": "Listing title",
    "ar": "عنوان الإعلان",
    "fr": "Titre de l’annonce"
  },
  "listing_information": {
    "tr": "Araç bilgileri ve açıklama",
    "en": "Vehicle information and description",
    "ar": "معلومات السيارة والوصف",
    "fr": "Informations et description"
  },
  "choose_avatar": {
    "tr": "Profil resmini değiştir",
    "en": "Change profile picture",
    "ar": "تغيير صورة الملف",
    "fr": "Changer l’avatar"
  },
  "market_all": {
    "tr": "Tümü",
    "en": "All",
    "ar": "الكل",
    "fr": "Tout"
  },
  "market_owner": {
    "tr": "Sahibinden",
    "en": "Private sellers",
    "ar": "مالكون",
    "fr": "Particuliers"
  },
  "market_dealer": {
    "tr": "Galericiler",
    "en": "Dealers",
    "ar": "تجار",
    "fr": "Professionnels"
  },
  "refresh_market": {
    "tr": "2. el pazarını yenile · {0}",
    "en": "Refresh used market · {0}",
    "ar": "تحديث سوق المستعمل · {0}",
    "fr": "Actualiser l’occasion · {0}"
  },
  "bills_paid": {
    "tr": "Günlük faturalar: {0} ödendi. Kalan borç: {1}.",
    "en": "Daily bills: {0} paid. Outstanding: {1}.",
    "ar": "الفواتير اليومية: دفع {0}. المتبقي: {1}.",
    "fr": "Factures : {0} payées. Solde dû : {1}."
  },
  "bills_title": {
    "tr": "Günlük işletme faturaları",
    "en": "Daily business bills",
    "ar": "فواتير العمل اليومية",
    "fr": "Factures quotidiennes"
  },
  "bill_rent": {
    "tr": "Kira",
    "en": "Rent",
    "ar": "إيجار",
    "fr": "Loyer"
  },
  "bill_power": {
    "tr": "Elektrik ve su",
    "en": "Utilities",
    "ar": "كهرباء وماء",
    "fr": "Énergie et eau"
  },
  "bill_staff": {
    "tr": "Personel",
    "en": "Staff",
    "ar": "موظفون",
    "fr": "Personnel"
  },
  "bill_ads": {
    "tr": "İlan hizmeti",
    "en": "Listing service",
    "ar": "خدمة الإعلانات",
    "fr": "Service d’annonces"
  },
  "bill_total": {
    "tr": "Günlük toplam",
    "en": "Daily total",
    "ar": "الإجمالي اليومي",
    "fr": "Total quotidien"
  },
  "bills_hint": {
    "tr": "Her yeni oyun gününde otomatik tahsil edilir. Ödenemeyen tutar sonraki güne borç olarak taşınır; itibar 1 azalır. Zaman hızlandırma ücreti ayrıca alınır.",
    "en": "Automatically charged each new game day. Unpaid amounts carry over and cost 1 reputation. Time acceleration is charged separately.",
    "ar": "تُدفع تلقائياً كل يوم لعب جديد. يُرحّل غير المدفوع وتنقص السمعة 1. تسريع الوقت برسوم منفصلة.",
    "fr": "Débit automatique chaque jour de jeu. Les impayés sont reportés et coûtent 1 réputation. L’accélération du temps est facturée séparément."
  },
  "cust_details": {
    "tr": "{0} model, {1} km. Ekspertiz ve hazırlık bilgileri araç kartında; sorularınızı cevaplayabilirim.",
    "en": "Year {0}, {1} km. Inspection and prep details are on the vehicle card; I can answer your questions.",
    "ar": "موديل {0}، {1} كم. تفاصيل الفحص والتجهيز في بطاقة السيارة؛ يمكنني الإجابة عن أسئلتك.",
    "fr": "Année {0}, {1} km. Expertise et préparation figurent sur la fiche ; je peux répondre à vos questions."
  },
  "visit_deadline": {
    "tr": "Görüşmeye katılmak için {0} sn",
    "en": "Join conversation within {0}s",
    "ar": "تحدث خلال {0} ث",
    "fr": "Répondre sous {0}s"
  },
  "finish_sale": {
    "tr": "Satışı onayla",
    "en": "Confirm sale",
    "ar": "تأكيد البيع",
    "fr": "Confirmer la vente"
  },
  "shop_title": {
    "tr": "Mağaza",
    "en": "Shop",
    "ar": "المتجر",
    "fr": "Boutique"
  },
  "shop_intro": {
    "tr": "Oyun parası ve elmas arasında takas yap. Paketler gerçek para kullanmaz.",
    "en": "Exchange game cash and diamonds. Packs do not use real money.",
    "ar": "بدّل مال اللعبة والماس. لا تُستخدم أموال حقيقية.",
    "fr": "Échangez argent de jeu et diamants. Aucun argent réel."
  },
  "shop_cash": {
    "tr": "Para paketleri",
    "en": "Cash packs",
    "ar": "حزم المال",
    "fr": "Packs argent"
  },
  "shop_gems": {
    "tr": "Elmas paketleri",
    "en": "Diamond packs",
    "ar": "حزم الماس",
    "fr": "Packs diamants"
  },
  "pack_0": {
    "tr": "Başlangıç paketi",
    "en": "Starter pack",
    "ar": "حزمة البداية",
    "fr": "Pack initial"
  },
  "pack_1": {
    "tr": "Gelişim paketi",
    "en": "Growth pack",
    "ar": "حزمة التطوير",
    "fr": "Pack évolution"
  },
  "pack_2": {
    "tr": "Patron paketi",
    "en": "Boss pack",
    "ar": "حزمة المدير",
    "fr": "Pack patron"
  },
  "purchase_confirm": {
    "tr": "Satın almayı onayla",
    "en": "Confirm purchase",
    "ar": "تأكيد الشراء",
    "fr": "Confirmer l’achat"
  },
  "purchase_body": {
    "tr": "Bu paket için {0} harcanacak.",
    "en": "This pack costs {0}.",
    "ar": "هذه الحزمة تكلف {0}.",
    "fr": "Ce pack coûte {0}."
  },
  "purchase_done": {
    "tr": "Paket cüzdanına eklendi.",
    "en": "Pack added to your wallet.",
    "ar": "أضيفت الحزمة لمحفظتك.",
    "fr": "Pack ajouté au portefeuille."
  },
  "gem_earning": {
    "tr": "Elmaslar satış, eğitim tamamlama ve günlük giriş ödüllerinden kazanılır.",
    "en": "Earn diamonds from sales, completed training and daily rewards.",
    "ar": "اربح الماس من المبيعات والتدريب والهدايا اليومية.",
    "fr": "Gagnez des diamants avec ventes, formations et cadeaux."
  },
  "academy_title": {
    "tr": "Eğitim Merkezi",
    "en": "Training Centre",
    "ar": "مركز التدريب",
    "fr": "Centre de formation"
  },
  "academy_tagline": {
    "tr": "Becerilerini geliştirmeye başla",
    "en": "Build your business skills",
    "ar": "طور مهاراتك المهنية",
    "fr": "Développez vos compétences"
  },
  "academy_short": {
    "tr": "Bir beceri seç. Kademeleri sırayla tamamla. Her eğitim gerçek zamanla ilerler.",
    "en": "Choose a skill. Complete tiers in order. Training progresses in real time.",
    "ar": "اختر مهارة. أكمل المراحل بالترتيب. يتقدم التدريب بالوقت الحقيقي.",
    "fr": "Choisissez une compétence. Terminez les étapes dans l’ordre et en temps réel."
  },
  "course_in_progress": {
    "tr": "EĞİTİM DEVAM EDİYOR",
    "en": "TRAINING IN PROGRESS",
    "ar": "تدريب جارٍ",
    "fr": "FORMATION EN COURS"
  },
  "accelerate_training": {
    "tr": "Eğitimi hızlandır",
    "en": "Accelerate training",
    "ar": "تسريع التدريب",
    "fr": "Accélérer"
  },
  "course_mastered": {
    "tr": "Ustalık tamamlandı",
    "en": "Mastery completed",
    "ar": "اكتملت المهارة",
    "fr": "Maîtrise acquise"
  },
  "training_reward": {
    "tr": "Tamamlama ödülü: +2 elmas ve XP",
    "en": "Completion reward: +2 diamonds and XP",
    "ar": "مكافأة الإكمال: +2 ماس وخبرة",
    "fr": "Récompense : +2 diamants et XP"
  },
  "finish_current_first": {
    "tr": "Yeni eğitim için devam eden eğitimi tamamla.",
    "en": "Finish your current course before starting another.",
    "ar": "أكمل التدريب الحالي قبل التالي.",
    "fr": "Terminez la formation actuelle avant la suivante."
  },
  "portfolio_value": {
    "tr": "Portföy değeri",
    "en": "Portfolio value",
    "ar": "قيمة المحفظة",
    "fr": "Valeur du portefeuille"
  },
  "fin_market": {
    "tr": "Piyasalar",
    "en": "Markets",
    "ar": "الأسواق",
    "fr": "Marchés"
  },
  "fin_savings": {
    "tr": "Birikim",
    "en": "Savings",
    "ar": "الادخار",
    "fr": "Épargne"
  },
  "fin_holdings": {
    "tr": "Portföy",
    "en": "Holdings",
    "ar": "المحفظة",
    "fr": "Portefeuille"
  },
  "finance_short": {
    "tr": "Oyun içi fiyatlar · Her oyun günü değişir · Alış/satış farkı %1",
    "en": "Game prices · Change each game day · 1% buy/sell spread",
    "ar": "أسعار اللعبة · تتغير يومياً · فرق 1٪",
    "fr": "Prix de jeu · Variables chaque jour · Écart 1 %"
  },
  "ticker_usd": {
    "tr": "USD",
    "en": "USD",
    "ar": "USD",
    "fr": "USD"
  },
  "ticker_eur": {
    "tr": "EUR",
    "en": "EUR",
    "ar": "EUR",
    "fr": "EUR"
  },
  "ticker_gold": {
    "tr": "ALTIN",
    "en": "GOLD",
    "ar": "ذهب",
    "fr": "OR"
  },
  "ticker_index": {
    "tr": "OTO",
    "en": "OTO",
    "ar": "OTO",
    "fr": "OTO"
  },
  "day_change": {
    "tr": "günlük değişim",
    "en": "daily change",
    "ar": "التغير اليومي",
    "fr": "variation du jour"
  },
  "chart_period": {
    "tr": "Son 14 oyun günü · İlk gün sabit fiyat gösterilir",
    "en": "Last 14 game days · Flat price on day one",
    "ar": "آخر 14 يوم لعب · سعر ثابت في اليوم الأول",
    "fr": "14 derniers jours · Prix fixe le premier jour"
  },
  "trade_order": {
    "tr": "İşlem emri",
    "en": "Trade order",
    "ar": "أمر تداول",
    "fr": "Ordre"
  },
  "order_quote": {
    "tr": "Alış: {0} · Satış: {1}",
    "en": "Buy: {0} · Sell: {1}",
    "ar": "شراء: {0} · بيع: {1}",
    "fr": "Achat : {0} · Vente : {1}"
  },
  "quantity": {
    "tr": "Miktar",
    "en": "Quantity",
    "ar": "الكمية",
    "fr": "Quantité"
  },
  "cost_basis": {
    "tr": "Toplam maliyet",
    "en": "Cost basis",
    "ar": "التكلفة",
    "fr": "Coût total"
  },
  "business_account": {
    "tr": "İşletme hesabı",
    "en": "Business account",
    "ar": "حساب العمل",
    "fr": "Compte professionnel"
  },
  "property_owned": {
    "tr": "Mülk senin · Kira yok",
    "en": "Owned property · No rent",
    "ar": "ملكك · دون إيجار",
    "fr": "Propriétaire · Sans loyer"
  },
  "property_rented": {
    "tr": "Kiracı işletme",
    "en": "Rented premises",
    "ar": "مقر مستأجر",
    "fr": "Local loué"
  },
  "expense_details": {
    "tr": "Giderleri incele",
    "en": "View expenses",
    "ar": "عرض النفقات",
    "fr": "Voir les charges"
  },
  "buy_property": {
    "tr": "İşletmeyi satın al",
    "en": "Buy premises",
    "ar": "شراء المقر",
    "fr": "Acheter le local"
  },
  "property_hint": {
    "tr": "Bedel {0}. Satın aldıktan sonra kira kalkar; bakım gideri ve yıllık mülk vergisi devam eder. İşletme kapasitesi ayrıca geliştirilir.",
    "en": "Price {0}. Rent ends after purchase; maintenance and annual property tax remain. Capacity upgrades are separate.",
    "ar": "السعر {0}. ينتهي الإيجار وتبقى الصيانة وضريبة الملكية. ترقية السعة منفصلة.",
    "fr": "Prix {0}. Plus de loyer ; entretien et taxe annuelle subsistent. Capacité améliorée séparément."
  },
  "tax_hint": {
    "tr": "Giderler oyuncu seviyesiyle artar. Her 30 oyun gününde dönem kârının %12’si vergi; sahip olunan işletmeye her 365 günde %1,5 mülk vergisi uygulanır. Bunlar oyun kurallarıdır.",
    "en": "Expenses scale with level. Every 30 game days: 12% of period profits. Every 365 days: 1.5% owned property tax. These are game rules.",
    "ar": "النفقات تتزايد مع المستوى. كل 30 يوماً: 12٪ من الربح. كل 365 يوماً: 1.5٪ للملكية. قواعد اللعبة.",
    "fr": "Charges selon le niveau. Tous les 30 jours : 12 % du bénéfice. Tous les 365 jours : taxe immobilière de 1,5 %. Règles du jeu."
  },
  "day_report": {
    "tr": "Yeni gün · Hesap özeti",
    "en": "New day · Account report",
    "ar": "يوم جديد · كشف الحساب",
    "fr": "Nouveau jour · Relevé"
  },
  "yesterday_income": {
    "tr": "Dünkü para girişleri",
    "en": "Yesterday’s cash inflows",
    "ar": "تدفقات الأمس",
    "fr": "Entrées d’hier"
  },
  "yesterday_expenses": {
    "tr": "Dünkü para çıkışları",
    "en": "Yesterday’s cash outflows",
    "ar": "نفقات الأمس",
    "fr": "Sorties d’hier"
  },
  "bill_maintenance": {
    "tr": "Mülk bakımı",
    "en": "Property upkeep",
    "ar": "صيانة الملكية",
    "fr": "Entretien"
  },
  "bill_monthly_tax": {
    "tr": "Aylık kâr vergisi",
    "en": "Monthly profit tax",
    "ar": "ضريبة الربح الشهرية",
    "fr": "Impôt mensuel"
  },
  "bill_yearly_tax": {
    "tr": "Yıllık mülk vergisi",
    "en": "Annual property tax",
    "ar": "ضريبة الملكية السنوية",
    "fr": "Taxe immobilière annuelle"
  },
  "bill_loans": {
    "tr": "Kredi taksitleri",
    "en": "Loan installments",
    "ar": "أقساط القرض",
    "fr": "Mensualités"
  },
  "bankrupt_title": {
    "tr": "İşletmen iflas etti",
    "en": "Your business is bankrupt",
    "ar": "أفلست شركتك",
    "fr": "Votre entreprise a fait faillite"
  },
  "bankrupt_body": {
    "tr": "Nakit bakiye tükendi. Araçlar, borçlar ve gelişim sıfırlanarak ₺300.000 ile yeni işletme otomatik başlayacak. Profil fotoğrafı ve günlük ödül geçmişi korunur.",
    "en": "Cash ran out. Cars, debt and progression reset; a new business starts automatically with ₺300,000. Avatar and daily claim history remain.",
    "ar": "نفد النقد. تُعاد السيارات والديون والتقدم وتبدأ تلقائياً بـ ₺300,000. تبقى الصورة وسجل الهدايا.",
    "fr": "Trésorerie épuisée. Voitures, dettes et progression sont réinitialisées ; nouveau départ à ₺300 000. Avatar et historique cadeaux conservés."
  },
  "restart_now": {
    "tr": "Yeni başlangıç",
    "en": "Start again",
    "ar": "بداية جديدة",
    "fr": "Recommencer"
  },
  "restart_in": {
    "tr": "Yeni işletme {0} saniye sonra başlayacak",
    "en": "New business starts in {0} seconds",
    "ar": "بداية جديدة خلال {0} ثانية",
    "fr": "Nouvelle activité dans {0} secondes"
  },
  "daily_premium_hint": {
    "tr": "7 günlük hediye yolu: para, elmas ve XP. Yedinci ardışık gün bir otomobil hediyesi!",
    "en": "7-day reward path: cash, diamonds and XP. A car on the seventh consecutive day!",
    "ar": "مسار هدايا 7 أيام: مال وماس وخبرة. سيارة في اليوم السابع!",
    "fr": "Parcours de 7 jours : argent, diamants, XP. Une voiture le septième jour consécutif !"
  },
  "gift_day": {
    "tr": "Gün {0}",
    "en": "Day {0}",
    "ar": "اليوم {0}",
    "fr": "Jour {0}"
  },
  "seventh_gift": {
    "tr": "7. gün otomobil hediyesi",
    "en": "Day 7 car gift",
    "ar": "هدية سيارة اليوم 7",
    "fr": "Voiture offerte au jour 7"
  },
  "gift_cash_fallback": {
    "tr": "Garaj ve depo dolu: araç bedeli nakit olarak eklendi.",
    "en": "Garage and storage full: vehicle value credited as cash.",
    "ar": "المرآب ممتلئ: أضيفت قيمة السيارة نقداً.",
    "fr": "Garage et stockage pleins : valeur créditée en argent."
  },
  "showroom_sign": {
    "tr": "OTOPATRON · GALERİM",
    "en": "OTOPATRON · MY SHOWROOM",
    "ar": "OTOPATRON · معرضي",
    "fr": "OTOPATRON · MON SHOWROOM"
  },
  "market_suv": {
    "tr": "SUV",
    "en": "SUV",
    "ar": "SUV",
    "fr": "SUV"
  },
  "app_subtitle": {
    "tr": "GALERİ SİMÜLATÖR",
    "en": "DEALERSHIP SIMULATOR",
    "ar": "محاكي معرض السيارات",
    "fr": "SIMULATEUR DE CONCESSION"
  },
  "market_passenger": {
    "tr": "Otomobil",
    "en": "Passenger",
    "ar": "سيارات",
    "fr": "Voitures"
  },
  "market_sport": {
    "tr": "Spor",
    "en": "Sport",
    "ar": "رياضية",
    "fr": "Sport"
  },
  "market_pickup": {
    "tr": "Kamyonet / Van",
    "en": "Pickup / Van",
    "ar": "بيك أب / فان",
    "fr": "Pick-up / Van"
  },
  "market_truck": {
    "tr": "Kamyon / TIR",
    "en": "Truck",
    "ar": "شاحنات",
    "fr": "Camions"
  },
  "category_empty": {
    "tr": "Bu kategoride şu an ilan yok. Yeni araçlar seviye ilerledikçe pazara açılır.",
    "en": "No listings here yet. More models unlock as you level up.",
    "ar": "لا توجد إعلانات الآن. تفتح موديلات مع تقدم المستوى.",
    "fr": "Aucune annonce. De nouveaux modèles arrivent avec les niveaux."
  },
  "garage_stage": {
    "tr": "Garaj kapasitesi",
    "en": "Garage capacity",
    "ar": "سعة المرآب",
    "fr": "Capacité du garage"
  },
  "garage_develop": {
    "tr": "Garajı geliştir",
    "en": "Develop garage",
    "ar": "تطوير المرآب",
    "fr": "Agrandir le garage"
  },
  "time_confirm": {
    "tr": "Zamanı ilerlet",
    "en": "Advance time",
    "ar": "تقديم الوقت",
    "fr": "Avancer le temps"
  },
  "time_quote": {
    "tr": "{0} oyun dakikası ilerletilecek. İşlem bedeli: {1}. Gün değişirse kira, faturalar ve taksitler ayrıca kesilir.",
    "en": "Advance {0} game minutes for {1}. Crossing a day also charges rent, bills and instalments.",
    "ar": "تقديم {0} دقيقة مقابل {1}. عند بداية يوم جديد تخصم الفواتير والإيجار والأقساط.",
    "fr": "Avancer de {0} minutes pour {1}. Un nouveau jour entraîne aussi loyers, factures et échéances."
  },
  "listing_live": {
    "tr": "İlan yayında · Alıcı ilgisi takip ediliyor",
    "en": "Live listing · Monitoring interest",
    "ar": "إعلان منشور · متابعة الاهتمام",
    "fr": "Annonce active · Suivi des acheteurs"
  },
  "goal_wait": {
    "tr": "İlanlarını takip et ve gelen alıcılarla görüş.",
    "en": "Manage listings and meet interested buyers.",
    "ar": "تابع الإعلانات وقابل المشترين.",
    "fr": "Suivez vos annonces et recevez les acheteurs."
  },
  "deposit_total": {
    "tr": "Vade sonu toplam",
    "en": "Total at maturity",
    "ar": "المجموع عند الاستحقاق",
    "fr": "Total à échéance"
  },
  "portfolio_day_result": {
    "tr": "Yatırımların günlük değişimi",
    "en": "Daily portfolio change",
    "ar": "التغير اليومي للاستثمارات",
    "fr": "Variation quotidienne"
  },
  "portfolio_day_hint": {
    "tr": "Bu sonuç elde tutulan varlıkların değer değişimidir; satış yapmadan bakiyene geçmez.",
    "en": "This is the value change of held assets; cash is received only on selling.",
    "ar": "هذا تغير قيمة الأصول المحتفظ بها وليس نقداً حتى البيع.",
    "fr": "Variation des actifs détenus, versée seulement à la vente."
  },
  "shop_featured": {
    "tr": "Patron paketi",
    "en": "Patron pack",
    "ar": "حزمة المدير",
    "fr": "Pack Patron"
  },
  "exchange_rate": {
    "tr": "Tek seferlik oyun içi takas",
    "en": "One-time in-game exchange",
    "ar": "تبادل داخل اللعبة لمرة واحدة",
    "fr": "Échange unique dans le jeu"
  },
  "garage_quote": {
    "tr": "Kapasite {0} araca çıkacak ve garaj görünümü yenilenecek. Bedel: {1}.",
    "en": "Capacity increases to {0} vehicles and the garage appearance improves. Cost: {1}.",
    "ar": "تزداد السعة إلى {0} سيارات ويتحسن مظهر المرآب. التكلفة: {1}.",
    "fr": "Capacité portée à {0} véhicules et garage rénové. Coût : {1}."
  },
  "realized_result": {
    "tr": "Satış ve faiz net sonucu",
    "en": "Realized trades and interest",
    "ar": "نتيجة البيع والفائدة",
    "fr": "Ventes réalisées et intérêts"
  },
  "my_dealership": {
    "tr": "Galerim",
    "en": "My dealership",
    "ar": "معرضي",
    "fr": "Ma concession"
  },
  "dealership_tagline": {
    "tr": "Al. Hazırla. Pazarlık yap. Büyü.",
    "en": "Buy. Prepare. Negotiate. Grow.",
    "ar": "اشترِ. جهز. تفاوض. تطور.",
    "fr": "Achetez. Préparez. Négociez. Progressez."
  },
  "enter_dealership": {
    "tr": "GALERİME GİR",
    "en": "ENTER DEALERSHIP",
    "ar": "دخول المعرض",
    "fr": "ENTRER DANS LA CONCESSION"
  },
  "market_action": {
    "tr": "Bir sonraki fırsatını bul",
    "en": "Find your next deal",
    "ar": "اعثر على فرصتك القادمة",
    "fr": "Trouvez la prochaine affaire"
  },
  "academy_action": {
    "tr": "Becerilerini geliştirmeye başla",
    "en": "Build your skills",
    "ar": "طور مهاراتك",
    "fr": "Développez vos compétences"
  },
  "shop_action": {
    "tr": "Elmas ve nakit paketleri",
    "en": "Gems and cash packs",
    "ar": "حزم الماس والنقد",
    "fr": "Packs de diamants et de cash"
  },
  "rewards_action": {
    "tr": "Bugünün hediyesini aç",
    "en": "Open today’s gift",
    "ar": "افتح هدية اليوم",
    "fr": "Ouvrez le cadeau du jour"
  },
  "course_details": {
    "tr": "Eğitimi incele",
    "en": "View course",
    "ar": "عرض التدريب",
    "fr": "Voir la formation"
  },
  "shop_heading": {
    "tr": "Bir sonraki hamleni güçlendir",
    "en": "Power your next move",
    "ar": "عزز خطوتك القادمة",
    "fr": "Préparez votre prochain coup"
  },
  "nav_home": {
    "tr": "Ana Sayfa",
    "en": "Home",
    "ar": "الرئيسية",
    "fr": "Accueil"
  },
  "appearance": {
    "tr": "Görünüm",
    "en": "Appearance",
    "ar": "المظهر",
    "fr": "Apparence"
  },
  "theme_dark": {
    "tr": "Koyu",
    "en": "Dark",
    "ar": "داكن",
    "fr": "Sombre"
  },
  "theme_light": {
    "tr": "Açık",
    "en": "Light",
    "ar": "فاتح",
    "fr": "Clair"
  },
  "street_modes": {
    "tr": "Tefeci ve hırsız olayları",
    "en": "Loan shark and theft events",
    "ar": "أحداث المرابي والسرقة",
    "fr": "Événements usurier et vol"
  },
  "property_price": {
    "tr": "İşletme fiyatı",
    "en": "Property price",
    "ar": "سعر المنشأة",
    "fr": "Prix de l’établissement"
  },
  
  "garage_visual_stage_0": {
    "tr": "Başlangıç garajı",
    "en": "Starter garage",
    "ar": "مرآب البداية",
    "fr": "Garage de départ"
  },
  "garage_visual_stage_1": {
    "tr": "Gelişen garaj",
    "en": "Growing garage",
    "ar": "مرآب متطور",
    "fr": "Garage agrandi"
  },
  "garage_visual_stage_2": {
    "tr": "Profesyonel garaj",
    "en": "Professional garage",
    "ar": "مرآب محترف",
    "fr": "Garage professionnel"
  },
  "garage_visual_stage_3": {
    "tr": "Lüks garaj",
    "en": "Luxury garage",
    "ar": "مرآب فاخر",
    "fr": "Garage de luxe"
  },
  "reputation_line": {
    "tr": "İtibar · {0} / 100",
    "en": "Reputation · {0} / 100",
    "ar": "السمعة · {0} / 100",
    "fr": "Réputation · {0} / 100"
  },
  "security_title": {
    "tr": "Garaj güvenliği",
    "en": "Garage security",
    "ar": "أمان المرآب",
    "fr": "Sécurité du garage"
  },
  "security_hint": {
    "tr": "Kamera ve alarm geliştirmeleri hırsızlık olayında kayıp riskini azaltır. Üç güvenlik kademesi bulunur.",
    "en": "Cameras and alarms lower theft risk. Three security tiers.",
    "ar": "الكاميرات والإنذارات تقلل خطر السرقة. ثلاث مراحل.",
    "fr": "Caméras et alarmes réduisent le risque. Trois niveaux."
  },
  "security_upgrade": {
    "tr": "Güvenlik {0} · {1}",
    "en": "Security {0} · {1}",
    "ar": "الأمان {0} · {1}",
    "fr": "Sécurité {0} · {1}"
  },
  "street_title": {
    "tr": "Sokak olayları",
    "en": "Street encounters",
    "ar": "أحداث الشارع",
    "fr": "Rencontres de rue"
  },
  "street_quote": {
    "tr": "Tefeci {0} verir; 7 oyun günü sonra {1} otomatik tahsil edilir. Gecikirse kalan borca günlük %5 eklenir, itibar 5 düşer. Kabul etmek itibarını 2 düşürür.",
    "en": "Borrow {0}; {1} is due automatically in 7 game days. Overdue balance gains %5 daily and loses 5 reputation. Accepting costs 2 reputation.",
    "ar": "اقترض {0} وادفع {1} تلقائياً بعد 7 أيام. التأخير يزيد الدين %5 يومياً ويخفض السمعة 5. القبول يخفضها 2.",
    "fr": "Empruntez {0}; {1} sera prélevé dans 7 jours. Retard : %5 par jour et -5 réputation. Accepter : -2 réputation."
  },
  "street_offer": {
    "tr": "Tefecinin teklifini incele",
    "en": "Review loan shark offer",
    "ar": "عرض المرابي",
    "fr": "Voir l’offre de l’usurier"
  },
  "street_close": {
    "tr": "Tefeci borcunu kapat",
    "en": "Settle street debt",
    "ar": "سداد دين المرابي",
    "fr": "Régler la dette"
  },
  "street_repaid": {
    "tr": "Tefeci borcu kapatıldı.",
    "en": "Street debt settled.",
    "ar": "تم سداد الدين.",
    "fr": "Dette réglée."
  },
  "bill_street_payment": {
    "tr": "Tefeci tahsilatı",
    "en": "Street debt payment",
    "ar": "سداد دين المرابي",
    "fr": "Paiement de l’usurier"
  },
  "theft_alert": {"tr": "Galeride şüpheli hareket! Yönetim > Sokak olayları bölümünden müdahale et.", "en": "Suspicious activity! Go to Manage > Street events.", "ar": "حركة مشبوهة! انتقل إلى الإدارة ثم أحداث الشارع.", "fr": "Activité suspecte ! Gestion > Événements de rue."},
  "call_police": {
    "tr": "Polisi ara · ücretsiz",
    "en": "Call police · free",
    "ar": "اتصل بالشرطة · مجاناً",
    "fr": "Police · gratuit"
  },
  "call_guard": {
    "tr": "Güvenlik çağır · {0}",
    "en": "Call guard · {0}",
    "ar": "اطلب حارساً · {0}",
    "fr": "Appeler un gardien · {0}"
  },
  "theft_choices": {
    "tr": "Polis müdahalesi güvenlikle birlikte %65–95 başarılıdır. Başarısızlıkta nakdin %3’ü, en fazla ₺15.000 kaybedilir. Özel güvenlik ücretle kaybı önler.",
    "en": "Police success is %65–95 with security. Failure costs %3 cash, capped at ₺15,000. A paid guard prevents loss.",
    "ar": "نجاح الشرطة %65–95 مع الأمان. الفشل يكلف %3 بحد ₺15,000. الحارس المدفوع يمنع الخسارة.",
    "fr": "Succès police : %65–95 avec sécurité. Échec : %3 du cash, maximum ₺15 000. Un gardien payant évite la perte."
  },
  "theft_stopped": {
    "tr": "Şüpheli uzaklaştırıldı. İtibar +1.",
    "en": "Intruder stopped. Reputation +1.",
    "ar": "تم إبعاد المتسلل. السمعة +1.",
    "fr": "Intrus éloigné. Réputation +1."
  },
  "theft_loss": {
    "tr": "Hırsızlık kaybı: {0}.",
    "en": "Theft loss: {0}.",
    "ar": "خسارة السرقة: {0}.",
    "fr": "Perte du vol : {0}."
  },
  "market_search": {
    "tr": "Marka/model ara · Enter ile uygula",
    "en": "Search model · Enter to apply",
    "ar": "ابحث عن موديل · Enter",
    "fr": "Chercher un modèle · Entrée"
  },
  "sort_price": {
    "tr": "Fiyat",
    "en": "Price",
    "ar": "السعر",
    "fr": "Prix"
  },
  "sort_year": {
    "tr": "Yıl",
    "en": "Year",
    "ar": "السنة",
    "fr": "Année"
  },
  "sort_deal": {
    "tr": "Fırsatlar",
    "en": "Best deals",
    "ar": "فرص",
    "fr": "Bonnes affaires"
  },
  "deal_badge": {
    "tr": "Piyasanın altında",
    "en": "Below market",
    "ar": "أقل من السوق",
    "fr": "Sous le marché"
  },
  "phone_incoming": {
    "tr": "Gelen arama",
    "en": "Incoming call",
    "ar": "مكالمة واردة",
    "fr": "Appel entrant"
  },
  "phone_outgoing": {
    "tr": "Satıcı aranıyor",
    "en": "Calling seller",
    "ar": "الاتصال بالبائع",
    "fr": "Appel du vendeur"
  },
  "phone_wait": {
    "tr": "Telefon çalıyor…",
    "en": "Phone ringing…",
    "ar": "الهاتف يرن…",
    "fr": "Le téléphone sonne…"
  },
  "phone_connecting": {
    "tr": "Bağlanıyor",
    "en": "Connecting",
    "ar": "جارٍ الاتصال",
    "fr": "Connexion"
  },
  "phone_remaining": {
    "tr": "Cevaplamak için {0} sn",
    "en": "{0}s to answer",
    "ar": "{0} ثانية للرد",
    "fr": "{0}s pour répondre"
  },
  "phone_answer": {
    "tr": "Cevapla",
    "en": "Answer",
    "ar": "رد",
    "fr": "Répondre"
  },
  "phone_decline": {
    "tr": "Reddet",
    "en": "Decline",
    "ar": "رفض",
    "fr": "Refuser"
  },
  "phone_cancel": {
    "tr": "Aramayı iptal et",
    "en": "Cancel call",
    "ar": "إلغاء الاتصال",
    "fr": "Annuler l’appel"
  },
  "phone_other_buyer": {
    "tr": "Başka bir alıcı daha bekliyor. İşletmemde görüşebilirsin.",
    "en": "Another buyer is waiting in your dealership.",
    "ar": "مشتري آخر ينتظر في المعرض.",
    "fr": "Un autre acheteur attend dans la concession."
  },
  "phone_missed": {
    "tr": "Arama sona erdi; müşteri ayrıldı.",
    "en": "Call ended; buyer left.",
    "ar": "انتهى الاتصال وغادر العميل.",
    "fr": "Appel terminé, client parti."
  },
  "bank_limit": {
    "tr": "Kullanılabilir banka limiti",
    "en": "Available bank limit",
    "ar": "الحد البنكي المتاح",
    "fr": "Crédit bancaire disponible"
  },
  "bank_open": {
    "tr": "Banka / Kredi",
    "en": "Bank / Loans",
    "ar": "البنك / القروض",
    "fr": "Banque / Crédit"
  },
  "bank_access_hint": {
    "tr": "Kredi başlangıçtan itibaren açık. Seviye 1–5: ₺200.000; 6–10: ₺750.000; 11–15: ₺1.000.000; 16–19: ₺1.500.000; 20+: ₺2.000.000. Kredi eğitimi daha yüksek limit açabilir. Yeni kredi için önceki kredinin en az %40’ı ödenmiş olmalı.",
    "en": "Loans are available from the start. Level 1–5: ₺200k; 6–10: ₺750k; 11–15: ₺1m; 16–19: ₺1.5m; 20+: ₺2m. Credit training may raise limits. Repay at least 40% before another loan.",
    "ar": "القروض متاحة منذ البداية. مستويات 1–5: ₺200 ألف، 6–10: ₺750 ألف، 11–15: ₺1 مليون، 16–19: ₺1.5 مليون، 20+: ₺2 مليون. التدريب يرفع الحد. سدد 40٪ قبل قرض آخر.",
    "fr": "Crédit disponible dès le début. Niv. 1–5 : ₺200k; 6–10 : ₺750k; 11–15 : ₺1m; 16–19 : ₺1,5m; 20+ : ₺2m. Formation possible. Remboursez 40% avant un autre prêt."
  },
  "business_stock_tab": {
    "tr": "Araçlar",
    "en": "Vehicles",
    "ar": "المركبات",
    "fr": "Véhicules"
  },
  "business_visitors_tab": {
    "tr": "Müşteriler",
    "en": "Customers",
    "ar": "العملاء",
    "fr": "Clients"
  },
  "business_finance_tab": {
    "tr": "Hesap",
    "en": "Account",
    "ar": "الحساب",
    "fr": "Compte"
  },
  "business_daily_summary": {
    "tr": "Günlük gider · {0}  ›",
    "en": "Daily expenses · {0}  ›",
    "ar": "النفقات اليومية · {0}  ›",
    "fr": "Dépenses quotidiennes · {0}  ›"
  },
  "business_garage_action": {
    "tr": "Garaja git",
    "en": "Open garage",
    "ar": "فتح المرآب",
    "fr": "Ouvrir le garage"
  },
  "business_time_action": {
    "tr": "Zamanı ilerlet",
    "en": "Advance time",
    "ar": "تقديم الوقت",
    "fr": "Avancer le temps"
  }
}
