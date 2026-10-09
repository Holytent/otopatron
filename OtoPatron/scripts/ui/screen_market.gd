extends ScreenBase
## Araç Pazarı: günlük yenilenen satıcı ilanları.


var _rare_labels: Array = []
func _ready() -> void:
	super._ready()
	Game.live_tick.connect(_update_rare)
func _update_rare() -> void:
	for item in _rare_labels:
		if not is_instance_valid(item["label"]): continue
		if not DealerExpansion.listing_alive(item["listing"]):
			rebuild()
			return
		item["label"].text = Loc.t("rare_time", [int(ceil(DealerExpansion.rare_seconds(item["listing"])/60.0))])

var _search: String = ""
var _sort: String = "price"
var _source: String = "all"
var _filter: String = "all"

func _build() -> void:
	_rare_labels.clear()
	UI.header(self, Loc.t("market_title"), "home")
	add_child(UI.lbl(Loc.t("market_sub", [Game.market.size()]), 14, UI.C_MUTED))
	DealerExpansion.ensure_rare()
	var sc := UI.scroll_area(self)
	sc.add_child(UI.btn(Loc.t("life_auction"),"primary",func(): Game.go("auction"),48))
	for kind in ["rescue","rival"]:
		var destination: String = kind
		sc.add_child(UI.btn(Loc.t("play_"+kind),"ghost",func(): Game.go("gameplay",{"kind":destination}),46))
	var trend_card := UI.add_card(sc)
	trend_card.add_child(UI.lbl(Loc.t("trend_title"), 18, UI.C_TEXT, -1, true))
	trend_card.add_child(UI.lbl(Loc.t("trend_info", [Loc.t("market_"+DealerExpansion.trend())]), 14, UI.C_MUTED))
	var search := LineEdit.new()
	search.placeholder_text = Loc.t("market_search")
	search.text = _search
	search.custom_minimum_size.y = 44
	search.text_submitted.connect(func(value: String):
		_search = value.strip_edges().to_lower()
		rebuild())
	sc.add_child(search)
	var controls := UI.hbox(sc, 8)
	controls.add_child(UI.btn_icon("market", Loc.t("market_" + _filter) + " · " + Loc.t("market_filters"), "chip", _filter_dialog, 46))
	controls.add_child(UI.btn(Loc.t("sort_" + _sort), "ghost", func():
		_sort = "deal" if _sort == "price" else ("year" if _sort == "deal" else "price")
		rebuild(), 46))
	var count := 0
	var listings := Game.market.duplicate()
	listings.sort_custom(func(a, b):
		if _sort == "year": return int(a["car"]["year"]) > int(b["car"]["year"])
		if _sort == "deal": return float(a["ask"]) / Game.car_value(a["car"]) < float(b["ask"]) / Game.car_value(b["car"])
		return int(a["ask"]) < int(b["ask"]))
	for l in listings:
		if not DealerExpansion.listing_alive(l): continue
		if not _search.is_empty() and not CarDB.full_name(str(l["car"]["model"])).to_lower().contains(_search): continue
		var source := str(l.get("source", "owner"))
		if (_source == "all" or source == _source) and (_filter == "all" or CarDB.body_type(str(l["car"]["model"])) == _filter):
			count += 1
			_card(sc, l)
	if count == 0:
		sc.add_child(UI.lbl(Loc.t("category_empty"), 15, UI.C_MUTED))
	sc.add_child(UI.btn(Loc.t("refresh_market", [Loc.money(3000 + Game.level * 500)]), "ghost", func():
		Game.refresh_used_market()
		rebuild(), 46))
	UI.spacer(sc, 6)


func _card(parent: Node, l: Dictionary) -> void:
	var car: Dictionary = l["car"]
	var m := CarDB.model(str(car["model"]))
	var c := UI.add_card(parent)
	c.add_child(UI.pill(Loc.t("market_" + str(l.get("source", "owner"))), UI.C_ACCENT))
	c.add_child(UI.car_image(str(car["model"]), 130, car))
	if l.has("rare_until"):
		c.add_child(UI.pill(Loc.t("rare_title"), UI.C_GOLD))
		var timer := UI.lbl(Loc.t("rare_time", [int(ceil(DealerExpansion.rare_seconds(l)/60.0))]), 13, UI.C_MUTED)
		c.add_child(timer)
		_rare_labels.append({"label":timer,"listing":l})
	if bool(l.get("special_deal", false)): c.add_child(UI.pill(Loc.t("deal_alert_title"), UI.C_GOOD))
	if int(l["ask"]) < Game.car_value(car) * 0.96:
		c.add_child(UI.pill(Loc.t("deal_badge"), UI.C_GOOD))
	var t := UI.hbox(c, 8)
	t.add_child(UI.lbl(CarDB.full_name(str(car["model"])), 19, UI.C_TEXT, -1, true, false))
	t.add_child(UI.pill(Loc.t("cls_%s" % m["cls"]), UI.C_BLUE))
	var info := UI.hbox(c, 8)
	info.add_child(UI.lbl("%d  •  %s km" % [int(car["year"]), Loc.num(int(car["km"]))], 14, UI.C_MUTED))
	var r := Game.est_range(car)
	UI.kv(c, Loc.t("est_value"), "%s – %s" % [Loc.money(r[0]), Loc.money(r[1])], UI.C_MUTED)
	UI.kv(c, Loc.t("asking"), Loc.money(int(l["ask"])), UI.C_GOLD)
	var id: int = int(l["id"])
	c.add_child(UI.btn(Loc.t("btn_inspect_open"), "primary", func(): Game.go("listing", {"id": id}), 50))


func _filter_dialog() -> void:
	var panel := UI.dialog_card(Loc.t("market_filters"))
	var root := UI.show_dialog(panel)
	for category in ["all", "passenger", "sport", "suv", "pickup", "truck"]:
		var key: String = category
		panel.add_child(UI.btn(Loc.t("market_" + key), "primary" if _filter == key else "chip", func():
			_filter = key
			root.queue_free()
			rebuild(), 44))
	for source in ["all", "owner", "dealer"]:
		var key: String = source
		panel.add_child(UI.btn(Loc.t("market_" + key), "ghost", func():
			_source = key
			root.queue_free()
			rebuild(), 42))
	panel.add_child(UI.btn(Loc.t("cancel"), "chip", func(): root.queue_free()))
