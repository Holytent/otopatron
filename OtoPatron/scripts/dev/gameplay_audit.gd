extends Node
var checks: int = 0
var failures: int = 0
func check(ok: bool, title: String) -> void:
	checks+=1
	if not ok: failures+=1
	print("PASS " if ok else "FAIL ",title)
func _ready() -> void:
	run.call_deferred()
func run() -> void:
	Game.new_game("Kontrol","34")
	Game.set_process(false)
	Game.money=10000000
	Gameplay.ensure_offers()
	var offer := Gameplay.offer("rescue")
	check(not offer.is_empty() and offer["car"]["clean"]==8,"Neglected rescue generated")
	var uid: int = int(offer["car"]["uid"])
	Gameplay.ensure_offers()
	check(uid==int(Gameplay.offer("rescue")["car"]["uid"]),"Reopening cannot reroll offers")
	var money: int = Game.money
	var price: int = int(offer["ask"])
	check(Gameplay.acquire("rescue")=="ok" and Game.money==money-price,"Rescue debits exact price")
	check(Gameplay.acquire("rescue")=="gone" and Game.money==money-price,"Double purchase blocked")
	var car := Game.car_by_uid(uid)
	check(not car.is_empty() and car["bought_price"]==price and not Gameplay.rescued(car),"Rescue ownership and goal tracked")
	var snapshot := Game.to_dict().duplicate(true)
	Game.from_dict(snapshot)
	car=Game.car_by_uid(uid)
	check(car.get("rescue",false) and Gameplay.offer("rescue").is_empty(),"Rescue persists after reload")
	money=Game.money
	var repair_total: int = Game.clean_cost(car)
	for part in Game.PARTS: repair_total+=Game.repair_cost(car,part)
	Game.clean_car(car)
	for part in Game.PARTS: Game.repair_part(car,part)
	check(Game.money==money-repair_total and car["invested"]==repair_total,"All restoration costs match budget and investment")
	check(Gameplay.rescued(car),"Restoration goal requires all four parts")
	car["listed"]=true
	car["list_price"]=Game.suggested_price(car)
	var v := Gameplay.rival_trade()
	check(not v.is_empty() and v["name"]=="Cem" and v.has("trade"),"Named rival offers normal atomic trade")
	check(Gameplay.rival_trade().is_empty(),"Daily rival trade cannot repeat")
	check(Gameplay.rival_alive(),"Rival bargain starts active")
	Game.minute=int(Gameplay.offer("rival")["deadline"])-Game.day*1440
	money=Game.money
	check(Gameplay.acquire("rival")=="gone" and Game.money==money,"Expired rival offer cannot charge")
	Game.day+=1
	Gameplay.ensure_offers()
	Game.money=0
	check(Gameplay.acquire("rescue")=="no_money" and not Gameplay.offer("rescue").is_empty(),"Insufficient funds preserve offer")
	Game.money=10000000
	Game.garage_cap=Game.cars.size()
	check(Gameplay.acquire("rescue")=="no_space","Full garage blocks rescue purchase")
	Game.garage_cap=5
	var main=get_parent()
	for width in [320,432,1280]:
		get_window().size=Vector2i(width,768)
		for language in ["tr","en","ar","fr"]:
			Loc.set_lang(language)
			for kind in ["rescue","rival"]:
				main.show_screen("gameplay",{"kind":kind})
				await get_tree().process_frame
				check(is_instance_valid(main._current),kind+language+str(width))
	Loc.set_lang("tr")
	main.show_screen("garage",{})
	await get_tree().process_frame
	var stages=main._current.find_children("*","Control",true,false).filter(func(c): return c is LobbyScene)
	check(stages.size()==1 and stages[0]._workers.filter(func(w): return w.role=="customer").size()==Game.visits.slice(0,3).size(),"Visible buyers linked to visits")
	get_window().size=Vector2i(320,680)
	await get_tree().process_frame
	var buyer: Dictionary=Game.visits.back()
	main._current._open_visit(buyer)
	await get_tree().process_frame
	var screen=main._current
	screen._start_test_drive()
	await get_tree().process_frame
	var modal=UI.overlay.get_child(UI.overlay.get_child_count()-1)
	var drive=modal.find_children("*","Control",true,false).filter(func(c): return c is PlayableDrive)[0]
	await get_tree().process_frame
	var panels: Array = modal.find_children("*","PanelContainer",true,false)
	check(not panels.is_empty() and panels[0].get_global_rect().position.y>=0 and panels[0].get_global_rect().end.y<=get_viewport().get_visible_rect().size.y,"Drive dialog fits 320 by 680 screen")
	check(drive.status.size.x>100 and drive.status.size.y<40,"Drive status remains a single bounded line")
	var old_offer: int=int(buyer["offer"])
	drive.start()
	drive.steer=1
	drive._process(.05)
	check(drive.lane>0 and drive.distance>0,"Steering and throttle respond")
	drive.braking=true
	drive._process(.05)
	check(drive.speed==0,"Brake stops vehicle")
	modal.queue_free()
	await get_tree().process_frame
	check(not screen._busy and not buyer.get("test_drive_done",false) and int(buyer["offer"])==old_offer,"Cancel leaves offer untouched and unlocks controls")
	screen._start_test_drive()
	await get_tree().process_frame
	modal=UI.overlay.get_child(UI.overlay.get_child_count()-1)
	drive=modal.find_children("*","Control",true,false).filter(func(c): return c is PlayableDrive)[0]
	drive.start()
	# Follow the actual course, including the finish braking zone.
	for i in 2000:
		if drive.done: break
		drive.lane=drive.road_center(drive.distance)
		drive.braking=drive.distance>850
		drive._process(.02)
	check(drive.done and bool(buyer.get("test_drive_done",false)),"Complete course returns to negotiation")
	var result:=Game.test_drive(buyer,0)
	check(result==buyer["test_drive_result"],"Repeat result cannot farm offers")
	screen._root.queue_free()
	await get_tree().process_frame
	check(Game._negotiation_depth==0,"Closing dialogue releases pause")
	main.show_screen("home",{})
	await get_tree().process_frame
	var nodes: int = 0
	var resources: int = 0
	for step in 126:
		main.show_screen("gameplay",{"kind":"rescue" if step%2==0 else "rival"})
		await get_tree().process_frame
		main.show_screen("garage",{})
		await get_tree().process_frame
		main.show_screen("home",{})
		await get_tree().process_frame
		if step==5:
			nodes=int(Performance.get_monitor(Performance.OBJECT_NODE_COUNT))
			resources=int(Performance.get_monitor(Performance.OBJECT_RESOURCE_COUNT))
	check(int(Performance.get_monitor(Performance.OBJECT_NODE_COUNT))-nodes<=3,"New pages: 360 repeated transitions without node growth")
	check(int(Performance.get_monitor(Performance.OBJECT_RESOURCE_COUNT))-resources<=5,"New pages: bounded resource use")
	print("GAMEPLAY_AUDIT_COMPLETE checks=",checks," failures=",failures)
	get_tree().quit(1 if failures else 0)
