extends Node
func _ready() -> void:
	_run.call_deferred()
func _run() -> void:
	get_tree().root.size = Vector2i(1000,740)
	var sheet := Panel.new()
	sheet.add_theme_stylebox_override("panel",UI.sb(Color("f5f7fa"),0))
	sheet.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	get_tree().root.add_child(sheet)
	var lender := ConversationActor.new()
	lender.role = "lender"
	lender.mood = 35
	lender.position = Vector2(25,30)
	lender.size = Vector2(620,387.5)
	sheet.add_child(lender)
	var actors: Array = []
	for i in 6:
		var identity := "Character%d" % i
		while absi(identity.hash())%6 != i: identity += "a"
		var actor := ConversationActor.new()
		actor.identity = identity
		actor.position = Vector2(15+(i%3)*326,435+(i/3)*145)
		actor.size = Vector2(320,130)
		sheet.add_child(actor)
		actors.append(actor)
	await get_tree().create_timer(.3).timeout
	assert(lender._head != null and lender._body != null and lender._variant == 6)
	for i in 6: assert(actors[i]._variant == i)
	var before: int = lender._draw_count
	await get_tree().create_timer(.6).timeout
	assert(lender._draw_count > before and lender._draw_count-before <= 7)
	lender.speak(1.0)
	assert(lender._speaking_until > lender.elapsed)
	if DisplayServer.get_name() != "headless":
		await RenderingServer.frame_post_draw
		get_tree().root.get_texture().get_image().save_png("C:/Users/ozkes/Documents/Codex/2026-10-04/referenced-chatgpt-conversation-this-is-an/build_tools/characters-v1920.png")
	lender.position.y = 2000
	await get_tree().process_frame
	var stopped: float = lender.elapsed
	await get_tree().create_timer(.3).timeout
	assert(lender.elapsed == stopped)
	lender.position.y = 30
	lender.hide()
	await get_tree().process_frame
	stopped = lender.elapsed
	await get_tree().create_timer(.3).timeout
	assert(lender.elapsed == stopped)
	sheet.queue_free()
	await get_tree().process_frame
	Game.new_game("Test","34")
	for dimensions in [Vector2i(320,680),Vector2i(432,768)]:
		get_tree().root.size = dimensions
		get_parent().show_screen("workshop",{})
		await get_tree().process_frame
		get_parent()._current._confirm_loan()
		await get_tree().create_timer(.3).timeout
		assert(UI.overlay.get_child_count() > 0)
		for child in UI.overlay.get_children(): child.queue_free()
		await get_tree().process_frame
	print("ACTORS_AUDIT_COMPLETE: 7 variants, speaking, idle rate, offscreen and hidden pause")
	get_tree().quit()
