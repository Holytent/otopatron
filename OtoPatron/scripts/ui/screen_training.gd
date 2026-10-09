extends ScreenBase
var _selected: String = "market"
var _clock: Label
var _progress: ProgressBar
var _signature: String = ""
func _ready() -> void:
	super._ready()
	Game.live_tick.connect(_tick)
func _build() -> void:
	_clock = null
	_progress = null
	_signature = str(Game.active_training) + str(Game.trainings)
	UI.header(self, Loc.t("academy_title"), "home")
	var sc := UI.scroll_area(self)
	if not Game.active_training.is_empty():
		_active_panel(sc)
	var intro := UI.add_card(sc, UI.C_PANEL)
	intro.add_child(UI.lbl(Loc.t("academy_tagline"), 20, UI.C_TEXT, -1, true))
	intro.add_child(UI.lbl(Loc.t("academy_short"), 13, UI.C_MUTED))
	for item in TrainingDB.ITEMS:
		var id: String = str(item["id"])
		var current: int = Game.sk(id)
		var card := UI.add_card(sc, UI.C_PANEL, 18)
		var row := UI.hbox(card, 10)
		row.add_child(Ico.new(str(item["icon"]), UI.C_ACCENT, 32))
		var heading := UI.vbox(row, 2)
		heading.add_child(UI.lbl(Loc.t("tr_" + id), 19, UI.C_TEXT, -1, true))
		heading.add_child(UI.lbl(Loc.t("course_not_started") if current == 0 else Loc.t("course_completed_count", [current]), 12, UI.C_MUTED))
		card.add_child(UI.bar(current, 10, UI.C_ACCENT, 5))
		card.add_child(UI.lbl(Loc.t("tr_" + id + "_desc"), 13, UI.C_MUTED))
		if current >= 10:
			card.add_child(UI.pill(Loc.t("course_mastered"), UI.C_GOOD))
		else:
			var required: int = int(item["levels"][current])
			var details := UI.hbox(card, 8)
			details.add_child(UI.pill(Loc.t("min_n", [Game.training_minutes(id, current + 1)]), UI.C_MUTED))
			details.add_child(UI.lbl(Loc.money(int(item["costs"][current])), 16, UI.C_TEXT, HORIZONTAL_ALIGNMENT_RIGHT, true))
			card.add_child(UI.lbl(Loc.t("course_required_level", [required]), 12, UI.C_MUTED))
			card.add_child(UI.btn(Loc.t("course_details") if Game.level >= required else Loc.t("skill_locked", [required]), "ghost", func():
				_selected = id
				_course_dialog(), 44))
func _course_dialog() -> void:
	var v := UI.dialog_card(Loc.t("tr_" + _selected))
	_course_panel(v)
	var root := UI.show_dialog(v)
	v.add_child(UI.btn(Loc.t("cancel"), "ghost", func(): root.queue_free()))
func _active_panel(sc: Node) -> void:
	var a := UI.add_card(sc, Color("25252e"), 20, Color("25252e"))
	var row := UI.hbox(a, 10)
	row.add_child(Ico.new("school", Color("ff8994"), 32))
	var title := UI.vbox(row, 2)
	title.add_child(UI.lbl(Loc.t("course_in_progress"), 12, Color("ff8994"), -1, true))
	title.add_child(UI.lbl(Loc.t("tr_" + str(Game.active_training["id"])), 19, Color.WHITE, -1, true))
	_clock = UI.lbl(Game.training_clock(), 42, Color.WHITE, HORIZONTAL_ALIGNMENT_CENTER, true)
	a.add_child(_clock)
	_progress = UI.bar(Game.training_progress() * 100.0, 100, UI.C_ACCENT, 8)
	a.add_child(_progress)
	a.add_child(UI.lbl(Loc.t("academy_short"), 12, Color("ddd6d9")))
	a.add_child(UI.btn_icon("diamond", Loc.t("accelerate_training"), "primary", _speedup_options, 46))
func _course_panel(sc: Node) -> void:
	var it := TrainingDB.item(_selected)
	var cur := Game.sk(_selected)
	var c := UI.add_card(sc)
	c.add_child(UI.lbl(Loc.t("tr_" + _selected), 23, UI.C_TEXT, -1, true))
	c.add_child(UI.lbl(Loc.t("tr_" + _selected + "_desc"), 14, UI.C_MUTED))
	c.add_child(SkillTrack.new(cur))
	if cur >= 10:
		c.add_child(UI.lbl(Loc.t("course_mastered"), 18, UI.C_GOOD))
		return
	var next := cur + 1
	var required := int(it["levels"][cur])
	var row := UI.hbox(c, 8)
	row.add_child(UI.pill(Loc.t("min_n", [Game.training_minutes(_selected, next)]), UI.C_ACCENT))
	row.add_child(UI.pill(Loc.t("course_required_level", [required]), UI.C_BLUE))
	c.add_child(UI.lbl(Loc.t("course_next_stage", [next]), 14, UI.C_TEXT))
	c.add_child(UI.lbl(Loc.t("training_reward"), 13, UI.C_GOOD))
	var cost := int(it["costs"][cur])
	var b := UI.btn(Loc.t("btn_train", [next]) + " · " + Loc.money(cost), "primary", func():
		Game.start_training(_selected)
		for modal in UI.overlay.get_children(): modal.queue_free()
		rebuild(), 52)
	b.disabled = required > Game.level or Game.money < cost or not Game.active_training.is_empty()
	c.add_child(b)
	if not Game.active_training.is_empty():
		c.add_child(UI.lbl(Loc.t("finish_current_first"), 12, UI.C_MUTED))
func _tick() -> void:
	if _signature != str(Game.active_training) + str(Game.trainings):
		rebuild()
	elif is_instance_valid(_clock):
		_clock.text = Game.training_clock()
		_progress.value = Game.training_progress() * 100.0
func _speedup_options() -> void:
	var v := UI.dialog_card(Loc.t("accelerate_training"))
	for seconds in [900, 86400]:
		if seconds == 900 and Game.training_seconds_left() <= 900:
			continue
		for gems in [false, true]:
			var cost := Game.training_skip_cost(seconds, gems)
			v.add_child(UI.btn(Loc.t("skip_quarter" if seconds == 900 else "finish_training") + " · " + ("%d ♦" % cost if gems else Loc.money(cost)), "ghost", func(): _confirm_skip(seconds, gems), 46))
	var root := UI.show_dialog(v)
	v.add_child(UI.btn(Loc.t("cancel"), "chip", func(): root.queue_free()))
func _confirm_skip(seconds: int, gems: bool) -> void:
	var cost := Game.training_skip_cost(seconds, gems)
	var v := UI.dialog_card(Loc.t("finish_training"))
	v.add_child(UI.lbl(Loc.t("skip_confirm", ["%d ♦" % cost if gems else Loc.money(cost)]), 16, UI.C_TEXT))
	var root := UI.show_dialog(v)
	v.add_child(UI.btn(Loc.t("ok"), "primary", func():
		Game.skip_training(seconds, gems)
		root.queue_free()
		for overlay in UI.overlay.get_children():
			overlay.queue_free()
		rebuild()))
	v.add_child(UI.btn(Loc.t("cancel"), "ghost", func(): root.queue_free()))
