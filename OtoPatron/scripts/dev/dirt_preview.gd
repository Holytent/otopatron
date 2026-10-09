extends Node
func _ready() -> void:
	_render.call_deferred()
func _render() -> void:
	get_tree().root.size = Vector2i(960,520)
	var sheet := Panel.new()
	sheet.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	sheet.add_theme_stylebox_override("panel",UI.sb(Color("f5f7fa"),0))
	get_tree().root.add_child(sheet)
	var grid := GridContainer.new()
	grid.columns = 3
	grid.position = Vector2(15,15)
	sheet.add_child(grid)
	for model in ["aldora_brix","kordan_zeph"]:
		for cleanliness in [20,60,100]:
			var column := VBoxContainer.new()
			column.custom_minimum_size.x = get_tree().root.get_visible_rect().size.x/3.0-24
			grid.add_child(column)
			column.add_child(UI.lbl(["Yoğun kir","Hafif kir","Yıkandı"][[20,60,100].find(cleanliness)],32))
			column.add_child(UI.car_image(model,int(get_tree().root.get_visible_rect().size.y*.37),{"model":model,"clean":cleanliness,"parts":{"body":95}}))
	await get_tree().create_timer(.5).timeout
	await RenderingServer.frame_post_draw
	get_tree().root.get_texture().get_image().save_png("C:/Users/ozkes/Documents/Codex/2026-10-04/referenced-chatgpt-conversation-this-is-an/build_tools/dirt-v1921.png")
	get_tree().quit()
