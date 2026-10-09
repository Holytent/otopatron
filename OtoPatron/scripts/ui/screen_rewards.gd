extends ScreenBase
## Seviye ödülleri: para ödülü veya ödül kasası. Her seviye ödülü yalnızca bir kez alınır.


func _build() -> void:
	UI.header(self, Loc.t("rewards_title"), "management")
	var sc := UI.scroll_area(self)
	var dc := UI.add_card(sc, UI.C_PANEL2, 16, UI.C_GOLD)
	dc.add_child(UI.lbl(Loc.t("daily_crate"), 22, UI.C_GOLD, -1, true))
	dc.add_child(UI.lbl(Loc.t("daily_premium_hint"), 14, UI.C_MUTED))
	var board := GridContainer.new()
	board.columns = 4
	board.add_theme_constant_override("h_separation", 8)
	board.add_theme_constant_override("v_separation", 8)
	dc.add_child(board)
	for tier in range(1, 8):
		var is_claimed := Game.daily_date == Game.real_date() and tier <= Game.daily_streak
		var cell := UI.add_card(board, UI.C_PANEL2, 8, UI.C_GOOD if is_claimed else UI.C_LINE)
		cell.add_child(Ico.new("check" if is_claimed else ("car" if tier == 7 else "crate"), UI.C_ACCENT, 24))
		cell.add_child(UI.lbl(Loc.t("gift_day", [tier]), 12, UI.C_TEXT, HORIZONTAL_ALIGNMENT_CENTER, true))
		var reward := Game.daily_reward(tier)
		cell.add_child(UI.lbl("+%d ♦" % int(reward["diamonds"]), 12, UI.C_BLUE, HORIZONTAL_ALIGNMENT_CENTER))
	var claim := UI.btn(Loc.t("claim_daily") if Game.daily_date != Game.real_date() else Loc.t("claimed_daily"), "primary", _claim_daily, 52)
	claim.disabled = Game.daily_date == Game.real_date()
	dc.add_child(claim)
	dc.add_child(UI.lbl("♦ %d" % Game.diamonds, 20, UI.C_ACCENT))
	dc.add_child(UI.btn(Loc.t("shop_title"), "ghost", func(): Game.go("shop"), 48))
	var pend := Game.pending_reward_levels()
	if pend.is_empty():
		var ec := UI.add_card(sc)
		ec.add_child(UI.lbl(Loc.t("rewards_none"), 16, UI.C_MUTED, HORIZONTAL_ALIGNMENT_CENTER))
		ec.add_child(UI.lbl(Loc.t("rewards_next", [Game.level + 1]), 14, UI.C_MUTED, HORIZONTAL_ALIGNMENT_CENTER))
	for l in pend:
		_reward_card(sc, int(l))
	if not Game.claimed.is_empty():
		var hc := UI.add_card(sc)
		hc.add_child(UI.lbl(Loc.t("rewards_history"), 15, UI.C_ACCENT, -1, true))
		var keys := Game.claimed.keys()
		keys.sort()
		for k in keys:
			UI.kv(hc, Loc.t("lvl_short", [int(k)]), Loc.t("reward_%s" % Game.claimed[k]), UI.C_MUTED)
	UI.spacer(sc, 6)


func _reward_card(parent: Node, l: int) -> void:
	var c := UI.add_card(parent, Color("e3eff1"), 16, UI.C_ACCENT)
	c.add_child(UI.lbl(Loc.t("reward_for_level", [l]), 20, UI.C_GOLD, -1, true))
	var uk := Game.level_unlock_key(l)
	if uk != "":
		c.add_child(UI.lbl(Loc.t("unlocks") + ": " + Loc.t(uk), 14, UI.C_TEXT))
	c.add_child(UI.lbl(Loc.t("reward_choose"), 14, UI.C_MUTED))
	var cash := Game.cash_reward(l)
	c.add_child(UI.btn_icon("coin", Loc.t("btn_reward_cash", [Loc.money(cash)]), "primary", func():
		var amt := Game.claim_cash(l)
		if amt > 0:
			Game.toast(Loc.t("toast_cash_reward", [Loc.money(amt)]), "good")
			rebuild(), 58))
	var oc := UI.add_card(c, UI.C_PANEL, 12)
	oc.add_child(UI.lbl(Loc.t("crate_odds_title"), 14, UI.C_ACCENT, -1, true))
	var lo := Game.r500(cash * 0.4)
	var hi := Game.r500(cash * 2.2)
	oc.add_child(UI.lbl("%%50 — %s: %s – %s" % [Loc.t("crate_money"), Loc.money(lo), Loc.money(hi)], 13, UI.C_TEXT))
	oc.add_child(UI.lbl("%%15 — %s" % Loc.t("crate_car"), 13, UI.C_TEXT))
	oc.add_child(UI.lbl("%%35 — %s: %d – %d XP" % [Loc.t("crate_xp"), int((15 + Game.level * 6) * 0.6), int((15 + Game.level * 6) * 1.5)], 13, UI.C_TEXT))
	oc.add_child(UI.lbl(Loc.t("crate_note"), 12, UI.C_MUTED))
	c.add_child(UI.btn_icon("crate", Loc.t("btn_reward_crate"), "ghost", func(): _open_crate(l), 58))


func _open_crate(l: int) -> void:
	var v := UI.dialog_card(Loc.t("crate_opening"))
	var cc := CenterContainer.new()
	var ic := Ico.new("crate", UI.C_ACCENT, 110)
	ic.pivot_offset = Vector2(55, 55)
	cc.add_child(ic)
	v.add_child(cc)
	var root := UI.show_dialog(v)
	Fx.play("crate")
	var tw := ic.create_tween().set_loops(6)
	tw.tween_property(ic, "rotation", 0.15, 0.08)
	tw.tween_property(ic, "rotation", -0.15, 0.16)
	tw.tween_property(ic, "rotation", 0.0, 0.08)
	await get_tree().create_timer(1.1).timeout
	if not is_instance_valid(root):
		return
	var res := Game.open_crate(l)
	for ch in v.get_children():
		v.remove_child(ch)
		ch.queue_free()
	if res.is_empty():
		root.queue_free()
		return
	v.add_child(UI.lbl(Loc.t("crate_result"), 22, UI.C_GOLD, HORIZONTAL_ALIGNMENT_CENTER, true))
	match str(res["kind"]):
		"money":
			v.add_child(Ico.new("coin", UI.C_GOLD, 80))
			v.add_child(UI.lbl("+" + Loc.money(int(res["amount"])), 30, UI.C_GOLD, HORIZONTAL_ALIGNMENT_CENTER, true))
		"xp":
			v.add_child(Ico.new("star", UI.C_GOLD, 80))
			v.add_child(UI.lbl("+%d XP" % int(res["amount"]), 30, UI.C_ACCENT, HORIZONTAL_ALIGNMENT_CENTER, true))
		_:
			var car: Dictionary = res["car"]
			v.add_child(UI.car_image(str(car["model"]), 130, car))
			v.add_child(UI.lbl(CarDB.full_name(str(car["model"])), 22, UI.C_TEXT, HORIZONTAL_ALIGNMENT_CENTER, true))
			var where := str(res.get("where", "cash"))
			if str(res["kind"]) == "car_cash":
				v.add_child(UI.lbl(Loc.t("crate_car_cash", [Loc.money(int(res["amount"]))]), 15, UI.C_MUTED, HORIZONTAL_ALIGNMENT_CENTER))
			else:
				v.add_child(UI.lbl(Loc.t("crate_car_%s" % where), 15, UI.C_MUTED, HORIZONTAL_ALIGNMENT_CENTER))
	Fx.play("levelup")
	v.add_child(UI.btn(Loc.t("ok"), "primary", func():
		root.queue_free()
		rebuild(), 54))


func _claim_daily() -> void:
	var reward := Game.claim_daily()
	if reward.is_empty():
		return
	var v := UI.dialog_card(Loc.t("daily_crate"))
	v.add_child(Ico.new("crate", UI.C_GOLD, 80))
	v.add_child(UI.lbl("+%s · +%d ♦ · +%d XP" % [Loc.money(int(reward["money"])), int(reward["diamonds"]), int(reward["xp"])], 22, UI.C_GOLD))
	if bool(reward.get("car", false)):
		v.add_child(UI.car_image("karya_pico", 100))
		v.add_child(UI.lbl(Loc.t("seventh_gift") + " · " + Loc.t("crate_car_" + str(reward.get("car_where", "garage"))) if str(reward.get("car_where", "garage")) != "cash" else Loc.t("gift_cash_fallback"), 14, UI.C_ACCENT))
	var root := UI.show_dialog(v)
	v.add_child(UI.btn(Loc.t("ok"), "primary", func(): root.queue_free()))
	rebuild()
