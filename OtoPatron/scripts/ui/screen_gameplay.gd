extends ScreenBase
var _deadline: Label
func _ready() -> void:
	super._ready()
	Game.live_tick.connect(func():
		if is_instance_valid(_deadline):
			var offer := Gameplay.offer("rival")
			_deadline.text = Loc.t("play_deadline",[maxi(0,int(offer.get("deadline",0))-Game.day*1440-Game.minute)]) if Gameplay.rival_alive() else Loc.t("play_unavailable"))
func _build() -> void:
	var kind: String = str(params.get("kind","rescue"))
	Gameplay.ensure_offers()
	UI.header(self,Loc.t("play_"+kind),"market")
	var sc := UI.scroll_area(self)
	var intro := UI.add_card(sc)
	intro.add_child(UI.lbl(Loc.t("play_"+kind+"_help"),15,UI.C_MUTED))
	if kind=="rival":
		var actor := ConversationActor.new()
		actor.identity = "Cem"
		intro.add_child(actor)
		intro.add_child(UI.btn(Loc.t("play_rival_trade"),"ghost",func():
			var v := Gameplay.rival_trade()
			if v.is_empty(): Game.toast(Loc.t("play_trade_hint"),"bad")
			else: Game.go("trade",{"visit":v["id"]}),46))
	var offer := Gameplay.offer(kind)
	if not offer.is_empty() and (kind!="rival" or Gameplay.rival_alive()):
		var car: Dictionary = offer["car"]
		var card := UI.add_card(sc)
		card.add_child(UI.car_image(str(car["model"]),170,car))
		card.add_child(UI.lbl(CarDB.full_name(str(car["model"])),20,UI.C_TEXT,-1,true))
		if kind=="rival":
			_deadline = UI.lbl(Loc.t("play_deadline",[maxi(0,int(offer["deadline"])-Game.day*1440-Game.minute)]),14,UI.C_ACCENT)
			card.add_child(_deadline)
		else:
			for part in Game.PARTS: UI.kv(card,Loc.t("part_"+part),"%d / 100" % int(car["parts"][part]))
			var budget: int = Game.clean_cost(car)
			for part in Game.PARTS: budget += Game.repair_cost(car,part)
			UI.kv(card,Loc.t("play_repair_budget"),Loc.money(budget))
			UI.kv(card,Loc.t("play_total_budget"),Loc.money(budget+int(offer["ask"])))
		UI.kv(card,Loc.t("asking"),Loc.money(int(offer["ask"])),UI.C_GOLD)
		card.add_child(UI.btn(Loc.t("play_buy"),"primary",func():
			var uid: int = int(car["uid"])
			var result := Gameplay.acquire(kind)
			if result=="ok": Game.go("car",{"uid":uid})
			else:
				Game.toast(Loc.t("err_no_money" if result=="no_money" else ("err_no_space" if result=="no_space" else "play_unavailable")),"bad")
				rebuild(),50))
	else: sc.add_child(UI.lbl(Loc.t("play_unavailable"),15,UI.C_MUTED))
	if kind=="rescue":
		for car in Game.cars:
			if not bool(car.get("rescue",false)): continue
			var owned: Dictionary = car
			var card := UI.add_card(sc)
			card.add_child(UI.car_image(str(car["model"]),120,car))
			card.add_child(UI.lbl(CarDB.full_name(str(car["model"])),18,UI.C_TEXT,-1,true))
			card.add_child(UI.lbl(Loc.t("play_restored" if Gameplay.rescued(car) else "play_restore_goal"),14,UI.C_GOOD if Gameplay.rescued(car) else UI.C_MUTED))
			UI.kv(card,Loc.t("sale_expenses"),Loc.money(int(car["invested"])))
			card.add_child(UI.btn(Loc.t("btn_manage"),"ghost",func(): Game.go("car",{"uid":owned["uid"]}),46))
