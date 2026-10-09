extends Node
var count: int = 0
var failures: int = 0
func check(ok: bool, label: String) -> void:
	count+=1
	if not ok: failures+=1
	print("PASS " if ok else "FAIL ",label)
func _ready() -> void:
	run.call_deferred()
func run() -> void:
	Game.new_game("Test","34")
	Game.set_process(false)
	Game.money=10000000
	var car := Game.gen_car("karya_pico",30,40)
	car["known"]={"engine":true,"body":true,"tires":true,"interior":true}
	Game.cars.append(car)
	var main=get_parent()
	main.show_screen("car",{"uid":car["uid"]})
	for i in 4: await get_tree().process_frame
	var screen=main._current
	screen._page_scroll.scroll_vertical=300
	screen._title_input.text="Taslak ilan"
	screen._description_input.text="Kaybolmayan açıklama"
	var before: int=Game.money
	var cost: int=Game.repair_cost(car,"engine")
	Game.repair_part(car,"engine")
	screen.rebuild()
	for i in 4: await get_tree().process_frame
	check(screen._page_scroll.scroll_vertical==300,"Repair retains exact scroll position")
	check(screen._title_input.text=="Taslak ilan" and screen._description_input.text=="Kaybolmayan açıklama","Repair preserves draft listing")
	check(Game.money==before-cost,"Repair charges exactly once")
	Game.flags["security"]=5
	Game.flags["theft_pending"]=true
	before=Game.money
	Game.resolve_theft(true)
	check(Game.money==before and not Game.flags["theft_pending"],"Tier five stops thief without dispatch fee")
	Game.resolve_theft(true)
	check(Game.money==before,"Repeated alarm resolution cannot charge")
	Game.flags["security"]=0
	Game.flags["theft_pending"]=true
	main._sync_alarm()
	check(main._alarm.visible and not main._alarm.disabled,"Red intervention strip active without guards")
	Game.flags["security"]=3
	main._sync_alarm()
	check(main._alarm.disabled,"Purchased guards show automatic response")
	main._build_chrome()
	main._sync_alarm()
	check(is_instance_valid(main._alarm) and main._alarm.visible,"Alarm survives theme chrome rebuild")
	Game.flags["theft_pending"]=false
	main._sync_alarm()
	check(not main._alarm.visible,"Resolved alarm disappears")
	for pack in 3:
		before=Game.money
		var gems: int=Game.diamonds
		check(Game.shop_exchange("gems",pack) and Game.money==before-[100000,320000,900000][pack] and Game.diamonds==gems+[5,15,40][pack],"Gem pack exact new price "+str(pack))
	Game.money=99999
	check(not Game.shop_exchange("gems",0),"Old cheap gem budget rejected")
	check(DealerExpansion.TEAM["cleaner"]["wage"]==650 and DealerExpansion.TEAM["mechanic"]["wage"]==1200 and DealerExpansion.TEAM["sales"]["wage"]==1100,"Staff wages moderately increased")
	check(ReleaseInfo.NOTES["tr"]==["Performans iyileştirildi.","Optimizasyon yapıldı."],"Release notes contain only allowed truthful phrases")
	main.show_screen("home",{})
	for i in 3: await get_tree().process_frame
	var road=main._current.find_children("*","Control",true,false).filter(func(c): return c is RoadAnim)[0]
	MobileScroll._active_until=Time.get_ticks_msec()+1000
	var start: float=road._t
	road._process(.016)
	check(road._t>start,"Touch activity no longer freezes home traffic")
	MobileScroll._active_until=0
	Game.flags["theft_pending"]=false
	print("FIX_AUDIT_COMPLETE ",count," checks; ",failures," failures")
	get_tree().quit(1 if failures else 0)
