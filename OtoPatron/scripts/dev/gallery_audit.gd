extends Node
func _ready() -> void:
	_run.call_deferred()
func _find_field(node: Node) -> LineEdit:
	if node is LineEdit: return node
	for child in node.get_children():
		var field := _find_field(child)
		if field != null: return field
	return null
func _find_button(node: Node, caption: String) -> Button:
	if node is Button and node.text == caption: return node
	for child in node.get_children():
		var button := _find_button(child,caption)
		if button != null: return button
	return null
func _stages(node: Node) -> Array:
	var result: Array = []
	if node is GarageStage: result.append(node)
	for child in node.get_children(): result.append_array(_stages(child))
	return result
func _run() -> void:
	get_tree().root.size = Vector2i(432,768)
	Game.new_game("Test","34")
	Game.money = 2000000
	Loc.set_lang("tr")
	get_parent().show_screen("workshop", {})
	var screen: Control = get_parent()._current
	await get_tree().process_frame
	await get_tree().process_frame
	screen.rebuild()
	await get_tree().create_timer(.2).timeout
	var field := _find_field(screen)
	assert(field != null)
	field.text = "RAMAZAN OTOMOTİV"
	field.text_changed.emit(field.text)
	assert(GalleryStyle.title() == field.text)
	assert(Game.to_dict()["flags"]["gallery_name"] == field.text)
	assert(GalleryStyle.buy_package("modern"))
	assert(Game.money == 1800000)
	assert(Game.garage_cap == 8)
	assert(GalleryStyle.buy_package("luxury"))
	assert(Game.money == 1300000)
	assert(Game.garage_cap == 12)
	assert(GalleryStyle.buy_package("prestige"))
	assert(Game.money == 300000)
	assert(Game.garage_cap == 18)
	assert(GalleryStyle.buy_package("modern"))
	assert(Game.money == 300000 and Game.garage_cap == 18)
	for modal in UI.overlay.get_children(): modal.queue_free()
	await get_tree().process_frame
	screen.rebuild()
	await get_tree().create_timer(.3).timeout
	var stages: Array = _stages(screen)
	assert(stages.size() >= 5)
	for stage in stages: stage.queue_redraw()
	await get_tree().process_frame
	await get_tree().process_frame
	var retained_after_eviction: bool = false
	for stage in stages:
		assert(stage._background != null)
		assert(stage._background.get_rid().is_valid())
		if not GarageStage._backgrounds.values().has(stage._background): retained_after_eviction = true
	assert(retained_after_eviction)
	assert(GarageStage._backgrounds.size() <= 2)
	var original_city: String = Game.city
	Game.set_city("06" if original_city != "06" else "34")
	assert(Game.city == original_city)
	if DisplayServer.get_name() != "headless":
		await RenderingServer.frame_post_draw
		get_tree().root.get_texture().get_image().save_png("C:/Users/ozkes/Documents/Codex/2026-10-04/referenced-chatgpt-conversation-this-is-an/build_tools/gallery-v199.png")
	var save := _find_button(screen,Loc.t("gallery_save"))
	var back := _find_button(screen,Loc.t("management_back"))
	assert(save != null and back != null)
	save.pressed.emit()
	assert(GalleryStyle.title()=="RAMAZAN OTOMOTİV")
	back.pressed.emit()
	await get_tree().process_frame
	assert(get_parent().cur_name=="management")
	await get_tree().process_frame
	get_parent().show_screen("home", {})
	await get_tree().create_timer(.4).timeout
	if DisplayServer.get_name() != "headless":
		await RenderingServer.frame_post_draw
		get_tree().root.get_texture().get_image().save_png("C:/Users/ozkes/Documents/Codex/2026-10-04/referenced-chatgpt-conversation-this-is-an/build_tools/home-v1914.png")
	print("GALLERY_AUDIT_COMPLETE: name edit, persisted title, prices, capacity and owned reuse")
	get_tree().quit()
