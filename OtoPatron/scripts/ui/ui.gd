class_name UI
extends RefCounted
## Koyu otomotiv teması + yeniden kullanılabilir arayüz bileşenleri.

const C_BG := Color("101e30")
const C_PANEL := Color("172d42")
const C_PANEL2 := Color("20394d")
const C_LINE := Color("38566b")
const C_ACCENT := Color("087d83")
const C_GOLD := Color("edc16b")
const C_TEXT := Color("eef4f8")
const C_MUTED := Color("b2c6d5")
const C_GOOD := Color("63d7a0")
const C_BAD := Color("fa8794")
const C_BLUE := Color("edc16b")

static var dark: bool = false
static func resolve(c: Color, surface: bool = false) -> Color:
	if surface:
		if c==C_BG: return Color("0c1727") if dark else C_BG
		if c==C_PANEL: return Color("13263a") if dark else C_PANEL
		if c in [Color("ffffff"),Color("f8f9fb")]: return C_PANEL
		if c in [Color("e3e7ee"),Color("eef0f4"),Color("fae8e9")]: return C_PANEL2
	else:
		if c==C_ACCENT: return Color("59ddce")
	return c

static var overlay: Control = null
static var bold_font: Font = null


static func sb(color: Color, radius: int = 14, border: Color = Color(0, 0, 0, 0), bw: int = 0, ph: int = 16, pv: int = 10) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = resolve(color, true)
	s.set_corner_radius_all(radius)
	s.border_color = resolve(border)
	s.set_border_width_all(bw)
	s.content_margin_left = ph
	s.content_margin_right = ph
	s.content_margin_top = pv
	s.content_margin_bottom = pv
	return s


static func _btn_style(th: Theme, type_name: String, base: Color, fg: Color, border: Color = Color(0, 0, 0, 0), bw: int = 0) -> void:
	if type_name != "Button":
		th.add_type(type_name)
		th.set_type_variation(type_name, "Button")
	th.set_stylebox("normal", type_name, sb(base, 14, border, bw))
	th.set_stylebox("hover", type_name, sb(resolve(base, true).lightened(0.12), 14, border, bw))
	th.set_stylebox("pressed", type_name, sb(resolve(base, true).darkened(0.18), 14, border, bw))
	th.set_stylebox("focus", type_name, sb(Color(0, 0, 0, 0), 14))
	th.set_stylebox("disabled", type_name, sb(Color("e3e7ee"), 14))
	th.set_color("font_color", type_name, resolve(fg))
	th.set_color("font_hover_color", type_name, resolve(fg))
	th.set_color("font_pressed_color", type_name, resolve(fg))
	th.set_color("font_focus_color", type_name, resolve(fg))
	th.set_color("font_disabled_color", type_name, resolve(C_MUTED))


static func build_theme() -> Theme:
	var th := Theme.new()
	var f: Font = load("res://fonts/NotoSans.ttf")
	var fa: Font = load("res://fonts/NotoSansArabic.ttf")
	if f != null:
		if fa != null:
			f.fallbacks = [fa]
		th.default_font = f
		var fb := FontVariation.new()
		fb.base_font = f
		fb.variation_embolden = 0.5
		bold_font = fb
	th.default_font_size = 18
	_btn_style(th, "Button", C_PANEL2, C_TEXT, C_LINE, 1)
	_btn_style(th, "PrimaryButton", C_ACCENT, Color("ffffff"))
	_btn_style(th, "DangerButton", (Color("3b2730") if dark else Color("fae8e9")), C_BAD, C_BAD, 1)
	_btn_style(th, "GhostButton", Color(0, 0, 0, 0), C_ACCENT, C_ACCENT, 2)
	_btn_style(th, "ChipButton", C_PANEL2, C_TEXT, C_LINE, 1)
	_btn_style(th, "ChipOnButton", C_ACCENT, Color("ffffff"), C_ACCENT, 2)
	th.set_stylebox("normal", "LineEdit", sb(C_PANEL2, 12, C_LINE, 1))
	th.set_stylebox("focus", "LineEdit", sb(C_PANEL2, 12, C_ACCENT, 2))
	th.set_color("font_color", "LineEdit", resolve(C_TEXT))
	th.set_color("caret_color", "LineEdit", resolve(C_TEXT))
	th.set_stylebox("background", "ProgressBar", sb(Color("e3e7ee"), 6, Color(0, 0, 0, 0), 0, 0, 0))
	th.set_stylebox("fill", "ProgressBar", sb(C_ACCENT, 6, Color(0, 0, 0, 0), 0, 0, 0))
	th.set_stylebox("slider", "HSlider", sb(Color("e3e7ee"), 6, Color(0, 0, 0, 0), 0, 0, 4))
	th.set_stylebox("grabber_area", "HSlider", sb(C_ACCENT, 6, Color(0, 0, 0, 0), 0, 0, 4))
	th.set_stylebox("grabber_area_highlight", "HSlider", sb(C_GOLD, 6, Color(0, 0, 0, 0), 0, 0, 4))
	th.set_color("font_color", "Label", resolve(C_TEXT))
	th.set_stylebox("normal", "TextEdit", sb(C_PANEL2, 12, C_LINE, 1))
	th.set_stylebox("focus", "TextEdit", sb(C_PANEL2, 12, C_ACCENT, 2))
	th.set_color("font_color", "TextEdit", resolve(C_TEXT))
	th.set_color("font_placeholder_color", "TextEdit", resolve(C_MUTED))
	th.set_stylebox("panel", "PanelContainer", sb(C_PANEL, 18, C_LINE, 1, 14, 14))
	return th


# ------------------------------------------------------------------ yapı taşları
static func start_align() -> int:
	return HORIZONTAL_ALIGNMENT_RIGHT if Loc.is_rtl() else HORIZONTAL_ALIGNMENT_LEFT


static func lbl(text: String, size: int = 17, color: Color = C_TEXT, align: int = -1, is_bold: bool = false, wrap: bool = true) -> Label:
	var l := Label.new()
	l.text = Loc.display_text(text)
	var readable_size: int = maxi(16, size)
	if color == C_MUTED and wrap and size >= 13:
		readable_size = maxi(17, readable_size)
	l.add_theme_font_size_override("font_size", readable_size)
	l.add_theme_color_override("font_color", resolve(color))
	if is_bold and bold_font != null:
		l.add_theme_font_override("font", bold_font)
	l.horizontal_alignment = (start_align() if align == -1 else align) as HorizontalAlignment
	if wrap:
		l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return l


static func btn(text: String, kind: String, cb: Callable, min_h: int = 54) -> Button:
	var b := Button.new()
	b.text = Loc.display_text(text)
	b.clip_text = false
	b.text_overrun_behavior = TextServer.OVERRUN_NO_TRIMMING
	if not text.is_empty():
		b.tree_entered.connect(func():
			var compact: bool = text.length() > 3 and (b.size_flags_horizontal & Control.SIZE_EXPAND) != 0
			b.clip_text = compact
			b.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS if compact else TextServer.OVERRUN_NO_TRIMMING)
	b.focus_mode = Control.FOCUS_NONE
	b.custom_minimum_size = Vector2(0, min_h)
	b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	match kind:
		"primary":
			b.theme_type_variation = "PrimaryButton"
		"danger":
			b.theme_type_variation = "DangerButton"
		"ghost":
			b.theme_type_variation = "GhostButton"
		"chip":
			b.theme_type_variation = "ChipButton"
		"chipon":
			b.theme_type_variation = "ChipOnButton"
	b.add_theme_font_size_override("font_size", 19)
	if bold_font != null and kind == "primary":
		b.add_theme_font_override("font", bold_font)
	b.pressed.connect(func():
		Fx.play("click")
		Fx.vibrate(12)
		cb.call())
	return b


static func btn_icon(icon_kind: String, text: String, kind: String, cb: Callable, min_h: int = 54) -> Button:
	var b := btn("", kind, cb, min_h)
	var col := Color("ffffff") if kind in ["primary", "chipon"] else (C_BAD if kind == "danger" else (C_ACCENT if kind == "ghost" else C_TEXT))
	var cc := CenterContainer.new()
	cc.set_anchors_preset(Control.PRESET_FULL_RECT)
	cc.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var h := HBoxContainer.new()
	h.add_theme_constant_override("separation", 10)
	h.mouse_filter = Control.MOUSE_FILTER_IGNORE
	h.add_child(Ico.new(icon_kind, col, 24))
	var l := lbl(text, 18, col, HORIZONTAL_ALIGNMENT_CENTER, kind == "primary", false)
	l.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	h.add_child(l)
	cc.add_child(h)
	b.add_child(cc)
	return b


static func hbox(parent: Node, sep: int = 10) -> HBoxContainer:
	var h := HBoxContainer.new()
	h.add_theme_constant_override("separation", sep)
	h.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	if parent != null:
		parent.add_child(h)
	return h


static func vbox(parent: Node, sep: int = 10) -> VBoxContainer:
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", sep)
	v.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	if parent != null:
		parent.add_child(v)
	return v


static func spacer(parent: Node, h: int = 8) -> Control:
	var c := Control.new()
	c.custom_minimum_size = Vector2(0, h)
	parent.add_child(c)
	return c


static func add_card(parent: Node, color: Color = C_PANEL, pad: int = 14, border: Color = C_LINE) -> VBoxContainer:
	var p := PanelContainer.new()
	p.add_theme_stylebox_override("panel", sb(color, 18, border, 1, pad, pad))
	p.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	parent.add_child(p)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 8)
	p.add_child(v)
	return v


static func bar(value: float, maxv: float, color: Color = C_ACCENT, h: int = 10) -> ProgressBar:
	var b := ProgressBar.new()
	b.min_value = 0
	b.max_value = maxf(maxv, 1.0)
	b.value = value
	b.show_percentage = false
	b.custom_minimum_size = Vector2(0, h)
	b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	if color != C_ACCENT:
		b.add_theme_stylebox_override("fill", sb(color, 6, Color(0, 0, 0, 0), 0, 0, 0))
	return b


static func pill(text: String, color: Color = C_ACCENT) -> PanelContainer:
	var p := PanelContainer.new()
	p.add_theme_stylebox_override("panel", sb(Color(color.r, color.g, color.b, 0.16), 20, Color(color.r, color.g, color.b, 0.6), 1, 10, 3))
	var l := lbl(text, 13, color, HORIZONTAL_ALIGNMENT_CENTER, true, false)
	l.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	p.add_child(l)
	p.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	return p


static func car_image(model_id: String, h: int = 150, car: Dictionary = {}) -> Control:
	return CarPortrait.new(model_id, h, car)


static func kv(parent: Node, k: String, v: String, vcolor: Color = C_TEXT) -> HBoxContainer:
	var h := hbox(parent, 8)
	h.add_child(lbl(k, 15, C_MUTED))
	var r := lbl(v, 15, vcolor, HORIZONTAL_ALIGNMENT_RIGHT if not Loc.is_rtl() else HORIZONTAL_ALIGNMENT_LEFT, true)
	h.add_child(r)
	return h


static func divider(parent: Node) -> void:
	var c := ColorRect.new()
	c.color = C_LINE
	c.custom_minimum_size = Vector2(0, 1)
	parent.add_child(c)


static func scroll_area(parent: Node) -> VBoxContainer:
	var sc := ScrollContainer.new()
	sc.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	sc.size_flags_vertical = Control.SIZE_EXPAND_FILL
	sc.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	parent.add_child(sc)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 12)
	v.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	sc.add_child(v)
	return v


static func header(parent: Node, title: String, back_to: String = "home") -> HBoxContainer:
	var h := hbox(parent, 10)
	if back_to != "":
		var b := Button.new()
		b.focus_mode = Control.FOCUS_NONE
		b.custom_minimum_size = Vector2(52, 52)
		var ico := Ico.new("back", C_TEXT, 26)
		if Loc.is_rtl():
			ico.scale = Vector2(-1, 1)
			ico.pivot_offset = Vector2(13, 13)
		var cc := CenterContainer.new()
		cc.set_anchors_preset(Control.PRESET_FULL_RECT)
		cc.mouse_filter = Control.MOUSE_FILTER_IGNORE
		cc.add_child(ico)
		b.add_child(cc)
		b.pressed.connect(func():
			Fx.play("click")
			Game.go(back_to))
		h.add_child(b)
	h.add_child(lbl(title, 24, C_TEXT, -1, true))
	return h


# ------------------------------------------------------------------ modal / efektler
static func modal(content: Control, dismiss_on_dim: bool = false) -> Control:
	var root := Control.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.72)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.add_child(dim)
	if dismiss_on_dim:
		dim.gui_input.connect(func(ev):
			if ev is InputEventMouseButton and ev.pressed:
				root.queue_free())
	var m := MarginContainer.new()
	m.set_anchors_preset(Control.PRESET_FULL_RECT)
	m.add_theme_constant_override("margin_left", 18)
	m.add_theme_constant_override("margin_right", 18)
	m.add_theme_constant_override("margin_top", 30)
	m.add_theme_constant_override("margin_bottom", 30)
	m.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(m)
	var cc := CenterContainer.new()
	cc.mouse_filter = Control.MOUSE_FILTER_IGNORE
	m.add_child(cc)
	content.custom_minimum_size.x = minf(440, maxf(200, overlay.size.x - 36))
	cc.add_child(content)
	overlay.add_child(root)
	root.modulate.a = 0.0
	content.pivot_offset = content.size / 2.0
	var tw := root.create_tween()
	tw.tween_property(root, "modulate:a", 1.0, 0.18)
	return root


static func dialog_card(title: String) -> VBoxContainer:
	var p := PanelContainer.new()
	p.add_theme_stylebox_override("panel", sb(C_PANEL, 22, C_ACCENT, 2, 18, 18))
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 12)
	p.add_child(v)
	if title != "":
		v.add_child(lbl(title, 22, C_TEXT, HORIZONTAL_ALIGNMENT_CENTER, true))
	# kart referansını koru: dışarıya VBox döner; modal() için parent'ı kullan
	return v


static func style_menu_dialog(v: VBoxContainer) -> void:
	v.get_parent().add_theme_stylebox_override("panel",sb(Color("14283a"),22,Color("51687d"),1,18,18))
	for control in v.find_children("*","Control",true,false):
		if control is Label: control.add_theme_color_override("font_color",Color("e8eff7"))
		elif control is LineEdit:
			control.add_theme_stylebox_override("normal",sb(Color("21364a"),12,Color("51687d"),1))
			control.add_theme_stylebox_override("focus",sb(Color("21364a"),12,Color("087d83"),2))
			control.add_theme_color_override("font_color",Color.WHITE)
			control.add_theme_color_override("caret_color",Color.WHITE)
		elif control is Button:
			var selected: bool=control.theme_type_variation in ["PrimaryButton","ChipOnButton"]
			control.add_theme_stylebox_override("normal",sb(Color("087d83") if selected else Color("21364a"),12,Color("51687d"),1))
			control.add_theme_stylebox_override("hover",sb(Color("304a62"),12,Color("7892a8"),1))
			control.add_theme_stylebox_override("pressed",sb(Color("065a62"),12))
			for key in ["font_color","font_hover_color","font_pressed_color"]: control.add_theme_color_override(key,Color.WHITE)

static func show_dialog(v: VBoxContainer) -> Control:
	return modal(v.get_parent())


static func message(title: String, body: String, ok_text: String = "", cb: Callable = Callable(), menu_theme: bool = false) -> void:
	var v := dialog_card(title)
	v.add_child(lbl(body, 17, C_TEXT, HORIZONTAL_ALIGNMENT_CENTER))
	var root := show_dialog(v)
	v.add_child(btn(ok_text if ok_text != "" else Loc.t("ok"), "primary", func():
		root.queue_free()
		if cb.is_valid():
			cb.call()))
	if menu_theme: style_menu_dialog(v)


static func fade_in(n: Control, dur: float = 0.22) -> void:
	n.modulate.a = 0.0
	n.scale = Vector2(0.99, 0.99)
	var tw := n.create_tween()
	tw.set_parallel(true)
	tw.tween_property(n, "modulate:a", 1.0, dur).set_ease(Tween.EASE_OUT)
	tw.tween_property(n, "scale", Vector2.ONE, dur).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)


# ------------------------------------------------------------------ sabır / kızgınlık barı
static func mood_bar(parent: Node, title: String, value: float) -> ProgressBar:
	var h := hbox(parent, 8)
	var l := lbl(title, 13, C_MUTED, -1, false, false)
	l.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	h.add_child(l)
	var b := bar(clampf(value, 0.0, 100.0), 100.0, mood_color(value), 12)
	b.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	h.add_child(b)
	return b


static func mood_color(v: float) -> Color:
	return C_GOOD if v > 60.0 else (C_GOLD if v > 30.0 else C_BAD)


static func set_mood(b: ProgressBar, value: float) -> void:
	if not is_instance_valid(b):
		return
	var tw := b.create_tween()
	tw.tween_property(b, "value", clampf(value, 0.0, 100.0), 0.45)
	b.add_theme_stylebox_override("fill", sb(mood_color(value), 6, Color(0, 0, 0, 0), 0, 0, 0))


# ------------------------------------------------------------------ şehir seçici (81 il)
static func pick_city(current: String, cb: Callable, menu_theme: bool = false) -> void:
	var v := dialog_card(Loc.t("city_pick_title"))
	var search := LineEdit.new()
	search.placeholder_text = Loc.t("city_search")
	search.custom_minimum_size = Vector2(0, 48)
	search.clear_button_enabled = true
	v.add_child(search)
	var sc := ScrollContainer.new()
	sc.custom_minimum_size = Vector2(0, 380)
	sc.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	v.add_child(sc)
	var list := vbox(null, 6)
	sc.add_child(list)
	var root := show_dialog(v)
	var fill := func(q: String):
		for c in list.get_children():
			list.remove_child(c)
			c.queue_free()
		var qq := CityDB.fold(q.strip_edges())
		for i in CityDB.NAMES.size():
			var code := CityDB.code(i + 1)
			var nm: String = CityDB.NAMES[i]
			if qq != "" and not (CityDB.fold(nm).contains(qq) or code.begins_with(qq)):
				continue
			var cur := code == CityDB.normalize(current)
			list.add_child(btn(nm, "chipon" if cur else "chip", func():
				root.queue_free()
				cb.call(code), 46))
		if menu_theme: style_menu_dialog(v)
	fill.call("")
	search.text_changed.connect(func(t: String): fill.call(t))
	v.add_child(btn(Loc.t("cancel"), "ghost", func(): root.queue_free(), 46))
	if menu_theme: style_menu_dialog(v)
