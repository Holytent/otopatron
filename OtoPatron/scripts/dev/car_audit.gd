extends Node
func _ready() -> void:
	_run.call_deferred()
func _run() -> void:
	get_tree().root.size = Vector2i(1100,820)
	Game.new_game("Test","34")
	Game.money = 2000000
	var tested: Dictionary = Game.gen_car("aldora_brix")
	Game.cars.append(tested)
	tested["clean"] = 20.0
	tested["parts"]["body"] = 25.0
	assert(Game.clean_car(tested))
	assert(tested["clean"] == 100.0 and tested["parts"]["body"] == 25.0)
	assert(Game.repair_part(tested,"body"))
	assert(tested["parts"]["body"] == 95.0)
	var sheet := Panel.new()
	sheet.add_theme_stylebox_override("panel",UI.sb(Color("f5f7fa"),0))
	sheet.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	get_tree().root.add_child(sheet)
	var grid := GridContainer.new()
	grid.columns = 4
	grid.position = Vector2(10,10)
	sheet.add_child(grid)
	for id in ["karya_pico","aldora_brix","lavin_station","kordan_zeph","marlen_drift","sorvik_bora","tivora_grano","dalmor_haul"]:
		var col := VBoxContainer.new()
		col.custom_minimum_size.x = 264
		grid.add_child(col)
		col.add_child(UI.lbl(CarDB.full_name(id),18))
		col.add_child(UI.car_image(id,140))
	var car := {"model":"aldora_brix","clean":20.0,"parts":{"body":25.0}}
	for state in ["Kirli ve çizik","Yıkandı","Kaporta onarıldı"]:
		var col := VBoxContainer.new()
		col.custom_minimum_size.x = 264
		grid.add_child(col)
		col.add_child(UI.lbl(state,18))
		if state == "Yıkandı": car["clean"] = 100.0
		if state == "Kaporta onarıldı": car["parts"]["body"] = 95.0
		col.add_child(UI.car_image("aldora_brix",140,car.duplicate(true)))
	for model in CarDB.MODELS: assert(CarDB.texture(str(model["id"])) != null)
	await get_tree().create_timer(.6).timeout
	if DisplayServer.get_name() != "headless":
		await RenderingServer.frame_post_draw
		get_tree().root.get_texture().get_image().save_png("C:/Users/ozkes/Documents/Codex/2026-10-04/referenced-chatgpt-conversation-this-is-an/build_tools/vehicles-v1918.png")
	print("CAR_AUDIT_COMPLETE: 54 textures, 8 silhouettes, dirt/wash/body-repair stages")
	get_tree().quit()
