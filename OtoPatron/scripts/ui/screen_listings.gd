extends ScreenBase
var _signature: String = ""
var _boost_labels: Array = []

func _ready() -> void:
	super._ready()
	Game.live_tick.connect(_tick)

func _build() -> void:
	_boost_labels.clear()
	_signature = str(Game.visits) + str(Game.listing_rank) + str(Game.cars)
	UI.header(self, Loc.t("my_listings"), "garage")
	var sc := UI.scroll_area(self)
	var listed: Array = Game.cars.filter(func(car): return bool(car.get("listed", false)))
	listed.sort_custom(func(a, b): return _waiting(int(a["uid"])).size() > _waiting(int(b["uid"])).size())
	var summary := UI.add_card(sc, UI.C_PANEL2)
	var stats := UI.hbox(summary, 14)
	stats.add_child(UI.lbl(Loc.t("sales_active", [listed.size()]), 18, UI.C_TEXT, -1, true))
	stats.add_child(UI.lbl(Loc.t("sales_waiting", [Game.visits.size()]), 14, UI.C_GOOD, HORIZONTAL_ALIGNMENT_RIGHT, true))
	for car in listed:
		var uid: int = int(car["uid"])
		var c := UI.add_card(sc)
		var pending: Dictionary = _waiting(uid)
		c.add_child(UI.pill(Loc.t("buyer_waiting") if not pending.is_empty() else Loc.t("listing_live"), UI.C_GOOD if not pending.is_empty() else UI.C_MUTED))
		c.add_child(UI.car_image(str(car["model"]), 110, car))
		c.add_child(UI.lbl(str(car.get("listing_title", CarDB.full_name(str(car["model"])))), 19, UI.C_TEXT, -1, true))
		UI.kv(c, Loc.t("asking"), Loc.money(int(car["list_price"])), UI.C_TEXT)
		var margin: int = int(car["list_price"]) - int(car["bought_price"]) - int(car["invested"])
		UI.kv(c, Loc.t("sales_estimate"), Loc.money(margin), UI.C_GOOD if margin >= 0 else UI.C_BAD)
		if not pending.is_empty():
			c.add_child(UI.btn_icon("phone", Loc.t("btn_talk") + " · " + str(pending["name"]), "primary", func(): Game.go("garage", {"open": int(pending["id"])}), 48))
		var boost_label := UI.lbl("", 13, UI.C_ACCENT)
		c.add_child(boost_label)
		_boost_labels.append({"label": boost_label, "car": car})
		var actions := UI.hbox(c, 8)
		actions.add_child(UI.btn(Loc.t("manage_listing"), "chip", func(): Game.go("car", {"uid": uid}), 44))
		var promote := UI.btn(Loc.t("boost_title"), "ghost", func(): _boost_dialog(car), 44)
		promote.disabled = Game.boost_seconds_left(car) > 0
		actions.add_child(promote)
	if listed.is_empty():
		var empty := UI.add_card(sc)
		empty.add_child(Ico.new("market", UI.C_ACCENT, 42))
		empty.add_child(UI.lbl(Loc.t("empty_listings"), 16, UI.C_MUTED))
		empty.add_child(UI.btn(Loc.t("nav_garage"), "primary", func(): Game.go("garage")))
	var development := UI.add_card(sc, UI.C_PANEL2)
	UI.kv(development, Loc.t("listing_development"), "%d / 5" % Game.listing_rank)
	if Game.listing_rank < 5:
		development.add_child(UI.lbl(Loc.t("course_unlock") + ": " + Loc.t("lvl_short", [2 + Game.listing_rank * 4]), 12, UI.C_MUTED))
		development.add_child(UI.btn(Loc.t("upgrade_listing") + " · " + Loc.money(Game.listing_upgrade_cost()), "ghost", _upgrade_dialog, 44))
	_update_boosts()

func _waiting(uid: int) -> Dictionary:
	for visit in Game.visits:
		if int(visit["car_uid"]) == uid: return visit
	return {}

func _boost_dialog(car: Dictionary) -> void:
	var panel := UI.dialog_card(Loc.t("boost_title"))
	panel.add_child(UI.lbl(Loc.t("boost_body"), 15, UI.C_MUTED))
	var root := UI.show_dialog(panel)
	for gems in [false, true]:
		var cost: int = Game.boost_cost(car, gems)
		panel.add_child(UI.btn(("%d ♦" % cost if gems else Loc.money(cost)) + " · " + Loc.t("boost_confirm"), "primary", func():
			if Game.boost_listing(car, gems):
				root.queue_free()
				rebuild(), 48))
	panel.add_child(UI.btn(Loc.t("cancel"), "ghost", func(): root.queue_free()))

func _upgrade_dialog() -> void:
	var panel := UI.dialog_card(Loc.t("listing_development"))
	panel.add_child(UI.lbl(Loc.money(Game.listing_upgrade_cost()), 22, UI.C_TEXT, -1, true))
	var root := UI.show_dialog(panel)
	panel.add_child(UI.btn(Loc.t("ok"), "primary", func():
		Game.upgrade_listings()
		root.queue_free()
		rebuild()))
	panel.add_child(UI.btn(Loc.t("cancel"), "ghost", func(): root.queue_free()))

func _update_boosts() -> void:
	for entry in _boost_labels:
		var left: int = Game.boost_seconds_left(entry["car"])
		var label: Label = entry["label"]
		label.text = Loc.t("boost_remaining", ["%02d:%02d" % [left / 60, left % 60]]) if left > 0 else ""
		label.visible = left > 0

func _tick() -> void:
	if _signature != str(Game.visits) + str(Game.listing_rank) + str(Game.cars): rebuild()
	else: _update_boosts()
