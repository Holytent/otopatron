extends ScreenBase
var zoom: float = 1.0
var focus: float = .5
var preview: bool = false
var portrait: CarCloseup
func _build() -> void:
	var uid: int = int(params.get("uid", -1))
	var car := Game.car_by_uid(uid)
	UI.header(self, Loc.t("closeup_title"))
	var sc := UI.scroll_area(self)
	sc.add_child(UI.btn(Loc.t("closeup_back"), "ghost", func(): Game.go("car", {"uid": uid}), 44))
	if car.is_empty():
		sc.add_child(UI.lbl(Loc.t("listing_gone"), 16))
		return
	var card := UI.add_card(sc)
	card.add_child(UI.lbl(CarDB.full_name(str(car["model"])), 20, UI.C_TEXT, -1, true))
	var visible_car := car.duplicate(true)
	if preview:
		visible_car["clean"] = 100.0
		visible_car["parts"]["body"] = maxf(95, float(visible_car["parts"]["body"]))
	portrait = CarCloseup.new(str(car["model"]), visible_car)
	portrait.zoom = zoom
	portrait.focus = focus
	card.add_child(portrait)
	var zooms := UI.hbox(card, 6)
	for value in [1.0, 1.6, 2.2]:
		var selected: float = value
		zooms.add_child(UI.btn("%.1f×" % value, "chipon" if zoom == value else "chip", func():
			zoom = selected
			rebuild(), 42))
	var focus_row := UI.hbox(card, 6)
	for index in 3:
		var point: float = [.35,.5,.68][index]
		focus_row.add_child(UI.btn(Loc.t(["closeup_rear", "closeup_all", "closeup_front"][index]), "chipon" if focus == point else "chip", func():
			focus = point
			rebuild(), 42))
	card.add_child(UI.btn(Loc.t("closeup_current") if preview else Loc.t("closeup_preview"), "ghost", func():
		preview = not preview
		rebuild(), 46))
	card.add_child(UI.lbl(Loc.t("closeup_preview_hint") if preview else Loc.t("closeup_hint"), 14, UI.C_MUTED))
	UI.kv(card, Loc.t("clean"), "%d/100" % int(car["clean"]))
	for part in Game.PARTS:
		var known: bool = bool(car["known"].get(part, false))
		UI.kv(card, Loc.t("part_"+part), "%d/100" % int(car["parts"][part]) if known else Loc.t("state_unknown"))
