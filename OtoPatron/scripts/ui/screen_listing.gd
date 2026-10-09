extends ScreenBase
## İlan detayı: ekspertiz + satıcıyla telefon pazarlığı + satın alma.

var _rare_label: Label
func _ready() -> void:
	super._ready()
	Game.live_tick.connect(func():
		if is_instance_valid(_rare_label) and _l.has("rare_until"):
			_rare_label.text = Loc.t("rare_time", [int(ceil(DealerExpansion.rare_seconds(_l)/60.0))]) if DealerExpansion.listing_alive(_l) else Loc.t("rare_expired"))

var _actor: ConversationActor
var _dial: Control
var _l: Dictionary = {}
var _offer: int = 0
var _chat: VBoxContainer
var _scroll: ScrollContainer
var _send_btn: Button
var _offer_lbl: Label
var _action_box: VBoxContainer
var _busy: bool = false
var _root: Control
var _counter: int = 0
var _mood_bar: ProgressBar


func _build() -> void:
	_l = Game.listing_by_id(int(params.get("id", -1)))
	UI.header(self, Loc.t("listing_title"), "market")
	if _l.is_empty():
		add_child(UI.lbl(Loc.t("listing_gone"), 17, UI.C_MUTED, HORIZONTAL_ALIGNMENT_CENTER))
		return
	var car: Dictionary = _l["car"]
	var m := CarDB.model(str(car["model"]))
	var sc := UI.scroll_area(self)
	var c := UI.add_card(sc)
	c.add_child(UI.car_image(str(car["model"]), 150, car))
	var t := UI.hbox(c, 8)
	t.add_child(UI.lbl(CarDB.full_name(str(car["model"])), 22, UI.C_TEXT, -1, true, false))
	t.add_child(UI.pill(Loc.t("cls_%s" % m["cls"]), UI.C_BLUE))
	UI.kv(c, Loc.t("year_km"), "%d • %s km" % [int(car["year"]), Loc.num(int(car["km"]))])
	var r := Game.est_range(car)
	UI.kv(c, Loc.t("est_value"), "%s – %s" % [Loc.money(r[0]), Loc.money(r[1])], UI.C_MUTED)
	UI.kv(c, Loc.t("asking"), Loc.money(int(_l["ask"])), UI.C_GOLD)
	UI.kv(c, Loc.t("seller"), str(_l["seller"]))
	if _l.has("rare_until"):
		_rare_label = UI.lbl(Loc.t("rare_time", [int(ceil(DealerExpansion.rare_seconds(_l)/60.0))]), 14, UI.C_GOLD)
		c.add_child(_rare_label)

	# Ekspertiz
	var ec := UI.add_card(sc)
	ec.add_child(UI.lbl(Loc.t("inspect_title"), 18, UI.C_ACCENT, -1, true))
	ec.add_child(UI.lbl(Loc.t("inspect_hint", [Loc.money(Game.inspect_cost(car))]), 13, UI.C_MUTED))
	for p in Game.PARTS:
		var part: String = p
		var row := UI.hbox(ec, 8)
		row.add_child(UI.lbl(Loc.t("part_%s" % part), 16, UI.C_TEXT, -1, true, false))
		if bool(car["known"].get(part, false)):
			var st := Game.part_state(float(car["parts"][part]))
			var col := UI.C_GOOD if st == "good" else (UI.C_ACCENT if st == "mid" else UI.C_BAD)
			var rv := UI.vbox(row, 0)
			var pl := UI.pill(Loc.t("state_%s" % st), col)
			pl.size_flags_horizontal = Control.SIZE_SHRINK_END
			rv.add_child(pl)
			var rr := Game.repair_range(car, part)
			if rr[1] > 0:
				rv.add_child(UI.lbl(Loc.t("repair_est", [Loc.money(rr[0]), Loc.money(rr[1])]), 12, UI.C_MUTED, HORIZONTAL_ALIGNMENT_RIGHT if not Loc.is_rtl() else HORIZONTAL_ALIGNMENT_LEFT, false, false))
		else:
			var b := UI.btn(Loc.t("btn_inspect", [Loc.money(Game.inspect_cost(car))]), "chip", func():
				if not DealerExpansion.listing_alive(_l):
					Game.toast(Loc.t("rare_expired"), "bad")
				elif Game.inspect_part(car, part):
					rebuild(), 44)
			b.size_flags_horizontal = Control.SIZE_SHRINK_END
			b.clip_text = false
			row.add_child(b)

	# Eylemler
	var ac := UI.add_card(sc)
	ac.add_child(UI.btn_icon("phone", Loc.t("btn_call_seller"), "primary", _open_call, 58))
	ac.add_child(UI.btn_icon("coin", Loc.t("btn_buy_ask", [Loc.money(int(_l["ask"]))]), "ghost", func(): _try_buy(int(_l["ask"])), 54))
	UI.spacer(sc, 6)


func _try_buy(price: int) -> void:
	var res := Game.buy_listing(_l, price)
	if res == "ok":
		Game.toast(Loc.t("toast_bought", [CarDB.full_name(str(_l["car"]["model"]))]), "good")
		if _root != null:
			_root.queue_free()
		Game.go("car", {"uid": int(_l["car"]["uid"]), "fresh": true})
	elif res == "gone":
		Game.toast(Loc.t("listing_gone"),"bad")
		Game.go("market")
	elif res == "no_money":
		Fx.play("error")
		var v := UI.dialog_card(Loc.t("err_no_money"))
		v.add_child(UI.lbl(Loc.t("need_money_body", [Loc.money(price - Game.money)]), 16, UI.C_TEXT, HORIZONTAL_ALIGNMENT_CENTER))
		var root := UI.show_dialog(v)
		var rr := UI.hbox(v, 10)
		rr.add_child(UI.btn(Loc.t("cancel"), "ghost", func(): root.queue_free()))
		rr.add_child(UI.btn(Loc.t("btn_take_loan"), "primary", func():
			root.queue_free()
			if _root != null:
				_root.queue_free()
			Game.go("loans")))
	else:
		Fx.play("error")
		var v2 := UI.dialog_card(Loc.t("err_no_space"))
		v2.add_child(UI.lbl(Loc.t("no_space_body"), 16, UI.C_TEXT, HORIZONTAL_ALIGNMENT_CENTER))
		var root2 := UI.show_dialog(v2)
		var r2 := UI.hbox(v2, 10)
		r2.add_child(UI.btn(Loc.t("cancel"), "ghost", func(): root2.queue_free()))
		r2.add_child(UI.btn(Loc.t("menu_business"), "primary", func():
			root2.queue_free()
			if _root != null:
				_root.queue_free()
			Game.go("garage")))


# ------------------------------------------------------------------ pazarlık (telefon diyaloğu)
func _open_call() -> void:
	if not DealerExpansion.listing_alive(_l):
		Game.toast(Loc.t("rare_expired"), "bad")
		return
	if is_instance_valid(_dial) or is_instance_valid(_root): return
	_dial = PhoneCall.present(false, str(_l["seller"]), CarDB.full_name(str(_l["car"]["model"])), func():
		if is_inside_tree(): _connect_call(), func(): pass)

func _connect_call() -> void:
	if not DealerExpansion.listing_alive(_l):
		Game.toast(Loc.t("rare_expired"), "bad")
		return
	var ask: int = int(_l["ask"])
	_offer = Game.r500(ask * 0.88)
	_counter = 0
	_busy = true
	var v := UI.dialog_card(Loc.t("call_title", [str(_l["seller"])]))
	_actor = ConversationActor.new()
	_actor.identity = str(_l["seller"])
	_actor.mood = float(_l["mood"])
	v.add_child(_actor)
	_mood_bar = UI.mood_bar(v, Loc.t("mood_seller"), float(_l["mood"]))
	var sc := ScrollContainer.new()
	sc.custom_minimum_size = Vector2(0, 220)
	sc.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_scroll = sc
	_chat = UI.vbox(null, 8)
	sc.add_child(_chat)
	v.add_child(sc)
	_action_box = UI.vbox(v, 8)
	_root = UI.show_dialog(v)
	Game.begin_negotiation()
	_root.tree_exited.connect(Game.end_negotiation, CONNECT_ONE_SHOT)
	_run_call_intro()


func _bubble(text: String, mine: bool, tint: Color = UI.C_PANEL2) -> Label:
	Fx.play("msg_out" if mine else "msg_in")
	var row := UI.hbox(_chat, 0)
	var p := PanelContainer.new()
	var bg := UI.C_PANEL2 if mine or tint.get_luminance() < 0.1 else tint
	p.add_theme_stylebox_override("panel", UI.sb(bg, 14, UI.C_ACCENT if mine else UI.C_LINE, 1, 12, 8))
	var l := UI.lbl(text, 15, UI.C_TEXT, -1, false)
	l.custom_minimum_size = Vector2(220, 0)
	l.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	p.add_child(l)
	p.size_flags_horizontal = Control.SIZE_SHRINK_END if mine else Control.SIZE_SHRINK_BEGIN
	row.add_child(p)
	UI.fade_in(p, 0.2)
	l.visible_ratio = 0
	l.create_tween().tween_property(l, "visible_ratio", 1.0, minf(2.0, text.length()/40.0))
	if is_instance_valid(_actor):
		_actor.mood = float(_l.get("mood", 100))
		_actor.speak(minf(2.0, text.length()/40.0))
	await get_tree().process_frame
	if is_instance_valid(_scroll):
		_scroll.scroll_vertical = int(_scroll.get_v_scroll_bar().max_value)
	return l


func _clear_actions() -> void:
	for c in _action_box.get_children():
		_action_box.remove_child(c)
		c.queue_free()


func _run_call_intro() -> void:
	_clear_actions()
	var ring := UI.lbl(Loc.t("call_ringing"), 15, UI.C_ACCENT, HORIZONTAL_ALIGNMENT_CENTER)
	_action_box.add_child(ring)
	Fx.play("success")
	await get_tree().create_timer(0.3).timeout
	if not is_inside_tree() or not is_instance_valid(_root):
		return
	_bubble(Loc.t_rand("sell_greet", [Loc.money(int(_l["ask"]))]), false)
	Game.advance(10)
	_busy = false
	_show_offer_controls()


func _show_offer_controls() -> void:
	_clear_actions()
	if float(_l["mood"]) <= 0.0:
		return
	_action_box.add_child(UI.lbl(Loc.t("your_offer"), 13, UI.C_MUTED, HORIZONTAL_ALIGNMENT_CENTER))
	var row := UI.hbox(_action_box, 8)
	var step := maxi(500, Game.r500(int(_l["ask"]) * 0.01))
	var minus := UI.btn("−", "chip", func():
		_offer = maxi(step, _offer - step)
		_update_offer(), 52)
	minus.custom_minimum_size.x = 64
	minus.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	row.add_child(minus)
	_offer_lbl = UI.lbl(Loc.money(_offer), 22, UI.C_GOLD, HORIZONTAL_ALIGNMENT_CENTER, true, false)
	row.add_child(_offer_lbl)
	var plus := UI.btn("+", "chip", func():
		_offer = mini(int(_l["ask"]), _offer + step)
		_update_offer(), 52)
	plus.custom_minimum_size.x = 64
	plus.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	row.add_child(plus)
	if _counter > 0:
		_action_box.add_child(UI.btn(Loc.t("btn_accept_counter", [Loc.money(_counter)]), "ghost", func(): _try_buy(_counter), 50))
	_send_btn = UI.btn(Loc.t("btn_send_offer"), "primary", _send_offer, 54)
	_action_box.add_child(_send_btn)
	_action_box.add_child(UI.btn(Loc.t("btn_hang_up"), "danger", func(): _root.queue_free(), 46))


func _update_offer() -> void:
	if is_instance_valid(_offer_lbl):
		_offer_lbl.text = Loc.money(_offer)


func _send_offer() -> void:
	if _busy:
		return
	_busy = true
	var offer := _offer
	_clear_actions()
	await _bubble(Loc.t_rand("offer_bubble", [Loc.money(offer)]), true)
	var typing := await _bubble("…", false)
	await get_tree().create_timer(Game.rng.randf_range(1.2, 2.2)).timeout
	if not is_inside_tree() or not is_instance_valid(_root):
		return
	typing.get_parent().get_parent().queue_free()
	var res := Game.negotiate(_l, offer)
	Game.advance(5)
	UI.set_mood(_mood_bar, float(_l["mood"]))
	var kind := str(res["kind"])
	match kind:
		"accept":
			Fx.play("success")
			await _bubble(Loc.t_rand("sell_accept", [Loc.money(int(res["price"]))]), false, Color("dff2e8"))
			_busy = false
			_clear_actions()
			_action_box.add_child(UI.btn(Loc.t("btn_buy_at", [Loc.money(int(res["price"]))]), "primary", func(): _try_buy(int(res["price"])), 56))
			_action_box.add_child(UI.btn(Loc.t("btn_hang_up"), "danger", func(): _root.queue_free(), 46))
			return
		"counter":
			_counter = int(res["price"])
			await _bubble(Loc.t_rand("sell_counter", [Loc.money(_counter)]), false)
		"sad":
			_counter = int(res["price"])
			Fx.play("error")
			await _bubble(Loc.t_rand("sell_sad", [Loc.money(_counter)]), false, Color("f3edf3"))
		"angry":
			Fx.play("error")
			Fx.vibrate(50)
			await _bubble(Loc.t_rand("sell_angry"), false, Color("fae8e9"))
		"end":
			pass
	if res.get("ended", false) or kind == "end":
		await _bubble(Loc.t_rand("sell_end"), false, Color("fae8e9"))
		Game.seller_leave(_l)
		_busy = false
		_clear_actions()
		_action_box.add_child(UI.btn(Loc.t("ok"), "primary", func():
			_root.queue_free()
			Game.go("market")))
		return
	_offer = mini(int(_l["ask"]), maxi(_offer, 0))
	_busy = false
	_show_offer_controls()
