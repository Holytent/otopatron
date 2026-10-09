class_name Gameplay
extends RefCounted
# Optional save flags keep existing saves compatible; all transfers use Game.
static func ensure_offers() -> void:
	if int(Game.flags.get("gameplay_day", -1)) == Game.day: return
	Game.flags["gameplay_day"] = Game.day
	var pool: Array = CarDB.MODELS.filter(func(m): return int(m["min_level"]) <= Game.level)
	if pool.is_empty(): return
	var model: Dictionary = pool[Game.rng.randi()%pool.size()]
	var car: Dictionary = Game.gen_car(str(model["id"]),28,58)
	car["clean"] = 8.0
	car["rescue"] = true
	car["known"] = {"engine":true,"body":true,"tires":true,"interior":true}
	var price: int = maxi(1000, Game.r500(Game.car_value(car)*.72))
	Game.flags["rescue_offer"] = _listing(car,price,"Kurtarma")
	car = Game.gen_car(str(pool[Game.rng.randi()%pool.size()]["id"]),50,85)
	price = maxi(1000, Game.r500(Game.car_value(car)*.88))
	var rival: Dictionary = _listing(car,price,"Cem")
	rival["deadline"] = Game.day*1440+Game.minute+120
	Game.flags["rival_offer"] = rival
	Game.save_game()
static func _listing(car: Dictionary, price: int, seller: String) -> Dictionary:
	return {"id":Game.next_uid(),"car":car,"ask":price,"reserve":price,"source":"owner","mood":100.0,"day":Game.day,"seller":seller}
static func offer(kind: String) -> Dictionary:
	var value: Variant = Game.flags.get(kind+"_offer",{})
	if not value is Dictionary or not Game._valid_car(value.get("car")): return {}
	if int(value.get("ask",0)) <= 0: return {}
	return value
static func rival_alive() -> bool:
	var value := offer("rival")
	return not value.is_empty() and Game.day*1440+Game.minute < int(value.get("deadline",0))
static func acquire(kind: String) -> String:
	if kind not in ["rescue","rival"]: return "gone"
	var value := offer(kind)
	if value.is_empty() or (kind=="rival" and not rival_alive()): return "gone"
	if Game.cars.size() >= Game.garage_cap: return "no_space"
	if Game.money < int(value["ask"]): return "no_money"
	if not Game.car_by_uid(int(value["car"]["uid"])).is_empty(): return "gone"
	# Normal purchase saves the complete transfer; remove the optional offer first.
	Game.flags.erase(kind+"_offer")
	Game.market.append(value)
	var result: String = Game.buy_listing(value,int(value["ask"]))
	if result != "ok":
		Game.market.erase(value)
		Game.flags[kind+"_offer"] = value
	return result
static func rescued(car: Dictionary) -> bool:
	return bool(car.get("rescue",false)) and float(car.get("clean",0))>=99 and Game.PARTS.all(func(k): return float(car["parts"][k])>=95)
static func rival_trade() -> Dictionary:
	if int(Game.flags.get("rival_trade_day",-1))==Game.day: return {}
	for car in Game.cars:
		if not bool(car.get("listed",false)): continue
		Game._make_visit(car)
		var v: Dictionary = Game.visits.back()
		v["name"] = "Cem"
		v["accepted"] = true
		Game.flags["rival_trade_day"] = Game.day
		DealerExpansion.trade_quote(v)
		Game.save_game()
		return v
	return {}
