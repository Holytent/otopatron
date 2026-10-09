extends ScreenBase
func _build() -> void:
	UI.header(self, Loc.t("management_title"), "home")
	var sc := UI.scroll_area(self)
	var gallery := UI.add_card(sc)
	gallery.add_child(UI.lbl(Loc.t("management_gallery"), 20, UI.C_TEXT, -1, true))
	_link(gallery,"garage","gallery_manage","workshop")
	_link(gallery,"user","team_title","staff")
	if bool(Game.flags.get("theft_pending", false)):
		gallery.add_child(UI.lbl(Loc.t("theft_alert"), 15, UI.C_BAD))
	_link(gallery,"user","street_title","street")
	var finances := UI.add_card(sc)
	finances.add_child(UI.lbl(Loc.t("management_money"), 20, UI.C_TEXT, -1, true))
	_link(finances,"bank","finance_title","finance")
	_link(finances,"bank","bank_open","loans")
	_link(finances,"bank","gallery_expenses","business_account")
	var player := UI.add_card(sc)
	player.add_child(UI.lbl(Loc.t("management_player"), 20, UI.C_TEXT, -1, true))
	_link(player,"user","profile_title","profile")
	_link(player,"diamond","shop_title","shop")
	_link(player,"crate","daily_crate","rewards")
	_link(player,"gear","settings_title","settings")
func _link(parent: Node, icon: String, label: String, route: String) -> void:
	parent.add_child(UI.btn_icon(icon, Loc.t(label), "ghost", func(): Game.go(route, {"from":"management"}), 48))
