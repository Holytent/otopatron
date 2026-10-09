extends Control
## Kök sahne: tema, güvenli alan, HUD, alt gezinme çubuğu, ekran geçişleri ve bildirimler.

const SCREENS: Dictionary = {
	"auction": "res://scripts/ui/screen_auction.gd",
	"gameplay": "res://scripts/ui/screen_gameplay.gd",
	"business_account": "res://scripts/ui/screen_business_account.gd",
	"management": "res://scripts/ui/screen_management.gd",
	"staff": "res://scripts/ui/screen_staff.gd",
	"trade": "res://scripts/ui/screen_trade.gd",
	"street": "res://scripts/ui/screen_street.gd",
	"splash": "res://scripts/ui/screen_splash.gd",
	"home": "res://scripts/ui/screen_home.gd",
	"market": "res://scripts/ui/screen_market.gd",
	"listing": "res://scripts/ui/screen_listing.gd",
	"garage": "res://scripts/ui/screen_garage.gd",
	"sales_history": "res://scripts/ui/screen_sales_history.gd",
	"car": "res://scripts/ui/screen_car.gd",
	"car_closeup": "res://scripts/ui/screen_car_closeup.gd",
	"training": "res://scripts/ui/screen_training.gd",
	"loans": "res://scripts/ui/screen_loans.gd",
	"settings": "res://scripts/ui/screen_settings.gd",
	"profile": "res://scripts/ui/screen_profile.gd",
	"rewards": "res://scripts/ui/screen_rewards.gd",
	"listings": "res://scripts/ui/screen_listings.gd",
	"finance": "res://scripts/ui/screen_finance.gd",
	"shop": "res://scripts/ui/screen_shop.gd",
	"workshop": "res://scripts/ui/screen_workshop.gd",
	"bankruptcy": "res://scripts/ui/screen_bankruptcy.gd",
}
const NAV: Array = [
	{"id": "home", "icon": "home", "label": "nav_home", "covers": ["home"]},
	{"id": "garage", "icon": "garage", "label": "nav_garage", "covers": ["garage", "trade", "car", "car_closeup", "listings", "sales_history"]},
	{"id": "market", "icon": "market", "label": "nav_market", "covers": ["market", "listing", "gameplay", "auction"]},
	{"id": "training", "icon": "school", "label": "nav_training", "covers": ["training"]},
	{"id": "management", "icon": "gear", "label": "management_title", "covers": ["management", "staff", "workshop", "business_account", "street", "finance", "loans", "shop", "rewards", "settings", "profile"]},
]

var _sleep_button: Button
var _alarm: Button
var _alarm_time: float = 0.0
var _margin: MarginContainer
var _root_v: VBoxContainer
var _hud: PanelContainer
var _holder: Control
var _nav: PanelContainer
var _toast_box: VBoxContainer
var _current: Control = null
var cur_name: String = ""
var cur_params: Dictionary = {}

var _hud_gems: Button
var _hud_gems_label: Label
var _hud_money_button: Button
var _summary_day: int = -1
var _hud_money: Label
var _hud_time: Label
var _hud_level: Label
var _hud_xpbar: ProgressBar
var _hud_xptext: Label
var _nav_buttons: Dictionary = {}
var _banner: Control = null
var _badge: PanelContainer = null
var _badge_lbl: Label = null
var _web_frame_time: float = 0.0
var _rate_timer: float = 0.0
var _page_visible: bool = true

func _process(delta: float) -> void:
	if is_instance_valid(_alarm) and _alarm.visible:
		_alarm_time += delta
		_alarm.modulate.a = .88 + .12*sin(_alarm_time*5)
	if OS.has_feature("web") or OS.has_feature("mobile"):
		_rate_timer -= delta
		if _rate_timer <= 0.0:
			_rate_timer = 0.2
			if OS.has_feature("web"): _page_visible = bool(JavaScriptBridge.eval("!document.hidden", true))
		var active: bool = MobileScroll.is_interacting()
		if not active:
			for animation in get_tree().get_nodes_in_group("light_animations"):
				if animation.animation_visible():
					active = true
					break
		var target_rate: int = (60 if active else 30) if _page_visible else 15
		if Engine.max_fps != target_rate: Engine.max_fps = target_rate
	if not OS.has_feature("web"): return
	_web_frame_time += delta
	if _web_frame_time >= 2.0:
		_web_frame_time = 0.0
		JavaScriptBridge.eval("window.otoStartup?.frame()", true)


func _ready() -> void:
	if OS.has_feature("web") or OS.has_feature("mobile"):
		Engine.max_fps = 30
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	UI.dark = bool(Game.settings.get("dark_mode", false))
	theme = UI.build_theme()
	var bg := ColorRect.new()
	bg.color = UI.resolve(UI.C_BG, true)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)
	_margin = MarginContainer.new()
	_margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(_margin)
	_root_v = VBoxContainer.new()
	_root_v.add_theme_constant_override("separation", 8)
	_margin.add_child(_root_v)
	_holder = Control.new()
	_holder.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_holder.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_holder.clip_contents = true
	_build_chrome()
	var ov := Control.new()
	ov.set_anchors_preset(Control.PRESET_FULL_RECT)
	ov.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(ov)
	UI.overlay = ov
	_toast_box = VBoxContainer.new()
	_toast_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_toast_box.add_theme_constant_override("separation", 6)
	_root_v.add_child(_toast_box)
	_root_v.move_child(_toast_box, 1)
	_toast_box.hide()
	_alarm = UI.btn("", "danger", func():
		if int(Game.flags.get("security",0))==0: Game.resolve_theft(false),44)
	_alarm.clip_text = true
	_alarm.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	_alarm.add_theme_stylebox_override("disabled",UI.sb(Color("ba273c"),12))
	_alarm.add_theme_color_override("font_disabled_color",Color.WHITE)
	_root_v.add_child(_alarm)
	_root_v.move_child(_alarm,1)
	_alarm.hide()
	_sleep_button = UI.btn(Loc.t("sleep_free"),"primary",func():
		if Game.end_day():
			show_screen("home",{}),48)
	_root_v.add_child(_sleep_button)
	_root_v.move_child(_sleep_button,2)
	_sleep_button.hide()
	Game.live_tick.connect(_sync_alarm)
	_toast_box.child_exiting_tree.connect(func(_node: Node):
		call_deferred("_sync_toast_visibility"))
	_apply_safe_area()
	get_viewport().size_changed.connect(_apply_safe_area)
	Game.navigate.connect(show_screen)
	Game.toast_req.connect(_show_toast)
	Game.changed.connect(_refresh_hud)
	Game.visit_arrived.connect(_show_visit_banner)
	Game.market_deal_arrived.connect(_show_market_deal)
	Loc.language_changed.connect(_on_language_changed)
	Game.theme_changed.connect(_theme_changed)
	_apply_direction()
	show_screen("splash", {})
	if "--life-audit" in OS.get_cmdline_user_args():
		add_child(load("res://scripts/dev/life_audit.gd").new())
	elif "--lobby-audit" in OS.get_cmdline_user_args():
		add_child(load("res://scripts/dev/lobby_audit.gd").new())
	elif "--hours-audit" in OS.get_cmdline_user_args():
		add_child(load("res://scripts/dev/hours_audit.gd").new())
	elif "--fix-audit" in OS.get_cmdline_user_args():
		add_child(load("res://scripts/dev/fix_audit.gd").new())
	elif "--gameplay-audit" in OS.get_cmdline_user_args():
		add_child(load("res://scripts/dev/gameplay_audit.gd").new())
	elif "--expansion-audit" in OS.get_cmdline_user_args():
		add_child(load("res://scripts/dev/expansion_audit.gd").new())
	elif "--closeup-audit" in OS.get_cmdline_user_args():
		add_child(load("res://scripts/dev/closeup_audit.gd").new())
	elif "--sales-audit" in OS.get_cmdline_user_args():
		add_child(load("res://scripts/dev/sales_audit.gd").new())
	elif "--scroll-audit" in OS.get_cmdline_user_args():
		add_child(load("res://scripts/dev/scroll_audit.gd").new())
	elif "--management-audit" in OS.get_cmdline_user_args():
		add_child(load("res://scripts/dev/management_audit.gd").new())
	elif "--road-audit" in OS.get_cmdline_user_args():
		add_child(load("res://scripts/dev/road_audit.gd").new())
	elif "--navigation-audit" in OS.get_cmdline_user_args():
		add_child(load("res://scripts/dev/navigation_audit.gd").new())
	elif "--deep-audit" in OS.get_cmdline_user_args():
		add_child(load("res://scripts/dev/deep_audit.gd").new())
	elif "--dirt-preview" in OS.get_cmdline_user_args():
		add_child(load("res://scripts/dev/dirt_preview.gd").new())
	elif "--actors-audit" in OS.get_cmdline_user_args():
		add_child(load("res://scripts/dev/actors_audit.gd").new())
	elif "--orders-audit" in OS.get_cmdline_user_args():
		add_child(load("res://scripts/dev/orders_audit.gd").new())
	elif "--car-audit" in OS.get_cmdline_user_args():
		add_child(load("res://scripts/dev/car_audit.gd").new())
	elif "--gallery-audit" in OS.get_cmdline_user_args():
		var audit = load("res://scripts/dev/gallery_audit.gd").new()
		add_child(audit)
	elif "--layout-audit" in OS.get_cmdline_user_args():
		var audit: Node = load("res://scripts/dev/layout_audit.gd").new()
		add_child(audit)
		audit.run(self)
	if "--shots" in OS.get_cmdline_user_args():
		var sh: Node = load("res://scripts/dev/shots.gd").new()
		add_child(sh)
		sh.run(self)
	if "--econ" in OS.get_cmdline_user_args():
		var ec: Node = load("res://scripts/dev/econ_sim.gd").new()
		add_child(ec)
		ec.run(self)
	if "--smoke" in OS.get_cmdline_user_args():
		var st: Node = load("res://scripts/dev/smoke_test.gd").new()
		add_child(st)
		st.run(self)


func _apply_safe_area() -> void:
	var top := 10.0
	var bottom := 10.0
	var sa: Rect2i = DisplayServer.get_display_safe_area()
	var win: Vector2i = DisplayServer.window_get_size()
	if OS.has_feature("mobile") and sa.size.x > 0 and win.x > 0 and win.y > 0:
		var sc := get_viewport_rect().size.y / float(win.y)
		top = maxf(10.0, sa.position.y * sc + 6.0)
		bottom = maxf(10.0, (win.y - sa.end.y) * sc + 6.0)
	_margin.add_theme_constant_override("margin_top", int(top))
	_margin.add_theme_constant_override("margin_bottom", int(bottom))
	var side := int(maxf(14.0, (get_viewport_rect().size.x - 540.0) / 2.0 + 14.0))
	_margin.add_theme_constant_override("margin_left", side)
	_margin.add_theme_constant_override("margin_right", side)


# ------------------------------------------------------------------ HUD + alt gezinme
func _build_chrome() -> void:
	if is_instance_valid(_sleep_button) and _sleep_button.get_parent()==_root_v: _root_v.remove_child(_sleep_button)
	if is_instance_valid(_alarm) and _alarm.get_parent()==_root_v: _root_v.remove_child(_alarm)
	if is_instance_valid(_toast_box) and _toast_box.get_parent() == _root_v:
		_root_v.remove_child(_toast_box)
	if _holder.get_parent() == _root_v:
		_root_v.remove_child(_holder)
	for c in _root_v.get_children():
		_root_v.remove_child(c)
		c.queue_free()
	_nav_buttons.clear()
	# HUD
	_hud = PanelContainer.new()
	_hud.add_theme_stylebox_override("panel", UI.sb(UI.C_PANEL, 18, UI.C_LINE, 1, 14, 12))
	var hv := UI.vbox(_hud, 4)
	UI.spacer(hv, 4)
	var wallet_title := UI.lbl(Loc.t("wallet_title"), 13, UI.C_TEXT, -1, true)
	wallet_title.custom_minimum_size.y = 24
	wallet_title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	hv.add_child(wallet_title)
	var r1 := UI.hbox(hv, 8)
	_hud_money_button = UI.btn("", "primary", func(): show_screen("shop", {"tab": "cash"}), 34)
	_hud_money_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_hud_money_button.clip_text = true
	r1.add_child(_hud_money_button)
	_hud_gems = UI.btn_icon("diamond", "", "chip", func(): show_screen("shop", {"tab": "gems"}), 34)
	_hud_gems_label = _hud_gems.get_child(0).get_child(0).get_child(1)
	_hud_gems.size_flags_horizontal = Control.SIZE_SHRINK_END
	_hud_gems.custom_minimum_size.x = 100
	_hud_gems_label.add_theme_font_size_override("font_size",16)
	_hud_gems_label.text_overrun_behavior=TextServer.OVERRUN_NO_TRIMMING
	_hud_gems_label.clip_text=false
	r1.add_child(_hud_gems)
	_hud_money_button.add_theme_color_override("font_color", Color.WHITE)
	_hud_money_button.add_theme_font_size_override("font_size", 18)
	_hud_money_button.add_theme_stylebox_override("normal", UI.sb(Color("102537"), 14,UI.C_GOLD,1))
	_hud_money_button.add_theme_stylebox_override("pressed", UI.sb(UI.C_PANEL2, 14))
	_hud_gems.add_theme_color_override("font_color", UI.resolve(UI.C_BLUE))
	var date_row := UI.hbox(hv, 6)
	date_row.add_child(Ico.new("clock", UI.C_MUTED, 18))
	_hud_time = UI.lbl("", 12, UI.C_MUTED, HORIZONTAL_ALIGNMENT_RIGHT if not Loc.is_rtl() else HORIZONTAL_ALIGNMENT_LEFT, false, false)
	_hud_time.size_flags_horizontal = Control.SIZE_SHRINK_END
	date_row.add_child(_hud_time)
	var r2 := UI.hbox(hv, 8)
	_hud_level = UI.lbl("", 14, UI.C_ACCENT, -1, true, false)
	_hud_level.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	r2.add_child(_hud_level)
	_hud_xpbar = UI.bar(0, 1, UI.C_ACCENT, 8)
	_hud_xpbar.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	r2.add_child(_hud_xpbar)
	_hud_xptext = UI.lbl("", 12, UI.C_MUTED, -1, false, false)
	_hud_xptext.size_flags_horizontal = Control.SIZE_SHRINK_END
	r2.add_child(_hud_xptext)
	_root_v.add_child(_hud)
	if is_instance_valid(_alarm): _root_v.add_child(_alarm)
	if is_instance_valid(_toast_box): _root_v.add_child(_toast_box)
	if is_instance_valid(_sleep_button): _root_v.add_child(_sleep_button)
	_root_v.add_child(_holder)
	# Alt gezinme
	_nav = PanelContainer.new()
	_nav.add_theme_stylebox_override("panel", UI.sb(UI.C_PANEL, 20, UI.C_LINE, 1, 6, 6))
	var nh := UI.hbox(_nav, 4)
	for n in NAV:
		var b := Button.new()
		b.focus_mode = Control.FOCUS_NONE
		b.custom_minimum_size = Vector2(0, 62)
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		b.add_theme_stylebox_override("normal", UI.sb(Color(0, 0, 0, 0), 14))
		b.add_theme_stylebox_override("hover", UI.sb(UI.C_PANEL2, 14))
		b.add_theme_stylebox_override("pressed", UI.sb(UI.C_PANEL2, 14))
		b.add_theme_stylebox_override("focus", UI.sb(Color(0, 0, 0, 0), 14))
		var v := VBoxContainer.new()
		v.set_anchors_preset(Control.PRESET_FULL_RECT)
		v.alignment = BoxContainer.ALIGNMENT_CENTER
		v.mouse_filter = Control.MOUSE_FILTER_IGNORE
		v.add_theme_constant_override("separation", 2)
		var ic := Ico.new(str(n["icon"]), UI.C_MUTED, 26)
		ic.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		v.add_child(ic)
		var l := UI.lbl(Loc.t(str(n["label"])), 12, UI.C_MUTED, HORIZONTAL_ALIGNMENT_CENTER, false, false)
		l.mouse_filter = Control.MOUSE_FILTER_IGNORE
		v.add_child(l)
		b.add_child(v)
		var target: String = str(n["id"])
		if target == "garage":
			_badge = PanelContainer.new()
			_badge.add_theme_stylebox_override("panel", UI.sb(UI.C_BAD, 12, Color(0, 0, 0, 0), 0, 7, 0))
			_badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
			_badge.set_anchors_preset(Control.PRESET_TOP_RIGHT)
			_badge.position = Vector2(-34, 4)
			_badge_lbl = UI.lbl("0", 11, Color("ffffff"), HORIZONTAL_ALIGNMENT_CENTER, true, false)
			_badge_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
			_badge.add_child(_badge_lbl)
			b.add_child(_badge)
		b.pressed.connect(func():
			Fx.play("click")
			Fx.vibrate(10)
			show_screen(target, {}))
		nh.add_child(b)
		_nav_buttons[target] = {"icon": ic, "label": l, "covers": n["covers"]}
	_root_v.add_child(_nav)
	_refresh_hud()


func _refresh_hud() -> void:
	_sync_alarm()
	if is_instance_valid(_sleep_button):
		_sleep_button.visible = Game.started and Game.shop_closed() and cur_name != "splash"
		_sleep_button.text = Loc.t("sleep_free")
	if _hud_money_button == null:
		return
	_hud_money_button.text = Loc.money(Game.money)
	_hud_gems_label.text = str(Game.diamonds)
	_hud_time.text = "%s  %s  %s" % [Game.weekday_name(), Game.date_str(), Game.time_str()]
	_hud_level.text = Loc.t("lvl_short", [Game.level])
	_hud_xpbar.max_value = Game.xp_need()
	_hud_xpbar.value = Game.xp_in_level()
	_hud_xptext.text = "%d/%d" % [Game.xp_in_level(), Game.xp_need()] if Game.level < Game.MAX_LEVEL else "MAX"
	if _badge != null and is_instance_valid(_badge):
		var alerts := Game.visits.size()
		_badge.visible = alerts > 0
		_badge_lbl.text = str(alerts)
	for k in _nav_buttons.keys():
		var d: Dictionary = _nav_buttons[k]
		var active: bool = cur_name in d["covers"]
		var col := UI.C_ACCENT if active else UI.C_MUTED
		(d["icon"] as Ico).set_color(col)
		(d["label"] as Label).add_theme_color_override("font_color", UI.resolve(col))


# ------------------------------------------------------------------ ekran yönetimi
func show_screen(screen: String, params: Dictionary = {}) -> void:
	(get_child(0) as ColorRect).color = Color("101c2b") if screen=="splash" else UI.resolve(UI.C_BG,true)
	Game.menu_paused = screen=="splash" or (screen=="settings" and str(params.get("from",""))=="splash")
	if not Game.bankrupt_state.is_empty():
		screen = "bankruptcy"
		if is_instance_valid(UI.overlay):
			for overlay_child in UI.overlay.get_children():
				overlay_child.queue_free()
	if bool(params.get("summary", false)) and is_instance_valid(UI.overlay):
		for overlay_child in UI.overlay.get_children():
			overlay_child.queue_free()
	if not SCREENS.has(screen):
		push_warning("Bilinmeyen ekran: " + screen)
		return
	if _current != null:
		_holder.remove_child(_current)
		_current.queue_free()
	var script: Script = load(SCREENS[screen])
	var node: Control = script.new()
	node.set("params", params)
	node.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	node.size_flags_vertical = Control.SIZE_EXPAND_FILL
	node.set_anchors_preset(Control.PRESET_FULL_RECT)
	_holder.add_child(node)
	_current = node
	cur_name = screen
	cur_params = params
	var in_game: bool = Game.started and screen != "splash"
	_hud.visible = in_game
	_nav.visible = in_game
	UI.fade_in(node)
	_refresh_hud()


func _apply_direction() -> void:
	layout_direction = Control.LAYOUT_DIRECTION_RTL if Loc.is_rtl() else Control.LAYOUT_DIRECTION_LTR


func _theme_changed() -> void:
	UI.dark = bool(Game.settings.get("dark_mode", false))
	theme = UI.build_theme()
	(get_child(0) as ColorRect).color = UI.resolve(UI.C_BG, true)
	_build_chrome()
	show_screen(cur_name, cur_params)

func _on_language_changed() -> void:
	_apply_direction()
	_build_chrome()
	if cur_name != "":
		show_screen(cur_name, cur_params)


func _show_toast(text: String, kind: String) -> void:
	_clear_toasts()
	var col := UI.C_ACCENT
	if kind == "good":
		col = UI.C_GOOD
	elif kind == "bad":
		col = UI.C_BAD
	var p := PanelContainer.new()
	p.add_theme_stylebox_override("panel", UI.sb(UI.C_PANEL, 14, col, 2, 14, 10))
	p.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var l := UI.lbl(text, 15, UI.C_TEXT, HORIZONTAL_ALIGNMENT_CENTER)
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	p.add_child(l)
	_toast_box.add_child(p)
	_toast_box.show()
	p.modulate.a = 0.0
	var tw := p.create_tween()
	tw.tween_property(p, "modulate:a", 1.0, 0.2)
	tw.tween_interval(2.6)
	tw.tween_property(p, "modulate:a", 0.0, 0.4)
	tw.tween_callback(p.queue_free)
	while _toast_box.get_child_count() > 3:
		_toast_box.get_child(0).queue_free()
		break


# ------------------------------------------------------------------ müşteri geldi bildirimi
func _show_visit_banner(v: Dictionary) -> void:
	if not Game.started: return
	# Inside the gallery, arriving buyers remain visible and tappable.
	if cur_name == "garage" and UI.overlay.get_child_count()==0:
		Game.toast(Loc.t("play_live"),"info")
		return
	if is_instance_valid(_banner) or UI.overlay.get_child_count() > 0:
		Game.toast(Loc.t("phone_other_buyer"), "info")
		return
	var car := Game.car_by_uid(int(v["car_uid"]))
	if car.is_empty(): return
	_banner = PhoneCall.present(true, str(v["name"]), CarDB.full_name(str(car["model"])), func():
		if Game.visits.has(v): show_screen("garage", {"open": int(v["id"])})
		else: Game.toast(Loc.t("phone_missed"), "bad"), func():
		Game.dismiss_visit(v), float(v.get("expires_at", Game.now_seconds()+20.0)))

func _exit_tree() -> void:
	UI.overlay = null
	UI.bold_font = null
	AvatarBadge._atlas = null
	AvatarBadge._shader = null


func _sync_toast_visibility() -> void:
	_toast_box.visible = _toast_box.get_child_count() > 0

func _clear_toasts() -> void:
	for child in _toast_box.get_children():
		_toast_box.remove_child(child)
		child.queue_free()

func _show_market_deal(id: int) -> void:
	_clear_toasts()
	var banner := UI.btn(Loc.t("deal_alert_title") + " · " + Loc.t("deal_open"), "primary", func(): show_screen("listing", {"id": id}), 54)
	_toast_box.add_child(banner)
	_toast_box.show()
	get_tree().create_timer(12.0).timeout.connect(func():
		if is_instance_valid(banner): banner.queue_free())

func _sync_alarm() -> void:
	if not is_instance_valid(_alarm): return
	_alarm.visible = Game.started and bool(Game.flags.get("theft_pending",false))
	_alarm.disabled = int(Game.flags.get("security",0))>0
	_alarm.text = Loc.t("alarm_auto" if _alarm.disabled else "alarm_action")
