extends ScreenBase
func _build() -> void:
	UI.header(self, Loc.t("history_title"), "garage")
	var sc := UI.scroll_area(self)
	var history := Game.sales_history()
	sc.add_child(UI.lbl(Loc.t("history_info"), 13, UI.C_MUTED))
	if history.is_empty():
		UI.add_card(sc).add_child(UI.lbl(Loc.t("history_empty"), 16))
		return
	history.reverse()
	for entry in history:
		var card := UI.add_card(sc)
		card.add_child(UI.lbl(CarDB.full_name(str(entry["model"])) + " · " + str(entry.get("year", "")), 19, UI.C_TEXT, -1, true))
		card.add_child(UI.lbl(Loc.t("history_date", [entry["day"], "%02d:%02d" % [int(entry["minute"])/60, int(entry["minute"])%60]]) + " · " + str(entry.get("buyer", "")), 13, UI.C_MUTED))
		UI.kv(card, Loc.t("history_bought"), Loc.money(int(entry["bought"])))
		UI.kv(card, Loc.t("history_cost"), Loc.money(int(entry["invested"])))
		UI.kv(card, Loc.t("history_price"), Loc.money(int(entry["price"])))
		if entry.has("trade_credit"):
			UI.kv(card, Loc.t("trade_credit"), Loc.money(int(entry["trade_credit"])))
			UI.kv(card, Loc.t("trade_cash"), Loc.money(int(entry["cash_received"])))
		if int(entry["bonus"]) > 0:
			UI.kv(card, Loc.t("history_bonus"), Loc.money(int(entry["bonus"])))
		UI.kv(card, Loc.t("history_profit"), Loc.money(int(entry["profit"])), UI.C_GOOD if int(entry["profit"]) >= 0 else UI.C_BAD)
