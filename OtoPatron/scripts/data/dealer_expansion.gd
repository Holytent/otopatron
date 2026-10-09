class_name DealerExpansion
extends RefCounted
const TEAM: Dictionary = {
	"cleaner": {"wage":650,"fee":3000},
	"mechanic": {"wage":1200,"fee":5500},
	"sales": {"wage":1100,"fee":5000}}
static var saving_trade: bool = false
static func staff_limit() -> int:
	var slots := 1
	for upgrade in Game.GARAGE_UPGRADES:
		if Game.garage_cap >= int(upgrade["cap"]): slots += 1
	return mini(5, slots)
static func count(id: String) -> int:
	var data: Variant = Game.flags.get("team", {})
	if not data is Dictionary: return 0
	var value: Variant = data.get(id, 0)
	if value is bool: return 1 if value else 0
	if not (value is int or value is float): return 0
	return clampi(int(value), 0, 5)
static func staff(id: String) -> bool:
	return count(id) > 0
static func wages() -> int:
	var total := 0
	for id in TEAM: total += count(id)*int(TEAM[id]["wage"])
	return total
static func hire(id: String) -> String:
	if not TEAM.has(id) or count(id) >= staff_limit(): return "gone"
	if int(Game.flags.get("unpaid_bills", 0)) > 0: return "debt"
	var fee: int = int(TEAM[id]["fee"])
	if Game.money < fee + int(TEAM[id]["wage"]): return "no_money"
	var previous := count(id)
	Game.money -= fee
	if not Game.flags.get("team", null) is Dictionary: Game.flags["team"] = {}
	Game.flags["team"][id] = previous + 1
	Game.save_game()
	Game.changed.emit()
	return "ok"
static func dismiss(id: String) -> void:
	if not TEAM.has(id) or not staff(id): return
	Game.flags["team"][id] = count(id) - 1
	if count(id)==0 and Game.flags.get("team_experience",null) is Dictionary: Game.flags["team_experience"].erase(id)
	Game.save_game()
	Game.changed.emit()
static func cleaner_hour() -> void:
	if not staff("cleaner") or Game.shop_closed(): return
	var stamp: int = Game.day*24 + int(Game.minute/60)
	if int(Game.flags.get("cleaner_hour", -1)) == stamp: return
	Game.flags["cleaner_hour"] = stamp
	var jobs := count("cleaner")*(1+int((DealerLife.rank("cleaner")-1)/2))
	for car in Game.cars:
		if float(car.get("clean",100)) >= 99: continue
		var cost: int = Game.clean_cost(car)
		if Game.money < cost: return
		Game.money -= cost
		car["clean"] = 100.0
		car["invested"] = int(car.get("invested",0))+cost
		Game.flags["cleaner_jobs"] = int(Game.flags.get("cleaner_jobs",0))+1
		DealerLife.earn("cleaner",10)
		jobs -= 1
		if jobs <= 0: return
static func trend() -> String:
	return ["passenger","suv","pickup","sport","truck"][posmod(Game.day,5)]
static func trend_factor(car: Dictionary) -> float:
	return 1.25 if CarDB.body_type(str(car["model"])) == trend() else .95
static func listing_alive(listing: Dictionary) -> bool:
	return not listing.has("rare_until") or Game.now_seconds() < float(listing["rare_until"])
static func rare_seconds(listing: Dictionary) -> int:
	return maxi(0, int(ceil(float(listing.get("rare_until", 0))-Game.now_seconds())))
static func ensure_rare() -> void:
	if Game.day % 3 != 0 or int(Game.flags.get("rare_day", -1)) == Game.day: return
	Game.flags["rare_day"] = Game.day
	var pool: Array = CarDB.MODELS.filter(func(m): return CarDB.body_type(str(m["id"])) == "sport" and int(m["min_level"]) <= Game.level+4)
	if pool.is_empty(): return
	var model: Dictionary = pool[Game.rng.randi()%pool.size()]
	var car: Dictionary = Game.gen_car(str(model["id"]),55,90)
	var ask: int = maxi(100000, Game.r500(Game.car_value(car)*.93))
	var listing := {"id":Game.next_uid(),"car":car,"ask":ask,"reserve":maxi(50000,Game.r500(ask*.94)),"source":"owner","mood":100.0,"day":Game.day,"seller":Game.SELLER_NAMES[Game.rng.randi()%Game.SELLER_NAMES.size()],"rare_until":Game.now_seconds()+1200.0}
	Game.market.append(listing)
	if Game.market.size()>24: Game.market.pop_front()
	Game.save_game()
static func trade_quote(visit: Dictionary) -> Dictionary:
	if not Game.visits.has(visit): return {}
	var own: Dictionary = Game.car_by_uid(int(visit.get("car_uid",0)))
	if own.is_empty(): return {}
	if visit.get("trade", null) is Dictionary: return visit["trade"]
	var pool: Array = CarDB.MODELS.filter(func(m): return int(m["min_level"]) <= Game.level and int(m["base"]) <= maxi(200000, Game.car_value(own)))
	if pool.is_empty(): return {}
	var model: Dictionary = pool[Game.rng.randi()%pool.size()]
	var incoming: Dictionary = Game.gen_car(str(model["id"]),35,80)
	var credit: int = maxi(1, int(Game.car_value(incoming)*.9))
	visit["trade"] = {"car":incoming,"credit":credit}
	Game.save_game()
	return visit["trade"]
static func accept_trade(visit: Dictionary) -> Dictionary:
	if not Game.visits.has(visit) or not bool(visit.get("accepted",false)): return {}
	var own: Dictionary = Game.car_by_uid(int(visit.get("car_uid",0)))
	if own.is_empty() or not Game.cars.has(own) or Game.cars.size() > Game.garage_cap: return {}
	var quote: Variant = visit.get("trade", null)
	if not quote is Dictionary or not Game._valid_car(quote.get("car")): return {}
	var incoming: Dictionary = quote["car"]
	if not Game.car_by_uid(int(incoming["uid"])).is_empty(): return {}
	var credit: int = int(quote.get("credit",0))
	var sale: int = int(visit["offer"])
	if credit <= 0 or sale <= 0 or Game.money+sale < credit: return {}
	# Suppress every nested save until sale and acquisition are both complete.
	saving_trade = true
	Game.money -= credit
	var result: Dictionary = Game.finalize_sale(own,sale,0,str(visit.get("name","")))
	if result.is_empty():
		Game.money += credit
		saving_trade = false
		return {}
	incoming["bought_price"] = credit
	incoming["invested"] = int(incoming.get("invested",0))
	incoming["listed"] = false
	Game.cars.append(incoming)
	Game.stats["bought"] = int(Game.stats["bought"])+1
	var records: Array = Game.sales_history()
	if not records.is_empty():
		records[-1]["trade_credit"] = credit
		records[-1]["cash_received"] = sale-credit
		Game.flags["sales_history"] = records
	saving_trade = false
	Game.save_game()
	Game.changed.emit()
	return {"car":incoming,"cash":sale-credit,"credit":credit,"sale":result}
