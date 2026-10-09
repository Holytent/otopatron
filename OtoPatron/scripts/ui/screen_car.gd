extends ScreenBase
## Galerideki araç: ekspertiz, hazırlık (tamir/temizlik), fiyat ve ilan yönetimi.

var _page_scroll: ScrollContainer
var _draft_title: String = ""
var _draft_description: String = ""
var _has_draft: bool = false
var _car: Dictionary = {}
var _price: int = 0
var _price_lbl: SpinBox
var _title_input: LineEdit
var _description_input: TextEdit


func _build() -> void:
	_car = Game.car_by_uid(int(params.get("uid", -1)))
	UI.header(self, Loc.t("car_title"), "garage")
	if _car.is_empty():
		add_child(UI.lbl(Loc.t("listing_gone"), 17, UI.C_MUTED, HORIZONTAL_ALIGNMENT_CENTER))
		return
	if _price <= 0:
		_price = int(_car["list_price"]) if bool(_car["listed"]) else Game.suggested_price(_car)
	var m := CarDB.model(str(_car["model"]))
	var sc := UI.scroll_area(self)
	sc.add_child(UI.btn(Loc.t("life_parking_outside" if bool(_car.get("outdoors",false)) else "life_parking_inside"),"ghost",func():
		_car["outdoors"]=not bool(_car.get("outdoors",false))
		Game.save_game()
		rebuild(),44))
	_page_scroll = sc.get_parent() as ScrollContainer
	var c := UI.add_card(sc)
	c.add_child(UI.car_image(str(_car["model"]), 140, _car))
	c.add_child(UI.btn(Loc.t("closeup_title"), "ghost", func(): Game.go("car_closeup", {"uid": int(_car["uid"])}), 44))
	var t := UI.hbox(c, 8)
	t.add_child(UI.lbl(CarDB.full_name(str(_car["model"])), 21, UI.C_TEXT, -1, true, false))
	t.add_child(UI.pill(Loc.t("cls_%s" % m["cls"]), UI.C_BLUE))
	UI.kv(c, Loc.t("year_km"), "%d • %s km" % [int(_car["year"]), Loc.num(int(_car["km"]))])
	var r := Game.est_range(_car)
	UI.kv(c, Loc.t("est_value"), "%s – %s" % [Loc.money(r[0]), Loc.money(r[1])], UI.C_MUTED)
	UI.kv(c, Loc.t("sale_bought"), Loc.money(int(_car["bought_price"])), UI.C_MUTED)
	UI.kv(c, Loc.t("sale_expenses"), Loc.money(int(_car["invested"])), UI.C_MUTED)
	var expected: int = Game.suggested_price(_car) - int(_car["bought_price"]) - int(_car["invested"])
	UI.kv(c, Loc.t("deal_margin_label"), Loc.money(expected), UI.C_GOOD if expected >= 0 else UI.C_BAD)
	if bool(params.get("fresh", false)):
		c.add_child(UI.lbl(Loc.t("next_step_prep"), 14, UI.C_ACCENT))

	# Ekspertiz + onarım
	var pc := UI.add_card(sc)
	pc.add_child(UI.lbl(Loc.t("prep_title"), 18, UI.C_ACCENT, -1, true))
	pc.add_child(UI.lbl(Loc.t("prep_hint"), 13, UI.C_MUTED))
	for p in Game.PARTS:
		var part: String = p
		var row := UI.hbox(pc, 8)
		var col := UI.vbox(row, 0)
		col.add_child(UI.lbl(Loc.t("part_%s" % part), 16, UI.C_TEXT, -1, true, false))
		if bool(_car["known"].get(part, false)):
			var v := float(_car["parts"][part])
			var st := Game.part_state(v)
			var sc_col := UI.C_GOOD if st == "good" else (UI.C_ACCENT if st == "mid" else UI.C_BAD)
			col.add_child(UI.lbl("%s • %d/100" % [Loc.t("state_%s" % st), int(v)], 13, sc_col, -1, false, false))
			var cost := Game.repair_cost(_car, part)
			if cost > 0:
				var b := UI.btn(Loc.t("btn_repair", [Loc.money(cost)]), "chip", func():
					if Game.repair_part(_car, part):
						rebuild(), 44)
				b.size_flags_horizontal = Control.SIZE_SHRINK_END
				row.add_child(b)
			else:
				var ok := Ico.new("check", UI.C_GOOD, 26)
				row.add_child(ok)
		else:
			col.add_child(UI.lbl(Loc.t("state_unknown"), 13, UI.C_MUTED, -1, false, false))
			var b2 := UI.btn(Loc.t("btn_inspect", [Loc.money(Game.inspect_cost(_car))]), "chip", func():
				if Game.inspect_part(_car, part):
					rebuild(), 44)
			b2.size_flags_horizontal = Control.SIZE_SHRINK_END
			row.add_child(b2)
	UI.divider(pc)
	var cr := UI.hbox(pc, 8)
	var cv := UI.vbox(cr, 0)
	cv.add_child(UI.lbl(Loc.t("clean"), 16, UI.C_TEXT, -1, true, false))
	cv.add_child(UI.lbl("%d/100" % int(_car["clean"]), 13, UI.C_MUTED, -1, false, false))
	if float(_car["clean"]) < 99.0:
		var cb := UI.btn(Loc.t("btn_clean", [Loc.money(Game.clean_cost(_car))]), "chip", func():
			if Game.clean_car(_car):
				rebuild(), 44)
		cb.size_flags_horizontal = Control.SIZE_SHRINK_END
		cr.add_child(cb)
	else:
		cr.add_child(Ico.new("check", UI.C_GOOD, 26))

	pc.add_child(UI.btn(Loc.t("gem_repair", [Game.gem_repair_cost(_car)]), "ghost", func():
		if Game.repair_with_gems(_car):
			rebuild(), 48))
	# İlan
	var lc := UI.add_card(sc)
	lc.add_child(UI.lbl(Loc.t("listing_card_title"), 18, UI.C_ACCENT, -1, true))
	lc.add_child(UI.lbl(Loc.t("suggested", [Loc.money(Game.suggested_price(_car))]), 13, UI.C_MUTED))
	_title_input = LineEdit.new()
	_title_input.placeholder_text = Loc.t("listing_name")
	_title_input.text = _draft_title if _has_draft else str(_car.get("listing_title", CarDB.full_name(str(_car["model"]))))
	_title_input.max_length = 70
	_title_input.custom_minimum_size.y = 48
	lc.add_child(_title_input)
	_description_input = TextEdit.new()
	_description_input.placeholder_text = Loc.t("listing_information")
	_description_input.text = _draft_description if _has_draft else str(_car.get("listing_description", ""))
	_description_input.custom_minimum_size = Vector2(0, 100)
	lc.add_child(_description_input)
	var row2 := UI.hbox(lc, 8)
	var step := maxi(1000, Game.r500(Game.suggested_price(_car) * 0.01))
	var minus := UI.btn("−", "chip", func():
		_price = maxi(step, _price - step)
		_update_price(), 52)
	minus.custom_minimum_size.x = 64
	minus.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	row2.add_child(minus)
	_price_lbl = SpinBox.new()
	_price_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_price_lbl.min_value = 1000
	_price_lbl.max_value = 999999999
	_price_lbl.step = 1
	_price_lbl.value = _price
	_price_lbl.get_line_edit().virtual_keyboard_type = LineEdit.KEYBOARD_TYPE_NUMBER
	_price_lbl.value_changed.connect(func(value: float):
		_price = int(value)
		_update_price())
	row2.add_child(_price_lbl)
	var plus := UI.btn("+", "chip", func():
		_price += step
		_update_price(), 52)
	plus.custom_minimum_size.x = 64
	plus.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	row2.add_child(plus)
	_demand_row = UI.lbl("", 14, UI.C_MUTED, HORIZONTAL_ALIGNMENT_CENTER)
	lc.add_child(_demand_row)
	_update_price()
	if bool(_car["listed"]):
		lc.add_child(UI.btn(Loc.t("btn_update_price"), "primary", func():
			_save_listing()
			Fx.play("success")
			Game.toast(Loc.t("toast_listed"), "good")
			rebuild(), 54))
		lc.add_child(UI.btn(Loc.t("btn_unlist"), "danger", func():
			Game.set_listed(_car, false)
			rebuild(), 48))
	else:
		lc.add_child(UI.btn_icon("check", Loc.t("btn_list"), "primary", func():
			_save_listing()
			Fx.play("success")
			Fx.vibrate(40)
			Game.toast(Loc.t("toast_listed"), "good")
			rebuild(), 56))
	# Hızlı satış
	var dc := UI.add_card(sc)
	dc.add_child(UI.lbl(Loc.t("dealer_hint"), 13, UI.C_MUTED))
	dc.add_child(UI.btn(Loc.t("btn_dealer", [Loc.money(int(Game.car_value(_car) * 0.80))]), "danger", _confirm_dealer, 48))
	UI.spacer(sc, 6)


var _demand_row: Label


func _update_price() -> void:
	if is_instance_valid(_price_lbl):
		_price_lbl.value = _price
	if is_instance_valid(_demand_row):
		var ratio := float(_price) / maxf(float(Game.car_value(_car)), 1.0)
		var key := "demand_high" if ratio <= 1.0 else ("demand_mid" if ratio <= 1.12 else "demand_low")
		_demand_row.text = Loc.t("demand_line", [Loc.t(key)])


func _confirm_dealer() -> void:
	var price := int(Game.car_value(_car) * 0.80)
	var v := UI.dialog_card(Loc.t("btn_dealer_short"))
	v.add_child(UI.lbl(Loc.t("dealer_confirm", [Loc.money(price)]), 16, UI.C_TEXT, HORIZONTAL_ALIGNMENT_CENTER))
	var root := UI.show_dialog(v)
	var r := UI.hbox(v, 10)
	r.add_child(UI.btn(Loc.t("cancel"), "ghost", func(): root.queue_free()))
	r.add_child(UI.btn(Loc.t("ok"), "danger", func():
		Game.sell_to_dealer(_car)
		root.queue_free()
		Game.toast(Loc.t("toast_dealer_sold", [Loc.money(price)]), "info")
		Game.go("garage")))


func _save_listing() -> void:
	_update_price()
	var title := _title_input.text.strip_edges()
	_car["listing_title"] = title if not title.is_empty() else CarDB.full_name(str(_car["model"]))
	_car["listing_description"] = _description_input.text.strip_edges().substr(0, 600)
	Game.set_listed(_car, true, _price)

func rebuild() -> void:
	var position: int = _page_scroll.scroll_vertical if is_instance_valid(_page_scroll) else 0
	if is_instance_valid(_title_input) and is_instance_valid(_description_input):
		_draft_title = _title_input.text
		_draft_description = _description_input.text
		_has_draft = true
	super.rebuild()
	_restore_scroll.call_deferred(position)
func _restore_scroll(position: int) -> void:
	await get_tree().process_frame
	if is_instance_valid(_page_scroll): _page_scroll.scroll_vertical = position
