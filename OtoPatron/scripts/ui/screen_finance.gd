extends ScreenBase
var _section: String = "overview"
var _asset: String = "usd"
var _amount: int = 10000
var _term: int = 7
var _qty: SpinBox
var _quote: Label
var _interest: Label
func _build() -> void:
	UI.header(self, Loc.t("finance_title"), "management")
	var sc := UI.scroll_area(self)
	if _section == "overview":
		var hero := UI.add_card(sc, UI.C_PANEL2)
		var total := 0.0
		var basis := 0
		for id in Game.investments:
			var position: Dictionary = Game.investments[id]
			total += int(position["units"]) * float(Game.finance_prices[id]) * 0.99
			basis += int(position["cost"])
		hero.add_child(UI.lbl(Loc.t("portfolio_value"), 15, UI.C_MUTED))
		hero.add_child(UI.lbl(Loc.money(int(total)), 28, UI.C_TEXT, -1, true))
		var result := int(total) - basis
		hero.add_child(UI.lbl(Loc.t("unrealized") + " · " + Loc.money(result), 15, UI.C_GOOD if result >= 0 else UI.C_BAD))
		for section in ["market", "savings", "holdings"]:
			var target: String = section
			var card := UI.add_card(sc)
			card.add_child(UI.lbl(Loc.t("finance_hint_" + target), 14, UI.C_MUTED))
			card.add_child(UI.btn(Loc.t("fin_" + target), "ghost", func():
				_section = target
				rebuild(), 48))
	else:
		sc.add_child(UI.btn(Loc.t("finance_back"), "ghost", func():
			_section = "overview"
			rebuild(), 44))
		match _section:
			"market": _market_panel(sc)
			"savings": _savings_panel(sc)
			"holdings": _holdings_panel(sc)
	sc.add_child(UI.lbl(Loc.t("finance_short"), 12, UI.C_MUTED))
func _market_panel(sc: Node) -> void:
	var assets := UI.hbox(sc, 6)
	for key in ["usd", "eur", "gold", "index"]:
		var id: String = key
		assets.add_child(UI.btn(Loc.t("ticker_" + id), "primary" if id == _asset else "chip", func():
			_asset = id
			rebuild(), 42))
	var c := UI.add_card(sc)
	var price := float(Game.finance_prices[_asset])
	c.add_child(UI.lbl(Loc.t("asset_" + _asset), 22, UI.C_TEXT, -1, true))
	c.add_child(UI.lbl("₺%.2f" % price, 32, UI.C_TEXT, -1, true))
	var history: Array = Game.finance_history.get(_asset, [price])
	var previous := float(history[-2]) if history.size() > 1 else price
	var change := (price / maxf(previous, 0.01) - 1.0) * 100.0
	c.add_child(UI.pill("%+.2f%%" % change + " · " + Loc.t("day_change"), UI.C_GOOD if change >= 0 else UI.C_BAD))
	var chart := MiniChart.new()
	chart.custom_minimum_size.y = 125
	chart.points = history
	c.add_child(chart)
	c.add_child(UI.lbl(Loc.t("chart_period"), 12, UI.C_MUTED))
	var trade := UI.add_card(sc, UI.C_PANEL2)
	trade.add_child(UI.lbl(Loc.t("trade_order"), 18, UI.C_TEXT, -1, true))
	_qty = SpinBox.new()
	_qty.min_value = 1
	_qty.max_value = 100000
	_qty.value = 1 if _asset == "gold" else 100
	_qty.custom_minimum_size.y = 46
	trade.add_child(_qty)
	_quote = UI.lbl("", 13, UI.C_MUTED)
	trade.add_child(_quote)
	_qty.value_changed.connect(func(_value: float): _update_quote())
	_update_quote()
	var row := UI.hbox(trade, 8)
	row.add_child(UI.btn(Loc.t("buy_asset"), "primary", func(): _confirm_order(true), 48))
	row.add_child(UI.btn(Loc.t("sell_asset"), "ghost", func(): _confirm_order(false), 48))
func _update_quote() -> void:
	var units := int(_qty.value)
	var price := float(Game.finance_prices[_asset])
	_quote.text = Loc.t("order_quote", [Loc.money(int(ceil(units * price * 1.01))), Loc.money(int(floor(units * price * 0.99)))])
func _confirm_order(buy: bool) -> void:
	var id := _asset
	var units := int(_qty.value)
	var price := float(Game.finance_prices[id])
	var cost := int(ceil(units * price * 1.01)) if buy else int(floor(units * price * 0.99))
	var v := UI.dialog_card(Loc.t("trade_order"))
	v.add_child(UI.lbl("%s · %d · %s" % [Loc.t("asset_" + id), units, Loc.money(cost)], 18, UI.C_TEXT))
	var root := UI.show_dialog(v)
	v.add_child(UI.btn(Loc.t("ok"), "primary", func():
		Game.trade_asset(id, units, buy)
		root.queue_free()
		rebuild()))
	v.add_child(UI.btn(Loc.t("cancel"), "ghost", func(): root.queue_free()))
func _holdings_panel(sc: Node) -> void:
	for id in ["usd", "eur", "gold", "index"]:
		var position: Dictionary = Game.investments.get(id, {"units": 0, "cost": 0})
		var units := int(position["units"])
		var c := UI.add_card(sc)
		c.add_child(UI.lbl(Loc.t("asset_" + id), 19, UI.C_TEXT, -1, true))
		UI.kv(c, Loc.t("quantity"), str(units))
		UI.kv(c, Loc.t("portfolio_value"), Loc.money(int(units * float(Game.finance_prices[id]) * 0.99)), UI.C_ACCENT)
		UI.kv(c, Loc.t("cost_basis"), Loc.money(int(position["cost"])))
func _savings_panel(sc: Node) -> void:
	var c := UI.add_card(sc)
	c.add_child(UI.lbl(Loc.t("deposit_title"), 21, UI.C_TEXT, -1, true))
	c.add_child(UI.lbl(Loc.t("deposit_hint"), 13, UI.C_MUTED))
	var amount := SpinBox.new()
	amount.min_value = 10000
	amount.max_value = 10000000
	amount.step = 10000
	amount.value = _amount
	amount.custom_minimum_size.y = 46
	amount.value_changed.connect(func(value: float):
		_amount = int(value)
		if is_instance_valid(_interest):
			_interest.text = Loc.money(_amount + int(_amount * 0.004 * _term)))
	c.add_child(amount)
	var terms := UI.hbox(c, 8)
	for days in [7,14,30]:
		var term: int = days
		terms.add_child(UI.btn(Loc.t("days_term", [days]), "primary" if _term == days else "chip", func():
			_term = term
			rebuild(), 44))
	var interest_row := UI.kv(c, Loc.t("deposit_total"), Loc.money(_amount + int(_amount * 0.004 * _term)), UI.C_GOOD)
	_interest = interest_row.get_child(1)
	c.add_child(UI.btn(Loc.t("open_deposit"), "primary", func():
		var v := UI.dialog_card(Loc.t("open_deposit"))
		UI.kv(v, Loc.t("cost_basis"), Loc.money(_amount))
		UI.kv(v, Loc.t("maturity"), Loc.t("days_term", [_term]))
		UI.kv(v, Loc.t("deposit_total"), Loc.money(_amount + int(_amount * 0.004 * _term)), UI.C_GOOD)
		var root := UI.show_dialog(v)
		v.add_child(UI.btn(Loc.t("ok"), "primary", func():
			root.queue_free()
			Game.open_deposit(_amount, _term)
			rebuild()))
		v.add_child(UI.btn(Loc.t("cancel"), "ghost", func(): root.queue_free())), 48))
	for item in Game.deposits:
		var d: Dictionary = item
		var card := UI.add_card(sc, UI.C_PANEL2)
		UI.kv(card, Loc.t("deposit_title"), Loc.money(int(d["amount"])))
		UI.kv(card, Loc.t("interest"), Loc.money(int(d["interest"])), UI.C_GOOD)
		UI.kv(card, Loc.t("deposit_total"), Loc.money(int(d["amount"]) + int(d["interest"])), UI.C_ACCENT)
		card.add_child(UI.bar(int(d["term"]) - int(d["due"]) + Game.day, int(d["term"]), UI.C_ACCENT, 8))
		UI.kv(card, Loc.t("maturity"), Loc.t("days_term", [maxi(0, int(d["due"]) - Game.day)]))
		card.add_child(UI.btn(Loc.t("withdraw_deposit"), "danger", func(): _confirm_withdraw(int(d["id"])), 44))
func _confirm_withdraw(id: int) -> void:
	var v := UI.dialog_card(Loc.t("withdraw_deposit"))
	v.add_child(UI.lbl(Loc.t("withdraw_hint"), 15, UI.C_MUTED))
	var root := UI.show_dialog(v)
	v.add_child(UI.btn(Loc.t("ok"), "danger", func():
		Game.withdraw_deposit(id)
		root.queue_free()
		rebuild()))
	v.add_child(UI.btn(Loc.t("cancel"), "ghost", func(): root.queue_free()))
