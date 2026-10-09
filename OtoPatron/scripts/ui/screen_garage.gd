extends ScreenBase
## İşletmem: galeri kapasitesi, zaman, müşteri ziyaretleri, araçlar ve depo.

var _deal_scene: DealScene
var _actor: ConversationActor
var _chat: VBoxContainer
var _scroll: ScrollContainer
var _action_box: VBoxContainer
var _root: Control
var _visit: Dictionary = {}
var _price: int = 0
var _price_lbl: Label
var _margin_lbl: Label
var _busy: bool = false
var _mood_bar: ProgressBar
var _visit_timers: Array = []
var _gallery_view: String="exterior"
var _section: int = 0
var _visits_count: int = -1

func _ready() -> void:
	super._ready()
	Game.live_tick.connect(_update_visits)

func _update_visits() -> void:
	for entry in _visit_timers:
		var label: Label = entry["label"]
		var visit: Dictionary = entry["visit"]
		if is_instance_valid(label):
			label.text = Loc.t("visit_deadline", [maxi(0, int(ceil(float(visit["expires_at"]) - Game.now_seconds())))])
	if _visits_count != Game.visits.size() and not is_instance_valid(_root):
		rebuild()


func _build() -> void:
	_visit_timers.clear()
	_visits_count = Game.visits.size()
	UI.header(self, Loc.t("garage_title"), "home")
	var sc := UI.scroll_area(self)
	if int(params.get("open", 0)) > 0:
		_section = 1
	if bool(params.get("summary", false)):
		Game.go.call_deferred("business_account")
		return
	_business_overview(sc)
	var tabs := UI.hbox(sc, 6)
	for i in 2:
		var section: int = i
		var title: String = Loc.t(["business_stock_tab", "gallery_buyers"][i])
		if i == 1 and not Game.visits.is_empty():
			title += " · %d" % Game.visits.size()
		tabs.add_child(UI.btn(title, "chipon" if i == _section else "chip", func():
			_section = section
			rebuild(), 46))
	match _section:
		0:
			_cars_section(sc)
			_storage_section(sc)
		1:
			_visits_card(sc)
	UI.spacer(sc, 6)
	if int(params.get("open", 0)) > 0:
		var vid: int = int(params["open"])
		params["open"] = 0
		for v in Game.visits:
			if int(v["id"]) == vid:
				_open_visit.call_deferred(v)


func _kpi(parent: Node, icon: String, value: String, label: String, col: Color = UI.C_TEXT) -> void:
	var p := PanelContainer.new()
	p.add_theme_stylebox_override("panel", UI.sb(UI.C_PANEL, 16, UI.C_LINE, 1, 10, 10))
	p.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var v := UI.vbox(p, 2)
	v.add_child(Ico.new(icon, UI.C_ACCENT, 22))
	v.add_child(UI.lbl(value, 18, col, -1, true, false))
	v.add_child(UI.lbl(label, 11, UI.C_MUTED, -1, false, false))
	parent.add_child(p)


func _business_overview(sc: Node) -> void:
	var c := UI.add_card(sc, UI.C_PANEL, 18, UI.C_LINE)
	c.add_child(UI.lbl(GalleryStyle.title(), 23, UI.C_TEXT, -1, true))
	UI.kv(c, Loc.t("capacity"), "%d / %d" % [Game.cars.size(), Game.garage_cap])
	c.add_child(UI.bar(Game.cars.size(), Game.garage_cap, UI.C_ACCENT, 5))
	var view_tabs:=UI.hbox(c,6)
	for view in ["exterior","interior"]:
		var chosen: String=view
		view_tabs.add_child(UI.btn(Loc.t("lobby_"+view),"chipon" if view==_gallery_view else "chip",func():
			_gallery_view=chosen
			rebuild(),42))
	var stage := LobbyScene.new()
	stage.live=true
	stage.mode=_gallery_view
	stage.customer_pressed.connect(_open_visit)
	c.add_child(stage)
	if not Game.visits.is_empty(): c.add_child(UI.lbl(Loc.t("play_live"),13,UI.C_MUTED))
	c.add_child(UI.btn(Loc.t("history_title"), "ghost", func(): Game.go("sales_history"), 42))
	c.add_child(UI.btn(Loc.t("my_listings"), "ghost", func(): Game.go("listings"), 42))



func _open_time() -> void:
	var content := UI.dialog_card(Loc.t("business_time_action"))
	_time_card(content)
	var root := UI.show_dialog(content)
	content.add_child(UI.btn(Loc.t("cancel"), "ghost", func(): root.queue_free()))


func _time_card(sc: Node) -> void:
	var tc := UI.add_card(sc, UI.C_PANEL, 14, UI.C_LINE)
	var h := UI.hbox(tc, 8)
	h.add_child(Ico.new("clock", UI.C_ACCENT, 22))
	h.add_child(UI.lbl(Loc.t("time_title", [Game.time_str()]), 15, UI.C_TEXT, -1, true, false))
	tc.add_child(UI.lbl(Loc.t("wait_cost_hint", [Loc.money(Game.hour_cost())]), 12, UI.C_MUTED))
	var tr := UI.hbox(tc, 8)
	tr.add_child(_wait_btn(Loc.t("wait_1h"), 60, "chip"))
	tr.add_child(_wait_btn(Loc.t("wait_3h"), 180, "chip"))
	if Game.shop_closed():
		tr.add_child(UI.btn(Loc.t("sleep_free"),"primary",func():
			if Game.end_day():
				for child in UI.overlay.get_children(): child.queue_free()
				rebuild(),64))


func _wait_btn(label: String, mins: int, kind: String) -> Button:
	var b := UI.btn("%s\n%s" % [label, Loc.money(Game.wait_cost(mins))], kind, func():
		for overlay_child in UI.overlay.get_children():
			overlay_child.queue_free()
		var v := UI.dialog_card(Loc.t("time_confirm"))
		v.add_child(UI.lbl(Loc.t("time_quote", [mins, Loc.money(Game.wait_cost(mins))]), 17))
		var root := UI.show_dialog(v)
		v.add_child(UI.btn(Loc.t("ok"), "primary", func():
			root.queue_free()
			if Game.wait_minutes(mins):
				rebuild()))
		v.add_child(UI.btn(Loc.t("cancel"), "ghost", func(): root.queue_free())), 64)
	return b


func _visits_card(sc: Node) -> void:
	var vc := UI.add_card(sc, UI.C_PANEL, 14, UI.C_ACCENT if not Game.visits.is_empty() else UI.C_LINE)
	var hh := UI.hbox(vc, 8)
	hh.add_child(Ico.new("user", UI.C_GOLD if not Game.visits.is_empty() else UI.C_MUTED, 22))
	hh.add_child(UI.lbl(Loc.t("visits_title", [Game.visits.size()]), 17, UI.C_TEXT, -1, true, false))
	if Game.visits.is_empty():
		vc.add_child(UI.lbl(Loc.t("visits_empty"), 13, UI.C_MUTED))
		return
	for v in Game.visits:
		var visit: Dictionary = v
		var car := Game.car_by_uid(int(visit["car_uid"]))
		if car.is_empty():
			continue
		var card := PanelContainer.new()
		card.add_theme_stylebox_override("panel", UI.sb(UI.C_PANEL, 14, UI.C_LINE, 1, 10, 10))
		vc.add_child(card)
		var cv := UI.vbox(card, 6)
		var top := UI.hbox(cv, 10)
		var img := UI.car_image(str(car["model"]), 54, car)
		img.size_flags_stretch_ratio = 0.8
		top.add_child(img)
		var info := UI.vbox(top, 0)
		info.size_flags_stretch_ratio = 1.4
		info.add_child(UI.lbl(str(visit["name"]), 16, UI.C_TEXT, -1, true, false))
		info.add_child(UI.lbl(CarDB.full_name(str(car["model"])), 12, UI.C_MUTED, -1, false, false))
		var pr := UI.hbox(cv, 6)
		pr.add_child(UI.pill(Loc.t("cust_%s" % visit["type"]), UI.C_BLUE))
		pr.add_child(UI.pill(Loc.t("visit_offer", [Loc.money(int(visit["offer"]))]), UI.C_GOLD))
		pr.add_child(UI.pill(Loc.t("visit_list", [Loc.money(int(car["list_price"]))]), UI.C_MUTED))
		if not bool(visit.get("accepted", false)):
			var timer := UI.lbl(Loc.t("visit_deadline", [maxi(0, int(ceil(float(visit["expires_at"]) - Game.now_seconds())))]), 13, UI.C_BAD)
			cv.add_child(timer)
			_visit_timers.append({"label": timer, "visit": visit})
		UI.mood_bar(cv, Loc.t("mood_buyer"), float(visit["mood"]))
		cv.add_child(UI.btn_icon("phone", Loc.t("btn_talk"), "primary", func(): _open_visit(visit), 46))


func _cars_section(sc: Node) -> void:
	sc.add_child(UI.lbl(Loc.t("my_cars"), 18, UI.C_TEXT, -1, true))
	if Game.cars.is_empty():
		var ec := UI.add_card(sc)
		ec.add_child(UI.lbl(Loc.t("garage_empty"), 15, UI.C_MUTED, HORIZONTAL_ALIGNMENT_CENTER))
		ec.add_child(UI.btn(Loc.t("menu_market"), "primary", func(): Game.go("market"), 50))
	for c in Game.cars:
		var car: Dictionary = c
		var card := UI.add_card(sc)
		var top := UI.hbox(card, 10)
		var img := UI.car_image(str(car["model"]), 108, car)
		img.size_flags_stretch_ratio = 0.9
		top.add_child(img)
		var info := UI.vbox(top, 2)
		info.size_flags_stretch_ratio = 1.1
		info.add_child(UI.lbl(CarDB.full_name(str(car["model"])), 17, UI.C_TEXT, -1, true))
		info.add_child(UI.lbl("%d • %s km" % [int(car["year"]), Loc.num(int(car["km"]))], 13, UI.C_MUTED))
		if bool(car["listed"]):
			info.add_child(UI.pill(Loc.t("listed_at", [Loc.money(int(car["list_price"]))]), UI.C_GOOD))
		else:
			info.add_child(UI.pill(Loc.t("not_listed"), UI.C_MUTED))
		var uid: int = int(car["uid"])
		card.add_child(UI.btn_icon("wrench", Loc.t("btn_manage"), "ghost", func(): Game.go("car", {"uid": uid}), 46))


func _storage_section(sc: Node) -> void:
	if Game.storage.is_empty():
		return
	sc.add_child(UI.lbl(Loc.t("storage_title", [Game.storage.size(), Game.STORAGE_CAP]), 18, UI.C_TEXT, -1, true))
	for i in Game.storage.size():
		var idx: int = i
		var sc_car: Dictionary = Game.storage[i]
		var card2 := UI.add_card(sc)
		card2.add_child(UI.lbl("%s • %d" % [CarDB.full_name(str(sc_car["model"])), int(sc_car["year"])], 16, UI.C_TEXT, -1, true))
		var r2 := UI.hbox(card2, 8)
		r2.add_child(UI.btn(Loc.t("btn_to_garage"), "chip", func():
			if Game.storage_to_garage(idx):
				Fx.play("success")
				rebuild()
			else:
				Game.toast(Loc.t("err_no_space"), "bad"), 46))
		r2.add_child(UI.btn(Loc.t("btn_to_market", [Loc.money(int(Game.car_value(sc_car) * 0.85))]), "ghost", func():
			Game.storage_sell(idx)
			rebuild(), 46))


func _on_upgrade() -> void:
	var upgrade: Dictionary = Game.next_garage_upgrade()
	if upgrade.is_empty():
		return
	var v := UI.dialog_card(Loc.t("garage_develop"))
	v.add_child(UI.lbl(Loc.t("garage_quote", [upgrade["cap"], Loc.money(int(upgrade["cost"]))]), 17))
	var root := UI.show_dialog(v)
	v.add_child(UI.btn(Loc.t("ok"), "primary", func():
		root.queue_free()
		_apply_upgrade()))
	v.add_child(UI.btn(Loc.t("cancel"), "ghost", func(): root.queue_free()))

func _apply_upgrade() -> void:
	var r := Game.upgrade_garage()
	if r == "ok":
		Game.toast(Loc.t("toast_upgraded", [Game.garage_cap]), "good")
		rebuild()
	elif r == "level":
		Game.toast(Loc.t("err_level"), "bad")
		Fx.play("error")
	else:
		Game.toast(Loc.t("err_no_money"), "bad")
		Fx.play("error")


# ------------------------------------------------------------------ müşteri diyaloğu
func _open_visit(v: Dictionary) -> void:
	if not Game.accept_visit(v):
		return
	_visit = v
	var car := Game.car_by_uid(int(v["car_uid"]))
	if car.is_empty():
		return
	_price = int(car["list_price"])
	var card := UI.dialog_card(Loc.t("visit_title", [str(v["name"])]))
	var content_scroll := ScrollContainer.new()
	content_scroll.custom_minimum_size = Vector2(0, minf(580, maxf(280, UI.overlay.size.y-160)))
	content_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	card.add_child(content_scroll)
	var body := UI.vbox(null, 8)
	content_scroll.add_child(body)
	_actor = ConversationActor.new()
	_actor.identity = str(v["name"])
	_actor.mood = float(v["mood"])
	body.add_child(_actor)
	_deal_scene=DealScene.new()
	_deal_scene.car=car.duplicate(true)
	body.add_child(_deal_scene)
	body.add_child(UI.lbl("%s • %s" % [Loc.t("cust_%s" % v["type"]), CarDB.full_name(str(car["model"]))], 14, UI.C_MUTED, HORIZONTAL_ALIGNMENT_CENTER))
	_mood_bar = UI.mood_bar(body, Loc.t("mood_buyer"), float(v["mood"]))
	var sc := ScrollContainer.new()
	sc.custom_minimum_size = Vector2(0, 140)
	sc.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_scroll = sc
	_chat = UI.vbox(null, 8)
	sc.add_child(_chat)
	body.add_child(sc)
	_action_box = UI.vbox(body, 8)
	_root = UI.show_dialog(card)
	Game.begin_negotiation()
	_root.tree_exited.connect(Game.end_negotiation, CONNECT_ONE_SHOT)
	_bubble(Loc.t_rand("cust_greet", [Loc.money(int(v["offer"]))]), false)
	_bubble(Loc.t("cust_details", [int(car["year"]), Loc.num(int(car["km"]))]), true)
	_bubble(Loc.t("buyer_concern_" + Game.buyer_concern(v)), false)
	Game.advance(10)
	_visit_controls()


func _bubble(text: String, mine: bool, tint: Color = UI.C_PANEL2) -> Label:
	Fx.play("msg_out" if mine else "msg_in")
	var row := UI.hbox(_chat, 0)
	var p := PanelContainer.new()
	p.add_theme_stylebox_override("panel", UI.sb(UI.C_PANEL2 if mine else (UI.C_PANEL2 if tint.get_luminance() < 0.1 else tint), 14, UI.C_ACCENT if mine else UI.C_LINE, 1, 12, 8))
	var l := UI.lbl(text, 15, UI.C_TEXT, -1, false)
	l.custom_minimum_size = Vector2(220, 0)
	l.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	p.add_child(l)
	p.size_flags_horizontal = Control.SIZE_SHRINK_END if mine else Control.SIZE_SHRINK_BEGIN
	row.add_child(p)
	UI.fade_in(p, 0.22)
	l.visible_ratio = 0.0
	l.create_tween().tween_property(l, "visible_ratio", 1.0, minf(2.2, text.length() / 40.0))
	if is_instance_valid(_actor):
		_actor.mood = float(_visit.get("mood", 100))
		_actor.speak(minf(2.2, text.length() / 40.0))
	if is_instance_valid(_scroll):
		_scroll.call_deferred("set", "scroll_vertical", 100000)
	return l


func _clear_actions() -> void:
	for c in _action_box.get_children():
		_action_box.remove_child(c)
		c.queue_free()


func _visit_controls() -> void:
	_clear_actions()
	var car := Game.car_by_uid(int(_visit["car_uid"]))
	if car.is_empty(): return
	if not bool(_visit.get("concern_answered", false)):
		_action_box.add_child(UI.lbl(Loc.t("buyer_choose"), 14, UI.C_ACCENT, -1, true))
		for choice in ["honest", "care", "discount"]:
			if choice == "care" and not Game.can_explain_care(car): continue
			var response: String = choice
			_action_box.add_child(UI.btn(Loc.t("buyer_answer_"+choice), "ghost", func(): _answer_concern(response), 42))
	var expected: int = _price - int(car["bought_price"]) - int(car["invested"])
	_margin_lbl = UI.lbl(Loc.t("deal_margin", [Loc.money(expected)]), 13, UI.C_GOOD if expected >= 0 else UI.C_BAD, HORIZONTAL_ALIGNMENT_CENTER)
	_action_box.add_child(_margin_lbl)
	if not bool(_visit.get("test_drive_done", false)):
		_action_box.add_child(UI.btn(Loc.t("drive_start"), "ghost", _start_test_drive, 42))
	else:
		_action_box.add_child(UI.lbl(Loc.t("drive_done"), 12, UI.C_MUTED, HORIZONTAL_ALIGNMENT_CENTER))
	_action_box.add_child(UI.btn(Loc.t("btn_accept_offer", [Loc.money(int(_visit["offer"]))]), "primary", func(): _accept_current_offer(), 54))
	_action_box.add_child(UI.btn(Loc.t("trade_open"), "ghost", func():
		var id: int = int(_visit["id"])
		_root.queue_free()
		Game.go("trade", {"visit": id}), 44))
	var buyer_profit: int = int(_visit["offer"]) - int(car["bought_price"]) - int(car["invested"])
	_action_box.add_child(UI.lbl(Loc.t("buyer_offer_margin", [Loc.money(buyer_profit)]), 12, UI.C_GOOD if buyer_profit >= 0 else UI.C_BAD, HORIZONTAL_ALIGNMENT_CENTER))
	_action_box.add_child(UI.lbl(Loc.t("your_counter"), 13, UI.C_MUTED, HORIZONTAL_ALIGNMENT_CENTER))
	var row := UI.hbox(_action_box, 8)
	var step := maxi(500, Game.r500(int(car["list_price"]) * 0.01))
	var minus := UI.btn("−", "chip", func():
		_price = maxi(step, _price - step)
		_update_price_margin(), 50)
	minus.custom_minimum_size.x = 64
	minus.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	row.add_child(minus)
	_price_lbl = UI.lbl(Loc.money(_price), 22, UI.C_GOLD, HORIZONTAL_ALIGNMENT_CENTER, true, false)
	row.add_child(_price_lbl)
	var plus := UI.btn("+", "chip", func():
		_price += step
		_update_price_margin(), 50)
	plus.custom_minimum_size.x = 64
	plus.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	row.add_child(plus)
	_action_box.add_child(UI.btn(Loc.t("btn_send_counter"), "ghost", _send_counter, 50))
	_action_box.add_child(UI.btn(Loc.t("btn_dismiss"), "danger", func():
		Game.dismiss_visit(_visit)
		_root.queue_free()
		rebuild(), 46))


func _answer_concern(choice: String) -> void:
	if _busy: return
	var result := Game.answer_buyer(_visit, choice, _price)
	if result.is_empty(): return
	_price = int(result["counter"])
	_bubble(Loc.t("buyer_answer_"+choice), true)
	_bubble(Loc.t("buyer_reply_"+choice), false)
	UI.set_mood(_mood_bar, float(_visit["mood"]))
	_visit_controls()

func _start_test_drive() -> void:
	if _busy or bool(_visit.get("test_drive_done",false)): return
	var car := Game.car_by_uid(int(_visit.get("car_uid",0)))
	if car.is_empty() or not Game.visits.has(_visit): return
	_busy = true
	var card := UI.dialog_card(Loc.t("play_drive"))
	card.add_child(UI.lbl(Loc.t("play_drive_hint"),14,UI.C_MUTED))
	var stage := PlayableDrive.new(str(car["model"]))
	stage.custom_minimum_size.y = minf(320,maxf(230,UI.overlay.size.y-340))
	card.add_child(stage)
	var root := UI.show_dialog(card)
	var go := UI.btn(Loc.t("play_drive_go"),"primary",func(): stage.start(),46)
	card.add_child(go)
	go.pressed.connect(func(): go.hide())
	root.tree_exited.connect(func(): _busy=false,CONNECT_ONE_SHOT)
	stage.finished.connect(func(score: int):
		if not is_instance_valid(_root): root.queue_free(); return
		var result := Game.test_drive(_visit,score)
		root.queue_free()
		_busy = false
		if result.is_empty(): return
		_bubble(Loc.t("play_drive_finish",[score]),true)
		_bubble(Loc.t("drive_result",[result["score"],Loc.money(int(result["offer"])),("+" if int(result["delta"])>=0 else "")+Loc.money(int(result["delta"]))]),false)
		_visit_controls())
	card.add_child(UI.btn(Loc.t("cancel"),"ghost",func(): root.queue_free(),46))


func _send_counter() -> void:
	if _busy:
		return
	_busy = true
	var price := _price
	_clear_actions()
	_bubble(Loc.t_rand("counter_bubble", [Loc.money(price)]), true)
	var typing := _bubble("…", false)
	await get_tree().create_timer(Game.rng.randf_range(1.0, 2.0)).timeout
	if not is_inside_tree() or not is_instance_valid(_root):
		return
	typing.get_parent().get_parent().queue_free()
	var res := Game.customer_reply(_visit, price)
	Game.advance(5)
	_busy = false
	UI.set_mood(_mood_bar, float(_visit["mood"]))
	if is_instance_valid(_deal_scene): _deal_scene.respond(str(res["kind"]))
	match str(res["kind"]):
		"accept":
			_bubble(Loc.t_rand("cust_accept"), false, Color("dff2e8"))
			_action_box.add_child(UI.btn(Loc.t("finish_sale"), "primary", func(): _complete_sale(int(res["price"])), 54))
		"counter":
			_bubble(Loc.t_rand("cust_counter", [Loc.money(int(res["price"]))]), false)
			_visit_controls()
		"low":
			Fx.play("error")
			_bubble(Loc.t_rand("cust_low"), false, Color("f3edf3"))
			_visit_controls()
		_:
			Fx.play("error")
			Fx.vibrate(40)
			_bubble(Loc.t_rand("cust_leave"), false, Color("fae8e9"))
			Game.dismiss_visit(_visit)
			_clear_actions()
			_action_box.add_child(UI.btn(Loc.t("ok"), "primary", func():
				_root.queue_free()
				rebuild()))


func _update_price_margin() -> void:
	_price_lbl.text = Loc.money(_price)
	var car: Dictionary = Game.car_by_uid(int(_visit["car_uid"]))
	if car.is_empty(): return
	var profit: int = _price - int(car["bought_price"]) - int(car["invested"])
	_margin_lbl.text = Loc.t("deal_margin", [Loc.money(profit)])
	_margin_lbl.add_theme_color_override("font_color", UI.resolve(UI.C_GOOD if profit >= 0 else UI.C_BAD))


func _complete_sale(price: int) -> void:
	var car: Dictionary = Game.car_by_uid(int(_visit["car_uid"]))
	if car.is_empty(): return
	var profit: int = price - int(car["bought_price"]) - int(car["invested"])
	if profit < 0:
		var content := UI.dialog_card(Loc.t("loss_sale_title"))
		content.add_child(UI.lbl(Loc.t("loss_sale_body", [Loc.money(-profit)]), 16, UI.C_BAD, HORIZONTAL_ALIGNMENT_CENTER))
		var confirmation := UI.show_dialog(content)
		content.add_child(UI.lbl(Loc.t("loss_cancel_hint"), 13, UI.C_MUTED))
		content.add_child(UI.btn(Loc.t("loss_cancel"), "ghost", func():
			confirmation.queue_free()
			Game.dismiss_visit(_visit)
			if is_instance_valid(_root): _root.queue_free()
			rebuild()))
		content.add_child(UI.btn(Loc.t("loss_confirm"), "danger", func():
			confirmation.queue_free()
			_finalize_sale(price)))
		return
	_finalize_sale(price)


func _finalize_sale(price: int) -> void:
	var car := Game.car_by_uid(int(_visit["car_uid"]))
	if car.is_empty():
		return
	var res := Game.finalize_sale(car, price, 0, str(_visit.get("name", "")))
	if is_instance_valid(_root):
		_root.queue_free()
	if res.is_empty():
		return
	rebuild()
	show_sale_result(res)


static func show_sale_result(res: Dictionary) -> void:
	var car: Dictionary = res["car"]
	var v := UI.dialog_card(Loc.t("sale_title"))
	var scroll:=ScrollContainer.new()
	scroll.horizontal_scroll_mode=ScrollContainer.SCROLL_MODE_DISABLED
	scroll.custom_minimum_size.y=minf(530,maxf(230,UI.overlay.size.y-250))
	v.add_child(scroll)
	var body:=UI.vbox(null,12)
	body.size_flags_horizontal=Control.SIZE_EXPAND_FILL
	scroll.add_child(body)
	var delivery:=DealScene.new()
	delivery.car=car.duplicate(true)
	delivery.delivery=true
	body.add_child(delivery)
	body.add_child(UI.lbl(CarDB.full_name(str(car["model"])), 18, UI.C_TEXT, HORIZONTAL_ALIGNMENT_CENTER, true))
	var box := UI.add_card(body, UI.C_PANEL2, 12)
	UI.kv(box, Loc.t("sale_income"), Loc.money(int(res["price"])), UI.C_GOLD)
	UI.kv(box, Loc.t("sale_bought"), "- " + Loc.money(int(res["bought"])), UI.C_MUTED)
	UI.kv(box, Loc.t("sale_expenses"), "- " + Loc.money(int(res["invested"])), UI.C_MUTED)
	UI.divider(box)
	var profit := int(res["profit"])
	UI.kv(box, Loc.t("sale_net"), Loc.money(profit), UI.C_GOOD if profit >= 0 else UI.C_BAD)
	UI.kv(box, Loc.t("sale_xp"), "+%d XP · +%d ♦" % [int(res["xp"]), int(res.get("diamonds", 2))], UI.C_ACCENT)
	var review: Dictionary = res.get("review", {})
	if not review.is_empty():
		UI.kv(box, Loc.t("customer_rating"), "%d / 5" % int(review["score"]), UI.C_GOLD)
		box.add_child(UI.lbl(Loc.t(str(review["comment"])), 13, UI.C_MUTED))
	var ni: Dictionary = res["installment"]
	if ni.is_empty():
		UI.kv(box, Loc.t("sale_installment"), Loc.t("none"), UI.C_MUTED)
	else:
		UI.kv(box, Loc.t("sale_installment"), Loc.money(int(ni["amount"])), UI.C_MUTED)
	UI.kv(box, Loc.t("debt_total"), Loc.money(int(res["debt"])), UI.C_MUTED)
	Fx.play("coin")
	var root := UI.show_dialog(v)
	if bool(res["leveled"]):
		v.add_child(UI.lbl(Loc.t("level_up_line", [Game.level]), 18, UI.C_GOLD, HORIZONTAL_ALIGNMENT_CENTER, true))
		v.add_child(UI.btn_icon("crate", Loc.t("btn_pick_reward"), "primary", func():
			root.queue_free()
			Game.go("rewards"), 56))
	v.add_child(UI.btn(Loc.t("btn_continue_game"), "ghost", func(): root.queue_free(), 50))


func _bill_card(sc: Node) -> void:
	var c := UI.add_card(sc, UI.C_PANEL)
	var items := BusinessLedger.charges(Game.level, Game.garage_cap, Game.listing_rank, Game.business_owned)
	c.add_child(UI.lbl(Loc.t("business_account"), 19, UI.C_TEXT, -1, true))
	c.add_child(UI.pill(Loc.t("property_owned" if Game.business_owned else "property_rented"), UI.C_ACCENT))
	UI.kv(c, Loc.t("property_price"), Loc.money(Game.business_price_paid if Game.business_owned else Game.business_purchase_price()), UI.C_ACCENT)
	UI.kv(c, Loc.t("bill_total"), Loc.money(BusinessLedger.total(items)), UI.C_BAD)
	var row := UI.hbox(c, 8)
	row.add_child(UI.btn(Loc.t("expense_details"), "ghost", _show_expenses, 44))
	if not Game.business_owned:
		row.add_child(UI.btn(Loc.t("buy_property"), "primary", _confirm_property, 44))
	if not Game.daily_summary.is_empty():
		c.add_child(UI.btn(Loc.t("day_report"), "chip", func(): _show_day_report(), 44))
	c.add_child(UI.btn_icon("bank", Loc.t("bank_open"), "ghost", func(): Game.go("loans"), 44))
	if bool(params.get("summary", false)):
		params["summary"] = false
		_show_day_report.call_deferred()

func _show_expenses() -> void:
	var v := UI.dialog_card(Loc.t("bills_title"))
	var items := BusinessLedger.charges(Game.level, Game.garage_cap, Game.listing_rank, Game.business_owned)
	for key in items:
		UI.kv(v, Loc.t("bill_" + key), Loc.money(int(items[key])))
	UI.kv(v, Loc.t("bill_total"), Loc.money(BusinessLedger.total(items)), UI.C_BAD)
	v.add_child(UI.lbl(Loc.t("tax_hint"), 13, UI.C_MUTED))
	var root := UI.show_dialog(v)
	v.add_child(UI.btn(Loc.t("ok"), "primary", func(): root.queue_free()))

func _confirm_property() -> void:
	var v := UI.dialog_card(Loc.t("buy_property"))
	v.add_child(UI.lbl(Loc.t("property_hint", [Loc.money(Game.business_purchase_price())]), 16, UI.C_TEXT))
	var root := UI.show_dialog(v)
	v.add_child(UI.btn(Loc.t("buy_asset"), "primary", func():
		Game.buy_business()
		root.queue_free()
		rebuild()))
	v.add_child(UI.btn(Loc.t("cancel"), "ghost", func(): root.queue_free()))

func _show_day_report() -> void:
	var report := Game.daily_summary
	if report.is_empty():
		return
	var v := UI.dialog_card(Loc.t("day_report"))
	v.add_child(UI.lbl(Game.date_str(), 13, UI.C_MUTED, HORIZONTAL_ALIGNMENT_CENTER))
	UI.kv(v, Loc.t("yesterday_income"), Loc.money(int(report.get("previous_income", 0))), UI.C_GOOD)
	UI.kv(v, Loc.t("yesterday_expenses"), Loc.money(int(report.get("previous_expenses", 0))), UI.C_BAD)
	for key in ["rent", "power", "staff", "team", "advertising", "maintenance", "monthly_tax", "yearly_tax", "loans", "street_payment"]:
		if int(report.get(key, 0)) > 0:
			UI.kv(v, Loc.t("bill_" + key), "−" + Loc.money(int(report[key])), UI.C_BAD)
	if report.has("portfolio_change"):
		UI.kv(v, Loc.t("realized_result"), Loc.money(int(report.get("investment_realized", 0))), UI.C_GOOD if int(report.get("investment_realized", 0)) >= 0 else UI.C_BAD)
		var delta := int(report["portfolio_change"])
		UI.kv(v, Loc.t("portfolio_day_result"), Loc.money(delta), UI.C_GOOD if delta >= 0 else UI.C_BAD)
		for item in report.get("portfolio_assets", []):
			UI.kv(v, Loc.t("asset_" + str(item["id"])), Loc.money(int(item["change"])), UI.C_GOOD if int(item["change"]) >= 0 else UI.C_BAD)
		v.add_child(UI.lbl(Loc.t("portfolio_day_hint"), 12, UI.C_MUTED))
	UI.divider(v)
	UI.kv(v, Loc.t("balance"), Loc.money(int(report.get("closing", Game.money))), UI.C_ACCENT)
	var root := UI.show_dialog(v)
	v.add_child(UI.btn(Loc.t("ok"), "primary", func(): root.queue_free()))


func _accept_current_offer() -> void:
	if _busy:
		return
	_busy = true
	var price := int(_visit["offer"])
	_clear_actions()
	_bubble(Loc.t_rand("counter_bubble", [Loc.money(price)]), true)
	await get_tree().create_timer(1.2).timeout
	if not is_inside_tree() or not is_instance_valid(_root):
		return
	if is_instance_valid(_deal_scene): _deal_scene.respond("accept")
	_bubble(Loc.t_rand("cust_accept"), false, UI.C_GOOD.darkened(0.8))
	_busy = false
	_action_box.add_child(UI.btn(Loc.t("finish_sale"), "primary", func(): _complete_sale(price), 54))
