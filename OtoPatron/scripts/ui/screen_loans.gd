extends ScreenBase
## Kredi: seviye/eğitim limiti, 3-36 ay vade, günlük otomatik taksit, %40 ödeme kuralı, ucuz erken kapatma.

var _amount: int = 50000
var _months: int = 6


func _build() -> void:
	UI.header(self, Loc.t("loans_title"), "management")
	var sc := UI.scroll_area(self)
	var intro := UI.add_card(sc)
	intro.add_child(UI.lbl(Loc.t("bank_access_hint"), 14, UI.C_MUTED))
	_summary(sc)
	for l in Game.loans:
		_loan_card(sc, l)
	_new_loan(sc)
	UI.spacer(sc, 6)


func _summary(sc: Node) -> void:
	var c := UI.add_card(sc)
	UI.kv(c, Loc.t("debt_total"), Loc.money(Game.total_debt()), UI.C_BAD if Game.total_debt() > 0 else UI.C_GOOD)
	var ni := Game.next_installment()
	if not ni.is_empty():
		UI.kv(c, Loc.t("daily"), Loc.money(int(ni["amount"])), UI.C_GOLD)
	UI.divider(c)
	UI.kv(c, Loc.t("loan_level_cap"), Loc.money(Game.loan_level_cap()), UI.C_MUTED)
	UI.kv(c, Loc.t("loan_train_cap"), Loc.money(Game.loan_train_cap()) if Game.loan_train_cap() > 0 else Loc.t("none"), UI.C_MUTED)
	UI.kv(c, Loc.t("loan_limit"), Loc.money(Game.loan_limit()), UI.C_TEXT)
	UI.kv(c, Loc.t("loan_room"), Loc.money(Game.loan_room()), UI.C_GOLD)
	c.add_child(UI.bar(Game.principal_outstanding(), maxf(Game.loan_limit(), 1.0), UI.C_BAD, 10))
	c.add_child(UI.lbl(Loc.t("late_rule"), 12, UI.C_MUTED))
	c.add_child(UI.lbl(Loc.t("loan_tip"), 12, UI.C_MUTED))


func _loan_card(sc: Node, loan: Dictionary) -> void:
	var c := UI.add_card(sc)
	c.add_child(UI.lbl(Loc.t("loan_item", [Loc.money(int(loan["principal"])), int(loan["months"])]), 16, UI.C_TEXT, -1, true))
	UI.kv(c, Loc.t("daily"), Loc.money(int(loan["daily"])), UI.C_GOLD)
	UI.kv(c, Loc.t("remaining_days"), "%d" % int(loan["left"]))
	UI.kv(c, Loc.t("paid_pct"), "%%%d" % int(Game.loan_paid_fraction(loan) * 100.0), UI.C_GOOD if Game.loan_paid_fraction(loan) >= Game.MIN_PAID_FOR_NEXT_LOAN else UI.C_MUTED)
	if int(loan["fees"]) > 0:
		UI.kv(c, Loc.t("late_fee"), Loc.money(int(loan["fees"])), UI.C_BAD)
	UI.kv(c, Loc.t("loan_left_total"), Loc.money(Game.loan_total_left(loan)), UI.C_MUTED)
	c.add_child(UI.lbl(Loc.t("settle_hint"), 12, UI.C_MUTED))
	c.add_child(UI.btn(Loc.t("btn_settle", [Loc.money(Game.settle_cost(loan))]), "ghost", func():
		if Game.settle_loan(loan):
			Game.toast(Loc.t("toast_loan_done"), "good")
			rebuild(), 48))


func _new_loan(sc: Node) -> void:
	var room := Game.loan_room()
	var nc := UI.add_card(sc)
	nc.add_child(UI.lbl(Loc.t("new_loan"), 18, UI.C_ACCENT, -1, true))
	var blocked := Game.loan_block_fraction()
	if blocked >= 0.0:
		nc.add_child(UI.lbl(Loc.t("err_loan_40", [int(blocked * 100.0)]), 14, UI.C_GOLD))
		return
	if room < 10000:
		nc.add_child(UI.lbl(Loc.t("loan_cap_reached"), 15, UI.C_BAD))
		return
	_amount = clampi(_amount, 10000, room)
	var row := UI.hbox(nc, 8)
	var minus := UI.btn("−", "chip", func():
		_amount = maxi(10000, _amount - 10000)
		rebuild(), 52)
	minus.custom_minimum_size.x = 64
	minus.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	row.add_child(minus)
	row.add_child(UI.lbl(Loc.money(_amount), 22, UI.C_GOLD, HORIZONTAL_ALIGNMENT_CENTER, true, false))
	var plus := UI.btn("+", "chip", func():
		_amount = mini(room, _amount + 10000)
		rebuild(), 52)
	plus.custom_minimum_size.x = 64
	plus.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	row.add_child(plus)
	var qr := UI.hbox(nc, 6)
	for qa in [50000, 100000, 200000]:
		var amt: int = qa
		if amt <= room:
			qr.add_child(UI.btn(Loc.num(amt), "chip", func():
				_amount = amt
				rebuild(), 42))
	qr.add_child(UI.btn(Loc.t("max"), "chip", func():
		_amount = room
		rebuild(), 42))
	nc.add_child(UI.lbl(Loc.t("term"), 13, UI.C_MUTED))
	var tr := UI.hbox(nc, 6)
	for m in Game.LOAN_TERMS.keys():
		var mo: int = m
		tr.add_child(UI.btn(Loc.t("months_n", [mo]), "chipon" if mo == _months else "chip", func():
			_months = mo
			rebuild(), 44))
	var q := Game.loan_quote(_amount, _months)
	var box := UI.add_card(nc, UI.C_PANEL2, 12)
	UI.kv(box, Loc.t("interest"), "%%%d" % int(round(float(q["rate"]) * 100.0)), UI.C_TEXT)
	UI.kv(box, Loc.t("daily"), Loc.money(int(q["daily"])), UI.C_GOLD)
	UI.kv(box, Loc.t("total_repay"), Loc.money(int(q["total"])), UI.C_MUTED)
	UI.kv(box, Loc.t("first_payment"), Game.date_str(Game.day + 1), UI.C_TEXT)
	UI.kv(box, Loc.t("last_payment"), Game.date_str(Game.day + int(q["days"])), UI.C_TEXT)
	nc.add_child(UI.btn_icon("bank", Loc.t("btn_take", [Loc.money(_amount)]), "primary", func():
		var r := Game.take_loan(_amount, _months)
		if r == "ok":
			Game.toast(Loc.t("toast_loan_taken", [Loc.money(_amount)]), "good")
			rebuild()
		else:
			Fx.play("error")
			Game.toast(Loc.t("err_loan_cap"), "bad"), 56))
