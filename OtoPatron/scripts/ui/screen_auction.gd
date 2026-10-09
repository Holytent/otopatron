extends ScreenBase
var _page_scroll: ScrollContainer
func rebuild() -> void:
	var old_position: int=_page_scroll.scroll_vertical if is_instance_valid(_page_scroll) else 0
	super.rebuild()
	_restore.call_deferred(old_position)
func _restore(old_position: int) -> void:
	await get_tree().process_frame
	if is_instance_valid(_page_scroll): _page_scroll.scroll_vertical=old_position
func _build() -> void:
	UI.header(self,Loc.t("life_auction"),"market")
	var sc:=UI.scroll_area(self)
	_page_scroll=sc.get_parent() as ScrollContainer
	var lot:=DealerLife.auction()
	var card:=UI.add_card(sc)
	card.add_child(UI.lbl(Loc.t("life_auction_week",[DealerLife.week()+1]),20,UI.C_TEXT,-1,true))
	card.add_child(UI.lbl(Loc.t("life_auction_help"),14,UI.C_MUTED))
	var car: Dictionary=lot["car"]
	card.add_child(UI.car_image(str(car["model"]),145,car))
	card.add_child(UI.lbl(CarDB.full_name(str(car["model"])),20,UI.C_TEXT,-1,true))
	UI.kv(card,Loc.t("year_km"),"%d · %s km" % [int(car["year"]),Loc.num(int(car["km"]))])
	for part in Game.PARTS: UI.kv(card,Loc.t("part_"+part),"%d / 100" % int(car["parts"][part]))
	var leader: String=Loc.t("life_you") if str(lot["leader"])=="player" else (Loc.t("life_auction_house") if str(lot["leader"])=="auction_house" else str(lot["leader"]))
	UI.kv(card,Loc.t("life_high_bid"),Loc.money(int(lot["price"])),UI.C_GOLD)
	UI.kv(card,Loc.t("life_leader"),leader)
	var status: String=str(lot["status"])
	if status=="open":
		var next: int=int(lot["price"])+int(lot["step"])
		var row:=UI.vbox(card,6)
		row.add_child(UI.btn(Loc.t("life_bid",[Loc.money(next)]),"primary",func(): _bid(next),48))
		row.add_child(UI.btn(Loc.t("life_bid",[Loc.money(next+int(lot["step"])*2)]),"ghost",func(): _bid(next+int(lot["step"])*2),44))
		row.add_child(UI.btn(Loc.t("life_withdraw"),"ghost",_withdraw,44))
	elif status=="won":
		card.add_child(UI.lbl(Loc.t("life_won"),16,UI.C_GOOD,-1,true))
		card.add_child(UI.btn(Loc.t("life_collect",[Loc.money(int(lot["price"]))]),"primary",_collect,48))
	else:
		card.add_child(UI.lbl(Loc.t("life_collected" if status=="collected" else "life_lost"),16,UI.C_MUTED))
	for entry in lot["log"]:
		UI.kv(card,Loc.t("life_you") if str(entry["name"])=="player" else str(entry["name"]),Loc.money(int(entry["price"])))
	card.add_child(UI.lbl(Loc.t("life_next_week",[8+DealerLife.week()*7]),13,UI.C_MUTED))
func _bid(amount: int) -> void:
	var result:=DealerLife.bid(amount)
	if result in ["counter","won"]:
		Game.toast(Loc.t("life_won" if result=="won" else "life_rival_bid"),"good" if result=="won" else "info")
	else: _error(result)
	rebuild()
func _error(result: String) -> void:
	Game.toast(Loc.t("err_no_space" if result=="no_space" else ("life_night" if result=="night" else "err_no_money")),"bad")
func _withdraw() -> void:
	var card:=UI.dialog_card(Loc.t("life_withdraw"))
	card.add_child(UI.lbl(Loc.t("life_withdraw_confirm"),16))
	var root:=UI.show_dialog(card)
	card.add_child(UI.btn(Loc.t("ok"),"danger",func(): DealerLife.withdraw(); root.queue_free(); rebuild(),44))
	card.add_child(UI.btn(Loc.t("cancel"),"ghost",func(): root.queue_free(),44))
func _collect() -> void:
	var result:=DealerLife.collect()
	if result=="ok": Game.go("car",{"uid":int(DealerLife.auction()["car"]["uid"])})
	else: _error(result)
