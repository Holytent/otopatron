class_name CarDB
extends RefCounted
## Özgün (kurgusal) marka ve model kayıtları. Gerçek markalarla ilgisi yoktur.
## base: 2022 model, ~60.000 km, kusursuz kondisyondaki referans piyasa değeri (₺).
## min_level: aracın pazarda görünmeye başladığı seviye. tier 5 = lüks segment.

const PARTS: Array = ["engine", "body", "tires", "interior"]

const MODELS: Array = [
	{"id": "karya_pico", "body": "passenger", "make": "Karya", "name": "Pico", "cls": "eco", "base": 165000, "min_level": 1, "tier": 1, "years": [2008, 2022]},
	{"id": "orvan_dot", "body": "passenger", "make": "Orvan", "name": "Dot", "cls": "eco", "base": 180000, "min_level": 1, "tier": 1, "years": [2009, 2022]},
	{"id": "aldora_kesa", "body": "passenger", "make": "Aldora", "name": "Kesa", "cls": "eco", "base": 172000, "min_level": 1, "tier": 1, "years": [2008, 2022]},
	{"id": "aldora_brix", "body": "passenger", "make": "Aldora", "name": "Brix", "cls": "eco", "base": 200000, "min_level": 1, "tier": 1, "years": [2009, 2023]},
	{"id": "tivora_lune", "body": "passenger", "make": "Tivora", "name": "Lune", "cls": "eco", "base": 220000, "min_level": 1, "tier": 1, "years": [2010, 2023]},
	{"id": "veltra_orin", "body": "passenger", "make": "Veltra", "name": "Orin", "cls": "eco", "base": 245000, "min_level": 1, "tier": 1, "years": [2010, 2023]},
	{"id": "brenor_city", "body": "passenger", "make": "Brenor", "name": "City", "cls": "eco", "base": 170000, "min_level": 2, "tier": 2, "years": [2011, 2024]},
	{"id": "veltra_taro", "body": "passenger", "make": "Veltra", "name": "Taro", "cls": "mid", "base": 190000, "min_level": 2, "tier": 2, "years": [2010, 2024]},
	{"id": "tivora_grano", "body": "pickup", "make": "Tivora", "name": "Grano", "cls": "com", "base": 210000, "min_level": 2, "tier": 2, "years": [2009, 2024]},
	{"id": "kordan_zeph", "body": "suv", "make": "Kordan", "name": "Zeph", "cls": "suv", "base": 230000, "min_level": 3, "tier": 2, "years": [2012, 2024]},
	{"id": "lavin_station", "body": "passenger", "make": "Lavin", "name": "Station", "cls": "mid", "base": 245000, "min_level": 3, "tier": 2, "years": [2011, 2024]},
	{"id": "kordan_mavo", "body": "passenger", "make": "Kordan", "name": "Mavo", "cls": "mid", "base": 260000, "min_level": 3, "tier": 2, "years": [2011, 2024]},
	{"id": "sorvik_bora", "body": "pickup", "make": "Sorvik", "name": "Bora", "cls": "com", "base": 280000, "min_level": 3, "tier": 2, "years": [2010, 2024]},
	{"id": "marlen_sora", "body": "passenger", "make": "Marlen", "name": "Sora", "cls": "mid", "base": 340000, "min_level": 4, "tier": 3, "years": [2012, 2025]},
	{"id": "kordan_rally", "body": "suv", "make": "Kordan", "name": "Rally", "cls": "suv", "base": 380000, "min_level": 4, "tier": 3, "years": [2012, 2025]},
	{"id": "marlen_drift", "body": "sport", "make": "Marlen", "name": "Drift", "cls": "sport", "base": 400000, "min_level": 5, "tier": 3, "years": [2012, 2025]},
	{"id": "veltra_cabra", "body": "sport", "make": "Veltra", "name": "Cabra", "cls": "sport", "base": 420000, "min_level": 6, "tier": 3, "years": [2013, 2025]},
	{"id": "sorvik_hale", "body": "suv", "make": "Sorvik", "name": "Hale", "cls": "suv", "base": 430000, "min_level": 5, "tier": 3, "years": [2012, 2025]},
	{"id": "nyvo_ion", "body": "passenger", "make": "Nyvo", "name": "Ion", "cls": "ev", "base": 480000, "min_level": 6, "tier": 3, "years": [2018, 2025]},
	{"id": "auren_vesta", "body": "passenger", "make": "Auren", "name": "Vesta", "cls": "lux", "base": 650000, "min_level": 7, "tier": 4, "years": [2012, 2025]},
	{"id": "dalmor_rex", "body": "pickup", "make": "Dalmor", "name": "Rex", "cls": "com", "base": 700000, "min_level": 8, "tier": 4, "years": [2013, 2025]},
	{"id": "marlen_gran", "body": "passenger", "make": "Marlen", "name": "Gran", "cls": "mid", "base": 750000, "min_level": 8, "tier": 4, "years": [2013, 2025]},
	{"id": "auren_kyro", "body": "suv", "make": "Auren", "name": "Kyro", "cls": "lux", "base": 820000, "min_level": 9, "tier": 4, "years": [2013, 2025]},
	{"id": "nyvo_arc", "body": "passenger", "make": "Nyvo", "name": "Arc", "cls": "ev", "base": 900000, "min_level": 10, "tier": 4, "years": [2019, 2025]},
	{"id": "sorvik_ridge", "body": "suv", "make": "Sorvik", "name": "Ridge", "cls": "suv", "base": 950000, "min_level": 10, "tier": 4, "years": [2014, 2025]},
	{"id": "dalmor_volt", "body": "sport", "make": "Dalmor", "name": "Volt", "cls": "sport", "base": 1100000, "min_level": 11, "tier": 4, "years": [2015, 2025]},
	{"id": "auren_solis", "body": "sport", "make": "Auren", "name": "Solis", "cls": "lux", "base": 1500000, "min_level": 12, "tier": 5, "years": [2015, 2025]},
	{"id": "veltra_regalia", "body": "passenger", "make": "Veltra", "name": "Regalia", "cls": "lux", "base": 1800000, "min_level": 14, "tier": 5, "years": [2016, 2025]},
	{"id": "valtorre_gt", "body": "sport", "make": "Valtorre", "name": "GT", "cls": "sport", "base": 2400000, "min_level": 16, "tier": 5, "years": [2016, 2025]},
	{"id": "kordan_atlas", "body": "suv", "make": "Kordan", "name": "Atlas", "cls": "lux", "base": 2600000, "min_level": 17, "tier": 5, "years": [2016, 2025]},
	{"id": "aurelia_prestige", "body": "passenger", "make": "Aurelia", "name": "Prestige", "cls": "lux", "base": 2800000, "min_level": 18, "tier": 5, "years": [2017, 2025]},
	{"id": "nyvo_halo", "body": "passenger", "make": "Nyvo", "name": "Halo", "cls": "ev", "base": 3000000, "min_level": 20, "tier": 5, "years": [2020, 2025]},
	{"id": "zephyra_one", "body": "sport", "make": "Zephyra", "name": "One", "cls": "sport", "base": 3500000, "min_level": 22, "tier": 5, "years": [2018, 2025]},
	{"id": "imperion_royale", "body": "passenger", "make": "Imperion", "name": "Royale", "cls": "lux", "base": 4500000, "min_level": 25, "tier": 5, "years": [2018, 2025]},
	{"id": "ravena_rova", "body": "suv", "make": "Ravena", "name": "Rova", "cls": "suv", "base": 175000, "min_level": 1, "tier": 1, "years": [2010, 2025]},
	{"id": "aldora_trail", "body": "suv", "make": "Aldora", "name": "Trail", "cls": "suv", "base": 150000, "min_level": 2, "tier": 2, "years": [2010, 2025]},
	{"id": "karya_bora", "body": "suv", "make": "Karya", "name": "Bora", "cls": "suv", "base": 240000, "min_level": 4, "tier": 2, "years": [2010, 2025]},
	{"id": "orvan_trek", "body": "suv", "make": "Orvan", "name": "Trek", "cls": "suv", "base": 360000, "min_level": 5, "tier": 3, "years": [2010, 2025]},
	{"id": "nyvo_terra", "body": "suv", "make": "Nyvo", "name": "Terra", "cls": "suv", "base": 700000, "min_level": 8, "tier": 4, "years": [2010, 2025]},
	{"id": "auren_stride", "body": "suv", "make": "Auren", "name": "Stride", "cls": "suv", "base": 1350000, "min_level": 12, "tier": 5, "years": [2010, 2025]},
	{"id": "dalmor_peak", "body": "suv", "make": "Dalmor", "name": "Peak", "cls": "suv", "base": 2200000, "min_level": 18, "tier": 5, "years": [2010, 2025]},
	{"id": "imperion_range", "body": "suv", "make": "Imperion", "name": "Range", "cls": "suv", "base": 4200000, "min_level": 27, "tier": 5, "years": [2010, 2025]},
	{"id": "brenor_cargo", "body": "pickup", "make": "Brenor", "name": "Cargo", "cls": "com", "base": 180000, "min_level": 2, "tier": 1, "years": [2016, 2025]},
	{"id": "dalmor_haul", "body": "truck", "make": "Dalmor", "name": "Haul", "cls": "com", "base": 650000, "min_level": 8, "tier": 3, "years": [2016, 2025]},
	{"id": "dalmor_titan", "body": "truck", "make": "Dalmor", "name": "Titan", "cls": "com", "base": 1600000, "min_level": 15, "tier": 4, "years": [2016, 2025]},
	{"id": "orvan_pulse", "body": "passenger", "make": "Orvan", "name": "Pulse", "cls": "mid", "base": 210000, "min_level": 3, "tier": 1, "years": [2016, 2025]},
	{"id": "valtorre_sprint", "body": "sport", "make": "Valtorre", "name": "Sprint", "cls": "sport", "base": 490000, "min_level": 6, "tier": 2, "years": [2016, 2025]},
	{"id": "sorvik_canyon", "body": "pickup", "make": "Sorvik", "name": "Canyon", "cls": "com", "base": 1750000, "min_level": 10, "tier": 3, "years": [2016, 2025]},
	{"id": "karya_nova", "make": "Karya", "name": "Nova", "cls": "eco", "body": "passenger", "base": 195000, "min_level": 1, "tier": 1, "years": [2015, 2025]},
	{"id": "tivora_aven", "make": "Tivora", "name": "Aven", "cls": "mid", "body": "passenger", "base": 390000, "min_level": 4, "tier": 3, "years": [2015, 2025]},
	{"id": "orvan_vera", "make": "Orvan", "name": "Vera", "cls": "mid", "body": "passenger", "base": 550000, "min_level": 6, "tier": 3, "years": [2015, 2025]},
	{"id": "ravena_koru", "make": "Ravena", "name": "Koru", "cls": "suv", "body": "suv", "base": 650000, "min_level": 7, "tier": 4, "years": [2015, 2025]},
	{"id": "valtorre_solis", "make": "Valtorre", "name": "Solis", "cls": "sport", "body": "sport", "base": 1350000, "min_level": 12, "tier": 5, "years": [2015, 2025]},
	{"id": "brenor_work", "make": "Brenor", "name": "Work", "cls": "com", "body": "pickup", "base": 320000, "min_level": 3, "tier": 2, "years": [2015, 2025]},
]

const CLASS_KEYS: Array = ["eco", "mid", "suv", "com", "sport", "ev", "lux"]

static var _by_id: Dictionary = {}


static func model(id: String) -> Dictionary:
	if _by_id.is_empty():
		for m in MODELS:
			_by_id[m["id"]] = m
	return _by_id.get(id, {})


static func full_name(id: String) -> String:
	var m: Dictionary = model(id)
	return "%s %s" % [m.get("make", "?"), m.get("name", "?")]


static var _texture_cache: Dictionary = {}
static var _texture_order: Array[String] = []
static func texture(id: String) -> Texture2D:
	if _texture_cache.has(id):
		_texture_order.erase(id)
		_texture_order.append(id)
		return _texture_cache[id]
	var p := "res://art/cars/%s.svg" % id
	if ResourceLoader.exists(p):
		var image: Texture2D = load(p)
		_texture_cache[id] = image
		_texture_order.append(id)
		while _texture_order.size() > 8:
			_texture_cache.erase(_texture_order.pop_front())
		return image
	return null

static func body_type(id: String) -> String:
	return str(model(id).get("body", "passenger"))
