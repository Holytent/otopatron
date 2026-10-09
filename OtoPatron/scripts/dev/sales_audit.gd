extends Node
var count: int = 0
func check(ok: bool, title: String) -> void:
	count += 1
	if not ok:
		push_error(title)
		get_tree().quit(1)
		return
	print("PASS ", title)
func _ready() -> void:
	run.call_deferred()
func run() -> void:
	Game.set_process(false)
	Game.new_game("Test", "34")
	Game.settings["music"] = 0.0
	Game.settings["sfx"] = 0.0
	Game.settings["vibe"] = false
	Game.money = 10000000
	var car := Game.gen_car("karya_pico")
	car["bought_price"] = 100000
	car["invested"] = 12000
	car["list_price"] = 150000
	car["listed"] = true
	car["clean"] = 100
	for key in Game.PARTS: car["parts"][key] = 100
	Game.cars.append(car)
	Game._make_visit(car)
	var v: Dictionary = Game.visits[0]
	var before: int = int(v["offer"])
	Game.begin_negotiation()
	var result := Game.test_drive(v)
	check(result["score"] == 100 and int(v["offer"]) > before, "Healthy clean car improves offer")
	var offer: int = int(v["offer"])
	var clock: int = Game.minute
	check(Game.test_drive(v) == result and int(v["offer"]) == offer and Game.minute == clock, "Repeat drive does not change offer or time")
	var snapshot := Game.to_dict().duplicate(true)
	check(snapshot["visits"][0]["test_drive_done"], "Drive result included in snapshot")
	Game.from_dict(snapshot)
	check(Game.visits.is_empty(), "Reload preserves existing expired-visit cleanup")
	car = Game.cars[0]
	for key in Game.PARTS: car["parts"][key] = 10
	car["clean"] = 5
	Game._make_visit(car)
	var second: Dictionary = Game.visits.back()
	before = int(second["offer"])
	result = Game.test_drive(second)
	check(result["score"] < 20 and int(second["offer"]) < before, "Poor condition reduces offer")
	Game.visits.erase(second)
	check(Game.test_drive(second).is_empty(), "Removed visit cannot run a drive")
	Game.end_negotiation()
	var sale := Game.finalize_sale(car, 160000, 2000, "Gül")
	var history := Game.sales_history()
	check(not sale.is_empty() and history.size()==1 and int(history[0]["profit"])==50000, "Sale records purchase costs bonus and true profit")
	check(Game.finalize_sale(car,160000).is_empty() and Game.sales_history().size()==1, "Duplicate sale cannot append history")
	snapshot = Game.to_dict().duplicate(true)
	Game.from_dict(snapshot)
	check(Game.sales_history()==history, "History survives save snapshot")
	Game.storage.append(Game.gen_car("karya_pico"))
	Game.storage_sell(0)
	check(Game.sales_history().size()==2, "Storage sales also recorded")
	Game.flags["sales_history"] = [null, "bad", {}, {"model":"bad","price":"bad"}]
	check(Game.sales_history().is_empty(), "Malformed history ignored safely")
	Game.flags.erase("sales_history")
	check(Game.sales_history().is_empty(), "Older saves without history supported")
	Game.flags["sales_history"] = history
	var main := get_parent()
	for width in [320, 432, 1280]:
		get_window().size = Vector2i(width, 768)
		for language in ["tr", "en", "ar", "fr"]:
			Loc.set_lang(language)
			main.show_screen("sales_history", {})
			await get_tree().process_frame
			check(is_instance_valid(main._current), "History screen " + language + str(width))
	Loc.set_lang("tr")
	Game.cars.append(Game.gen_car("karya_pico"))
	car = Game.cars.back()
	car["list_price"] = 150000
	car["listed"] = true
	Game._make_visit(car)
	v = Game.visits.back()
	main.show_screen("garage", {})
	await get_tree().process_frame
	var screen = main._current
	screen._open_visit(v)
	await get_tree().process_frame
	screen._start_test_drive()
	await get_tree().process_frame
	var drive = UI.overlay.get_child(UI.overlay.get_child_count()-1).find_children("*","Control",true,false).filter(func(c): return c is PlayableDrive)[0]
	drive.start()
	drive._complete()
	await get_tree().process_frame
	check(bool(v.get("test_drive_done",false)) and not screen._busy, "Animated drive finishes and restores negotiation")
	screen._root.queue_free()
	await get_tree().process_frame
	check(Game._negotiation_depth == 0, "Dialog close releases negotiation pause")
	print("SALES_AUDIT_COMPLETE ", count)
	get_tree().quit()

