extends Node
func _button(node: Node, caption: String) -> Button:
	if node is Button and node.text == caption: return node
	for child in node.get_children():
		var found := _button(child,caption)
		if found != null: return found
	return null
func _ready() -> void:
	_run.call_deferred()
func _run() -> void:
	Game.new_game("Test","34")
	Game.money = 2000000
	assert(CustomerOrders.board().size()==3)
	var id: int = int(CustomerOrders.board()[0]["id"])
	assert(CustomerOrders.accept(id))
	assert(not CustomerOrders.accept(id))
	assert(not CustomerOrders.accept(int(CustomerOrders.board()[1]["id"])))
	var car: Dictionary = Game.gen_car("karya_pico")
	car["year"] = 2010
	car["km"] = 150000
	car["bought_price"] = 50000
	car["clean"] = 100.0
	for part in CarDB.PARTS:
		car["parts"][part] = 95.0
		car["known"][part] = true
	Game.cars.append(car)
	var order := CustomerOrders.find(id)
	assert(CustomerOrders.eligible(order,car))
	car["clean"] = 20.0
	assert(not CustomerOrders.eligible(order,car))
	car["clean"] = 100.0
	car["known"]["engine"] = false
	assert(not CustomerOrders.eligible(order,car))
	car["known"]["engine"] = true
	car["parts"]["body"] = 30.0
	assert(not CustomerOrders.eligible(order,car))
	car["parts"]["body"] = 95.0
	var budget: int = int(order["budget"])
	order["budget"] = 1
	assert(not CustomerOrders.eligible(order,car))
	order["budget"] = budget
	var uid: int = int(car["uid"])
	var before: int = Game.money
	var payment: int = CustomerOrders.price(order,car)+int(order["bonus"])
	var sold: int = int(Game.stats["sold"])
	var result := CustomerOrders.deliver(id,uid)
	assert(not result.is_empty())
	assert(Game.money==before+payment)
	assert(int(result["profit"])==payment-50000)
	assert(int(Game.stats["sold"])==sold+1 and not Game.cars.has(car))
	assert(CustomerOrders.deliver(id,uid).is_empty())
	var snapshot: Dictionary = Game.to_dict().duplicate(true)
	Game.from_dict(snapshot)
	assert(CustomerOrders.find(id)["status"]=="done")
	assert(CustomerOrders.deliver(id,uid).is_empty())
	assert(Game.money==before+payment)
	Game.day = int(Game.flags["order_refresh"])
	assert(CustomerOrders.find(id).is_empty())
	assert(CustomerOrders.board().size()==3)
	get_tree().root.size = Vector2i(432,768)
	get_parent().show_screen("garage",{})
	await get_tree().process_frame
	for viewport in [Vector2i(320,680),Vector2i(432,768)]:
		get_tree().root.size = viewport
		for language in ["tr","en","fr","ar"]:
			Loc.set_lang(language)
			await get_tree().process_frame
			# The modal does not require a screen until its navigation is used.
			OrderBoard.show(null)
			await get_tree().create_timer(.15).timeout
			assert(UI.overlay.get_child_count()>0)
			var back := _button(UI.overlay,Loc.t("gallery_back"))
			assert(back != null and back.global_position.y+back.size.y <= get_tree().root.get_visible_rect().size.y)
			if language == "tr" and DisplayServer.get_name() != "headless":
				await RenderingServer.frame_post_draw
				get_tree().root.get_texture().get_image().save_png("C:/Users/ozkes/Documents/Codex/2026-10-04/referenced-chatgpt-conversation-this-is-an/build_tools/orders-v1919.png")
			for child in UI.overlay.get_children(): child.queue_free()
			await get_tree().process_frame
	Loc.set_lang("tr")
	OrderBoard.show(null)
	await get_tree().create_timer(.2).timeout
	var accept_button := _button(UI.overlay,OrderBoard.t("accept"))
	assert(accept_button != null)
	accept_button.pressed.emit()
	await get_tree().create_timer(.25).timeout
	assert(CustomerOrders.active())
	assert(_button(UI.overlay,OrderBoard.t("cancel")) != null)
	assert(_button(UI.overlay,Loc.t("gallery_back")) != null)
	_button(UI.overlay,OrderBoard.t("cancel")).pressed.emit()
	await get_tree().create_timer(.2).timeout
	assert(not CustomerOrders.active())
	print("ORDERS_AUDIT_COMPLETE: accept, conditions, budget, single reward, save/load, expiry, 4 languages")
	get_tree().quit()
