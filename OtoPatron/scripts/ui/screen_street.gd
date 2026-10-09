extends "res://scripts/ui/screen_workshop.gd"
func _build() -> void:
	UI.header(self, Loc.t("street_title"), "management")
	var sc := UI.scroll_area(self)
	if bool(Game.settings.get("street_events", true)) or not Game.flags.get("street_loan", {}).is_empty() or bool(Game.flags.get("theft_pending", false)):
		_street_panel(sc)
	else:
		var card := UI.add_card(sc)
		card.add_child(UI.lbl(Loc.t("street_disabled"), 16, UI.C_MUTED))
