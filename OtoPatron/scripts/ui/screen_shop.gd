extends ScreenBase
var _tab: String = "cash"
func _build() -> void:
	_tab = str(params.get("tab", _tab))
	UI.header(self, Loc.t("shop_title"), "management")
	var sc := UI.scroll_area(self)
	var hero := UI.add_card(sc, UI.C_PANEL2)
	hero.add_child(UI.lbl(Loc.t("shop_heading"), 24, UI.C_TEXT, -1, true))
	hero.add_child(UI.lbl(Loc.t("shop_intro"), 13, UI.C_MUTED))
	var wallet := UI.hbox(hero, 10)
	wallet.add_child(UI.pill(Loc.money(Game.money), UI.C_ACCENT))
	wallet.add_child(UI.pill("♦ %d" % Game.diamonds, UI.C_BLUE))
	var tabs := UI.hbox(sc, 8)
	for tab in ["cash", "gems"]:
		var target: String = tab
		tabs.add_child(UI.btn(Loc.t("shop_" + tab), "primary" if tab == _tab else "chip", func():
			params["tab"] = target
			rebuild(), 48))
	for pack in 3:
		var c := UI.add_card(sc, UI.C_PANEL, 18, UI.C_ACCENT if pack == 1 else UI.C_LINE)
		if pack == 1:
			c.add_child(UI.pill(Loc.t("shop_featured"), UI.C_GOLD))
		var gem_amount := int([5,15,40][pack])
		var cash_cost := int([100000,320000,900000][pack])
		var gem_cost := int([10,25,60][pack])
		var cash_reward := int([15000,40000,100000][pack])
		c.add_child(PackArt.new(_tab == "gems", pack))
		var row := UI.hbox(c, 14)
		row.add_child(UI.pill(Loc.t("pack_" + str(pack)), UI.C_ACCENT))
		var column := UI.vbox(row, 2)
		column.add_child(UI.lbl("%d ♦" % gem_amount if _tab == "gems" else Loc.money(cash_reward), 28, UI.C_TEXT, HORIZONTAL_ALIGNMENT_RIGHT, true))

		c.add_child(UI.lbl(Loc.t("exchange_rate"), 13, UI.C_MUTED))
		var price := Loc.money(cash_cost) if _tab == "gems" else "%d ♦" % gem_cost
		c.add_child(UI.btn(Loc.t("buy_asset") + " · " + price, "primary", func(): _purchase(pack, price), 50))
	sc.add_child(UI.lbl(Loc.t("gem_earning"), 13, UI.C_MUTED))

func _purchase(pack: int, price: String) -> void:
	var v := UI.dialog_card(Loc.t("purchase_confirm"))
	v.add_child(UI.lbl(Loc.t("purchase_body", [price]), 17, UI.C_TEXT))
	var root := UI.show_dialog(v)
	v.add_child(UI.btn(Loc.t("ok"), "primary", func():
		if Game.shop_exchange(_tab, pack):
			Fx.play("coin")
			Game.toast(Loc.t("purchase_done"), "good")
		root.queue_free()
		rebuild()))
	v.add_child(UI.btn(Loc.t("cancel"), "ghost", func(): root.queue_free()))
