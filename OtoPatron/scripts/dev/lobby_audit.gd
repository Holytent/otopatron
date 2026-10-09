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
	Game.new_game("Lobby Test","34")
	Game.set_process(false)
	Game.flags["gallery_name"]="RAMAZAN OTOMOTİV"
	Game.flags["gallery_style"]={"decor":"luxury","sign":"luxury","floor":"luxury"}
	Game.flags["team"]={"cleaner":2,"mechanic":1,"sales":1}
	Game.minute=1320
	Game.cars.append(Game.gen_car("karya_pico"))
	var before:=Game.to_dict().duplicate(true)
	var main=get_parent()
	main.show_screen("splash",{})
	for i in 4: await get_tree().process_frame
	var screen=main._current
	check(Game.menu_paused,"Opening menu pauses game simulation")
	check(screen._snapshot["flags"]["gallery_name"]=="RAMAZAN OTOMOTİV","Saved sign displayed")
	check(screen._scene._night and screen._scene._backdrop!=null,"Saved night and luxury scene loaded")
	check(screen._scene._workers.filter(func(w): return w.role!="customer").size()==4,"Owned staff visible in menu scene")
	check(screen._scene._cars.size()==3,"Owned car plus two ambient exterior cars")
	var before_pos: Vector2=screen._scene._cars.back().position
	screen._scene._clock+=2
	screen._scene._animate()
	check(screen._scene._cars.back().position!=before_pos,"Exterior traffic moves by transform")
	var scene=screen._scene
	var parked: Vector2=scene._cars[0].position
	scene._clock=1; scene._animate()
	var arriving: Vector2=scene._cars[-2].position
	scene._clock=2; scene._animate()
	check(scene._cars[-2].position.x>arriving.x and not scene._cars[-2].flip_h,"Arrival moves forward with nose facing right")
	check(scene._cars[0].position==parked,"Displayed vehicle remains parked")
	scene._clock=13; scene._animate(); arriving=scene._cars[-2].position
	scene._clock=14; scene._animate()
	check(scene._cars[-2].position.x>arriving.x,"Departure moves forward")
	scene._clock=0; var route0: Dictionary=scene._route(0)
	scene._clock=1; var route1: Dictionary=scene._route(0)
	check(route1["position"].distance_to(route0["position"])>60,"Visitor walks at visible speed")
	scene._clock=3.8; var stopped: Dictionary=scene._route(0)
	check(not stopped["walking"],"Visitor stops to inspect vehicle")
	scene._clock=1; scene._animate()
	check(absf(scene._workers[0].limbs[0].rotation)>.1,"Walking animates retained limbs")
	screen._scene.snapshot["visits"]=[{}]
	screen._select_scene("interior")
	for i in 2: await get_tree().process_frame
	check(screen._scene.mode=="interior" and screen._scene._cars.size()==1,"Interior shows owned vehicle")
	check(screen._scene._workers.filter(func(w): return w.role=="customer").size()==1,"Interior includes waiting customer")
	screen._scene.snapshot["visits"]=[]
	screen._select_scene("map")
	for i in 2: await get_tree().process_frame
	var buttons: Array=screen._scene.get_children().filter(func(c): return c is Button)
	check(buttons.size()==3,"Map contains gallery market and bank destinations")
	Game._process(60.0)
	check(Game.to_dict()==before,"Touring views does not change money time inventory or saves")
	for size in [Vector2i(320,680),Vector2i(432,850),Vector2i(1280,720)]:
		get_window().size=size
		for view in ["exterior","interior","map"]:
			screen._select_scene(view)
			for i in 3: await get_tree().process_frame
			check(screen._scene.size.x<=get_viewport().get_visible_rect().size.x and screen._scene.size.x>0,"Responsive scene "+view+str(size))
	screen._open_destination("market")
	for i in 2: await get_tree().process_frame
	check(main.cur_name=="market" and not Game.menu_paused,"Map routes to market and resumes game")
	main.show_screen("splash",{})
	for i in 2: await get_tree().process_frame
	main.show_screen("settings",{"from":"splash"})
	check(Game.menu_paused,"Menu settings keep simulation paused")
	main.show_screen("home",{})
	check(not Game.menu_paused,"Return to game restores simulation")
	Game.cars.clear(); Game.visits.clear()
	var live_scene:=LobbyScene.new(); live_scene.live=true; live_scene.mode="interior"
	main._current.add_child(live_scene)
	for i in 2: await get_tree().process_frame
	check(live_scene._cars.size()==3 and not is_instance_valid(live_scene._demo),"Empty showroom displays cars without sample caption")
	check(Game.cars.is_empty(),"Sample display never creates owned inventory")
	live_scene._refresh_live()
	var retained=live_scene._cars[0]
	live_scene._clock=5
	Game.money+=1; live_scene._refresh_live()
	check(live_scene._cars[0]==retained and live_scene._clock==5,"Balance updates retain animation nodes and phase")
	Game.cars.append(Game.gen_car("karya_pico")); live_scene._refresh_live()
	check(live_scene._cars.size()==1 and not is_instance_valid(live_scene._demo),"Purchase replaces samples with owned car")
	Game.visits.append({"id":999,"name":"Deneme alıcı"}); live_scene._refresh_live()
	var buyers=live_scene._workers.filter(func(w): return w.role=="customer")
	var selected: Array=[false]
	live_scene.customer_pressed.connect(func(v): selected[0]=int(v["id"])==999)
	check(buyers.size()==1,"Live visitors match actual buyers")
	for child in buyers[0].get_children():
		if child is Button: child.pressed.emit()
	check(selected[0],"Buyer interaction forwards original visit")
	Game.minute=480; live_scene._refresh_live()
	check(not live_scene._night,"Live gallery updates day lighting")
	for i in 20: live_scene.set_mode("exterior" if i%2==0 else "interior")
	for i in 3: await get_tree().process_frame
	check(live_scene.get_child_count()<40,"Repeated views keep node count bounded")
	live_scene.queue_free()
	main.show_screen("splash",{})
	await get_tree().process_frame
	main._current._on_new()
	await get_tree().process_frame
	var fields=UI.overlay.find_children("*","LineEdit",true,false)
	check(fields.size()==1,"New game contains single owner name field")
	var field: LineEdit=fields[0]
	MobileInput._field=field; MobileInput._original=field.text
	MobileInput._commit(["Ramazan Otomotiv",true])
	check(field.text=="Ramazan Otomotiv","Saved owner name appears in original form")
	MobileInput._field=field; MobileInput._original=field.text
	field.text="Leaked keyboard input"; MobileInput._commit(["Cancelled",false])
	check(field.text=="Ramazan Otomotiv","Cancelled editor restores original name")
	check(field.get_theme_color("font_color")==Color.WHITE,"Owner name has readable form contrast")
	for child in UI.overlay.get_children(): child.queue_free()
	await get_tree().process_frame
	UI.pick_city("34",func(_code): pass,true)
	await get_tree().process_frame
	var city_buttons=UI.overlay.find_children("*","Button",true,false)
	check(city_buttons.any(func(b): return b.text=="İstanbul"),"City list shows name without plate")
	check(not city_buttons.any(func(b): return b.text.begins_with("34")),"Plate prefix removed")
	for child in UI.overlay.get_children(): child.queue_free()
	await get_tree().process_frame
	Game.diamonds=105; main._refresh_hud()
	check(main._hud_gems_label.text=="105","Gem balance shows complete count without plus")
	check(main._hud_money_button.get_theme_font_size("font_size")==18,"Cash display reduced")
	check(UI.C_BG==Color("101e30") and UI.C_GOLD==Color("edc16b"),"Night blue and gold palette applied")
	var display:=LobbyScene.new(); display.snapshot={};display.mode="interior"
	main._current.add_child(display)
	await get_tree().process_frame
	check(display._platforms.size()==3,"Three rotating showroom platforms")
	check(display._cars.all(func(c): return not c.visible),"Flat showroom sprites replaced by rotating models")
	display._clock=1;display._animate();var turn: float=display._platforms[0].angle
	display._clock=5;display._animate()
	check(display._platforms[0].angle>turn,"Car model turns on platform")
	var kinds: Dictionary = {}
	for model in CarDB.MODELS: kinds[CarTurntable.kind_for(str(model["id"]))] = true
	check(kinds.keys().all(func(k): return CarTurntable.MODELS.has(k)),"Every car maps to an imported showroom model")
	check(kinds.size()>=6,"Showroom shows at least six distinct vehicle shapes")
	display.queue_free()
	print("LOBBY_AUDIT_COMPLETE ",checks," checks ",failures," failures")
	await Fx.release_audio()
	get_tree().quit(1 if failures else 0)
