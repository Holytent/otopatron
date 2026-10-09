extends ScreenBase
## Oyuncu profili, ilerleme istatistikleri ve gelecek sürüm yol haritası.


func _build() -> void:
	UI.header(self, Loc.t("profile_title"), "management")
	var sc := UI.scroll_area(self)
	var c := UI.add_card(sc)
	var top := UI.hbox(c, 12)
	top.add_child(AvatarBadge.new(Game.avatar_id, 64))
	var tv := UI.vbox(top, 0)
	tv.add_child(UI.lbl(Game.player_name, 22, UI.C_TEXT, -1, true))
	tv.add_child(UI.lbl("%s • %s" % [Loc.t("lvl_title_%d" % mini(Game.level / 5, 5)), city_name(Game.city)], 14, UI.C_MUTED))
	c.add_child(UI.bar(Game.xp_in_level(), Game.xp_need(), UI.C_ACCENT, 12))
	c.add_child(UI.lbl(Loc.t("xp_line", [Game.xp_in_level(), Game.xp_need(), Game.xp_need() - Game.xp_in_level()]) if Game.level < Game.MAX_LEVEL else Loc.t("max_level"), 13, UI.C_MUTED))
	c.add_child(UI.btn(Loc.t("choose_avatar"), "ghost", _choose_avatar, 48))
	sc.add_child(UI.btn_icon("user", Loc.t("account_title"), "ghost", func(): AccountBridge.open(), 48))
	var s := UI.add_card(sc)
	s.add_child(UI.lbl(Loc.t("stats"), 18, UI.C_ACCENT, -1, true))
	UI.kv(s, Loc.t("stat_level"), "%d" % Game.level, UI.C_ACCENT)
	UI.kv(s, Loc.t("stat_xp"), "%d" % Game.xp)
	UI.kv(s, Loc.t("stat_day"), "%d" % (Game.day + 1))
	UI.kv(s, Loc.t("stat_sold"), "%d" % int(Game.stats["sold"]))
	UI.kv(s, Loc.t("stat_bought"), "%d" % int(Game.stats["bought"]))
	UI.kv(s, Loc.t("stat_profit"), Loc.money(int(Game.stats["profit"])), UI.C_GOOD if int(Game.stats["profit"]) >= 0 else UI.C_BAD)
	UI.kv(s, Loc.t("stat_best"), Loc.money(int(Game.stats["best"])), UI.C_GOLD)
	UI.kv(s, Loc.t("customer_rating"), Game.review_average(), UI.C_GOLD)
	UI.kv(s, Loc.t("stat_rep"), "%d / 100" % Game.rep)
	s.add_child(UI.bar(Game.rep, 100))
	s.add_child(UI.lbl(Loc.t("reputation_hint"), 13, UI.C_MUTED))
	UI.kv(s, Loc.t("stat_crates"), "%d" % int(Game.stats["crates"]))
	var t := UI.add_card(sc)
	t.add_child(UI.lbl(Loc.t("training_title"), 18, UI.C_ACCENT, -1, true))
	for it in TrainingDB.ITEMS:
		UI.kv(t, Loc.t("tr_%s" % it["id"]), "%d / 10" % Game.sk(str(it["id"])))
	UI.kv(t, Loc.t("learning_skill"), Loc.t("lvl_short", [Game.learning_level()]), UI.C_GOLD)
	var r := UI.add_card(sc, UI.C_PANEL2)
	r.add_child(UI.lbl(Loc.t("roadmap_title"), 18, UI.C_ACCENT, -1, true))
	r.add_child(UI.lbl(Loc.t("roadmap_body"), 14, UI.C_MUTED))
	UI.spacer(sc, 6)


func _choose_avatar() -> void:
	var v := UI.dialog_card(Loc.t("choose_avatar"))
	var grid := GridContainer.new()
	grid.columns = 4
	grid.add_theme_constant_override("h_separation", 8)
	grid.add_theme_constant_override("v_separation", 8)
	v.add_child(grid)
	var root := UI.show_dialog(v)
	for id in 8:
		var button := Button.new()
		button.custom_minimum_size = Vector2(64, 72)
		var icon := AvatarBadge.new(id, 56)
		var center := CenterContainer.new()
		center.set_anchors_preset(Control.PRESET_FULL_RECT)
		center.mouse_filter = Control.MOUSE_FILTER_IGNORE
		center.add_child(icon)
		button.add_child(center)
		button.pressed.connect(func():
			Game.avatar_id = id
			Game.save_game()
			Game.changed.emit()
			root.queue_free()
			rebuild())
		grid.add_child(button)
	v.add_child(UI.btn(Loc.t("cancel"), "ghost", func(): root.queue_free()))
