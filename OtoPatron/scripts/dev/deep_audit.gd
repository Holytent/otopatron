extends Node
var checks: Array = []
func check(condition: bool, name: String) -> void:
	checks.append({"name":name,"passed":condition})
	print("PASS " if condition else "FAIL ", name)
func reset() -> void:
	Game.new_game("Denetim","34")
	Game.settings["music"] = 0.0
	Game.settings["sfx"] = 0.0
	Game.settings["vibe"] = false
	Game.money = 20000000
	Game.news = {"cm":{},"dm":1.0}
func json_copy() -> Dictionary:
	return JSON.parse_string(JSON.stringify(Game.to_dict()))
func _ready() -> void:
	Game.set_process(false)
	Game.settings["music"] = 0.0
	Game.settings["sfx"] = 0.0
	_run.call_deferred()
func _run() -> void:
	reset()
	check(Game.city=="34" and Game.cars.is_empty() and Game.market.size()>=8,"Yeni oyun, şehir ve ilk pazar")
	for model in CarDB.MODELS:
		var vehicle := Game.gen_car(str(model["id"]))
		check(Game.car_value(vehicle)>=100000,"Araç değeri: "+str(model["id"]))
	var listing: Dictionary = Game.market[0]
	var price: int = int(listing["ask"])
	var before: int = Game.money
	check(Game.buy_listing(listing,price)=="ok" and Game.money==before-price,"Alış tutarı bakiyeden tam düşüyor")
	before = Game.money
	check(Game.buy_listing(listing,price)!="ok" and Game.money==before and Game.cars.size()==1,"Aynı araç ikinci kez satın alınamıyor")
	reset()
	listing = Game.market[0]
	before = Game.money
	check(Game.buy_listing(listing,-100)!="ok" and Game.money==before,"Negatif alış fiyatı reddediliyor")
	reset()
	listing = Game.market[0]
	Game.money = 1
	check(Game.buy_listing(listing,int(listing["ask"]))=="no_money" and Game.cars.is_empty(),"Yetersiz bakiye ile alış reddediliyor")
	reset()
	for i in Game.garage_cap: Game.cars.append(Game.gen_car("karya_pico"))
	listing = Game.market[0]
	before = Game.money
	check(Game.buy_listing(listing,int(listing["ask"]))=="no_space" and Game.money==before,"Dolu garajda alış para harcamıyor")
	reset()
	listing = Game.market[0]
	var car: Dictionary = listing["car"]
	Game.buy_listing(listing,int(listing["ask"]))
	before = Game.money
	var inspect_fee := Game.inspect_cost(car)
	check(Game.inspect_part(car,"engine") and Game.money==before-inspect_fee,"Ekspertiz ücreti ve parça bilgisi")
	before = Game.money
	check(Game.inspect_part(car,"engine") and Game.money==before,"Aynı ekspertiz ikinci ücret almıyor")
	car["parts"]["body"] = 25.0
	before = Game.money
	var repair_fee := Game.repair_cost(car,"body")
	check(Game.repair_part(car,"body") and Game.money==before-repair_fee and car["parts"]["body"]==95.0,"Kaporta onarım ücreti ve durumu")
	before = Game.money
	check(not Game.repair_part(car,"body") and Game.money==before,"Onarılmış parça tekrar ücret almıyor")
	car["clean"] = 20.0
	before = Game.money
	var wash_fee := Game.clean_cost(car)
	check(Game.clean_car(car) and Game.money==before-wash_fee and car["clean"]==100.0,"Yıkama ücreti ve temizlik")
	before = Game.money
	check(not Game.clean_car(car) and Game.money==before,"Temiz araç tekrar ücret almıyor")
	var cost: int = int(car["bought_price"])+int(car["invested"])
	var gain_xp: int = Game.xp
	var sale := Game.finalize_sale(car,cost+5000)
	check(not sale.is_empty() and Game.money==before+cost+5000 and sale["profit"]==5000,"Satış, masraflar ve net kazanç")
	before = Game.money
	gain_xp = Game.xp
	check(Game.finalize_sale(car,cost+5000).is_empty() and Game.money==before and Game.xp==gain_xp,"Aynı satış tekrar para veya XP vermiyor")
	reset()
	car = Game.gen_car("karya_pico")
	Game.cars.append(car)
	before = Game.money
	check(Game.finalize_sale(car,-100).is_empty() and Game.money==before and Game.cars.has(car),"Negatif satış fiyatı reddediliyor")
	reset()
	before = Game.money
	var minute: int = Game.minute
	check(not Game.wait_minutes(-60) and Game.money==before and Game.minute==minute,"Negatif bekleme para üretmiyor")
	reset()
	Game.add_xp(Game.cum_xp(6))
	check(Game.claim_cash(2)>0,"Seviye para ödülü alınıyor")
	Game.open_crate(3)
	var restored := json_copy()
	Game.from_dict(restored)
	before = Game.money
	check(Game.claim_cash(2)==-1 and Game.money==before,"Buluttan yüklenen para ödülü tekrar alınamıyor")
	check(Game.open_crate(3).is_empty(),"Buluttan yüklenen kasa tekrar açılamıyor")
	reset()
	var quote := Game.loan_quote(10000,36)
	check(Game.take_loan(10000,36)=="ok","Kredi alınıyor")
	var loan: Dictionary = Game.loans[0]
	check(Game.loan_total_left(loan)==int(quote["total"]),"Kredi toplamı teklif edilen tutara eşit")
	check(Game.take_loan(10000,3)=="block","Yüzde 40 ödenmeden ikinci kredi alınamıyor")
	before = Game.money
	Game._process_loans()
	check(Game.money==before-int(loan["daily"]) and int(loan["left"])==int(loan["days"])-1,"Günlük kredi taksiti")
	var settle: int = Game.settle_cost(loan)
	before = Game.money
	check(Game.settle_loan(loan) and Game.money==before-settle and Game.loans.is_empty(),"Erken kredi kapatma")
	before = Game.money
	check(not Game.settle_loan(loan) and Game.money==before,"Kapanmış kredi ikinci kez ödenmiyor")
	reset()
	Game.flags["street_loan"] = {"remaining":50000,"due":7}
	Game.money = 50000
	check(Game.repay_street_loan() and Game.money==0,"Tefeci borcu tam bakiye ile ödeniyor")
	reset()
	Game.money = 100000
	check(Game.shop_exchange("gems",0) and Game.money==0 and Game.diamonds==8,"Mağaza paketi tam bakiye ile alınıyor")
	reset()
	before = Game.money
	check(Game.open_deposit(10000,7) and Game.money==before-10000,"Vadeli hesap açılışı")
	var deposit: Dictionary = Game.deposits[0]
	Game.day = 7
	before = Game.money
	Game.process_finance_day()
	check(Game.money==before+10280 and Game.deposits.is_empty(),"Vade sonunda anapara ve faiz bir kez ödeniyor")
	before = Game.money
	check(not Game.withdraw_deposit(int(deposit["id"])) and Game.money==before,"Ödenmiş vadeli hesap tekrar çekilemiyor")
	reset()
	Game.open_deposit(10000,7)
	deposit = Game.deposits[0]
	before = Game.money
	check(Game.withdraw_deposit(int(deposit["id"])) and Game.money==before+9900,"Erken vadeli hesap kapatma kesintisi")
	reset()
	before = Game.money
	check(not Game.trade_asset("usd",-10,true) and Game.money==before,"Negatif yatırım miktarı reddediliyor")
	check(Game.trade_asset("usd",10,true),"Yatırım alışı")
	check(not Game.trade_asset("usd",11,false),"Olmayan yatırım satılamıyor")
	check(Game.trade_asset("usd",10,false) and Game.money<before,"Yatırımda aynı fiyat alış-satış komisyonları korunuyor")
	reset()
	check(not Game.claim_daily().is_empty() and Game.claim_daily().is_empty(),"Günlük hediye yalnızca bir kez")
	check(Game.start_training("inspect")=="ok" and Game.start_training("haggle")=="busy","Aynı anda yalnızca bir eğitim")
	Game.active_training["finish_at"] = Game.now_seconds()-1
	Game._check_training()
	before = Game.diamonds
	Game._check_training()
	check(Game.sk("inspect")==1 and Game.diamonds==before,"Eğitim bir kez tamamlanıp ödül veriyor")
	reset()
	Game.set_city("06")
	check(Game.city=="34","Başlangıç şehri değiştirilemiyor")
	Game.flags["audit_marker"] = "persisted"
	Game.money = 765432
	Game.save_game()
	Game.money = 1
	check(Game.load_game() and Game.money==765432 and Game.flags["audit_marker"]=="persisted","Gerçek dosyaya kayıt ve yükleme")
	Game.save_game()
	var broken := FileAccess.open(Game.save_path(),FileAccess.WRITE)
	broken.store_var({})
	broken.close()
	Game.money = 2
	check(Game.load_game() and Game.money==765432,"Geçersiz ana kayıt yerine sağlam yedek yükleniyor")

	Game.save_game()
	broken = FileAccess.open(Game.save_path(),FileAccess.WRITE)
	broken.store_var({})
	broken.close()
	check(Game.load_game() and Game.money==765432,"Yedekten iyileşen kayıt yeniden bozulsa da önceki yedek korunuyor")
	reset()
	var no_stats := json_copy()
	no_stats["stats"] = {}
	no_stats["finance_prices"] = {}
	Game.from_dict(no_stats)
	check(Game.stats.has("sold") and Game.finance_prices.has("gold"),"Eski kayıtta eksik istatistik ve yatırım alanları tamamlanıyor")
	Game.money = 0
	Game.cars.append(Game.gen_car("aldora_brix"))
	Game.check_bankruptcy()
	check(Game.bankrupt_state.is_empty(),"Satılabilir aracı olan oyuncu sıfır nakitte sıfırlanmıyor")
	var legacy := json_copy()
	legacy["bankrupt_state"] = {"restart_at":0}
	Game.from_dict(legacy)
	check(Game.bankrupt_state.is_empty(),"Varlığı olan eski kayıttaki iflas sayacı kaldırılıyor")
	var stale := Game.gen_car("aldora_brix")
	before = Game.money
	check(not Game.clean_car(stale) and not Game.repair_part(stale,"body") and Game.money==before,"Sahip olunmayan araca bakım yapılmıyor")
	for term in Game.LOAN_TERMS:
		reset()
		var term_quote := Game.loan_quote(10000,int(term))
		Game.take_loan(10000,int(term))
		Game.money = 20000000
		before = Game.money
		for installment in range(int(term_quote["days"])): Game._process_loans()
		check(Game.loans.is_empty() and before-Game.money==int(term_quote["total"]),"Kredi vadesi boyunca toplam ödeme teklifle eşit: "+str(term)+" ay")
	reset()
	Game.rng.seed = 1922
	var expected_cash: int = Game.money
	var expected_profit := 0
	var simulation_ok := true
	for transaction in range(200):
		if Game.market.is_empty(): Game.refresh_market()
		listing = Game.market[0]
		price = int(listing["ask"])
		expected_cash -= price
		if Game.buy_listing(listing,price)!="ok": simulation_ok=false;break
		var owned: Dictionary = Game.cars[-1]
		var sale_price: int = price + 10000 + transaction*500
		expected_cash += sale_price
		expected_profit += sale_price-price
		if Game.finalize_sale(owned,sale_price).is_empty(): simulation_ok=false;break
		var serialized := json_copy()
		if not Game.valid_snapshot(serialized): simulation_ok=false;break
		Game.from_dict(serialized)
		if Game.money!=expected_cash or Game.stats["profit"]!=expected_profit: simulation_ok=false;break
	check(simulation_ok and Game.stats["sold"]==200 and Game.stats["bought"]==200,"200 alış-satış ve JSON kayıt dönüşümünde bakiye/kâr/araç sayıları korunuyor")
	reset()
	var healthy := json_copy()
	check(Game.valid_snapshot(healthy),"Tam yeni kayıt doğrulamadan geçiyor")
	for field in ["money","cars","loans","stats","finance_prices","investments","deposits","bankrupt_state","active_training"]:
		var invalid := healthy.duplicate(true)
		match field:
			"money": invalid[field] = "bozuk"
			"cars": invalid[field] = [{}]
			"loans": invalid[field] = [{}]
			"stats": invalid[field] = {"sold":"bozuk"}
			"finance_prices": invalid[field] = {"gold":-1}
			"investments": invalid[field] = {"gold":[]}
			"deposits": invalid[field] = [{}]
			"bankrupt_state": invalid[field] = {"restart_at":"bozuk"}
			"active_training": invalid[field] = {"id":"unknown","level":1}
		check(not Game.valid_snapshot(invalid),"Bozuk kayıt reddediliyor: "+field)
	reset()
	listing = Game.market[0]
	before = Game.money
	var saved_fee := Game.inspect_cost(listing["car"])
	Game.inspect_part(listing["car"],"engine")
	Game.money = 1
	check(Game.load_game() and Game.money==before-saved_fee and bool(Game.market[0]["car"]["known"]["engine"]),"Ekspertiz ücreti ve sonucu hemen kalıcı kaydediliyor")
	var failures: int = checks.filter(func(item): return not item["passed"]).size()
	var report := FileAccess.open(ProjectSettings.globalize_path("res://../../build_tools/deep-audit-results.json"),FileAccess.WRITE)
	report.store_string(JSON.stringify({"checks":checks,"failures":failures},"  "))
	report.close()
	print("DEEP_AUDIT_COMPLETE ",checks.size()," checks; ",failures," failures")
	get_tree().quit(1 if failures>0 else 0)
