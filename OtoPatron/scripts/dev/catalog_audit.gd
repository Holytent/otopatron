extends Node
## Catalog expansion audit: the 54 original cars must be untouched, the new cars must fit the price and
## class bands, every car needs art and a showroom look, and saves with old and new cars must round-trip.
const LEGACY_IDS: Array = [
	"karya_pico", "orvan_dot", "aldora_kesa", "aldora_brix", "tivora_lune", "veltra_orin",
	"brenor_city", "veltra_taro", "tivora_grano", "kordan_zeph", "lavin_station", "kordan_mavo",
	"sorvik_bora", "marlen_sora", "kordan_rally", "marlen_drift", "veltra_cabra", "sorvik_hale",
	"nyvo_ion", "auren_vesta", "dalmor_rex", "marlen_gran", "auren_kyro", "nyvo_arc",
	"sorvik_ridge", "dalmor_volt", "auren_solis", "veltra_regalia", "valtorre_gt", "kordan_atlas",
	"aurelia_prestige", "nyvo_halo", "zephyra_one", "imperion_royale", "ravena_rova", "aldora_trail",
	"karya_bora", "orvan_trek", "nyvo_terra", "auren_stride", "dalmor_peak", "imperion_range",
	"brenor_cargo", "dalmor_haul", "dalmor_titan", "orvan_pulse", "valtorre_sprint", "sorvik_canyon",
	"karya_nova", "tivora_aven", "orvan_vera", "ravena_koru", "valtorre_solis", "brenor_work"
]
const LEGACY_FINGERPRINT := "a7f64d3fbe838ac4beca9df2fa91af829ee5c910d21acd076881399922478778"
const NEW_IDS: Array = ["lavin_corso", "marlen_vento", "brenor_duty"]
const BODIES: Array = ["passenger", "sport", "suv", "pickup", "truck"]
var checks: Array = []

func check(condition: bool, name: String) -> void:
	checks.append({"name": name, "passed": condition})
	print("PASS " if condition else "FAIL ", name)

func _ready() -> void:
	Game.set_process(false)
	_run.call_deferred()

func _run() -> void:
	var ids: Array = CarDB.MODELS.map(func(m): return str(m["id"]))
	check(CarDB.MODELS.size() == 57 and ids.size() == 54 + NEW_IDS.size(), "Catalog has 57 cars: 54 original and 3 new")
	var unique: Dictionary = {}
	for id in ids: unique[id] = true
	check(unique.size() == ids.size(), "Catalog ids are unique")
	check(LEGACY_IDS.size() == 54 and LEGACY_IDS.all(func(id): return ids.has(id)), "All 54 original ids are still present")
	var parts: Array = []
	for id in LEGACY_IDS: parts.append(JSON.stringify(CarDB.model(id), "", true))
	check("|".join(parts).sha256_text() == LEGACY_FINGERPRINT, "Original 54 car definitions are unchanged (id, class, body, price, level, tier, years)")
	check(NEW_IDS.all(func(id): return ids.has(id) and not LEGACY_IDS.has(id)), "The three new cars are new ids")
	check(ids.slice(54) == NEW_IDS, "New cars are appended after the original catalog")
	var shape_ok := true
	var art_ok := true
	var look_ok := true
	for model in CarDB.MODELS:
		var id := str(model["id"])
		for key in ["id", "make", "name", "cls", "body", "base", "min_level", "tier", "years"]:
			if not model.has(key): shape_ok = false
		if not CarDB.CLASS_KEYS.has(str(model["cls"])) or not BODIES.has(str(model["body"])): shape_ok = false
		if int(model["base"]) < 100000 or int(model["min_level"]) < 1 or int(model["tier"]) < 1 or int(model["tier"]) > 5: shape_ok = false
		var years: Array = model["years"]
		if years.size() != 2 or int(years[0]) >= int(years[1]) or int(years[1]) > 2025: shape_ok = false
		if CarDB.texture(id) == null: art_ok = false
		var spokes: int = CarLook.spokes(id)
		if not CarLook.has_look(id) or spokes < 5 or spokes > 7: look_ok = false
	check(shape_ok, "Every catalog entry has valid fields, class, body, tier and years")
	check(art_ok, "Every catalog car has market and close-up art")
	check(look_ok, "Every catalog car has a showroom paint and 5-7 spoke wheel look")
	for id in NEW_IDS:
		var model: Dictionary = CarDB.model(id)
		var same_class: Array = CarDB.MODELS.filter(func(m): return LEGACY_IDS.has(str(m["id"])) and str(m["cls"]) == str(model["cls"]))
		# Tiers follow price across classes (650k-950k is tier 4 for SUVs and sedans), so compare with the
		# nearest priced original car of any class.
		var nearest: Dictionary = CarDB.model(LEGACY_IDS[0])
		for legacy_id in LEGACY_IDS:
			var other: Dictionary = CarDB.model(legacy_id)
			if absi(int(other["base"]) - int(model["base"])) < absi(int(nearest["base"]) - int(model["base"])): nearest = other
		var bases: Array = same_class.map(func(m): return int(m["base"]))
		var levels: Array = same_class.map(func(m): return int(m["min_level"]))
		check(int(model["base"]) >= bases.min() and int(model["base"]) <= bases.max(), id + ": price sits inside its class range")
		check(int(model["min_level"]) >= levels.min() and int(model["min_level"]) <= levels.max(), id + ": unlock level sits inside its class range")
		check(absi(int(nearest["tier"]) - int(model["tier"])) <= 1 and absi(int(nearest["min_level"]) - int(model["min_level"])) <= 3, id + ": tier and level match the nearest priced original car")
	check(CarTurntable.kind_for("brenor_duty") == "van" and CarTurntable.kind_for("marlen_vento") == "sport" and CarTurntable.kind_for("lavin_corso") == "sedan", "New cars map to van, sport and sedan showroom bodies")
	check(CarPortrait._wheels("brenor_duty") == Vector3(147, 480, 42) and CarPortrait._wheels("lavin_corso") == Vector3(147, 480, 42) and CarPortrait._wheels("marlen_vento") == Vector3(150, 483, 42), "New art matches the dirt and damage wheel positions")
	# Pricing: same rules as the original cars.
	Game.new_game("Katalog", "34")
	Game.settings["music"] = 0.0
	Game.settings["sfx"] = 0.0
	Game.news = {"cm": {}, "dm": 1.0}
	var floors_ok := true
	for id in ids:
		var car: Dictionary = Game.gen_car(id)
		if Game.car_value(car) < 100000 + (int(CarDB.model(id)["min_level"]) - 1) * 8000: floors_ok = false
	check(floors_ok, "Every car, old and new, keeps the existing value floor")
	# Market: new cars appear only from their unlock level.
	Game.rng.seed = 5702026
	var seen_low: Dictionary = {}
	Game.level = 1
	for i in 1500: seen_low[str(Game.gen_listing()["car"]["model"])] = true
	check(NEW_IDS.all(func(id): return not seen_low.has(id)), "New cars never appear below their unlock level")
	var seen_high: Dictionary = {}
	Game.level = 30
	for i in 6000: seen_high[str(Game.gen_listing()["car"]["model"])] = true
	check(ids.all(func(id): return seen_high.has(id)), "All 57 cars can appear in the market at a high level")
	# Saves: old and new cars survive the same JSON round trip the save file uses.
	Game.new_game("Eski Kayit", "34")
	Game.settings["music"] = 0.0
	Game.settings["sfx"] = 0.0
	Game.news = {"cm": {}, "dm": 1.0}
	Game.money = 12345678
	Game.cars = []
	for id in ids:
		var car: Dictionary = Game.gen_car(id)
		car["uid"] = Game.next_uid()
		Game.cars.append(car)
	var before_values: Dictionary = {}
	for car in Game.cars: before_values[str(car["model"])] = Game.car_value(car)
	var saved: Dictionary = JSON.parse_string(JSON.stringify(Game.to_dict()))
	check(int(saved["version"]) == 7 and Game.SAVE_VERSION == 7, "Save format version is still 7")
	Game.from_dict(saved)
	var after_values: Dictionary = {}
	for car in Game.cars: after_values[str(car["model"])] = Game.car_value(car)
	check(Game.cars.size() == 57 and Game.money == 12345678, "Save round trip keeps 57 cars and the balance")
	check(before_values == after_values, "Save round trip keeps every car model and value, old and new")
	var legacy_only: Dictionary = saved.duplicate(true)
	legacy_only["cars"] = legacy_only["cars"].filter(func(c): return LEGACY_IDS.has(str(c["model"])))
	Game.from_dict(legacy_only)
	check(Game.cars.size() == 54 and Game.cars.all(func(c): return LEGACY_IDS.has(str(c["model"])) and CarLook.has_look(str(c["model"]))), "A save holding only the original 54 cars loads unchanged")
	var failures: int = checks.filter(func(item): return not item["passed"]).size()
	print("CATALOG_AUDIT_COMPLETE ", checks.size(), " checks; ", failures, " failures")
	get_tree().quit(1 if failures > 0 else 0)
