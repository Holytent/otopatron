extends ScreenBase
func _build() -> void:
	UI.header(self, Loc.t("gallery_manage"), "management")
	var sc := UI.scroll_area(self)
	_decor_panel(sc)
	var security := UI.add_card(sc)
	security.add_child(UI.lbl(Loc.t("security_title"), 20, UI.C_TEXT, -1, true))
	security.add_child(UI.lbl(Loc.t("security_hint"), 13, UI.C_MUTED))
	var rank := int(Game.flags.get("security", 0))
	security.add_child(UI.bar(rank, maxi(rank,Game.security_limit())))
	UI.kv(security,Loc.t("team_slots"),"%d / %d" % [rank,maxi(rank,Game.security_limit())])
	UI.kv(security,Loc.t("team_wage"),Loc.money(Game.security_wages()))
	security.add_child(UI.lbl(Loc.t("team_capacity_hint"),13,UI.C_MUTED))
	security.add_child(UI.lbl(Loc.t("security_probability", [int(Game.security_protection() * 100)]), 14, UI.C_GOOD))
	if rank < Game.security_limit():
		security.add_child(UI.btn(Loc.t("security_upgrade", [rank + 1, Loc.money(15000 * (rank + 1))]), "ghost", _confirm_security, 46))
func _confirm_security() -> void:
	var rank := int(Game.flags.get("security", 0))
	_confirm(Loc.t("security_title"), Loc.t("security_upgrade", [rank + 1, Loc.money(15000 * (rank + 1))]), func():
		if not Game.upgrade_security(): Game.toast(Loc.t("err_no_money"), "bad")
		rebuild())
func _confirm_upgrade() -> void:
	var next := Game.next_garage_upgrade()
	_confirm(Loc.t("garage_develop"), Loc.t("garage_quote", [next["cap"], Loc.money(int(next["cost"]))]), func():
		var result := Game.upgrade_garage()
		if result != "ok": Game.toast(Loc.t("err_level" if result == "level" else "err_no_money"), "bad")
		else: Fx.play("success")
		rebuild())
func _street_panel(sc: Node) -> void:
	var c := UI.add_card(sc)
	c.add_child(UI.lbl(Loc.t("street_title"), 20, UI.C_TEXT, -1, true))
	var actor := ConversationActor.new()
	actor.role = "lender"
	actor.custom_minimum_size.y = 200
	actor.mood = 35
	c.add_child(actor)
	var loan: Dictionary = Game.flags.get("street_loan", {})
	if loan.is_empty() and bool(Game.settings.get("street_events", true)):
		var quote := Game.street_loan_quote()
		c.add_child(UI.lbl(Loc.t("street_quote", [Loc.money(int(quote["amount"])), Loc.money(int(quote["debt"]))]), 14, UI.C_MUTED))
		c.add_child(UI.btn(Loc.t("street_offer"), "danger", _confirm_loan, 46))
	elif not loan.is_empty():
		UI.kv(c, Loc.t("debt_total"), Loc.money(int(loan["remaining"])), UI.C_BAD)
		UI.kv(c, Loc.t("maturity"), Loc.t("days_term", [maxi(0, int(loan["due"]) - Game.day)]))
		c.add_child(UI.btn(Loc.t("street_close"), "ghost", func():
			_confirm(Loc.t("street_close"), Loc.money(int(loan["remaining"])), func():
				Game.repay_street_loan()
				rebuild()), 46))
	if bool(Game.flags.get("theft_pending", false)):
		c.add_child(UI.lbl(Loc.t("theft_alert"), 16, UI.C_BAD, -1, true))
		c.add_child(UI.lbl(Loc.t("theft_choices"), 13, UI.C_MUTED))
		c.add_child(UI.btn(Loc.t("call_police"), "ghost", func():
			Game.resolve_theft(false)
			rebuild(), 44))
func _decor_panel(body: Node) -> void:
	var preview := GarageStage.new()
	body.add_child(preview)
	body.add_child(UI.lbl(Loc.t("gallery_packages_hint"),13,UI.C_MUTED))
	body.add_child(UI.lbl(Loc.t("gallery_name"),16,UI.C_TEXT,-1,true))
	var input := LineEdit.new()
	input.placeholder_text = Loc.t("gallery_name")
	input.text = GalleryStyle.title()
	input.max_length = 24
	input.custom_minimum_size = Vector2(0,48)
	input.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body.add_child(input)
	var saved := UI.lbl("",13,UI.C_GOOD)
	input.text_changed.connect(func(text):
		GalleryStyle.rename(text)
		preview.queue_redraw()
		saved.text = Loc.t("gallery_name_saved"))
	body.add_child(saved)
	var actions := UI.hbox(body,8)
	var save := UI.btn(Loc.t("gallery_save"),"primary",func():
		GalleryStyle.rename(input.text)
		preview.queue_redraw()
		saved.text = Loc.t("gallery_name_saved")
		Game.toast(Loc.t("gallery_name_saved"),"good"),48)
	var back := UI.btn(Loc.t("management_back"),"ghost",func(): Game.go("management"),48)
	save.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	back.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	actions.add_child(save)
	actions.add_child(back)
	for choice in GalleryStyle.PACKAGES:
		var card := UI.add_card(body)
		card.add_child(UI.lbl(Loc.t("gallery_"+choice),20,UI.C_TEXT,-1,true))
		var art := GarageStage.new()
		art.preview_style = choice
		card.add_child(art)
		card.add_child(UI.lbl(Loc.t("gallery_package_"+choice),14,UI.C_MUTED))
		UI.kv(card,Loc.t("gallery_package_price"),Loc.money(int(GalleryStyle.PRICES[choice])),UI.C_ACCENT)
		card.add_child(UI.lbl(Loc.t("gallery_package_capacity",[int(GalleryStyle.CAPACITIES[choice])]),14,UI.C_TEXT))
		var selected: bool = GalleryStyle.package_selected() == choice
		var owned: bool = GalleryStyle.package_owned(choice)
		var caption: String = Loc.t("gallery_selected") if selected else (Loc.t("gallery_use") if owned else Loc.t("gallery_buy",[Loc.money(int(GalleryStyle.PRICES[choice]))]))
		var button := UI.btn(caption,"chipon" if selected else "primary",func():
			if GalleryStyle.package_owned(choice):
				_apply_package(choice)
			else:
				_confirm(Loc.t("gallery_"+choice),Loc.t("gallery_buy_confirm",[Loc.money(int(GalleryStyle.PRICES[choice])),int(GalleryStyle.CAPACITIES[choice])]),func(): _apply_package(choice)),48)
		button.disabled = selected
		card.add_child(button)
	# Existing component purchases remain selectable without charging again.
	if not Game.flags.get("gallery_owned",[]).is_empty():
		body.add_child(UI.lbl(Loc.t("gallery_owned_decor"),17,UI.C_TEXT,-1,true))
		for part in GalleryStyle.PARTS:
			body.add_child(UI.lbl(Loc.t("gallery_"+part),14,UI.C_MUTED))
			var options := OptionButton.new()
			var choices: Array[String] = []
			for choice in GalleryStyle.OPTIONS:
				if GalleryStyle.owned(part,choice):
					choices.append(choice)
					options.add_item(Loc.t("gallery_"+choice))
					if GalleryStyle.selected(part)==choice: options.select(choices.size()-1)
			options.item_selected.connect(func(index):
				GalleryStyle.select(part,choices[index])
				preview.queue_redraw())
			body.add_child(options)
func _apply_package(choice: String) -> void:
	if not GalleryStyle.buy_package(choice): return
	Fx.play("success")
	for modal in UI.overlay.get_children(): modal.queue_free()
	rebuild()

func _confirm_loan() -> void:
	var quote := Game.street_loan_quote()
	var v := UI.dialog_card(Loc.t("street_offer"))
	var actor := ConversationActor.new()
	actor.role = "lender"
	actor.custom_minimum_size.y = 150
	actor.mood = 35
	actor.speak(2.0)
	v.add_child(actor)
	v.add_child(UI.lbl(Loc.t("street_quote", [Loc.money(int(quote["amount"])), Loc.money(int(quote["debt"]))]), 16))
	var root := UI.show_dialog(v)
	v.add_child(UI.btn(Loc.t("ok"), "danger", func():
		Game.take_street_loan()
		root.queue_free()
		rebuild()))
	v.add_child(UI.btn(Loc.t("cancel"), "ghost", func(): root.queue_free()))

func _confirm(title: String, body: String, action: Callable) -> void:
	var v := UI.dialog_card(title)
	v.add_child(UI.lbl(body, 16))
	var root := UI.show_dialog(v)
	v.add_child(UI.btn(Loc.t("ok"), "primary", func():
		root.queue_free()
		action.call()))
	v.add_child(UI.btn(Loc.t("cancel"), "ghost", func(): root.queue_free()))
