extends ScreenBase
func _build() -> void:
	UI.header(self, Loc.t("team_title"), "management")
	var sc := UI.scroll_area(self)
	sc.add_child(UI.lbl(Loc.t("team_info"),14,UI.C_MUTED))
	UI.kv(sc,Loc.t("team_total"),Loc.money(DealerExpansion.wages()))
	sc.add_child(UI.lbl(Loc.t("life_xp_help"),14,UI.C_MUTED))
	for id in DealerExpansion.TEAM:
		var role: String = id
		var hired: bool = DealerExpansion.staff(id)
		var number: int = DealerExpansion.count(id)
		var card := UI.add_card(sc)
		card.add_child(UI.lbl(Loc.t("team_"+id),20,UI.C_TEXT,-1,true))
		card.add_child(UI.lbl(Loc.t("team_help_"+id),14,UI.C_MUTED))
		UI.kv(card,Loc.t("team_slots"),"%d / %d" % [number,DealerExpansion.staff_limit()])
		UI.kv(card,Loc.t("team_wage"),Loc.money(int(DealerExpansion.TEAM[id]["wage"])))
		if hired:
			card.add_child(UI.lbl(Loc.t("life_team_level",[DealerLife.rank(id)]),16,UI.C_ACCENT,-1,true))
			card.add_child(UI.bar(DealerLife.experience(id),400,UI.C_ACCENT,6))
			card.add_child(UI.lbl(Loc.t("life_team_xp",[DealerLife.experience(id)]),13,UI.C_MUTED))
			var benefit: int=int(round((1-DealerLife.cleaner_factor())*100)) if id=="cleaner" else (int(round(DealerLife.mechanic_discount()*100)) if id=="mechanic" else int(round((DealerLife.sales_factor()-1)*100)))
			card.add_child(UI.lbl(Loc.t("life_skill_"+id,[benefit]),14,UI.C_GOOD))
			card.add_child(UI.pill(Loc.t("team_active"),UI.C_GOOD))
			card.add_child(UI.btn(Loc.t("team_dismiss"),"ghost",func():
				DealerExpansion.dismiss(role)
				rebuild(),44))
		if number < DealerExpansion.staff_limit():
			card.add_child(UI.btn(Loc.t("team_hire",[Loc.money(int(DealerExpansion.TEAM[id]["fee"]))]),"primary",func():
				var result := DealerExpansion.hire(role)
				if result != "ok": Game.toast(Loc.t("team_debt") if result=="debt" else Loc.t("err_no_money"),"bad")
				rebuild(),48))
