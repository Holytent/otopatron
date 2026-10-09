extends ScreenBase
var _clock: Label
func _build() -> void:
	UI.header(self, Loc.t("bankrupt_title"), "home")
	var sc := UI.scroll_area(self)
	var c := UI.add_card(sc, UI.C_PANEL2)
	c.add_child(Ico.new("garage", UI.C_BAD, 72))
	c.add_child(UI.lbl(Loc.t("bankrupt_title"), 27, UI.C_BAD, HORIZONTAL_ALIGNMENT_CENTER, true))
	c.add_child(UI.lbl(Loc.t("bankrupt_body"), 16, UI.C_TEXT))
	UI.kv(c, Loc.t("stat_level"), str(Game.bankrupt_state.get("level", Game.level)))
	UI.kv(c, Loc.t("stat_sold"), str(Game.bankrupt_state.get("sold", 0)))
	UI.kv(c, Loc.t("debt_total"), Loc.money(int(Game.bankrupt_state.get("debt", 0))))
	_clock = UI.lbl("", 18, UI.C_ACCENT, HORIZONTAL_ALIGNMENT_CENTER, true)
	c.add_child(_clock)
	c.add_child(UI.btn(Loc.t("restart_now"), "primary", func(): Game.restart_after_bankruptcy(), 54))
func _process(_delta: float) -> void:
	if is_instance_valid(_clock) and not Game.bankrupt_state.is_empty():
		_clock.text = Loc.t("restart_in", [maxi(0, int(ceil(float(Game.bankrupt_state["restart_at"]) - Game.now_seconds())))])
