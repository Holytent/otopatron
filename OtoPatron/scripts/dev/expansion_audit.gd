extends Node
var checks: int = 0
var failures: int = 0
func check(ok: bool, name: String) -> void:
	checks += 1
	if not ok: failures += 1
	print("PASS " if ok else "FAIL ",name)
func _ready() -> void:
	run.call_deferred()
func setup() -> void:
	Game.new_game("Kontrol","34")
	Game.set_process(false)
	Game.settings["music"] = 0
	Game.settings["sfx"] = 0
	Game.settings["vibe"] = false
	Game.money = 10000000
func run() -> void:
	setup()
	check(DealerExpansion.wages()==0, "Old saves have no new staff charges")
	var before: int = Game.money
	check(DealerExpansion.hire("cleaner")=="ok" and Game.money==before-3000, "Hire costs exact fee")
	check(DealerExpansion.hire("cleaner")!="ok" and Game.money==before-3000,"Duplicate hire cannot charge twice")
	check(DealerExpansion.wages()==650,"Cleaner wage shown")
	var car := Game.gen_car("karya_pico")
	car["clean"] = 20
	Game.cars.append(car)
	var fee: int = Game.clean_cost(car)
	before = Game.money
	DealerExpansion.cleaner_hour()
	check(car["clean"]==100 and Game.money==before-fee and car["invested"]==fee,"Hourly wash charges and records exact cost")
	car["clean"] = 20
	DealerExpansion.cleaner_hour()
	check(car["clean"]==20 and Game.money==before-fee,"Cleaner cannot repeat within same hour")
	Game.minute += 60
	DealerExpansion.cleaner_hour()
	check(car["clean"]==100,"Cleaner works next game hour")
	var base_repair: int = Game.repair_cost(car,"engine")
	check(DealerExpansion.hire("mechanic")=="ok" and Game.repair_cost(car,"engine")<=int(base_repair*.93),"Mechanic reduces repair costs")
	check(DealerExpansion.hire("sales")=="ok" and DealerExpansion.wages()==2950,"All staff wages total correctly")
	car["listed"] = true
	car["list_price"] = Game.suggested_price(car)
	var chance: float = Game.visit_chance(car)
	DealerExpansion.dismiss("sales")
	check(is_equal_approx(Game.visit_chance(car)*1.2,chance),"Sales staff raises inquiry chances by 20 percent")
	check(DealerExpansion.wages()==1850,"Dismissal stops future wage")
	var bill := BusinessLedger.charges(Game.level,Game.garage_cap,Game.listing_rank,Game.business_owned)
	check(bill["team"]==1850,"Ledger includes actual hired staff")
	before = Game.money
	Game.process_bills()
	check(Game.money==before-BusinessLedger.total(bill),"Daily billing includes staff once")
	var snapshot := Game.to_dict().duplicate(true)
	Game.from_dict(snapshot)
	check(DealerExpansion.staff("cleaner") and DealerExpansion.staff("mechanic"),"Staff survives load")
	Game.flags["unpaid_bills"] = 100
	check(DealerExpansion.hire("sales")=="debt","Hire blocked while bills unpaid")
	Game.flags["unpaid_bills"] = 0
	Game.money = 100
	check(DealerExpansion.hire("sales")=="no_money","Hire requires fee and wage reserve")
	setup()
	var trends: Array = []
	for d in 5:
		Game.day = d
		trends.append(DealerExpansion.trend())
	check(trends.size()==5 and trends[0]!=trends[1] and trends[3]=="sport","Daily demand rotates across five categories")
	Game.day = 0
	car = Game.gen_car("karya_pico")
	check(DealerExpansion.trend_factor(car)==1.25,"Popular category gets demand boost")
	var rare: Dictionary = {}
	for listing in Game.market:
		if listing.has("rare_until"): rare=listing
	check(not rare.is_empty() and DealerExpansion.rare_seconds(rare)<=1200,"Limited rare sport listing generated")
	var size: int = Game.market.size()
	DealerExpansion.ensure_rare()
	check(Game.market.size()==size,"Rare opportunity not farmed by refreshing")
	rare["rare_until"] = Game.now_seconds()-1
	before = Game.money
	check(Game.buy_listing(rare,int(rare["ask"]))=="gone" and Game.money==before,"Expired opportunity cannot be bought")
	check(Game.listing_by_id(int(rare["id"])).is_empty(),"Expired listing details unavailable")
	Game.day = 1
	DealerExpansion.ensure_rare()
	check(Game.market.size()==size,"Rare listings do not spawn every day")
	setup()
	car = Game.gen_car("karya_pico")
	car["bought_price"] = 100000
	car["invested"] = 3000
	car["list_price"] = 160000
	car["listed"] = true
	Game.cars.append(car)
	Game._make_visit(car)
	var visit: Dictionary = Game.visits.back()
	Game.accept_visit(visit)
	var quote := DealerExpansion.trade_quote(visit)
	check(not quote.is_empty() and DealerExpansion.trade_quote(visit)==quote,"Trade quote stable across repeated opens")
	check(Game.valid_snapshot(Game.to_dict()),"Save snapshot valid with trade car")
	visit["offer"] = 160000
	var credit: int = int(quote["credit"])
	before = Game.money
	var result := DealerExpansion.accept_trade(visit)
	check(not result.is_empty() and Game.money==before+160000-credit,"Trade settles exact cash difference")
	check(Game.cars.size()==1 and Game.cars[0]["uid"]==quote["car"]["uid"] and Game.cars[0]["bought_price"]==credit,"Trade exchanges inventory and records cost basis")
	check(Game.sales_history().back()["cash_received"]==160000-credit,"Trade history separates cash and credit")
	check(Game.sales_history().back()["profit"]==57000,"Trade sale profit based on total consideration")
	before=Game.money
	check(DealerExpansion.accept_trade(visit).is_empty() and Game.money==before,"Duplicate trade cannot pay or add vehicle twice")
	check(not DealerExpansion.saving_trade,"Atomic save guard released")
	snapshot=Game.to_dict().duplicate(true)
	Game.from_dict(snapshot)
	check(Game.cars.size()==1 and Game.cars[0]["bought_price"]==credit,"Completed trade survives reload")
	Game._make_visit(Game.cars[0])
	visit=Game.visits.back()
	Game.accept_visit(visit)
	quote=DealerExpansion.trade_quote(visit)
	visit["offer"]=1000
	Game.money=0
	check(DealerExpansion.accept_trade(visit).is_empty() and Game.cars.size()==1,"Unaffordable trade rejected without inventory mutation")
	Game.money=10000000
	visit["offer"]=160000
	while Game.cars.size()<Game.garage_cap: Game.cars.append(Game.gen_car("karya_pico"))
	var full_result := DealerExpansion.accept_trade(visit)
	check(not full_result.is_empty() and Game.cars.size()==Game.garage_cap,"Full gallery permits exchange without extra slot")
	Game._make_visit(Game.cars[0])
	visit=Game.visits.back()
	Game.accept_visit(visit)
	quote=DealerExpansion.trade_quote(visit)
	Game.minute=1439
	visit["offer"] = int(quote["credit"])+100
	Game.money=0
	var midnight := DealerExpansion.accept_trade(visit)
	check(not midnight.is_empty() and Game.money>=0 and not DealerExpansion.saving_trade,"Midnight trade cannot create negative cash after bills")
	Game.money=10000000
	Game._make_visit(Game.cars[0])
	visit=Game.visits.back()
	Game.accept_visit(visit)
	DealerExpansion.trade_quote(visit)
	visit["offer"]=160000
	var main := get_parent()
	for dims in [Vector2i(320,680),Vector2i(432,768),Vector2i(1280,800)]:
		get_window().size=dims
		for language in ["tr","en","ar","fr"]:
			Loc.set_lang(language)
			main.show_screen("staff",{})
			await get_tree().process_frame
			check(is_instance_valid(main._current),"Staff screen "+language+str(dims.x))
			main.show_screen("trade",{"visit":int(visit["id"])})
			await get_tree().process_frame
			check(not main._current.visit.is_empty(),"Trade screen "+language+str(dims.x))
	main.show_screen("home",{})
	await get_tree().process_frame
	check(Game._negotiation_depth==0,"Trade page releases customer pause")
	print("EXPANSION_AUDIT_COMPLETE ",checks," checks; ",failures," failures")
	get_tree().quit(1 if failures else 0)
