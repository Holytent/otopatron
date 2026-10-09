extends Node
var checks:=0
var failures:=0
func check(ok: bool,label: String) -> void:
	checks+=1
	if not ok: failures+=1
	print("PASS " if ok else "FAIL ",label)
func _ready() -> void:
	run.call_deferred()
func run() -> void:
	Game.new_game("Life Audit","34")
	Game.set_process(false)
	Game.settings["sfx"]=0
	Game.settings["music"]=0
	Game.money=10000000
	check(DealerLife.rank("cleaner")==1 and DealerLife.mechanic_discount()==0,"Old saves start without skill bonuses")
	DealerLife.earn("cleaner",100)
	check(DealerLife.experience("cleaner")==0,"No XP without hired worker")
	for role in DealerExpansion.TEAM: DealerExpansion.hire(role)
	var car:=Game.gen_car("karya_pico",30,60)
	car["clean"]=25.0
	car["bought_price"]=10000
	Game.cars.append(car)
	check(Game.clean_car(car) and DealerLife.experience("cleaner")==10,"Actual cleaning grants XP")
	var xp: int=DealerLife.experience("cleaner")
	check(not Game.clean_car(car) and DealerLife.experience("cleaner")==xp,"Repeated clean grants no XP")
	check(Game.repair_part(car,"engine") and DealerLife.experience("mechanic")==10,"Actual repair grants XP")
	check(not Game.repair_part(car,"engine") and DealerLife.experience("mechanic")==10,"Repeated repair grants no XP")
	var base_repair: int=Game.repair_cost(car,"body")
	DealerLife.earn("mechanic",100)
	check(DealerLife.rank("mechanic")==2 and Game.repair_cost(car,"body")<base_repair,"Mechanic level lowers real quote")
	DealerLife.earn("mechanic",100000)
	check(DealerLife.rank("mechanic")==5 and DealerLife.experience("mechanic")==400,"XP and rank have strict caps")
	Game.flags["team"]["mechanic"]=5
	check(is_equal_approx(DealerLife.mechanic_discount(),.32),"Repair discount bounded at 32 percent")
	var wage: int=DealerExpansion.wages()
	DealerLife.earn("sales",400)
	check(DealerExpansion.wages()==wage and DealerLife.sales_factor()>1.2,"Experience affects interest without hidden wages")
	DealerExpansion.dismiss("sales")
	check(DealerLife.experience("sales")==0,"Last dismissal resets team mastery")
	Game.flags["team"]["cleaner"]=1
	DealerLife.earn("cleaner",390)
	check(is_equal_approx(DealerLife.cleaner_factor(),.3),"Maximum washing discount 70 percent")
	for i in 2:
		var dirty:=Game.gen_car("karya_pico")
		dirty["clean"]=0.0
		Game.cars.append(dirty)
	Game.flags.erase("cleaner_hour")
	DealerExpansion.cleaner_hour()
	check(float(Game.cars[1]["clean"])==100 and float(Game.cars[2]["clean"])==100,"Master cleaner completes extra hourly jobs")
	car["outdoors"]=true
	car["clean"]=100.0
	Game.cars[1]["outdoors"]=false
	Game.weather={"id":"rain","temp":15,"dm":.85}
	Game.flags.erase("weather_hour")
	DealerLife.weather_hour()
	check(float(car["clean"])==98 and float(Game.cars[1]["clean"])==100,"Rain dirt affects only outdoor vehicles")
	DealerLife.weather_hour()
	check(float(car["clean"])==98,"Repeated weather tick cannot double dirt")
	Game.weather["id"]="sunny"
	Game.minute+=60
	DealerLife.weather_hour()
	check(float(car["clean"])==98,"Sunshine creates no extra dirt")
	var snapshot:=Game.to_dict().duplicate(true)
	Game.from_dict(snapshot)
	car=Game.cars[0]
	check(DealerLife.rank("cleaner")==5 and bool(car["outdoors"]),"Staff XP and outdoor choice survive save load")
	var sale:=Game.finalize_sale(car,100000)
	check(not sale.is_empty(),"Existing sale still completes")
	var before: int=Game.money
	check(Game.finalize_sale(car,100000).is_empty() and Game.money==before,"Sale cannot be duplicated")
	var lot:=DealerLife.auction()
	var uid: int=int(lot["car"]["uid"])
	check(DealerLife.auction()["car"]["uid"]==uid,"Weekly lot stable across page rebuilds")
	check(DealerLife._valid_lot(lot),"Auction lot validates")
	var next: int=int(lot["price"])+int(lot["step"])
	before=Game.money
	check(DealerLife.bid(0)=="low" and Game.money==before,"Too low bid has no charge")
	Game.money=1
	check(DealerLife.bid(next)=="no_money" and int(lot["round"])==0,"Unaffordable bid rejected without advancing auction")
	Game.money=before
	Game.garage_cap=Game.cars.size()
	check(DealerLife.bid(next)=="no_space","Full garage blocks bid")
	Game.garage_cap=8
	Game.minute=1380
	check(DealerLife.bid(next)=="night","Closed shop blocks auction purchase")
	Game.minute=420
	check(DealerLife.bid(next)=="counter" and Game.money==before,"Rivals respond while money remains untouched")
	var fixed_limits: Array=lot["rivals"].duplicate(true)
	snapshot=Game.to_dict().duplicate(true)
	Game.from_dict(snapshot)
	lot=DealerLife.auction()
	check(lot["rivals"]==fixed_limits and int(lot["round"])==1,"Rival budgets and bidding round survive reload")
	var winning: int=maxi(int(lot["rivals"][0]["limit"]),int(lot["rivals"][1]["limit"]))+int(lot["step"])
	winning=maxi(winning,int(lot["price"])+int(lot["step"]))
	check(DealerLife.bid(winning)=="won" and Game.money==before,"Winning bid only creates claim, no charge")
	Game.money=1
	check(DealerLife.collect()=="no_money" and str(lot["status"])=="won","Insufficient balance preserves uncollected win")
	Game.money=before
	var count_before: int=Game.cars.size()
	check(DealerLife.collect()=="ok" and Game.money==before-winning and Game.cars.size()==count_before+1,"Collection charges once and adds owned vehicle")
	before=Game.money
	check(DealerLife.collect()=="closed" and DealerLife.bid(winning)=="closed" and Game.money==before,"Repeated collection and bidding cannot duplicate purchase")
	check(int(Game.car_by_uid(uid)["bought_price"])==winning,"Auction price becomes real vehicle acquisition cost")
	Game.day=8
	lot=DealerLife.auction()
	check(int(lot["car"]["uid"])!=uid and int(lot["week"])==1,"Next game week creates new lot")
	DealerLife.withdraw()
	check(str(DealerLife.auction()["status"])=="lost" and Game.money==before,"Withdrawing closes weekly lot without charge")
	Game.flags["weekly_auction"]={"week":1,"car":lot["car"]}
	check(DealerLife._valid_lot(DealerLife.auction()),"Incomplete nested auction data safely replaced")
	for language in Loc.LANGS:
		Loc.set_lang(language)
		check(not Loc.t("life_auction").contains("life_auction"),"New copy has language fallback "+language)
	Loc.set_lang("tr")
	var main:=get_parent()
	for page in ["auction","staff","home","garage","car"]:
		main.show_screen(page,{"uid":uid})
		for i in 3: await get_tree().process_frame
		check(is_instance_valid(main._current),"New feature page builds "+page)
	main.show_screen("auction",{})
	for i in 3: await get_tree().process_frame
	var auction_page=main._current
	auction_page._page_scroll.scroll_vertical=100
	var scroll_before: int=auction_page._page_scroll.scroll_vertical
	auction_page.rebuild()
	for i in 4: await get_tree().process_frame
	check(auction_page._page_scroll.scroll_vertical==scroll_before,"Auction rebuild retains scroll position")
	load("res://scripts/ui/screen_garage.gd").show_sale_result(sale)
	for i in 3: await get_tree().process_frame
	check(UI.overlay.get_child_count()>0,"Scrollable sale receipt builds with delivery")
	for child in UI.overlay.get_children(): child.queue_free()
	await get_tree().process_frame
	var scene:=DealScene.new()
	scene.car=Game.cars[0].duplicate(true)
	scene.delivery=true
	UI.overlay.add_child(scene)
	scene.size=Vector2(300,150)
	await get_tree().process_frame
	before=Game.money
	scene.elapsed=2.5
	scene._animate()
	check(scene._key.text==Loc.t("life_key") and scene._buyer.visible,"Delivery shows keys and customer")
	scene.elapsed=6
	scene._animate()
	check(not scene._buyer.visible and scene._vehicle.position.x>scene.size.x and Game.money==before,"Delivery departs without mutating economy")
	scene.delivery=false
	scene.respond("counter")
	check(scene._caption.text==Loc.t("life_reaction_counter"),"Negotiation feedback changes with reply")
	scene.queue_free()
	for child in UI.overlay.get_children(): child.queue_free()
	var weather_scene:=WeatherLayer.new()
	main.add_child(weather_scene)
	Game.weather["id"]="rain"
	await get_tree().process_frame
	check(weather_scene._particles.size()==24,"Rain has bounded retained particles")
	Game.weather["id"]="fog"
	weather_scene._sync()
	check(weather_scene._particles.is_empty(),"Fog requires no moving particles")
	weather_scene.queue_free()
	print("LIFE_AUDIT_COMPLETE ",checks," checks; ",failures," failures")
	get_tree().quit(1 if failures>0 else 0)
