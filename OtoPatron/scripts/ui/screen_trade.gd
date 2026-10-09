extends ScreenBase
var visit: Dictionary = {}
var committed: bool = false
func _ready() -> void:
	Game.begin_negotiation()
	super._ready()
func _exit_tree() -> void:
	Game.end_negotiation()
func _build() -> void:
	UI.header(self,Loc.t("trade_title"),"garage")
	var sc := UI.scroll_area(self)
	for v in Game.visits:
		if int(v["id"]) == int(params.get("visit",0)): visit = v
	if visit.is_empty() or not Game.visits.has(visit):
		sc.add_child(UI.lbl(Loc.t("listing_gone"),16))
		return
	var quote := DealerExpansion.trade_quote(visit)
	if quote.is_empty(): return
	var car: Dictionary = quote["car"]
	var credit: int = int(quote["credit"])
	var cash: int = int(visit["offer"])-credit
	var card := UI.add_card(sc)
	card.add_child(UI.lbl(Loc.t("trade_incoming"),19,UI.C_TEXT,-1,true))
	card.add_child(UI.car_image(str(car["model"]),150,car))
	card.add_child(UI.lbl(CarDB.full_name(str(car["model"])),20,UI.C_TEXT,-1,true))
	UI.kv(card,Loc.t("year_km"),"%d · %s km" % [car["year"],Loc.num(int(car["km"]))])
	UI.kv(card,Loc.t("trade_credit"),Loc.money(credit))
	UI.kv(card,Loc.t("trade_sale"),Loc.money(int(visit["offer"])))
	UI.kv(card,Loc.t("trade_receive" if cash>=0 else "trade_pay"),Loc.money(absi(cash)),UI.C_GOOD if cash>=0 else UI.C_BAD)
	card.add_child(UI.lbl(Loc.t("trade_hint"),14,UI.C_MUTED))
	for part in Game.PARTS:
		var key: String = part
		if bool(car["known"].get(part,false)):
			UI.kv(card,Loc.t("part_"+part),"%d/100" % int(car["parts"][part]))
		else:
			card.add_child(UI.btn(Loc.t("part_"+part)+" · "+Loc.t("btn_inspect",[Loc.money(Game.inspect_cost(car))]),"ghost",func():
				if Game.inspect_part(car,key): rebuild(),44))
	var accept := UI.btn(Loc.t("trade_accept"),"primary",_confirm,50)
	accept.disabled = cash<0 and Game.money < -cash
	sc.add_child(accept)
	sc.add_child(UI.btn(Loc.t("trade_back"),"ghost",func(): Game.go("garage",{"open":int(visit["id"])}),44))
func _confirm() -> void:
	if committed: return
	var panel := UI.dialog_card(Loc.t("trade_title"))
	panel.add_child(UI.lbl(Loc.t("trade_confirm"),16))
	var root := UI.show_dialog(panel)
	panel.add_child(UI.btn(Loc.t("trade_accept"),"primary",func():
		if committed: return
		committed = true
		var result := DealerExpansion.accept_trade(visit)
		root.queue_free()
		if result.is_empty():
			committed = false
			Game.toast(Loc.t("trade_failed"),"bad")
			rebuild()
		else:
			Game.toast(Loc.t("trade_done"),"good")
			Game.go("car",{"uid":int(result["car"]["uid"])}),48))
	panel.add_child(UI.btn(Loc.t("cancel"),"ghost",func(): root.queue_free(),44))
