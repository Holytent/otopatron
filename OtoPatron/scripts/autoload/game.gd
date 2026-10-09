extends Node
## OtoPatron Ã§ekirdek oyun durumu ve kurallarÄ± (ekonomi, pazar, pazarlÄ±k, XP, kredi, eÄŸitim, kayÄ±t).
## ArayÃ¼zden baÄŸÄ±msÄ±zdÄ±r; ekranlar yalnÄ±zca bu sÄ±nÄ±fÄ±n fonksiyonlarÄ±nÄ± Ã§aÄŸÄ±rÄ±r.

signal theme_changed
signal live_tick
signal changed
signal toast_req(text: String, kind: String)
signal navigate(screen: String, params: Dictionary)
signal visit_arrived(visit: Dictionary)
signal market_deal_arrived(id: int)

const START_MONEY := 300000
const LOAN_CAP := 2000000
const DAYS_PER_MONTH := 30
const EARLY_SETTLE_INTEREST := 0.25
const MIN_PAID_FOR_NEXT_LOAN := 0.4
const MAX_LEVEL := 50
const GAME_YEAR := 2026
const STORAGE_CAP := 8
const SAVE_PATH := "user://save.dat"
const SAVE_BAK := "user://save.bak"
const SETTINGS_PATH := "user://settings.cfg"
const SAVE_VERSION := 7
const VISITOR_WAIT_SECONDS := 90.0
const PARTS: Array = ["engine", "body", "tires", "interior"]
const PART_W: Dictionary = {"engine": 0.4, "body": 0.25, "tires": 0.15, "interior": 0.2}
const PART_K: Dictionary = {"engine": 0.0015, "body": 0.0008, "tires": 0.0005, "interior": 0.0005}
const GARAGE_UPGRADES: Array = [
	{"cap": 8, "cost": 180000, "level": 4},
	{"cap": 12, "cost": 450000, "level": 7},
	{"cap": 16, "cost": 1000000, "level": 10},
	{"cap": 20, "cost": 2000000, "level": 14},
	{"cap": 24, "cost": 4000000, "level": 20},
]
## Kredi vadeleri (ay) ve toplam faiz oranÄ±. 1 ay = 30 oyun gÃ¼nÃ¼; taksitler gÃ¼nlÃ¼k otomatik Ã§ekilir.
const LOAN_TERMS: Dictionary = {3: 0.15, 6: 0.28, 12: 0.50, 24: 0.85, 36: 1.20}
const CUSTOMER_TYPES: Array = [
	{"id": "student", "mult": 1.00, "min_level": 1, "q": 0.0, "max_value": 120000},
	{"id": "trader", "mult": 1.07, "min_level": 1, "q": 0.2, "max_value": 700000},
	{"id": "family", "mult": 1.13, "min_level": 1, "q": 0.6, "max_value": 800000},
	{"id": "corp", "mult": 1.15, "min_level": 4, "q": 1.0, "min_value": 150000},
	{"id": "vip", "mult": 1.17, "min_level": 7, "q": 1.6, "min_value": 400000},
]
const NEWS: Array = [
	{"id": "calm", "cm": {}, "dm": 1.0},
	{"id": "fuel", "cm": {"eco": 1.05, "suv": 0.94, "lux": 0.96}, "dm": 0.95},
	{"id": "ev", "cm": {"ev": 1.08}, "dm": 1.0},
	{"id": "holiday", "cm": {}, "dm": 1.2},
	{"id": "rates_down", "cm": {}, "dm": 1.12},
	{"id": "rates_up", "cm": {}, "dm": 0.88},
	{"id": "auction", "cm": {"eco": 0.95, "mid": 0.95}, "dm": 1.0},
	{"id": "lux_tax", "cm": {"lux": 0.92, "sport": 0.94}, "dm": 0.97},
	{"id": "truck", "cm": {"com": 1.07}, "dm": 1.0},
]
const WEATHER: Array = [
	{"id": "fog", "dm": .92},
	{"id": "sunny", "dm": 1.1},
	{"id": "cloudy", "dm": 1.0},
	{"id": "rain", "dm": 0.85},
	{"id": "snow", "dm": 0.75},
]
const SELLER_NAMES: Array = ["Hakan", "Murat", "Selin", "Ayşe", "Kemal", "Deniz", "Burak", "Elif", "Cem", "Gül", "Onur", "Zeynep", "Tolga", "Aylin", "Barış", "Seda"]

var settings: Dictionary = {"lang": "tr", "music": 0.6, "sfx": 0.8, "vibe": true, "dark_mode": false, "street_events": true, "seen_release": ""}
var rng := RandomNumberGenerator.new()

# ---- Oyun durumu (kayda yazÄ±lÄ±r) ----
var started: bool = false
var player_name: String = "Patron"
var city: String = "34"
var money: int = 0
var day: int = 0
var minute: int = 480
var xp: int = 0
var level: int = 1
var rep: int = 10
var garage_cap: int = 5
var cars: Array = []
var storage: Array = []
var market: Array = []
var visits: Array = []
var loans: Array = []
var trainings: Dictionary = {}
var active_training: Dictionary = {}
var claimed: Dictionary = {}
var crates_opened: Dictionary = {}
var sold_ids: Dictionary = {}
var stats: Dictionary = {"sold": 0, "bought": 0, "profit": 0, "best": 0, "crates": 0}
var weather: Dictionary = {}
var news: Dictionary = {}
var uid_counter: int = 1
var flags: Dictionary = {}
var business_owned: bool = false
var business_price_paid: int = 0
var _ledger_balance: int = 300000
var daily_income: int = 0
var daily_expenses: int = 0
var monthly_profit: int = 0
var day_opening_balance: int = 300000
var daily_summary: Dictionary = {}
var bankrupt_state: Dictionary = {}
var diamonds: int = 3
var avatar_id: int = 0
var daily_date: String = ""
var daily_streak: int = 0
var listing_rank: int = 0
var investments: Dictionary = {}
var finance_prices: Dictionary = {"usd": 40.0, "eur": 44.0, "gold": 4200.0, "index": 100.0}
var finance_history: Dictionary = {}
var deposits: Array = []
var bills: Array = []
var menu_paused: bool = false
var _sleeping: bool = false
var _world_seconds: float = 0.0
var _background_at: float = 0.0
var _bridge_seconds: float = 0.0
var _tick_seconds: float = 0.0
var _autosave_seconds: float = 0.0
var _next_visit_at: float = 0.0
var _negotiation_depth: int = 0
var _customer_tick_at: float = 0.0
var _active_seconds: float = 0.0
var play_reward_day: String = ""
var play_reward_claims: int = 0



func _ready() -> void:
	rng.randomize()
	load_settings()
	Loc.set_lang.call_deferred(str(settings.get("lang", "tr")))


# =====================================================================
# Ayarlar
# =====================================================================
func load_settings() -> void:
	if "--layout-audit" in OS.get_cmdline_user_args(): return
	var cf := ConfigFile.new()
	if cf.load(SETTINGS_PATH) == OK:
		for k in settings.keys():
			settings[k] = cf.get_value("settings", k, settings[k])


func save_settings() -> void:
	if "--layout-audit" in OS.get_cmdline_user_args(): return
	var cf := ConfigFile.new()
	for k in settings.keys():
		cf.set_value("settings", k, settings[k])
	cf.save(SETTINGS_PATH)


# =====================================================================
# YardÄ±mcÄ±lar
# =====================================================================
func next_uid() -> int:
	uid_counter += 1
	return uid_counter


func r500(x: float) -> int:
	return int(round(x / 500.0)) * 500


func toast(text: String, kind: String = "info") -> void:
	toast_req.emit(text, kind)


func go(screen: String, params: Dictionary = {}) -> void:
	navigate.emit(screen, params)


func sk(id: String) -> int:
	return int(trainings.get(id, 0))


func learning_level() -> int:
	var others := 0
	for k in trainings.keys():
		if k != "learn":
			others += int(trainings[k])
	return mini(10, sk("learn") + others / 10)


func time_str() -> String:
	return "%02d:%02d" % [minute / 60, minute % 60]


func date_dict(d: int = -1) -> Dictionary:
	if d < 0:
		d = day
	var base := Time.get_unix_time_from_datetime_dict({"year": GAME_YEAR, "month": 3, "day": 2, "hour": 0, "minute": 0, "second": 0})
	return Time.get_datetime_dict_from_unix_time(base + d * 86400)


func date_str(d: int = -1) -> String:
	var dd := date_dict(d)
	return "%d %s %d" % [dd["day"], Loc.t("month_%d" % dd["month"]), dd["year"]]


func weekday_name(d: int = -1) -> String:
	return Loc.t("wd_%d" % date_dict(d)["weekday"])


# =====================================================================
# Seviye ve XP
# =====================================================================
func need_for(l: int) -> int:
	return int(100 + 70 * (l - 1) + 25 * (l - 1) * (l - 1))


func cum_xp(l: int) -> int:
	var s := 0
	for i in range(1, l):
		s += need_for(i)
	return s


func level_for(total: int) -> int:
	var l := 1
	while l < MAX_LEVEL and total >= cum_xp(l + 1):
		l += 1
	return l


func xp_in_level() -> int:
	return xp - cum_xp(level)


func xp_need() -> int:
	return need_for(level) if level < MAX_LEVEL else 1


func add_xp(amount: int) -> int:
	if amount <= 0:
		return 0
	xp += amount
	var old := level
	level = level_for(xp)
	if level > old:
		Fx.play("levelup")
		Fx.vibrate(60)
		toast(Loc.t("toast_levelup", [level]), "good")
	return level - old


func pending_reward_levels() -> Array:
	var out: Array = []
	for l in range(2, level + 1):
		if not claimed.has(l):
			out.append(l)
	return out


func cash_reward(l: int) -> int:
	return 6000 * l + 600 * l * l


func level_unlock_key(l: int) -> String:
	var keys := {2: "unlock_2", 4: "unlock_4", 6: "unlock_6", 7: "unlock_7", 10: "unlock_10", 11: "unlock_11", 12: "unlock_12", 16: "unlock_16", 20: "unlock_20"}
	return keys.get(l, "")


func claim_cash(l: int) -> int:
	if l < 2 or l > level or claimed.has(l):
		return -1
	claimed[l] = "cash"
	var amt := cash_reward(l)
	money += amt
	Fx.play("coin")
	save_game()
	changed.emit()
	return amt


func crate_odds() -> Array:
	return [{"kind": "money", "p": 50}, {"kind": "car", "p": 15}, {"kind": "xp", "p": 35}]


func open_crate(l: int) -> Dictionary:
	if l < 2 or l > level or claimed.has(l):
		return {}
	claimed[l] = "crate"
	crates_opened[l] = true
	stats["crates"] = int(stats["crates"]) + 1
	var roll := rng.randf() * 100.0
	var res: Dictionary = {}
	if roll < 50.0:
		var amt := r500(cash_reward(l) * rng.randf_range(0.4, 2.2))
		money += amt
		res = {"kind": "money", "amount": amt}
	elif roll < 65.0:
		var pool: Array = []
		for m in CarDB.MODELS:
			if int(m["min_level"]) <= level and int(m["tier"]) <= 1 + level / 4:
				pool.append(m)
		var m: Dictionary = pool[rng.randi() % pool.size()]
		var car := gen_car(str(m["id"]), 40.0, 82.0)
		car["bought_price"] = car_value(car)
		var where := "garage"
		if cars.size() < garage_cap:
			cars.append(car)
		elif storage.size() < STORAGE_CAP:
			storage.append(car)
			where = "storage"
		else:
			var cash := int(car_value(car) * 0.85)
			money += cash
			where = "cash"
			res = {"kind": "car_cash", "car": car, "amount": cash}
		if res.is_empty():
			res = {"kind": "car", "car": car, "where": where}
	else:
		var gain := int((15 + level * 6) * rng.randf_range(0.6, 1.5))
		res = {"kind": "xp", "amount": gain}
		add_xp(gain)
	Fx.play("crate")
	Fx.vibrate(80)
	save_game()
	changed.emit()
	return res


# =====================================================================
# Pazar ve araÃ§ deÄŸeri
# =====================================================================
func class_mult(cls: String) -> float:
	return float(news.get("cm", {}).get(cls, 1.0))


func demand_mult() -> float:
	var d: float = float(news.get("dm", 1.0)) * float(weather.get("dm", 1.0))
	return d * CityDB.demand(city)


func base_value(model_id: String, year: int, km: int) -> float:
	var m := CarDB.model(model_id)
	var fa := clampf(1.0 - 0.03 * (2022 - year), 0.6, 1.12)
	var fk := clampf(1.0 - (km - 60000) / 1000000.0, 0.75, 1.1)
	return float(m["base"]) * fa * fk


func car_value(car: Dictionary, estimate: bool = false) -> int:
	var m := CarDB.model(str(car["model"]))
	var v := base_value(str(car["model"]), int(car["year"]), int(car["km"]))
	var cond := 0.0
	for p in PARTS:
		var pv: float = float(car["parts"][p])
		if estimate and not bool(car["known"].get(p, false)):
			pv = 65.0
		cond += pv * float(PART_W[p])
	v = maxf(v, 125000.0)
	v *= 0.62 + 0.38 * cond / 100.0
	v *= 1.0 + 0.03 * float(car["clean"]) / 100.0
	v *= class_mult(str(m["cls"]))
	return maxi(100000 + (int(m["min_level"]) - 1) * 8000, int(v))


func est_range(car: Dictionary) -> Array:
	var err := clampf(0.20 - 0.014 * sk("market"), 0.06, 0.2)
	var c := float(car_value(car, true)) * (1.0 + float(car["bias"]) * err * 0.5)
	return [int(round(c * (1.0 - err / 2.0) / 1000.0)) * 1000, int(round(c * (1.0 + err / 2.0) / 1000.0)) * 1000]


func gen_car(model_id: String, qmin: float = 35.0, qmax: float = 95.0) -> Dictionary:
	var m := CarDB.model(model_id)
	var y0: int = int(m["years"][0])
	var y1: int = int(m["years"][1])
	var year := int(lerpf(y0, y1, pow(rng.randf(), 0.8)))
	var km := int(maxf(2000.0, (GAME_YEAR - year) * rng.randf_range(9000.0, 26000.0)))
	km = int(round(km / 500.0)) * 500
	var q := rng.randf_range(qmin, qmax)
	var parts := {}
	for p in PARTS:
		parts[p] = clampf(q + rng.randf_range(-22.0, 22.0) - (GAME_YEAR - year) * 0.8, 8.0, 100.0)
	if rng.randf() < 0.12:
		parts[PARTS[rng.randi() % PARTS.size()]] = rng.randf_range(10.0, 35.0)
	return {
		"uid": next_uid(), "model": model_id, "year": year, "km": km,
		"parts": parts, "known": {}, "clean": rng.randf_range(20.0, 80.0),
		"bias": rng.randf_range(-1.0, 1.0), "bought_price": 0, "invested": 0,
		"listed": false, "list_price": 0, "listed_day": 0,
	}


func gen_listing() -> Dictionary:
	var pool: Array = []
	for m in CarDB.MODELS:
		if int(m["min_level"]) <= level:
			pool.append(m)
	var weights: Array = []
	for m in pool:
		weights.append(1.0 / (1.0 + 0.35 * (int(m["tier"]) - 1)))
	var model_dict: Dictionary = pool[_pick(weights)]
	var car := gen_car(str(model_dict["id"]))
	var value := float(car_value(car))
	var roll := rng.randf()
	var ask: float
	var ratio: float
	if roll < 0.18:
		ask = value * rng.randf_range(0.84, 0.91)
		ratio = rng.randf_range(0.91, 0.96)
	elif roll < 0.90:
		ask = value * rng.randf_range(0.94, 1.03)
		ratio = rng.randf_range(0.91, 0.97)
	else:
		ask = value * rng.randf_range(1.08, 1.18)
		ratio = rng.randf_range(0.82, 0.92)
	var source := "owner" if rng.randf() < 0.6 else "dealer"
	if source == "dealer":
		ask *= 1.03
		car["known"]["body"] = true
		car["clean"] = maxf(75.0, float(car["clean"]))
	var a := maxi(100000, r500(ask))
	return {
		"id": next_uid(), "car": car, "ask": a, "reserve": maxi(50000, r500(a * ratio)),
		"source": source, "mood": 100.0, "day": day, "seller": SELLER_NAMES[rng.randi() % SELLER_NAMES.size()],
	}


func _pick(weights: Array) -> int:
	var total := 0.0
	for w in weights:
		total += float(w)
	var r := rng.randf() * total
	for i in weights.size():
		r -= float(weights[i])
		if r <= 0.0:
			return i
	return weights.size() - 1


func refresh_market() -> void:
	var keep: Array = []
	for l in market:
		if DealerExpansion.listing_alive(l) and day - int(l["day"]) < 3 and (l.has("rare_until") or int(CarDB.model(str(l["car"]["model"]))["min_level"]) <= level):
			keep.append(l)
	market = keep
	var target := mini(12 + level / 2, 24)
	while market.size() < target:
		market.append(gen_listing())
	if level <= 3 and not market.any(func(listing): return str(listing["car"]["model"]) == "ravena_rova"):
		var suv := gen_car("ravena_rova", 55.0, 85.0)
		var asking := r500(car_value(suv) * 1.01)
		market[0] = {"id": next_uid(), "car": suv, "ask": asking, "reserve": maxi(50000, r500(asking * 0.88)), "source": "owner", "mood": 100.0, "day": day, "seller": SELLER_NAMES[rng.randi() % SELLER_NAMES.size()]}

	DealerExpansion.ensure_rare()

func listing_by_id(id: int) -> Dictionary:
	for l in market:
		if int(l["id"]) == id and DealerExpansion.listing_alive(l):
			return l
	return {}


func car_by_uid(uid: int) -> Dictionary:
	for c in cars:
		if int(c["uid"]) == uid:
			return c
	return {}


# =====================================================================
# Ekspertiz
# =====================================================================
func part_state(v: float) -> String:
	if v >= 75.0:
		return "good"
	if v >= 50.0:
		return "mid"
	return "bad"


func inspect_cost(car: Dictionary) -> int:
	var base := float(CarDB.model(str(car["model"]))["base"])
	return int(maxf(400.0, base * 0.004) * (1.0 - 0.06 * sk("inspect")))


func inspect_part(car: Dictionary, part: String) -> bool:
	if not part in PARTS or car.is_empty() or not car.has("known") or not car.has("parts"): return false
	if bool(car["known"].get(part, false)):
		return true
	var c := inspect_cost(car)
	if money < c:
		toast(Loc.t("err_no_money"), "bad")
		Fx.play("error")
		return false
	money -= c
	car["known"][part] = true
	car["invested"] = int(car.get("invested", 0)) + c
	Fx.play("click")
	advance(1)
	save_game()
	return true


func repair_cost(car: Dictionary, part: String, target: float = 95.0) -> int:
	var cond := float(car["parts"][part])
	if cond >= target:
		return 0
	var base := float(CarDB.model(str(car["model"]))["base"])
	return int((target - cond) * float(PART_K[part]) * base * 0.50 * (1.0 - 0.025 * sk("inspect")) * (1.0 - DealerLife.mechanic_discount()))


func repair_range(car: Dictionary, part: String) -> Array:
	var c := float(repair_cost(car, part))
	var err := clampf(0.30 - 0.024 * sk("inspect"), 0.06, 0.3)
	return [int(round(c * (1.0 - err) / 100.0)) * 100, int(round(c * (1.0 + err) / 100.0)) * 100]


func repair_part(car: Dictionary, part: String) -> bool:
	if not cars.has(car) or not part in PARTS: return false
	var c := repair_cost(car, part)
	if c <= 0:
		return false
	if money < c:
		toast(Loc.t("err_no_money"), "bad")
		Fx.play("error")
		return false
	money -= c
	car["parts"][part] = 95.0
	DealerLife.earn("mechanic",10)
	car["known"][part] = true
	car["invested"] = int(car["invested"]) + c
	Fx.play("repair")
	Fx.vibrate(30)
	advance(1)
	save_game()
	return true


func clean_cost(car: Dictionary) -> int:
	return int((250 + int(float(CarDB.model(str(car["model"]))["base"]) * 0.0006)) * DealerLife.cleaner_factor())


func clean_car(car: Dictionary) -> bool:
	if not cars.has(car): return false
	if float(car["clean"]) >= 99.0:
		return false
	var c := clean_cost(car)
	if money < c:
		toast(Loc.t("err_no_money"), "bad")
		Fx.play("error")
		return false
	money -= c
	car["clean"] = 100.0
	DealerLife.earn("cleaner",10)
	car["invested"] = int(car["invested"]) + c
	Fx.play("success")
	advance(1)
	save_game()
	return true


# =====================================================================
# SatÄ±n alma ve pazarlÄ±k (satÄ±cÄ±)
# =====================================================================
func buy_listing(l: Dictionary, price: int) -> String:
	if price <= 0 or not market.has(l) or not l.has("car") or not DealerExpansion.listing_alive(l): return "gone"
	if not car_by_uid(int(l["car"]["uid"])).is_empty(): return "gone"
	if price < seller_floor(l): return "gone"
	if money < price:
		return "no_money"
	if cars.size() >= garage_cap:
		return "no_space"
	money -= price
	var car: Dictionary = l["car"]
	car["bought_price"] = price
	car["invested"] = int(car.get("invested", 0))
	cars.append(car)
	market.erase(l)
	stats["bought"] = int(stats["bought"]) + 1
	Fx.play("coin")
	Fx.vibrate(40)
	advance(1)
	save_game()
	return "ok"


## SatÄ±cÄ±ya teklif. kind = accept | counter | sad | angry | end. SatÄ±cÄ±nÄ±n sabrÄ± (mood, 0-100) dÃ¼ÅŸer.
func negotiate(l: Dictionary, offer: int) -> Dictionary:
	var ask: int = int(l["ask"])
	var floor_price: int = seller_floor(l)
	var current: int = clampi(int(l.get("counter_price", ask)), floor_price, ask)
	var rounds: int = int(l.get("negotiation_rounds", 0)) + 1
	l["negotiation_rounds"] = rounds
	if float(l["mood"]) <= 0.0:
		return {"kind": "end", "price": 0}
	if offer >= current:
		return {"kind": "accept", "price": current}
	if offer >= floor_price and (rounds >= 3 or offer >= floor_price + (current - floor_price) * 0.35):
		return {"kind": "accept", "price": offer}
	var ratio: float = float(offer) / maxf(floor_price, 1.0)
	var kind: String = "counter"
	var loss: float = 8.0
	if ratio < 0.70:
		kind = "angry"
		loss = 32.0
	elif ratio < 0.86:
		kind = "sad"
		loss = 18.0
	elif ratio < 1.0:
		loss = 12.0
	l["mood"] = maxf(0.0, float(l["mood"]) - loss)
	var concession: int = maxi(500, r500((current - floor_price) * (0.42 if ratio >= 0.86 else 0.20)))
	var next_price: int = maxi(floor_price, current - concession)
	if offer >= floor_price:
		next_price = maxi(offer + 500, next_price)
	next_price = mini(current, next_price)
	l["counter_price"] = next_price
	save_game()
	return {"kind": kind, "price": next_price if kind != "angry" else 0, "ended": float(l["mood"]) <= 0.0}


func seller_floor(l: Dictionary) -> int:
	var discount: float = minf(0.08, 0.006 * sk("haggle") + rep * 0.0003)
	var ask: int = int(l["ask"])
	var flexibility: float = 0.91 if ask <= 120000 else (0.94 if str(l.get("source", "owner")) == "owner" else 0.96)
	var reserve: float = minf(float(l["reserve"]), ask * flexibility)
	return maxi(50000, r500(reserve * (1.0 - discount)))


func seller_leave(l: Dictionary) -> void:
	market.erase(l)
	changed.emit()


# =====================================================================
# Ä°lan, mÃ¼ÅŸteri ve satÄ±ÅŸ
# =====================================================================
func set_listed(car: Dictionary, listed: bool, price: int = 0) -> void:
	if not cars.has(car) or (listed and price <= 0): return
	car["listed"] = listed
	if listed:
		car["list_price"] = price
		car["listed_day"] = day
		car["first_inquiry"] = not bool(car.get("had_inquiry", false))
		car["next_customer_at"] = now_seconds() + rng.randf_range(20.0, 30.0)
	else:
		visits = visits.filter(func(v): return int(v["car_uid"]) != int(car["uid"]))
	save_game()
	changed.emit()


func suggested_price(car: Dictionary) -> int:
	return r500(car_value(car) * 1.09)


func demand_factor(ratio: float) -> float:
	if ratio <= 0.9:
		return 2.0
	if ratio <= 1.0:
		return lerpf(2.0, 1.0, (ratio - 0.9) / 0.1)
	if ratio <= 1.1:
		return lerpf(1.0, 0.5, (ratio - 1.0) / 0.1)
	if ratio <= 1.25:
		return lerpf(0.5, 0.15, (ratio - 1.1) / 0.15)
	return maxf(0.03, 0.15 - (ratio - 1.25) * 0.4)


func quality_score(car: Dictionary, ratio: float) -> float:
	var m := CarDB.model(str(car["model"]))
	var q := float(level) / 20.0 + float(rep) / 200.0 + 0.025 * sk("sales") + 0.03 * listing_rank + 0.06 * learning_level()
	q += 0.12 if CityDB.is_metro(city) else 0.04
	if int(m["tier"]) >= 3:
		q += 0.1
	if ratio <= 1.05:
		q += 0.12
	return clampf(q, 0.0, 1.2)


func visit_chance(car: Dictionary) -> float:
	var value := float(car_value(car))
	var ratio := float(car["list_price"]) / maxf(value, 1.0)
	return 0.085 * demand_factor(ratio) * (0.75 + rep / 200.0) * demand_mult() * DealerExpansion.trend_factor(car) * DealerLife.sales_factor()


func _spawn_visits() -> void:
	for car in cars:
		if not bool(car["listed"]) or visits.size() >= 6:
			continue
		var has := false
		for v in visits:
			if int(v["car_uid"]) == int(car["uid"]):
				has = true
		if has:
			continue
		if rng.randf() < visit_chance(car):
			_make_visit(car)


func _make_visit(car: Dictionary) -> void:
	var value := float(car_value(car))
	var ratio := float(car["list_price"]) / maxf(value, 1.0)
	var qs := quality_score(car, ratio)
	var cands: Array = []
	var weights: Array = []
	for t in CUSTOMER_TYPES:
		if level < int(t["min_level"]):
			continue
		if t.has("max_value") and value > float(t["max_value"]):
			continue
		if t.has("min_value") and value < float(t["min_value"]):
			continue
		var w: float
		if float(t["q"]) < 0.5:
			w = 1.2 * (1.0 - 0.5 * qs)
		else:
			w = 0.35 * (1.0 + float(t["q"]) * qs * 2.2)
		cands.append(t)
		weights.append(w)
	if cands.is_empty():
		# Existing saves may contain a car above the level's usual price band.
		# Such a listing must still receive inquiries.
		cands.append(CUSTOMER_TYPES[2])
		weights.append(1.0)
	var t: Dictionary = cands[_pick(weights)]
	var max_pay := value * (1.03 if CarDB.body_type(str(car["model"])) == DealerExpansion.trend() else 1.0) * float(t["mult"]) * (1.0 + minf(0.07, 0.003 * sk("sales") + rep * 0.0005)) * rng.randf_range(0.99, 1.03)
	var personality := rng.randf()
	if personality < 0.15:
		max_pay *= 0.89
	elif personality > 0.88:
		max_pay *= 1.04
	max_pay = minf(max_pay, value * 1.23)
	var opening := mini(int(car["list_price"]), r500(max_pay * rng.randf_range(0.87, 0.94)))
	var visit := {
		"id": next_uid(), "car_uid": int(car["uid"]), "type": str(t["id"]),
		"name": SELLER_NAMES[rng.randi() % SELLER_NAMES.size()], "max_pay": int(max_pay),
		"offer": opening, "mood": 100.0, "day": day,
		"expires_at": now_seconds() + VISITOR_WAIT_SECONDS, "accepted": false,
	}
	visits.append(visit)
	Fx.play("customer")
	Fx.vibrate(40)
	visit_arrived.emit(visit)


## MÃ¼ÅŸteriye karÅŸÄ± fiyat. kind = accept | counter | low | leave. mood (sabÄ±r) fiyat beÄŸenilmezse dÃ¼ÅŸer; Ã§ok abartÄ±lmaz.
func customer_reply(v: Dictionary, price: int) -> Dictionary:
	var ceiling: int = int(v["max_pay"])
	var current: int = int(v["offer"])
	var rounds: int = int(v.get("negotiation_rounds", 0)) + 1
	v["negotiation_rounds"] = rounds
	if float(v["mood"]) <= 0.0:
		return {"kind": "leave", "price": 0}
	if price <= current or (price <= ceiling and (rounds >= 3 or price <= ceiling * 0.98)):
		return {"kind": "accept", "price": price}
	var ratio: float = float(price) / maxf(ceiling, 1.0)
	var loss: float = 8.0 if ratio <= 1.02 else (14.0 if ratio <= 1.12 else 26.0)
	v["mood"] = maxf(0.0, float(v["mood"]) - loss)
	var rise: int = maxi(500, r500((ceiling - current) * (0.50 if ratio <= 1.12 else 0.30)))
	var counter: int = mini(ceiling, mini(price, current + rise))
	if rounds >= 3:
		counter = mini(ceiling, price)
	v["offer"] = counter
	save_game()
	return {"kind": "counter" if float(v["mood"]) > 0.0 else "leave", "price": counter}


func dismiss_visit(v: Dictionary) -> void:
	if not visits.has(v):
		return
	visits.erase(v)
	var unsold: Dictionary = car_by_uid(int(v["car_uid"]))
	if not unsold.is_empty(): unsold["next_customer_at"] = now_seconds() + rng.randf_range(20.0, 30.0)
	rep = maxi(0, rep - 1)
	save_game()
	changed.emit()


func sale_difficulty(car: Dictionary) -> int:
	return int(CarDB.model(str(car["model"]))["tier"])


## SatÄ±ÅŸÄ± kesinleÅŸtirir. XP yalnÄ±zca bir kez (sale_id) verilir.
func buyer_concern(v: Dictionary) -> String:
	if v.has("concern"): return str(v["concern"])
	var car := car_by_uid(int(v.get("car_uid", 0)))
	if car.is_empty(): return "mileage"
	var reason := "mileage"
	if float(car.get("clean", 100)) < 65: reason = "clean"
	elif float(car.get("parts", {}).get("body", 100)) < 70: reason = "body"
	elif bool(v.get("test_drive_done", false)) and float(car.get("parts", {}).get("engine", 100)) < 70: reason = "engine"
	v["concern"] = reason
	return reason

func can_explain_care(car: Dictionary) -> bool:
	if float(car.get("clean", 0)) >= 99: return true
	for part in PARTS:
		if bool(car.get("known", {}).get(part, false)) and float(car.get("parts", {}).get(part, 0)) >= 95: return true
	return false

func answer_buyer(v: Dictionary, choice: String, counter_price: int) -> Dictionary:
	if not visits.has(v) or bool(v.get("concern_answered", false)) or not choice in ["honest", "care", "discount"]: return {}
	var car := car_by_uid(int(v.get("car_uid", 0)))
	if car.is_empty() or not cars.has(car) or counter_price <= 0: return {}
	if choice == "care" and not can_explain_care(car): return {}
	buyer_concern(v)
	v["concern_answered"] = true
	v["concern_choice"] = choice
	var proposed: int = counter_price
	if choice == "care":
		var ceiling: int = mini(int(round(int(v["max_pay"])*1.01)), int(car_value(car)*1.23))
		v["max_pay"] = maxi(int(v["max_pay"]), ceiling)
		v["offer"] = mini(int(v["max_pay"]), int(round(int(v["offer"])*1.01)))
		v["mood"] = minf(100, float(v["mood"])+8)
	elif choice == "discount":
		proposed = maxi(1000, int(round(counter_price*.98)))
		v["mood"] = minf(100, float(v["mood"])+10)
	else:
		v["mood"] = minf(100, float(v["mood"])+6)
	save_game()
	return {"choice": choice, "counter": proposed, "offer": int(v["offer"])}

func test_drive(v: Dictionary, handling: int = -1) -> Dictionary:
	if not visits.has(v): return {}
	var car := car_by_uid(int(v.get("car_uid", 0)))
	if car.is_empty() or not cars.has(car): return {}
	if bool(v.get("test_drive_done", false)):
		return v.get("test_drive_result", {}).duplicate(true)
	var parts: Dictionary = car.get("parts", {})
	var engine: float = float(parts.get("engine", 100))
	var body: float = float(parts.get("body", 100))
	var tires: float = float(parts.get("tires", 100))
	var clean_score: float = float(car.get("clean", 100))
	var score: float = clampf(engine*.45 + tires*.25 + body*.15 + clean_score*.15, 0, 100)
	if handling >= 0: score = score*.75 + clampi(handling,0,100)*.25
	var factor: float = clampf((score-70.0)/1000.0, -.07, .03)
	var old_offer: int = int(v["offer"])
	var ceiling: int = maxi(1, int(round(int(v["max_pay"])*(1.0+factor))))
	var offer: int = clampi(int(round(old_offer*(1.0+factor))), 1, ceiling)
	var result := {"score": int(round(score)), "delta": offer-old_offer, "offer": offer,
		"engine": int(engine), "tires": int(tires), "clean": int(clean_score)}
	v["offer"] = offer
	v["max_pay"] = ceiling
	v["test_drive_done"] = true
	v["test_drive_result"] = result
	advance(10)
	save_game()
	return result.duplicate(true)

func sales_history() -> Array:
	var history: Variant = flags.get("sales_history", [])
	if not history is Array: return []
	var valid: Array = []
	for entry in history:
		if not entry is Dictionary: continue
		if not ["model", "price", "bought", "invested", "bonus", "profit", "day", "minute"].all(func(k): return entry.has(k)): continue
		if not ["price", "bought", "invested", "bonus", "profit", "day", "minute"].all(func(k): return entry[k] is int or entry[k] is float): continue
		valid.append(entry.duplicate(true))
	return valid.slice(maxi(0, valid.size()-100))

func _record_sale(car: Dictionary, price: int, bonus: int, buyer: String) -> void:
	var history := sales_history()
	history.append({"model": str(car["model"]), "year": int(car["year"]),
		"price": price, "bought": int(car["bought_price"]), "invested": int(car["invested"]),
		"bonus": bonus, "profit": price+bonus-int(car["bought_price"])-int(car["invested"]),
		"day": day, "minute": minute, "buyer": Loc.repair_text(buyer)})
	flags["sales_history"] = history.slice(maxi(0, history.size()-100))

func finalize_sale(car: Dictionary, price: int, service_bonus: int = 0, buyer: String = "") -> Dictionary:
	if price <= 0 or service_bonus < 0 or car.is_empty(): return {}
	var sale_id := "sale_%d" % int(car["uid"])
	if sold_ids.has(sale_id) or not cars.has(car):
		return {}
	var review: Dictionary = customer_review(car, price)
	var cost := int(car["bought_price"]) + int(car["invested"])
	var profit := price + service_bonus - cost
	money += price + service_bonus
	monthly_profit += profit
	_record_sale(car, price, service_bonus, buyer)
	diamonds += 2 + (1 if sale_difficulty(car) >= 3 else 0)
	cars.erase(car)
	visits = visits.filter(func(v): return int(v["car_uid"]) != int(car["uid"]))
	sold_ids[sale_id] = true
	var diff := sale_difficulty(car)
	var gain := 60 + diff * 20 + int(clampf(profit, 0.0, 500000.0) / 1500.0) if profit > 0 else 25 + diff * 10
	var lvl_before := level
	add_xp(gain)
	stats["sold"] = int(stats["sold"]) + 1
	DealerLife.earn("sales",25)
	stats["profit"] = int(stats["profit"]) + profit
	stats["best"] = maxi(int(stats["best"]), profit)
	rep = clampi(rep + (3 if profit > 0 else 1) + (1 if float(car["clean"]) >= 95.0 else 0), 0, 100)
	Fx.play("sale")
	Fx.vibrate(60)
	var ni := next_installment()
	advance(1)
	save_game()
	return {
		"review": review, "car": car, "price": price, "bought": int(car["bought_price"]), "invested": int(car["invested"]),
		"profit": profit, "bonus": service_bonus, "xp": gain, "diamonds": 2 + (1 if diff >= 3 else 0), "leveled": level > lvl_before, "installment": ni, "debt": total_debt(),
	}


func sell_to_dealer(car: Dictionary) -> int:
	if not cars.has(car):
		return 0
	var price := int(car_value(car) * 0.80)
	finalize_sale(car, price, 0, Loc.t("history_dealer"))
	visits = visits.filter(func(v): return int(v["car_uid"]) != int(car["uid"]))
	Fx.play("coin")
	advance(1)
	save_game()
	return price


func storage_to_garage(i: int) -> bool:
	if i < 0 or i >= storage.size() or cars.size() >= garage_cap:
		return false
	cars.append(storage[i])
	storage.remove_at(i)
	save_game()
	changed.emit()
	return true


func storage_sell(i: int) -> int:
	if i < 0 or i >= storage.size():
		return 0
	var price := int(car_value(storage[i]) * 0.85)
	_record_sale(storage[i], price, 0, Loc.t("history_dealer"))
	money += price
	storage.remove_at(i)
	Fx.play("coin")
	save_game()
	changed.emit()
	return price


func next_garage_upgrade() -> Dictionary:
	for u in GARAGE_UPGRADES:
		if int(u["cap"]) > garage_cap:
			return u
	return {}


func upgrade_garage() -> String:
	var u := next_garage_upgrade()
	if u.is_empty():
		return "max"
	if level < int(u["level"]):
		return "level"
	if money < int(u["cost"]):
		return "no_money"
	money -= int(u["cost"])
	garage_cap = int(u["cap"])
	Fx.play("success")
	save_game()
	changed.emit()
	return "ok"


# =====================================================================
# Kredi (gÃ¼nlÃ¼k otomatik taksit)
# =====================================================================
func loan_total_left(l: Dictionary) -> int:
	return loan_remaining(l) + int(l["fees"])

func loan_remaining(l: Dictionary) -> int:
	if l.has("remaining"): return maxi(0,int(l["remaining"]))
	var total := int(loan_quote(int(l["principal"]),int(l["months"]))["total"])
	return maxi(0,total-int(l["daily"])*(int(l["days"])-int(l["left"])))

func loan_installment(l: Dictionary) -> int:
	return int(ceil(float(loan_remaining(l))/maxi(1,int(l["left"]))))


func loan_principal_left(l: Dictionary) -> int:
	return int(float(l["principal"]) * float(l["left"]) / float(l["days"]))


func loan_paid_fraction(l: Dictionary) -> float:
	return 1.0 - float(l["left"]) / float(l["days"])


func total_debt() -> int:
	var s := 0
	for l in loans:
		s += loan_total_left(l)
	return s


func principal_outstanding() -> int:
	var s := 0
	for l in loans:
		s += loan_principal_left(l)
	return s


## Seviyeye baÄŸlÄ± kredi limiti: <=5: 200 bin, <=10: 750 bin, <=15: 1 milyon, <=19: 1,5 milyon, 20+: 2 milyon.
func loan_level_cap() -> int:
	if level <= 5:
		return 200000
	if level <= 10:
		return 750000
	if level <= 15:
		return 1000000
	if level <= 19:
		return 1500000
	return LOAN_CAP


## "Kredi Kullanımı" eÄŸitiminin aÃ§tÄ±ÄŸÄ± limit.
func loan_train_cap() -> int:
	return int(TrainingDB.CREDIT_CAPS[clampi(sk("credit"), 0, 10)])


func loan_limit() -> int:
	return mini(LOAN_CAP, maxi(loan_level_cap(), loan_train_cap()))


func loan_room() -> int:
	return maxi(0, loan_limit() - principal_outstanding())


## Mevcut kredilerin en az %40'Ä± Ã¶denmeden yeni kredi verilmez. DÃ¶nen deÄŸer: engelleyen en dÃ¼ÅŸÃ¼k Ã¶deme oranÄ± (0-1), engel yoksa -1.
func loan_block_fraction() -> float:
	var worst := -1.0
	for l in loans:
		var f := loan_paid_fraction(l)
		if f < MIN_PAID_FOR_NEXT_LOAN and (worst < 0.0 or f < worst):
			worst = f
	return worst


func loan_quote(amount: int, months: int) -> Dictionary:
	var rate: float = float(LOAN_TERMS.get(months, 0.5))
	var days := months * DAYS_PER_MONTH
	var total := int(ceil(amount * (1.0 + rate)))
	return {"rate": rate, "total": total, "days": days, "daily": int(ceil(total / float(days)))}


func take_loan(amount: int, months: int) -> String:
	if amount < 10000 or not LOAN_TERMS.has(months):
		return "invalid"
	if loan_block_fraction() >= 0.0:
		return "block"
	if amount > loan_room():
		return "cap"
	var q := loan_quote(amount, months)
	loans.append({"id": next_uid(), "principal": amount, "months": months, "days": q["days"], "left": q["days"],
		"daily": q["daily"], "remaining": q["total"], "missed": 0, "fees": 0, "taken_day": day})
	money += amount
	Fx.play("coin")
	save_game()
	changed.emit()
	return "ok"


## Erken kapatma: kalan anapara + kalan faizin yalnÄ±zca %25'i.
func settle_cost(l: Dictionary) -> int:
	var pl := loan_principal_left(l)
	var tl := loan_total_left(l)
	return pl + int(EARLY_SETTLE_INTEREST * maxi(0, tl - pl)) if tl > pl else tl


func settle_loan(l: Dictionary) -> bool:
	if not loans.has(l): return false
	var c := settle_cost(l)
	if money < c:
		toast(Loc.t("err_no_money"), "bad")
		Fx.play("error")
		return false
	money -= c
	loans.erase(l)
	Fx.play("success")
	save_game()
	changed.emit()
	return true


## GÃ¼nlÃ¼k otomatik Ã§ekilecek toplam taksit.
func next_installment() -> Dictionary:
	if loans.is_empty():
		return {}
	var amt := 0
	for l in loans:
		amt += loan_installment(l) + int(l["fees"])
	return {"amount": amt}


func _process_loans() -> void:
	var paid := 0
	for l in loans.duplicate():
		var installment := loan_installment(l)
		var remaining := loan_remaining(l)
		var due := installment + int(l["fees"])
		if money >= due:
			money -= due
			paid += due
			l["fees"] = 0
			l["remaining"] = maxi(0,remaining-installment)
			l["left"] = int(l["left"]) - 1
			l["daily"] = loan_installment(l)
			if int(l["left"]) <= 0:
				loans.erase(l)
				toast(Loc.t("toast_loan_done"), "good")
		else:
			l["missed"] = int(l["missed"]) + 1
			l["fees"] = int(l["fees"]) + int(int(l["daily"]) * 0.05)
			rep = clampi(rep - 1, 0, 100)
			Fx.play("error")
			toast(Loc.t("toast_installment_late"), "bad")
	if paid > 0:
		toast(Loc.t("toast_installment_paid", [Loc.money(paid)]), "info")


# =====================================================================
# EÄŸitim (sÄ±rayla, tek seferde bir tane; sÃ¼re oyun iÃ§i dakikadÄ±r)
# =====================================================================
func abs_minutes() -> int:
	return day * 1440 + minute


func training_minutes(id: String, lvl: int) -> int:
	return int(TrainingDB.item(id)["minutes"][clampi(lvl - 1, 0, 9)])


func training_seconds_left() -> int:
	if active_training.is_empty():
		return 0
	return maxi(0, int(ceil(float(active_training.get("finish_at", now_seconds())) - now_seconds())))


func training_left() -> int:
	return int(ceil(training_seconds_left() / 60.0))


func training_clock() -> String:
	var sec := training_seconds_left()
	return "%02d:%02d" % [sec / 60, sec % 60]


func training_progress() -> float:
	return 0.0 if active_training.is_empty() else clampf(1.0 - float(training_seconds_left()) / maxf(1.0, float(active_training["total"]) * 60.0), 0.0, 1.0)


## EÄŸitim kademesinin etkisi (ekranda "şimdi → sonra" olarak gÃ¶sterilir).
func training_value(id: String, lvl: int) -> String:
	match id:
		"inspect":
			return "-%d%%" % (6 * lvl)
		"haggle":
			return "-%d%%" % int(round(1.2 * lvl))
		"sales":
			return "+%.1f%%" % (0.4 * lvl)
		"market":
			return "±%d%%" % int(round(clampf(0.20 - 0.014 * lvl, 0.06, 0.2) * 50.0))
		"learn":
			return "+%d%%" % (6 * lvl)
		"credit":
			return Loc.money(int(TrainingDB.CREDIT_CAPS[clampi(lvl, 0, 10)]))
	return ""


func start_training(id: String) -> String:
	if not active_training.is_empty():
		return "busy"
	var it := TrainingDB.item(id)
	if it.is_empty():
		return "unknown"
	var next_lvl := sk(id) + 1
	if next_lvl > 10:
		return "max"
	if level < int(it["levels"][next_lvl - 1]):
		return "level"
	var cost := int(it["costs"][next_lvl - 1])
	if money < cost:
		return "no_money"
	money -= cost
	var mins := training_minutes(id, next_lvl)
	active_training = {"id": id, "level": next_lvl, "finish_at": now_seconds() + mins * 60.0, "total": mins}
	Fx.play("success")
	save_game()
	changed.emit()
	return "ok"


func _check_training() -> void:
	if active_training.is_empty() or training_seconds_left() > 0:
		return
	trainings[str(active_training["id"])] = int(active_training["level"])
	diamonds += 2
	add_xp(20 + int(active_training["level"]) * 5)
	toast(Loc.t("toast_training_done", [Loc.t("tr_%s" % active_training["id"])]) + " · +2 ♦", "good")
	active_training = {}
	Fx.play("levelup")
	save_game()
	changed.emit()


# =====================================================================
# Zaman, haber, hava
# =====================================================================
func shop_closed() -> bool:
	return minute < 420 or minute >= 1380

func advance(mins: int) -> void:
	var left := maxi(0, mins)
	if not _sleeping:
		left = 0 if shop_closed() else mini(left,1380-minute)
	while left > 0:
		var step := mini(left, 60 - (minute % 60))
		minute += step
		left -= step
		if minute % 60 == 0:
			var rolled := false
			if minute >= 1440:
				minute -= 1440
				day += 1
				rolled = true
			if rolled:
				_on_new_day()
			if not _sleeping and not shop_closed():
				DealerLife.weather_hour()
				DealerExpansion.cleaner_hour()
			# Customers use real elapsed time, independent of paid game-time skips.
	_check_training()
	changed.emit()


func _on_new_day() -> void:
	record_cashflow()
	var opening := money
	var previous_income := daily_income
	var previous_expenses := daily_expenses
	daily_income = 0
	daily_expenses = 0
	_roll_world()
	var before_loans := money
	_process_loans()
	var loan_payment := before_loans - money
	var prices_before := finance_prices.duplicate()
	process_finance_day()
	process_bills()
	var portfolio_delta := 0
	var assets: Array = []
	for id in investments:
		var position: Dictionary = investments[id]
		var units := int(position["units"])
		var delta := int(units * (float(finance_prices[id]) - float(prices_before[id])) * 0.99)
		portfolio_delta += delta
		if units > 0:
			assets.append({"id": id, "change": delta})
	daily_summary["portfolio_change"] = portfolio_delta
	daily_summary["portfolio_assets"] = assets
	daily_summary["investment_realized"] = int(flags.get("investment_realized", 0))
	flags["investment_realized"] = 0
	daily_summary["street_payment"] = process_street_day()
	daily_summary["loans"] = loan_payment
	daily_summary["previous_income"] = previous_income
	daily_summary["previous_expenses"] = previous_expenses
	daily_summary["opening"] = opening
	daily_summary["closing"] = money
	day_opening_balance = money
	visits = visits.filter(func(v): return day - int(v["day"]) <= 2)
	refresh_market()
	save_game()
	call_deferred("announce_day")


func _roll_world() -> void:
	news = NEWS[rng.randi() % NEWS.size()]
	var dd := date_dict()
	var temp := CityDB.temp(city, int(dd["month"])) + rng.randi_range(-3, 3)
	var pool: Array = []
	for w in WEATHER:
		if str(w["id"]) == "snow" and temp > 3:
			continue
		if str(w["id"]) == "rain" and temp <= 0:
			continue
		pool.append(w)
	var w: Dictionary = pool[rng.randi() % pool.size()]
	weather = {"id": w["id"], "dm": w["dm"], "temp": temp}


## Galeri gideri (kira, personel, elektrik): bekleyen her saat iÃ§in Ã¶denir.
func hour_cost() -> int:
	return 1500 + 350 * garage_cap + 100 * level


func wait_cost(mins: int) -> int:
	var span := 0 if shop_closed() else clampi(mins,0,1380-minute)
	return int(ceil(hour_cost() * span / 60.0))


func end_day_minutes() -> int:
	return (420 - minute) if minute < 420 else (1440 - minute) + 420


func wait_minutes(mins: int) -> bool:
	if mins <= 0 or mins > 1440*365 or shop_closed(): return false
	var c := wait_cost(mins)
	if money < c:
		toast(Loc.t("err_wait_money", [Loc.money(c)]), "bad")
		Fx.play("error")
		return false
	money -= c
	advance(mins)
	save_game()
	return true


func end_day() -> bool:
	if not started or not shop_closed() or _sleeping: return false
	_sleeping = true
	if bool(flags.get("theft_pending",false)): resolve_theft(false)
	advance(end_day_minutes())
	_sleeping = false
	_world_seconds = 0.0
	_customer_tick_at = now_seconds()
	_next_visit_at = now_seconds()+5.0
	for visitor in visits: visitor["expires_at"] = now_seconds()+VISITOR_WAIT_SECONDS
	save_game()
	changed.emit()
	return true


# =====================================================================
# Yeni oyun, hedef, kayÄ±t
# =====================================================================
func new_game(pname: String, city_id: String) -> void:
	started = true
	player_name = pname.strip_edges() if pname.strip_edges() != "" else Loc.t("default_name")
	city = CityDB.normalize(city_id)
	money = START_MONEY
	day = 0
	minute = 420
	xp = 0
	level = 1
	rep = 10
	garage_cap = 5
	cars = []
	storage = []
	market = []
	visits = []
	loans = []
	trainings = {}
	active_training = {}
	claimed = {}
	crates_opened = {}
	sold_ids = {}
	stats = {"sold": 0, "bought": 0, "profit": 0, "best": 0, "crates": 0}
	flags = {}
	business_owned = false
	business_price_paid = 0
	daily_income = 0
	daily_expenses = 0
	monthly_profit = 0
	day_opening_balance = START_MONEY
	_ledger_balance = START_MONEY
	daily_summary = {}
	bankrupt_state = {}
	diamonds = 3
	avatar_id = 0
	daily_date = ""
	daily_streak = 0
	listing_rank = 0
	investments = {}
	finance_prices = {"usd": 40.0, "eur": 44.0, "gold": 4200.0, "index": 100.0}
	finance_history = {}
	deposits = []
	bills = []
	play_reward_day = ""
	play_reward_claims = 0
	_active_seconds = 0.0
	uid_counter = 1
	_next_visit_at = 0.0
	_negotiation_depth = 0
	_customer_tick_at = now_seconds()
	_roll_world()
	refresh_market()
	save_game()
	changed.emit()


func set_city(c: String) -> void:
	if started: return
	city = CityDB.normalize(c)
	_roll_world()
	save_game()
	changed.emit()


func next_goal() -> Dictionary:
	if not pending_reward_levels().is_empty():
		return {"key": "goal_reward", "screen": "rewards"}
	if not visits.is_empty():
		return {"key": "goal_visit", "screen": "garage"}
	if cars.is_empty():
		return {"key": "goal_buy", "screen": "market"}
	var unlisted := false
	for c in cars:
		if not bool(c["listed"]):
			unlisted = true
	if unlisted:
		return {"key": "goal_list", "screen": "garage"}
	return {"key": "goal_wait", "screen": "listings"}


func to_dict() -> Dictionary:
	return {
		"version": SAVE_VERSION, "player_name": player_name, "city": city, "money": money, "day": day,
		"minute": minute, "xp": xp, "level": level, "rep": rep, "garage_cap": garage_cap, "cars": cars,
		"storage": storage, "market": market, "visits": visits, "loans": loans, "trainings": trainings,
		"active_training": active_training, "claimed": claimed, "crates_opened": crates_opened,
		"sold_ids": sold_ids, "stats": stats, "weather": weather, "news": news,
		"uid_counter": uid_counter, "flags": flags,
		"business_owned": business_owned, "business_price_paid": business_price_paid,
		"daily_income": daily_income, "daily_expenses": daily_expenses, "monthly_profit": monthly_profit,
		"day_opening_balance": day_opening_balance, "daily_summary": daily_summary, "bankrupt_state": bankrupt_state,
		"diamonds": diamonds, "avatar_id": avatar_id, "daily_date": daily_date, "daily_streak": daily_streak,
		"listing_rank": listing_rank, "investments": investments, "finance_prices": finance_prices,
		"finance_history": finance_history, "deposits": deposits, "bills": bills,
		"play_reward_day": play_reward_day, "play_reward_claims": play_reward_claims,
		"active_seconds": _active_seconds,

	}


func _migrate(d: Dictionary) -> Dictionary:
	var v := int(d.get("version", 0))
	# SÃ¼rÃ¼m geÃ§iÅŸleri burada yapÄ±lÄ±r. (v0 -> v1: eksik alanlar varsayÄ±lanla doldurulur)
	if v < 1:
		d["flags"] = d.get("flags", {})
		d["crates_opened"] = d.get("crates_opened", {})
		d["sold_ids"] = d.get("sold_ids", {})
	d["version"] = SAVE_VERSION
	return d


func from_dict(d: Dictionary) -> void:
	if not valid_snapshot(d): return
	var previous_version: int = int(d.get("version", 0))
	d = _migrate(d)
	d = _repair_saved_text(d)
	player_name = str(d.get("player_name", "Patron"))
	city = CityDB.normalize(str(d.get("city", "34")))
	money = int(d.get("money", START_MONEY))
	day = int(d.get("day", 0))
	minute = int(d.get("minute", 480))
	xp = int(d.get("xp", 0))
	level = level_for(xp)
	rep = int(d.get("rep", 10))
	garage_cap = maxi(5, int(d.get("garage_cap", 5)))
	cars = d.get("cars", [])
	storage = d.get("storage", [])
	market = d.get("market", [])
	for listing in market:
		listing["ask"] = maxi(100000, int(listing["ask"]))
		if previous_version < 5:
			listing["reserve"] = maxi(50000, mini(int(listing["reserve"]), r500(int(listing["ask"]) * 0.93)))
	if previous_version < 5:
		for listing in market:
			listing.erase("counter_price")
			listing.erase("negotiation_rounds")
			listing["mood"] = 100.0
	visits = d.get("visits", [])
	loans = d.get("loans", [])
	for loan in loans:
		loan["remaining"] = loan_remaining(loan)
		loan["daily"] = loan_installment(loan)
	trainings = d.get("trainings", {})
	active_training = d.get("active_training", {})
	claimed = _integer_keys(d.get("claimed", {}))
	crates_opened = _integer_keys(d.get("crates_opened", {}))
	sold_ids = d.get("sold_ids", {})
	stats = {"sold": 0, "bought": 0, "profit": 0, "best": 0, "crates": 0}
	stats.merge(d.get("stats",{}),true)
	weather = d.get("weather", {})
	news = d.get("news", {})
	uid_counter = int(d.get("uid_counter", 1000))
	flags = d.get("flags", {})
	business_owned = bool(d.get("business_owned", false))
	business_price_paid = int(d.get("business_price_paid", 0))
	daily_income = int(d.get("daily_income", 0))
	daily_expenses = int(d.get("daily_expenses", 0))
	monthly_profit = int(d.get("monthly_profit", 0))
	day_opening_balance = int(d.get("day_opening_balance", money))
	daily_summary = d.get("daily_summary", {})
	bankrupt_state = d.get("bankrupt_state", {})
	_ledger_balance = money
	diamonds = maxi(0, int(d.get("diamonds", 3)))
	avatar_id = clampi(int(d.get("avatar_id", 0)), 0, 7)
	daily_date = str(d.get("daily_date", ""))
	daily_streak = int(d.get("daily_streak", 0))
	listing_rank = clampi(int(d.get("listing_rank", 0)), 0, 5)
	investments = d.get("investments", {})
	finance_prices = {"usd": 40.0, "eur": 44.0, "gold": 4200.0, "index": 100.0}
	finance_prices.merge(d.get("finance_prices",{}),true)
	finance_history = d.get("finance_history", {})
	deposits = d.get("deposits", [])
	bills = d.get("bills", [])
	play_reward_day = str(d.get("play_reward_day", ""))
	play_reward_claims = int(d.get("play_reward_claims", 0))
	_active_seconds = maxf(0.0, float(d.get("active_seconds", 0.0)))
	if not active_training.is_empty() and not active_training.has("finish_at"):
		active_training["finish_at"] = now_seconds() + maxi(0, int(active_training.get("finish_abs", abs_minutes())) - abs_minutes()) * 60.0
	# No unattended visitor penalties while the game is closed.
	visits = []
	_next_visit_at = now_seconds() + 8.0
	for car in cars:
		if bool(car.get("listed", false)):
			car["first_inquiry"] = not bool(car.get("had_inquiry", false))
		car["next_customer_at"] = now_seconds() + rng.randf_range(20.0, 30.0)

	if weather.is_empty() or news.is_empty():
		_roll_world()
	started = true
	if not bankrupt_state.is_empty() and (money > 0 or can_recover_cash()): bankrupt_state = {}

func _repair_saved_text(value: Variant) -> Variant:
	if value is String: return Loc.repair_text(value)
	if value is Array:
		for i in value.size(): value[i] = _repair_saved_text(value[i])
	elif value is Dictionary:
		for key in value: value[key] = _repair_saved_text(value[key])
	return value

func _integer_keys(value: Dictionary) -> Dictionary:
	var result := {}
	for key in value:
		if str(key).is_valid_int(): result[int(key)] = value[key]
	return result

func _number(value: Variant, lower: float = -9.0e15, upper: float = 9.0e15) -> bool:
	return (value is int or value is float) and is_finite(float(value)) and float(value) >= lower and float(value) <= upper

func _valid_car(value: Variant) -> bool:
	if not value is Dictionary: return false
	if not value.get("model") is String or CarDB.model(value["model"]).is_empty(): return false
	if not _number(value.get("uid"),1) or not value.get("parts") is Dictionary or not value.get("known") is Dictionary: return false
	if not _number(value.get("clean"),0,100) or not _number(value.get("year"),1900,2100) or not _number(value.get("km"),0): return false
	if not _number(value.get("bought_price"),0) or not _number(value.get("invested"),0): return false
	for part in PARTS:
		if not _number(value["parts"].get(part),0,100): return false
	return true

func valid_snapshot(value: Dictionary) -> bool:
	if not _number(value.get("version"),0,SAVE_VERSION) or not _number(value.get("money")) or not value.get("cars") is Array: return false
	for field in ["storage","market","visits","loans","deposits","bills"]:
		if value.has(field) and not value[field] is Array: return false
	for field in ["settings","flags","claimed","crates_opened","sold_ids","trainings","active_training","stats","news","weather","investments","finance_prices","finance_history","daily_summary","bankrupt_state"]:
		if value.has(field) and not value[field] is Dictionary: return false
	for field in ["day","minute","xp","rep","garage_cap","uid_counter","diamonds","avatar_id"]:
		if value.has(field) and not _number(value[field],0): return false
	var identifiers := {}
	for car in value["cars"]+value.get("storage",[]):
		if not _valid_car(car) or identifiers.has(int(car["uid"])): return false
		identifiers[int(car["uid"])] = true
	for listing in value.get("market",[]):
		if not listing is Dictionary or not _valid_car(listing.get("car")) or not _number(listing.get("ask"),1): return false
	for loan in value.get("loans",[]):
		if not loan is Dictionary: return false
		for field in ["principal","days","left","daily"]:
			if not _number(loan.get(field),1): return false
		if not LOAN_TERMS.has(int(loan.get("months",0))) or not _number(loan.get("fees",0),0): return false
	for amount in value.get("stats",{}).values():
		if not _number(amount): return false
	for price in value.get("finance_prices",{}).values():
		if not _number(price,0.01): return false
	for position in value.get("investments",{}).values():
		if not position is Dictionary or not _number(position.get("units"),0) or not _number(position.get("cost"),0): return false
	for deposit in value.get("deposits",[]):
		if not deposit is Dictionary: return false
		for field in ["id","amount","due","term","interest"]:
			if not _number(deposit.get(field),0): return false
	var bankruptcy: Dictionary = value.get("bankrupt_state",{})
	if not bankruptcy.is_empty() and not _number(bankruptcy.get("restart_at"),0): return false
	var training: Dictionary = value.get("active_training",{})
	if not training.is_empty():
		if not training.get("id") is String or TrainingDB.item(training["id"]).is_empty() or not _number(training.get("level"),1,10): return false
		if training.has("finish_at") and not _number(training["finish_at"],0): return false
	return true


func has_save() -> bool:
	return FileAccess.file_exists(save_path()) or FileAccess.file_exists(save_path(true))

func save_path(backup: bool = false) -> String:
	if "--deep-audit" in OS.get_cmdline_user_args():
		var folder := ProjectSettings.globalize_path("res://").path_join("../../build_tools/audit_save").simplify_path()
		DirAccess.make_dir_recursive_absolute(folder)
		return folder.path_join("save.bak" if backup else "save.dat")
	return SAVE_BAK if backup else SAVE_PATH


func save_game() -> void:
	if DealerExpansion.saving_trade: return
	if "--layout-audit" in OS.get_cmdline_user_args() and not "--deep-audit" in OS.get_cmdline_user_args(): return
	if not started:
		return
	record_cashflow()
	var tmp := save_path() + ".tmp"
	var f := FileAccess.open(tmp, FileAccess.WRITE)
	if f == null:
		push_warning("Kayıt yazılamadı")
		return
	var snapshot := to_dict()
	f.store_var(snapshot)
	var write_error := f.get_error()
	f.close()
	if write_error != OK:
		push_warning("Kayıt tamamlanamadı; önceki kayıt korundu")
		return
	if FileAccess.file_exists(save_path()):
		var old := FileAccess.open(save_path(),FileAccess.READ)
		if old != null:
			var prior: Variant = old.get_var(false)
			old.close()
			if prior is Dictionary and valid_snapshot(prior): DirAccess.copy_absolute(save_path(),save_path(true))
	if DirAccess.rename_absolute(tmp,save_path()) != OK: push_warning("Cihaz kaydı tamamlanamadı; yedek korundu")
	AccountBridge.queue_save(snapshot)


func load_game() -> bool:
	for p in [save_path(), save_path(true)]:
		if not FileAccess.file_exists(p):
			continue
		var f := FileAccess.open(p, FileAccess.READ)
		if f == null:
			continue
		var d: Variant = f.get_var(false)
		f.close()
		if typeof(d) == TYPE_DICTIONARY and valid_snapshot(d):
			from_dict(d)
			changed.emit()
			return true
	return false


func delete_save() -> void:
	for p in [save_path(), save_path(true)]:
		if FileAccess.file_exists(p):
			DirAccess.remove_absolute(p)


func now_seconds() -> float:
	return Time.get_unix_time_from_system()


func real_date() -> String:
	return Time.get_date_string_from_system()


var _visibility_timer: float = 0.0
var _web_hidden: bool = false
func _process(delta: float) -> void:
	if menu_paused: return
	if not started:
		return
	if not bankrupt_state.is_empty():
		if now_seconds() >= float(bankrupt_state["restart_at"]):
			restart_after_bankruptcy()
		return
	if money <= 0:
		check_bankruptcy()
		if not bankrupt_state.is_empty(): return
	if OS.has_feature("web"):
		_visibility_timer -= delta
		if _visibility_timer <= 0.0:
			_visibility_timer = 0.25
			_web_hidden = bool(JavaScriptBridge.eval("document.hidden", true))
	if _web_hidden:
		if _background_at == 0.0:
			_background_at = now_seconds()
			save_game()
		return
	if _background_at > 0.0:
		var paused: float = maxf(0.0, now_seconds() - _background_at)
		for visitor in visits:
			visitor["expires_at"] = float(visitor.get("expires_at", now_seconds())) + paused
		if flags.has("theft_deadline"):
			flags["theft_deadline"] = float(flags["theft_deadline"]) + paused
		_background_at = 0.0
		_customer_tick_at = now_seconds()
	_world_seconds += minf(delta, 0.25)
	if _world_seconds >= 1.25:
		_world_seconds -= 1.25
		advance(1)
	_bridge_seconds += delta
	if _bridge_seconds >= 15.0:
		_bridge_seconds = 0.0
		sync_web_presence()
	_tick_seconds += delta
	_autosave_seconds += delta
	if _autosave_seconds >= 60.0:
		_autosave_seconds = 0.0
		save_game()
	if get_tree().root.has_focus():
		_active_seconds += delta
	if _tick_seconds < 1.0:
		return
	_tick_seconds = 0.0
	_check_training()
	if bool(flags.get("theft_pending", false)) and (now_seconds() >= float(flags.get("theft_deadline", now_seconds() + 45.0))):
		resolve_theft(false)
	process_live_customers()
	process_market_activity()
	process_night_security()
	if play_reward_day != real_date():
		play_reward_day = real_date()
		play_reward_claims = 0
		_active_seconds = 0.0
	if _active_seconds >= 1800.0 and play_reward_claims < 2:
		_active_seconds -= 1800.0
		play_reward_claims += 1
		add_xp(25)
		toast(Loc.t("play_gift"), "good")
		save_game()
	live_tick.emit()


func begin_negotiation() -> void:
	_negotiation_depth += 1
	_customer_tick_at = now_seconds()


func end_negotiation() -> void:
	_negotiation_depth = maxi(0, _negotiation_depth - 1)
	_next_visit_at = maxf(_next_visit_at, now_seconds() + 5.0)


func process_live_customers() -> void:
	if shop_closed():
		var paused: float = maxf(0.0,now_seconds()-_customer_tick_at) if _customer_tick_at>0 else 0.0
		for visitor in visits: visitor["expires_at"] = float(visitor.get("expires_at",now_seconds()))+paused
		_customer_tick_at = now_seconds()
		return
	var now: float = now_seconds()
	var elapsed: float = maxf(0.0, now - _customer_tick_at) if _customer_tick_at > 0.0 else 0.0
	_customer_tick_at = now
	if _negotiation_depth > 0:
		for pending in visits:
			if not bool(pending.get("accepted", false)):
				pending["expires_at"] = float(pending.get("expires_at", now + VISITOR_WAIT_SECONDS)) + elapsed
		_next_visit_at = maxf(_next_visit_at, now + 5.0)
		return
	var dirty: bool = false
	for v in visits.duplicate():
		if not bool(v.get("accepted", false)) and now >= float(v.get("expires_at", now + VISITOR_WAIT_SECONDS)):
			visits.erase(v)
			rep = maxi(0, rep - 1)
			toast(Loc.t("visitor_missed", [str(v["name"])]), "bad")
			dirty = true
	if now >= _next_visit_at and visits.size() < 5:
		var candidate: Dictionary = {}
		var earliest: float = INF
		for car in cars:
			if not bool(car.get("listed", false)):
				continue
			var has_visit: bool = false
			for v in visits:
				if int(v["car_uid"]) == int(car["uid"]):
					has_visit = true
			if not car.has("next_customer_at"):
				car["next_customer_at"] = now + rng.randf_range(20.0, 30.0)
			var due: float = float(car["next_customer_at"])
			if not has_visit and due <= now and due < earliest:
				candidate = car
				earliest = due
		if not candidate.is_empty():
			var delay: float = rng.randf_range(20.0, 30.0)
			candidate["next_customer_at"] = now + delay
			_next_visit_at = now + 2.0
			var ratio: float = float(candidate["list_price"]) / maxf(car_value(candidate), 1.0)
			# Fair listings get a real inquiry every 20â€“30 seconds. Overpriced listings lose demand.
			var chance: float = clampf(demand_factor(ratio) * demand_mult(), 0.12, 0.95)
			if boost_seconds_left(candidate) > 0: chance = minf(0.98, chance * 1.6)
			if ratio <= 1.15 or rng.randf() < chance:
				candidate["first_inquiry"] = false
				candidate["had_inquiry"] = true
				candidate["last_inquiry_at"] = now
				_make_visit(candidate)
			dirty = true
	if dirty:
		save_game()
		changed.emit()


func accept_visit(v: Dictionary) -> bool:
	if not visits.has(v):
		return false
	if not bool(v.get("accepted", false)) and now_seconds() >= float(v.get("expires_at", 0.0)):
		process_live_customers()
		return false
	v["accepted"] = true
	save_game()
	return true


func training_skip_cost(seconds: int, gems: bool) -> int:
	if active_training.is_empty():
		return 0
	var span := mini(seconds, training_seconds_left())
	var tier := int(active_training["level"])
	if gems:
		return maxi(1, int(ceil(span / 300.0)) + tier)
	return maxi(1000, int(ceil(span / 900.0 * (18000 + tier * 12000) / 1000.0)) * 1000)


func skip_training(seconds: int, gems: bool) -> bool:
	if active_training.is_empty() or seconds <= 0:
		return false
	_check_training()
	if active_training.is_empty():
		return false
	var cost := training_skip_cost(seconds, gems)
	if (diamonds if gems else money) < cost:
		toast(Loc.t("err_gems" if gems else "err_no_money"), "bad")
		return false
	if gems:
		diamonds -= cost
	else:
		money -= cost
	active_training["finish_at"] = float(active_training["finish_at"]) - seconds
	_check_training()
	save_game()
	changed.emit()
	return true


func daily_reward(tier: int) -> Dictionary:
	var index := clampi(tier, 1, 7) - 1
	return {"money": int([2000,2500,3500,4500,6000,8000,12000][index]), "diamonds": int([1,1,2,1,2,2,3][index]), "xp": int([15,20,25,30,35,40,60][index]), "car": tier == 7}

func claim_daily() -> Dictionary:
	var today := real_date()
	if daily_date == today:
		return {}
	var yesterday := Time.get_date_string_from_unix_time(Time.get_unix_time_from_datetime_dict(Time.get_datetime_dict_from_system()) - 86400)
	daily_streak = daily_streak % 7 + 1 if daily_date == yesterday else 1
	daily_date = today
	var reward := daily_reward(daily_streak)
	money += int(reward["money"])
	diamonds += int(reward["diamonds"])
	add_xp(int(reward["xp"]))
	if bool(reward["car"]):
		var car := gen_car("karya_pico", 65.0, 85.0)
		car["bought_price"] = car_value(car)
		if cars.size() < garage_cap:
			cars.append(car)
			reward["car_where"] = "garage"
		elif storage.size() < STORAGE_CAP:
			storage.append(car)
			reward["car_where"] = "storage"
		else:
			money += int(car_value(car) * 0.8)
			reward["car_where"] = "cash"
	stats["crates"] = int(stats["crates"]) + 1
	save_game()
	changed.emit()
	Fx.play("crate")
	return reward


func exchange_gems() -> bool:
	if diamonds < 10:
		toast(Loc.t("err_gems"), "bad")
		return false
	diamonds -= 10
	money += 15000
	save_game()
	changed.emit()
	return true


func gem_repair_cost(car: Dictionary) -> int:
	var total := 0
	for part in PARTS:
		total += repair_cost(car, str(part))
	return maxi(3, int(ceil(total / 5000.0)))


func repair_with_gems(car: Dictionary) -> bool:
	if not cars.has(car):
		return false
	var cost := gem_repair_cost(car)
	if diamonds < cost:
		toast(Loc.t("err_gems"), "bad")
		return false
	diamonds -= cost
	for part in PARTS:
		car["parts"][part] = maxf(95.0, float(car["parts"][part]))
		car["known"][part] = true
	car["clean"] = 100.0
	DealerLife.earn("cleaner",10)
	save_game()
	changed.emit()
	return true


func listing_upgrade_cost() -> int:
	return 40000 * (listing_rank + 1) * (listing_rank + 1)


func upgrade_listings() -> bool:
	if listing_rank >= 5 or level < 2 + listing_rank * 4 or money < listing_upgrade_cost():
		toast(Loc.t("upgrade_locked"), "bad")
		return false
	money -= listing_upgrade_cost()
	listing_rank += 1
	save_game()
	changed.emit()
	return true


func refresh_used_market() -> bool:
	var cost := 3000 + level * 500
	if money < cost:
		toast(Loc.t("err_no_money"), "bad")
		return false
	money -= cost
	market.clear()
	refresh_market()
	save_game()
	changed.emit()
	return true


func trade_asset(id: String, amount: int, buy: bool) -> bool:
	if not finance_prices.has(id) or amount <= 0:
		return false
	var position: Dictionary = investments.get(id, {"units": 0, "cost": 0})
	var price := float(finance_prices[id])
	if buy:
		var cost := int(ceil(price * amount * 1.01))
		if money < cost:
			toast(Loc.t("err_no_money"), "bad")
			return false
		money -= cost
		position["units"] = int(position["units"]) + amount
		position["cost"] = int(position["cost"]) + cost
	else:
		if int(position["units"]) < amount:
			toast(Loc.t("no_asset"), "bad")
			return false
		var basis := int(round(float(position["cost"]) * amount / int(position["units"])))
		var realized := int(floor(price * amount * 0.99)) - basis
		monthly_profit += realized
		flags["investment_realized"] = int(flags.get("investment_realized", 0)) + realized
		position["cost"] = maxi(0, int(position["cost"]) - basis)
		position["units"] = int(position["units"]) - amount
		money += int(floor(price * amount * 0.99))
	investments[id] = position
	save_game()
	changed.emit()
	return true


func open_deposit(amount: int, term: int) -> bool:
	if amount < 10000 or term not in [7, 14, 30] or money < amount or deposits.size() >= 3:
		toast(Loc.t("deposit_error"), "bad")
		return false
	money -= amount
	deposits.append({"id": next_uid(), "amount": amount, "due": day + term, "term": term, "interest": int(amount * 0.004 * term)})
	save_game()
	changed.emit()
	return true


func withdraw_deposit(id: int) -> bool:
	for d in deposits:
		if int(d["id"]) == id:
			money += int(d["amount"]) if day >= int(d["due"]) else int(int(d["amount"]) * 0.99)
			deposits.erase(d)
			save_game()
			changed.emit()
			return true
	return false


func process_finance_day() -> void:
	for id in finance_prices.keys():
		var volatility := 0.025 if id == "index" else 0.012
		finance_prices[id] = maxf(1.0, float(finance_prices[id]) * (1.0 + rng.randf_range(-volatility, volatility)))
		var history: Array = finance_history.get(id, [])
		history.append(float(finance_prices[id]))
		if history.size() > 14:
			history.pop_front()
		finance_history[id] = history
	for d in deposits.duplicate():
		if day >= int(d["due"]):
			var payout := int(d["amount"]) + int(d["interest"])
			money += payout
			monthly_profit += int(d["interest"])
			flags["investment_realized"] = int(flags.get("investment_realized", 0)) + int(d["interest"])
			deposits.erase(d)
			toast(Loc.t("deposit_paid", [Loc.money(payout)]), "good")


func process_bills() -> void:
	var items := BusinessLedger.charges(level, garage_cap, listing_rank, business_owned)
	var monthly_tax := maxi(0, int(ceil(monthly_profit * 0.12))) if day > 0 and day % 30 == 0 else 0
	var yearly_tax := int(ceil(business_price_paid * 0.015)) if day > 0 and day % 365 == 0 and business_owned else 0
	if day > 0 and day % 30 == 0:
		monthly_profit = 0
	items["monthly_tax"] = monthly_tax
	items["yearly_tax"] = yearly_tax
	var total := BusinessLedger.total(items)
	var unpaid := int(flags.get("unpaid_bills", 0))
	var paid := mini(maxi(0, money), total + unpaid)
	money -= paid
	flags["unpaid_bills"] = total + unpaid - paid
	daily_summary = items.duplicate()
	daily_summary.merge({"day": day, "total": total, "paid": paid, "unpaid": flags["unpaid_bills"]})
	bills.push_front(daily_summary.duplicate())
	if bills.size() > 14:
		bills.pop_back()
	toast(Loc.t("bills_paid", [Loc.money(paid), Loc.money(int(flags["unpaid_bills"]))]), "info")


func _exit_tree() -> void:
	save_game()


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST or what == NOTIFICATION_APPLICATION_PAUSED:
		save_game()


func business_purchase_price() -> int:
	return 450000 + garage_cap * 25000 + level * 5000

func buy_business() -> bool:
	var cost := business_purchase_price()
	if business_owned or money < cost:
		toast(Loc.t("err_no_money"), "bad")
		return false
	money -= cost
	business_owned = true
	business_price_paid = cost
	save_game()
	changed.emit()
	return true

func shop_exchange(tab: String, pack: int) -> bool:
	if pack < 0 or pack > 2 or not bankrupt_state.is_empty():
		return false
	var gem_amounts: Array = [5, 15, 40]
	var cash_costs: Array = [100000, 320000, 900000]
	var gem_costs: Array = [10, 25, 60]
	var cash_rewards: Array = [15000, 40000, 100000]
	if tab == "gems":
		var cost := int(cash_costs[pack])
		if money < cost:
			toast(Loc.t("err_no_money"), "bad")
			return false
		money -= cost
		diamonds += int(gem_amounts[pack])
	elif tab == "cash":
		if diamonds < int(gem_costs[pack]):
			toast(Loc.t("err_gems"), "bad")
			return false
		diamonds -= int(gem_costs[pack])
		money += int(cash_rewards[pack])
	else:
		return false
	save_game()
	changed.emit()
	return true

func announce_day() -> void:
	if money <= 0:
		check_bankruptcy()
	if bankrupt_state.is_empty():
		go("garage", {"summary": true})

func can_recover_cash() -> bool:
	# Lack of cash is recoverable while the player can sell, withdraw or borrow.
	if business_owned or not cars.is_empty() or not storage.is_empty() or not deposits.is_empty() or diamonds >= 10: return true
	for position in investments.values():
		if int(position.get("units",0)) > 0: return true
	if loan_block_fraction() < 0.0 and loan_room() >= 10000: return true
	if not pending_reward_levels().is_empty() or daily_date != real_date(): return true
	return false

func check_bankruptcy() -> void:
	if not started or money > 0 or not bankrupt_state.is_empty():
		return
	if can_recover_cash(): return
	bankrupt_state = {"restart_at": now_seconds() + 10.0, "sold": int(stats["sold"]), "level": level, "debt": total_debt() + int(flags.get("unpaid_bills", 0))}
	save_game()
	go("bankruptcy")

func restart_after_bankruptcy() -> void:
	var name := player_name
	var chosen_city := city
	var portrait := avatar_id
	var last_claim := daily_date
	var streak := daily_streak
	new_game(name, chosen_city)
	avatar_id = portrait
	daily_date = last_claim
	daily_streak = streak
	save_game()
	go("home")

func show_daily_summary() -> void:
	if not daily_summary.is_empty():
		go("garage", {"summary": true})


func record_cashflow() -> void:
	var delta := money - _ledger_balance
	if delta > 0:
		daily_income += delta
	else:
		daily_expenses -= delta
	_ledger_balance = money


# Street encounters are saved with the game; no timers or repayments run while offline.
func street_loan_quote() -> Dictionary:
	var amount := mini(200000, 50000 + level * 5000)
	var rate := 0.35 - rep * 0.0015
	return {"amount": amount, "debt": int(ceil(amount * (1.0 + rate))), "term": 7}

func take_street_loan() -> bool:
	if not bool(settings.get("street_events", true)) or not flags.get("street_loan", {}).is_empty(): return false
	var quote := street_loan_quote()
	money += int(quote["amount"])
	flags["street_loan"] = {"remaining": int(quote["debt"]), "due": day + 7}
	rep = maxi(0, rep - 2)
	save_game()
	changed.emit()
	return true

func repay_street_loan() -> bool:
	var loan: Dictionary = flags.get("street_loan", {})
	if loan.is_empty(): return false
	var debt := int(loan["remaining"])
	if money < debt:
		toast(Loc.t("err_no_money"), "bad")
		return false
	money -= debt
	flags["street_loan"] = {}
	save_game()
	changed.emit()
	return true

func process_street_day() -> int:
	var paid := 0
	var loan: Dictionary = flags.get("street_loan", {})
	if not loan.is_empty() and day >= int(loan["due"]):
		paid = mini(maxi(money, 0), int(loan["remaining"]))
		money -= paid
		loan["remaining"] = int(loan["remaining"]) - paid
		if int(loan["remaining"]) == 0:
			flags["street_loan"] = {}
			toast(Loc.t("street_repaid"), "good")
		else:
			loan["remaining"] = int(ceil(int(loan["remaining"]) * 1.05))
			loan["due"] = day + 1
			rep = maxi(0, rep - 5)
	return paid

func security_limit() -> int:
	return DealerExpansion.staff_limit()

func security_wages() -> int:
	return clampi(int(flags.get("security",0)),0,5)*900

func upgrade_security() -> bool:
	var rank := int(flags.get("security", 0))
	var cost := 15000 * (rank + 1)
	if rank >= security_limit() or money < cost + 900 or int(flags.get("unpaid_bills",0)) > 0: return false
	money -= cost
	flags["security"] = rank + 1
	save_game()
	changed.emit()
	return true

func resolve_theft(guard: bool) -> void:
	if not bool(flags.get("theft_pending", false)): return
	var result := "theft_stopped"
	var security: int = clampi(int(flags.get("security", 0)), 0, 5)
	if security < 5 and rng.randf() > security_protection():
		if security <= 1 and not cars.is_empty() and rng.randf() < 0.08:
			var stolen: Dictionary = cars[rng.randi_range(0, cars.size() - 1)]
			cars.erase(stolen)
			visits = visits.filter(func(v): return int(v["car_uid"]) != int(stolen["uid"]))
			toast(Loc.t("car_stolen", [CarDB.full_name(str(stolen["model"]))]), "bad")
			result = "theft_loss"
		else:
			var loss: int = mini(15000, maxi(0, int(money * 0.03)))
			money -= loss
			result = "theft_loss"
			toast(Loc.t(result, [Loc.money(loss)]), "bad")
	flags["theft_pending"] = false
	if result == "theft_stopped":
		rep = mini(100, rep + 1)
		toast(Loc.t(result), "good")
	save_game()
	changed.emit()


func customer_review(car: Dictionary, price: int) -> Dictionary:
	var health: float = 0.0
	for part in PARTS: health += float(car["parts"][part]) / 4.0
	var condition: float = health * 0.8 + float(car["clean"]) * 0.2
	var ratio: float = float(price) / maxf(1.0, car_value(car))
	var score: int = clampi(int(round(3.0 + (condition - 65.0) / 20.0 + (1.08 - ratio) * 4.0)), 1, 5)
	var key: String = "review_happy" if score >= 4 else ("review_fair" if score == 3 else "review_unhappy")
	var item: Dictionary = {"score": score, "comment": key, "model": str(car["model"]), "day": day}
	var reviews: Array = flags.get("customer_reviews", [])
	reviews.append(item)
	if reviews.size() > 20: reviews.pop_front()
	flags["customer_reviews"] = reviews
	flags["review_sum"] = int(flags.get("review_sum", 0)) + score
	flags["review_count"] = int(flags.get("review_count", 0)) + 1
	rep = clampi(rep + (1 if score >= 4 else (-2 if score <= 2 else 0)), 0, 100)
	return item

func review_average() -> String:
	var count: int = int(flags.get("review_count", 0))
	return "-" if count == 0 else "%.1f / 5 · %d" % [float(flags.get("review_sum", 0)) / count, count]

func is_night() -> bool:
	return minute < 420 or minute >= 1200

func sync_web_presence() -> void:
	if not OS.has_feature("web"): return
	var incoming: Variant = JSON.parse_string(str(JavaScriptBridge.eval("window.otoPush?.take() || '[]'", true)))
	if incoming is Array:
		for interest in incoming:
			if not interest is Dictionary: continue
			var car: Dictionary = car_by_uid(int(interest.get("uid", -1)))
			if car.is_empty() or not bool(car.get("listed", false)): continue
			var exists: bool = false
			for visitor in visits:
				if int(visitor["car_uid"]) == int(car["uid"]): exists = true
			if not exists: _make_visit(car)
	var inventory: Array = []
	for car in cars:
		if bool(car.get("listed", false)):
			inventory.append({"uid": int(car["uid"]), "name": CarDB.full_name(str(car["model"])), "fair": float(car["list_price"]) <= car_value(car) * 1.15})
	JavaScriptBridge.eval("window.otoPush?.presence(" + JSON.stringify({"listings": inventory}) + ")", true)

# Timed promotion increases visibility, never the buyer's spending limit.
func boost_seconds_left(car: Dictionary) -> int:
	return maxi(0, int(ceil(float(car.get("boost_until", 0.0)) - now_seconds())))

func boost_cost(car: Dictionary, gems: bool) -> int:
	return 3 if gems else maxi(2500, r500(car_value(car) * 0.02))

func boost_listing(car: Dictionary, gems: bool) -> bool:
	if car.is_empty() or not bool(car.get("listed", false)) or boost_seconds_left(car) > 0: return false
	var cost: int = boost_cost(car, gems)
	if (diamonds if gems else money) < cost:
		toast(Loc.t("err_no_money"), "bad")
		return false
	if gems: diamonds -= cost
	else: money -= cost
	car["boost_until"] = now_seconds() + 300.0
	save_game()
	changed.emit()
	return true

func security_protection() -> float:
	return float([0.45, 0.58, 0.70, 0.82, 0.93, 1.0][clampi(int(flags.get("security", 0)), 0, 5)])

func process_night_security() -> void:
	if not is_night() or level < 3 or cars.is_empty() or not bool(settings.get("street_events", true)): return
	if bool(flags.get("theft_pending", false)) or day < int(flags.get("next_theft_day", 0)): return
	var now: float = now_seconds()
	if now < float(flags.get("night_check_at", 0.0)): return
	flags["night_check_at"] = now + 90.0
	if rng.randf() > 0.16: return
	flags["theft_pending"] = true
	flags["next_theft_day"] = day + 1
	flags["theft_deadline"] = now + 3.0 if int(flags.get("security", 0)) > 0 else now + 45.0
	toast(Loc.t("theft_alert"), "bad")
	save_game()
	changed.emit()

func process_market_activity() -> void:
	var now: float = now_seconds()
	if not flags.has("deal_check_at"):
		flags["deal_check_at"] = now + 75.0
		return
	if _negotiation_depth > 0 or not visits.is_empty() or now < float(flags["deal_check_at"]): return
	flags["deal_check_at"] = now + rng.randf_range(240.0, 360.0)
	var deal: Dictionary = gen_listing()
	var value: int = car_value(deal["car"])
	# Never manufacture a discount that is above the estimated market value.
	if value < 115000: return
	deal["ask"] = maxi(100000, r500(value * 0.88))
	deal["reserve"] = r500(int(deal["ask"]) * 0.94)
	deal["source"] = "owner"
	deal["special_deal"] = true
	market.push_front(deal)
	if market.size() > 24: market.pop_back()
	save_game()
	changed.emit()
	market_deal_arrived.emit(int(deal["id"]))
