extends "res://scripts/ui/screen_garage.gd"
func _build() -> void:
	UI.header(self, Loc.t("gallery_expenses"), "management")
	var sc := UI.scroll_area(self)
	_bill_card(sc)
	sc.add_child(UI.btn_icon("clock", Loc.t("business_time_action"), "ghost", _open_time, 48))
