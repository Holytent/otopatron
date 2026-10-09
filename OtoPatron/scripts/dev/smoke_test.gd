extends Node
## Başsız duman testi: godot --headless --path . -- --smoke
## Çekirdek akış + yeni kurallar (81 il, ücretli bekleme, günlük kredi, %40 kuralı, sıralı eğitim, sabır barı).

var fails: int = 0


func check(cond: bool, msg: String) -> void:
	if cond:
		print("  OK   ", msg)
	else:
		fails += 1
		print("  FAIL ", msg)


func run(main: Node) -> void:
	await get_tree().process_frame
	print("== OtoPatron duman testi ==")
	check(CityDB.NAMES.size() == 81, "81 il tanımlı")
	var zone_total := 0
	for z in CityDB.ZONES.keys():
		zone_total += CityDB.ZONES[z].size()
	check(zone_total == 81, "81 ilin tamamı bir iklim bölgesinde (%d)" % zone_total)
	Game.new_game("Test", "14")
	check(Game.money == 300000, "başlangıç bakiyesi 300.000")
	check(CityDB.city_name(Game.city) == "Bolu", "şehir seçimi: " + CityDB.city_name(Game.city))
	check(CarDB.MODELS.size() >= 30, "araç sayısı: %d" % CarDB.MODELS.size())
	var cheap := true
	for l in Game.market:
		if int(l["ask"]) > 220000:
			cheap = false
	check(cheap and Game.market.size() >= 8, "seviye 1 pazarında ucuz araçlar (%d ilan)" % Game.market.size())
	for lang in ["tr", "en", "ar", "fr"]:
		Loc.set_lang(lang)
		await get_tree().process_frame
		for s in main.SCREENS.keys():
			if s == "splash" or s == "listing" or s == "car":
				continue
			main.show_screen(s, {})
			await get_tree().process_frame
		check(true, "ekranlar açıldı: " + lang)
	Loc.set_lang("tr")
	# --- satın alma
	var l: Dictionary = Game.market[0]
	var car: Dictionary = l["car"]
	main.show_screen("listing", {"id": int(l["id"])})
	await get_tree().process_frame
	check(Game.inspect_part(car, "engine"), "ekspertiz")
	var res: Dictionary = Game.negotiate(l, Game.r500(int(l["ask"]) * 0.5))
	check(res["kind"] == "angry" and float(l["mood"]) < 100.0, "çok düşük teklif satıcının sabrını düşürdü (%.0f)" % float(l["mood"]))
	var offer: int = int(l["ask"])
	var tries := 0
	while tries < 6 and float(l["mood"]) > 0.0:
		var rr: Dictionary = Game.negotiate(l, Game.r500(int(l["ask"]) * 0.97))
		if rr["kind"] == "accept":
			offer = int(rr["price"])
			break
		tries += 1
	var before := Game.money
	var r := Game.buy_listing(l, offer)
	check(r == "ok" and Game.money == before - offer, "satın alma (%s)" % str(r))
	for p in Game.PARTS:
		Game.repair_part(car, p)
	Game.clean_car(car)
	main.show_screen("car", {"uid": int(car["uid"])})
	await get_tree().process_frame
	Game.set_listed(car, true, Game.suggested_price(car))
	check(bool(car["listed"]), "ilan verildi")
	# --- ücretli bekleme
	var m0 := Game.money
	var cost := Game.wait_cost(60)
	check(Game.wait_minutes(60) and Game.money == m0 - cost and cost > 0, "1 saat bekleme ücretli (%d)" % cost)
	Game.money = 10
	check(not Game.wait_minutes(60), "bakiye yetmezse bekleme reddedilir")
	Game.money = 400000
	# --- müşteri
	var guard := 0
	while Game.visits.is_empty() and guard < 40:
		Game.end_day()
		guard += 1
	check(not Game.visits.is_empty(), "müşteri geldi (%d gün)" % guard)
	main.show_screen("garage", {})
	await get_tree().process_frame
	if not Game.visits.is_empty():
		var v: Dictionary = Game.visits[0]
		var c := Game.car_by_uid(int(v["car_uid"]))
		var bad := Game.customer_reply(v, int(v["max_pay"] * 1.5))
		check(float(v["mood"]) < 100.0 + 8.0 * Game.sk("sales"), "kötü teklif müşteri sabrını düşürdü (%.0f)" % float(v["mood"]))
		if bad["kind"] == "leave":
			check(true, "müşteri sabrı bitince gitti")
			Game.dismiss_visit(v)
			guard = 0
			while Game.visits.is_empty() and guard < 40:
				Game.end_day()
				guard += 1
			v = Game.visits[0]
			c = Game.car_by_uid(int(v["car_uid"]))
		var sale := Game.finalize_sale(c, int(v["offer"]))
		check(not sale.is_empty(), "satış tamamlandı, kâr=%d xp=%d" % [int(sale["profit"]), int(sale["xp"])])
		var xp1 := Game.xp
		var dup := Game.finalize_sale(c, 1000)
		check(dup.is_empty() and Game.xp == xp1, "aynı satıştan ikinci XP yok")
	# --- XP / ödül
	Game.add_xp(3000)
	check(Game.level >= 6, "seviye atlandı: %d" % Game.level)
	var pend := Game.pending_reward_levels()
	var m1 := Game.money
	check(Game.claim_cash(int(pend[0])) > 0 and Game.money > m1, "para ödülü alındı")
	check(Game.claim_cash(int(pend[0])) == -1, "aynı ödül tekrar alınamaz")
	var cr := Game.open_crate(int(pend[1]))
	check(not cr.is_empty() and Game.open_crate(int(pend[1])).is_empty(), "kasa bir kez açılır: " + str(cr.get("kind")))
	main.show_screen("rewards", {})
	await get_tree().process_frame
	# --- kredi kuralları
	check(Game.loan_limit() == 750000, "seviye 6-10 limiti 750.000 (%d)" % Game.loan_limit())
	check(Game.take_loan(800000, 12) == "cap", "limit üstü kredi reddedildi")
	check(Game.take_loan(600000, 36) == "ok", "36 aylık kredi alındı")
	check(Game.take_loan(50000, 6) == "block", "%40 ödenmeden ikinci kredi verilmez")
	var debt := Game.total_debt()
	var daily: int = int(Game.loans[0]["daily"])
	var m2 := Game.money
	Game.end_day()
	check(Game.money < m2 and Game.total_debt() < debt, "taksit günlük otomatik çekildi (%d)" % daily)
	var settle := Game.settle_cost(Game.loans[0])
	check(settle < Game.loan_total_left(Game.loans[0]), "erken kapatma indirimli")
	Game.money += 5000000
	for i in int(Game.loans[0]["days"] * 0.4) + 1:
		Game._on_new_day()
		Game.day += 1
	check(Game.loan_block_fraction() < 0.0, "%40 ödenince yeni kredi açıldı")
	# --- eğitim (sırayla + sayaç)
	Game.money += 1000000
	check(Game.start_training("inspect") == "ok", "eğitim başladı")
	check(Game.start_training("haggle") == "busy", "aynı anda ikinci eğitim yok")
	var left := Game.training_left()
	check(left > 0 and left <= 60, "eğitim süresi en çok 60 dk (%d)" % left)
	main.show_screen("training", {})
	await get_tree().process_frame
	Game.wait_minutes(15)
	check(Game.training_left() < left, "sayaç ilerledi")
	while not Game.active_training.is_empty():
		Game.wait_minutes(15)
	check(Game.sk("inspect") == 1, "eğitim tamamlandı")
	var lvl_cap_before := Game.loan_limit()
	Game.trainings["credit"] = 3
	check(Game.loan_train_cap() == 2000000, "Kredi Kullanımı 3. kademe = tüm limit")
	Game.trainings["credit"] = 0
	check(Game.loan_limit() == lvl_cap_before, "limit geri döndü")
	# --- şehir
	var chosen_city: String = Game.city
	Game.set_city("06" if chosen_city != "06" else "34")
	check(Game.city == chosen_city, "başlangıç şehri oyun içinde değiştirilemez")
	# --- kayıt
	var m_before := Game.money
	var lv := Game.level
	Game.save_game()
	Game.money = 1
	Game.level = 1
	check(Game.load_game() and Game.money == m_before and Game.level == lv, "kayıt / yükleme")
	for s in ["home", "market", "garage", "training", "loans", "settings", "profile"]:
		main.show_screen(s, {})
		await get_tree().process_frame
	Game.delete_save()
	print("== bitti: %d hata ==" % fails)
	get_tree().quit(1 if fails > 0 else 0)
