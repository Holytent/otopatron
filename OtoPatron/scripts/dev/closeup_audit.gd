extends Node
var checks: int = 0
var failures: int = 0
func check(ok: bool, label: String) -> void:
	checks += 1
	if not ok: failures += 1
	print("PASS " if ok else "FAIL ", label)
func _ready() -> void:
	run.call_deferred()
func run() -> void:
	Game.set_process(false)
	Game.new_game("Kontrol", "34")
	Game.settings["music"] = 0
	Game.settings["sfx"] = 0
	Game.money = 10000000
	var car := Game.gen_car("karya_pico")
	Game.cars.append(car)
	car["list_price"] = 150000
	car["listed"] = true
	car["clean"] = 20
	car["parts"]["body"] = 25
	car["parts"]["engine"] = 25
	Game._make_visit(car)
	var v: Dictionary = Game.visits.back()
	check(Game.buyer_concern(v)=="clean", "Dirt concern based on visible condition")
	car["clean"] = 80
	v.erase("concern")
	check(Game.buyer_concern(v)=="body", "Scratches create body concern")
	car["parts"]["body"] = 95
	v.erase("concern")
	check(Game.buyer_concern(v)=="mileage", "Hidden engine faults not exposed before drive")
	v.erase("concern")
	v["test_drive_done"] = true
	check(Game.buyer_concern(v)=="engine", "Drive reveals engine concern")
	check(not Game.can_explain_care(car), "Cannot claim uninspected good parts as evidence")
	var money: int = Game.money
	check(Game.answer_buyer(v,"care",150000).is_empty(), "Unavailable care answer rejected")
	v["mood"] = 60
	var result := Game.answer_buyer(v,"honest",150000)
	check(not result.is_empty() and v["mood"]==66, "Honest answer improves patience")
	check(Game.answer_buyer(v,"honest",150000).is_empty() and v["mood"]==66, "Answer cannot be farmed repeatedly")
	check(Game.money == money and Game.cars.has(car), "Dialogue alone never charges or sells")
	Game._make_visit(car)
	v = Game.visits.back()
	result = Game.answer_buyer(v,"discount",150000)
	check(result["counter"]==147000 and Game.cars.has(car), "Discount proposes price without automatic sale")
	Game._make_visit(car)
	v = Game.visits.back()
	car["clean"] = 100
	var before: int = int(v["offer"])
	result = Game.answer_buyer(v,"care",150000)
	check(not result.is_empty() and v["offer"]>=before and v["offer"]<=v["max_pay"], "Verified care improves bounded offer")
	var snapshot := Game.to_dict().duplicate(true)
	check(snapshot["visits"].back()["concern_answered"], "Response included in saved snapshot")
	Game.visits.erase(v)
	check(Game.answer_buyer(v,"honest",150000).is_empty(), "Stale buyer response rejected")
	car["clean"] = 20
	car["parts"]["body"] = 25
	var original := car.duplicate(true)
	var main := get_parent()
	for dimensions in [Vector2i(320,680),Vector2i(432,768),Vector2i(1280,800)]:
		get_window().size = dimensions
		for language in ["tr","en","ar","fr"]:
			Loc.set_lang(language)
			main.show_screen("car_closeup", {"uid":int(car["uid"])})
			await get_tree().process_frame
			var screen = main._current
			screen.zoom = 2.2
			screen.focus = .68
			screen.preview = true
			screen.rebuild()
			await get_tree().process_frame
			check(screen.portrait.zoom==2.2 and screen.portrait.car["clean"]==100 and car==original, "Zoom and non-mutating preview "+language+str(dimensions.x))
	Loc.set_lang("tr")
	get_window().size = Vector2i(320,680)
	Game._make_visit(car)
	v = Game.visits.back()
	main.show_screen("garage", {})
	await get_tree().process_frame
	var garage = main._current
	garage._open_visit(v)
	await get_tree().process_frame
	await get_tree().process_frame
	var panels: Array = garage._root.find_children("*", "PanelContainer", true, false)
	check(not panels.is_empty() and panels[0].get_global_rect().end.y <= get_viewport().get_visible_rect().size.y, "Negotiation modal fits small display")
	garage._answer_concern("discount")
	check(v["concern_answered"] and garage._price==147000, "Response UI updates negotiated price")
	garage._root.queue_free()
	await get_tree().process_frame
	print("CLOSEUP_AUDIT_COMPLETE ",checks," checks; ",failures," failures")
	get_tree().quit(1 if failures else 0)
