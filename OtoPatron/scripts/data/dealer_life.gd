class_name DealerLife
extends RefCounted
static func experience(role: String) -> int:
	var data: Variant = Game.flags.get("team_experience", {})
	if not data is Dictionary: return 0
	var amount: Variant = data.get(role, 0)
	return clampi(int(amount),0,400) if amount is int or amount is float else 0
static func rank(role: String) -> int:
	return 1 + int(experience(role)/100)
static func earn(role: String, amount: int) -> void:
	if not DealerExpansion.staff(role) or amount <= 0: return
	if not Game.flags.get("team_experience",null) is Dictionary: Game.flags["team_experience"]={}
	Game.flags["team_experience"][role]=mini(400,experience(role)+amount)
static func mechanic_discount() -> float:
	return minf(.32, .08*mini(3,DealerExpansion.count("mechanic")) + (.02*(rank("mechanic")-1) if DealerExpansion.staff("mechanic") else 0))
static func cleaner_factor() -> float:
	return .5-.05*(rank("cleaner")-1) if DealerExpansion.staff("cleaner") else 1.0
static func sales_factor() -> float:
	return 1.0+DealerExpansion.count("sales")*(.2+.03*(rank("sales")-1))
static func weather_hour() -> void:
	if Game.shop_closed(): return
	var stamp: int = Game.day*24+int(Game.minute/60)
	if int(Game.flags.get("weather_hour",-1))==stamp: return
	Game.flags["weather_hour"]=stamp
	if str(Game.weather.get("id","sunny")) not in ["rain","snow"]: return
	for car in Game.cars:
		if bool(car.get("outdoors",false)): car["clean"]=maxf(0,float(car.get("clean",100))-2.0)
static func week() -> int:
	return int((Game.day-1)/7)
static func _valid_lot(lot: Dictionary) -> bool:
	if not Game._valid_car(lot.get("car")): return false
	for key in ["price","step","round"]:
		if not Game._number(lot.get(key),0): return false
	if int(lot["price"])<=0 or int(lot["step"])<=0: return false
	if str(lot.get("status","")) not in ["open","won","lost","collected"]: return false
	if not lot.get("leader") is String or not lot.get("rivals") is Array or not lot.get("log") is Array: return false
	if lot["rivals"].size()!=2 or lot["log"].size()>12: return false
	for rival in lot["rivals"]:
		if not rival is Dictionary or not rival.get("name") is String or not Game._number(rival.get("limit"),0): return false
	for entry in lot["log"]:
		if not entry is Dictionary or not entry.get("name") is String or not Game._number(entry.get("price"),0): return false
	return true
static func auction() -> Dictionary:
	var stored: Variant = Game.flags.get("weekly_auction",{})
	if stored is Dictionary and int(stored.get("week",-1))==week() and _valid_lot(stored):
		return stored
	var pool: Array = CarDB.MODELS.filter(func(m): return int(m["min_level"])<=Game.level+2 and int(m["tier"])>=2)
	if pool.is_empty(): pool=CarDB.MODELS.filter(func(m): return int(m["min_level"])<=Game.level+2)
	var model: Dictionary=pool[Game.rng.randi()%pool.size()]
	var car: Dictionary=Game.gen_car(str(model["id"]),70,92)
	for part in Game.PARTS: car["known"][part]=true
	var value: int=Game.car_value(car)
	var step: int=maxi(1000,Game.r500(value*.025))
	var lot: Dictionary={"week":week(),"car":car,"price":maxi(step,Game.r500(value*.75)),"step":step,"round":0,"leader":"auction_house","status":"open","rivals":[{"name":"Cem","limit":Game.r500(value*Game.rng.randf_range(.89,1.02))},{"name":"Selin","limit":Game.r500(value*Game.rng.randf_range(.93,1.09))}],"log":[]}
	Game.flags["weekly_auction"]=lot
	Game.save_game()
	return lot
static func bid(amount: int) -> String:
	var lot:=auction()
	if str(lot["status"])!="open": return "closed"
	if Game.shop_closed(): return "night"
	if Game.cars.size()>=Game.garage_cap: return "no_space"
	if amount<int(lot["price"])+int(lot["step"]): return "low"
	if amount>Game.money: return "no_money"
	lot["price"]=amount
	lot["leader"]="player"
	lot["round"]=int(lot["round"])+1
	var log: Array=lot["log"]
	log.append({"name":"player","price":amount})
	# Rivals respond in turns and never exceed their fixed weekly budgets.
	for rival in lot["rivals"]:
		var reply: int=int(lot["price"])+int(lot["step"])
		if reply<=int(rival["limit"]):
			lot["price"]=reply
			lot["leader"]=str(rival["name"])
			log.append({"name":str(rival["name"]),"price":reply})
	lot["log"]=log.slice(maxi(0,log.size()-12))
	if str(lot["leader"])=="player": lot["status"]="won"
	Game.save_game()
	return "won" if str(lot["status"])=="won" else "counter"
static func withdraw() -> void:
	var lot:=auction()
	if str(lot["status"])!="open": return
	lot["status"]="lost"
	Game.save_game()
static func collect() -> String:
	var lot:=auction()
	if str(lot["status"])!="won": return "closed"
	if Game.shop_closed(): return "night"
	var price: int=int(lot["price"])
	if Game.money<price: return "no_money"
	if Game.cars.size()>=Game.garage_cap: return "no_space"
	var car: Dictionary=lot["car"]
	if not Game.car_by_uid(int(car["uid"])).is_empty(): return "closed"
	Game.money-=price
	car["bought_price"]=price
	car["invested"]=0
	car["listed"]=false
	Game.cars.append(car)
	Game.stats["bought"]=int(Game.stats["bought"])+1
	lot["status"]="collected"
	Game.save_game()
	Game.changed.emit()
	Fx.play("coin")
	return "ok"
