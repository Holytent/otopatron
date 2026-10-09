class_name OrderBoard
extends RefCounted
const TEXT: Dictionary = {
"tr":{"title":"Müşteri siparişleri","intro":"Bütçeye uygun araç bul, hazırla ve müşteriye teslim et.","rules":"Teslim koşulları: temizlik en az 80/100; tüm parçalar incelenmiş ve en az 70/100. Süre oyun günüdür.","budget":"Bütçe: %s","bonus":"Hizmet bedeli: %s","due":"Kalan süre: %d oyun günü","accept":"Siparişi kabul et","active":"Bir sipariş zaten aktif","done":"Teslim edildi","accepted":"Aktif sipariş","empty":"Uygun araç yok. Pazardan bu türde araç bul; ekspertiz, temizlik ve onarımını tamamla.","deliver":"Aracı teslim et","quote":"Satış: %s\nHizmet bedeli: %s\nToplam gelir: %s\nNet kazanç: %s","confirm":"Bu araç galerinden çıkarılacak. Teslimi onaylıyor musun?","cancel":"Siparişi bırak","find":"Araç pazarına git","success":"Sipariş tamamlandı. Net kazanç: %s"},
"en":{"title":"Customer orders","intro":"Find a car within budget, prepare it and deliver it.","rules":"Requirements: cleanliness 80/100; all parts inspected and at least 70/100. Deadlines use game days.","budget":"Budget: %s","bonus":"Service fee: %s","due":"Remaining: %d game days","accept":"Accept order","active":"An order is already active","done":"Delivered","accepted":"Active order","empty":"No eligible car. Find this vehicle type, inspect, clean and repair it.","deliver":"Deliver vehicle","quote":"Sale: %s\nService fee: %s\nTotal income: %s\nNet profit: %s","confirm":"This vehicle will leave your stock. Confirm delivery?","cancel":"Leave order","find":"Visit vehicle market","success":"Order complete. Net profit: %s"},
"fr":{"title":"Commandes clients","intro":"Trouvez un véhicule adapté au budget, préparez-le et livrez-le.","rules":"Conditions : propreté 80/100 ; pièces inspectées et au moins 70/100. Délais en jours de jeu.","budget":"Budget : %s","bonus":"Commission : %s","due":"Il reste %d jours de jeu","accept":"Accepter","active":"Une commande est déjà active","done":"Livré","accepted":"Commande active","empty":"Aucun véhicule adapté. Cherchez, inspectez, nettoyez et réparez un véhicule de ce type.","deliver":"Livrer","quote":"Vente : %s\nCommission : %s\nRevenu total : %s\nBénéfice net : %s","confirm":"Ce véhicule quittera votre stock. Confirmer ?","cancel":"Quitter la commande","find":"Marché automobile","success":"Commande terminée. Bénéfice : %s"},
"ar":{"title":"طلبات العملاء","intro":"ابحث عن سيارة ضمن الميزانية وجهزها وسلمها.","rules":"الشروط: النظافة 80/100 وفحص جميع الأجزاء وحالتها 70/100 على الأقل. المدة بأيام اللعبة.","budget":"الميزانية: %s","bonus":"رسوم الخدمة: %s","due":"المتبقي: %d أيام لعب","accept":"قبول الطلب","active":"يوجد طلب نشط","done":"تم التسليم","accepted":"طلب نشط","empty":"لا توجد سيارة مناسبة. ابحث عن النوع المطلوب وافحصه ونظفه وأصلحه.","deliver":"تسليم السيارة","quote":"البيع: %s\nرسوم الخدمة: %s\nإجمالي الدخل: %s\nصافي الربح: %s","confirm":"ستخرج السيارة من المخزون. تأكيد التسليم؟","cancel":"ترك الطلب","find":"سوق السيارات","success":"اكتمل الطلب. صافي الربح: %s"}}
static func t(key: String, args: Array = []) -> String:
	var value: String = TEXT.get(Loc.lang,TEXT["en"])[key]
	return value % args if not args.is_empty() else value
static func add_to(parent: Node, screen: ScreenBase) -> void:
	var card := UI.add_card(parent)
	card.add_child(UI.lbl(t("title"),20,UI.C_ACCENT,-1,true))
	card.add_child(UI.lbl(t("intro"),17,UI.C_MUTED))
	card.add_child(UI.btn(t("accepted") if CustomerOrders.active() else t("title"),"primary",func(): show(screen),48))
static func show(screen: ScreenBase) -> void:
	var dialog := UI.dialog_card(t("title"))
	var scroll := ScrollContainer.new()
	scroll.custom_minimum_size.y = clampf(UI.overlay.size.y-280,140,400)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	dialog.add_child(scroll)
	var content := UI.vbox(scroll,12)
	content.add_child(UI.lbl(t("rules"),17,UI.C_MUTED))
	var root := UI.show_dialog(dialog)
	for offer in CustomerOrders.board():
		var order: Dictionary = offer
		var card := UI.add_card(content)
		card.add_child(UI.lbl(str(order["name"])+" · "+Loc.t("cls_%s" % order["cls"]),20,UI.C_TEXT,-1,true))
		card.add_child(UI.lbl(t("budget",[Loc.money(int(order["budget"]))]),18))
		card.add_child(UI.lbl(t("bonus",[Loc.money(int(order["bonus"]))]),17,UI.C_GOOD))
		card.add_child(UI.lbl(t("due",[maxi(0,int(order["due"])-Game.day)]),17,UI.C_MUTED))
		if order["status"] == "done":
			card.add_child(UI.lbl(t("done"),18,UI.C_GOOD))
		elif order["status"] == "open":
			var accept := UI.btn(t("active") if CustomerOrders.active() else t("accept"),"primary",func():
				if CustomerOrders.accept(int(order["id"])):
					root.queue_free()
					show.call_deferred(screen),48)
			accept.disabled = CustomerOrders.active()
			card.add_child(accept)
		else:
			card.add_child(UI.lbl(t("accepted"),18,UI.C_ACCENT))
			var matches: Array = Game.cars.filter(func(car): return CustomerOrders.eligible(order,car))
			if matches.is_empty(): card.add_child(UI.lbl(t("empty"),17,UI.C_MUTED))
			for vehicle in matches:
				var car: Dictionary = vehicle
				card.add_child(UI.car_image(str(car["model"]),100,car))
				card.add_child(UI.lbl(CarDB.full_name(str(car["model"])),18))
				card.add_child(UI.btn(t("deliver"),"primary",func():
					root.queue_free()
					confirm.call_deferred(screen,int(order["id"]),int(car["uid"])),48))
			card.add_child(UI.btn(t("cancel"),"ghost",func():
				order["status"] = "open"
				Game.save_game()
				root.queue_free()
				show.call_deferred(screen),44))
	var actions := UI.vbox(dialog,8)
	actions.add_child(UI.btn(Loc.t("gallery_back"),"ghost",func(): root.queue_free(),48))
	actions.add_child(UI.btn(t("find"),"primary",func():
		root.queue_free()
		Game.go("market"),48))
static func confirm(screen: ScreenBase, id: int, uid: int) -> void:
	var order := CustomerOrders.find(id)
	var car: Dictionary = Game.car_by_uid(uid)
	if car.is_empty() or not CustomerOrders.eligible(order,car): return
	var sale := CustomerOrders.price(order,car)
	var bonus: int = int(order["bonus"])
	var dialog := UI.dialog_card(t("deliver"))
	dialog.add_child(UI.lbl(t("quote",[Loc.money(sale),Loc.money(bonus),Loc.money(sale+bonus),Loc.money(sale+bonus-int(car["bought_price"])-int(car["invested"]))]),18))
	dialog.add_child(UI.lbl(t("confirm"),17,UI.C_MUTED))
	var root := UI.show_dialog(dialog)
	dialog.add_child(UI.btn(Loc.t("ok"),"primary",func():
		var result := CustomerOrders.deliver(id,uid)
		if not result.is_empty():
			Game.toast(t("success",[Loc.money(int(result["profit"]))]),"good")
			if is_instance_valid(root): root.queue_free()
			if is_instance_valid(screen): screen.rebuild(),48))
	dialog.add_child(UI.btn(Loc.t("cancel"),"ghost",func(): root.queue_free(),48))
