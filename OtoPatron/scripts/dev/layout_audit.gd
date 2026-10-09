extends Node
var _main: Node
var _report: Array = []
const OUTPUT: String = "C:/Users/ozkes/Documents/Codex/2026-10-04/referenced-chatgpt-conversation-this-is-an/build_tools/layout_audit"

func run(main: Node) -> void:
	_main = main
	DirAccess.make_dir_recursive_absolute(OUTPUT)
	await get_tree().create_timer(4.0).timeout
	for child in UI.overlay.get_children(): child.queue_free()
	Game.new_game("Çok Uzun Oyuncu İsmi", "34")
	Game.money = 3000000
	Game.buy_listing(Game.market.back(), int(Game.market.back()["ask"]))
	Game.cars[0]["listed"] = true
	Game.cars[0]["list_price"] = Game.suggested_price(Game.cars[0])
	Game._make_visit(Game.cars[0])
	Game.accept_visit(Game.visits.back())
	var trade_id: int = int(Game.visits.back()["id"])
	for dimensions in [Vector2i(432, 768), Vector2i(320, 680), Vector2i(1280, 800)]:
		get_window().size = dimensions
		for language in ["tr", "en", "ar", "fr"]:
			Loc.set_lang(language)
			for screen in ["auction", "splash", "gameplay", "trade", "staff", "car_closeup", "sales_history", "business_account", "management", "street", "home", "garage", "profile", "workshop", "market", "training", "listings", "shop", "settings", "finance", "loans", "listing", "car"]:
				var params: Dictionary = {"visit": trade_id} if screen == "trade" else {"id": int(Game.market[0]["id"])} if screen == "listing" else ({"uid": int(Game.cars[0]["uid"])} if screen in ["car", "car_closeup"] else {})
				_main.show_screen(screen, params)
				await get_tree().create_timer(0.3).timeout
				_scan(_main._current, screen + "/" + language + "/" + str(dimensions))
				_scan(_main._hud, "hud/" + language + "/" + str(dimensions))
				_scan(_main._nav, "nav/" + language + "/" + str(dimensions))
				if screen == "finance":
					for section in ["market", "savings", "holdings"]:
						_main._current._section = section
						_main._current.rebuild()
						await get_tree().create_timer(0.2).timeout
						_scan(_main._current, "finance/"+section+"/"+language+"/"+str(dimensions))
				if language == "tr" and dimensions.x == 432 and DisplayServer.get_name() != "headless":
					await RenderingServer.frame_post_draw
					get_viewport().get_texture().get_image().save_png(OUTPUT + "/" + screen + ".png")
	var test_car: Dictionary = Game.market[0]["car"]
	var fee: int = Game.inspect_cost(test_car)
	var balance: int = Game.money
	assert(Game.inspect_part(test_car, "engine"))
	assert(Game.money == balance - fee)
	assert(bool(test_car["known"]["engine"]))
	assert(Loc.display_text("♦") != "♦")
	assert(Loc.display_text("−") == "-")
	assert(CarDB.texture("karya_pico").get_width() == 960)
	assert(CarDB.texture("karya_pico") == CarDB.texture("karya_pico"))
	assert(CarDB._texture_cache.size() <= 8)
	var before: int = Game.money
	assert(GalleryStyle.select("sign", "modern"))
	assert(Game.money == before - 5000)
	assert(GalleryStyle.select("sign", "classic"))
	assert(GalleryStyle.select("sign", "modern"))
	assert(Game.money == before - 5000)
	var snapshot: Dictionary = Game.to_dict()
	assert(snapshot["flags"]["gallery_style"]["sign"] == "modern")
	GalleryStyle.rename("Test Galeri")
	assert(GalleryStyle.title() == "Test Galeri")
	var package_balance: int = Game.money
	assert(GalleryStyle.buy_package("modern"))
	assert(Game.money == package_balance - 200000)
	assert(Game.garage_cap >= 8)
	assert(GalleryStyle.buy_package("classic"))
	assert(GalleryStyle.buy_package("modern"))
	assert(Game.money == package_balance - 200000)
	assert(GalleryStyle.owned("sign","modern"))
	assert(Game.to_dict()["flags"]["gallery_package"] == "modern")
	Game.garage_cap = 24
	assert(GalleryStyle.buy_package("luxury"))
	assert(Game.garage_cap == 24)
	Game.money = 100
	assert(not GalleryStyle.select("floor", "luxury"))
	assert(Game.money == 100)
	assert(not GalleryStyle.buy_package("prestige"))
	assert(Game.money == 100)
	Game.money = before
	_main.show_screen("workshop", {})
	await get_tree().create_timer(0.3).timeout
	_scan(_main._current, "customization")
	if DisplayServer.get_name() != "headless":
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png(OUTPUT + "/customization.png")
	assert(not Loc.t("sort_price").contains("↑"))
	assert(not Loc.t("sort_year").contains("↓"))
	for overlay_child in UI.overlay.get_children(): overlay_child.queue_free()
	get_window().size = Vector2i(432, 768)
	Loc.set_lang("tr")
	_main.show_screen("profile", {})
	_main._show_market_deal(int(Game.market[0]["id"]))
	await get_tree().create_timer(0.4).timeout
	assert(_main._toast_box.get_global_rect().position.y >= _main._hud.get_global_rect().end.y)
	assert(_main._holder.get_global_rect().position.y >= _main._toast_box.get_global_rect().end.y)
	_main._show_toast("İşlem tamamlandı", "good")
	await get_tree().process_frame
	assert(_main._toast_box.get_child_count() == 1)
	if DisplayServer.get_name() != "headless":
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png(OUTPUT + "/notice.png")
	var file := FileAccess.open(OUTPUT + "/report.json", FileAccess.WRITE)
	file.store_string(JSON.stringify(_report, "\t"))
	print("LAYOUT_AUDIT_COMPLETE ", _report.size())
	get_tree().quit()

func _scan(node: Node, screen: String) -> void:
	# Road sprites enter/leave inside a clipped animation; their offscreen positions are intentional.
	if node is TextureRect and (node.get_parent() is RoadAnim or node.get_parent() is LobbyScene): return
	if node is GalleryCustomer and node.get_parent() is GarageStage: return
	if node is Control and node.is_visible_in_tree():
		var control: Control = node
		var r: Rect2 = control.get_global_rect()
		if control is Label or control is Button:
			for mark in ["↑", "↓", "→", "←", "♦", "＋", "−", "★"]:
				if control.text.contains(mark):
					_report.append({"screen": screen, "error": "unsupported_symbol", "text": control.text})
		if control is Button and control.text.contains("₺") and control.size_flags_horizontal == Control.SIZE_SHRINK_END:
			var required: float = control.get_theme_font("font").get_string_size(control.text, HORIZONTAL_ALIGNMENT_LEFT, -1, control.get_theme_font_size("font_size")).x
			if control.size.x < required + 30:
				_report.append({"screen": screen, "error": "price_button_clipped", "text": control.text, "width": control.size.x, "required": required + 30})
		if r.position.x < -1.0 or r.end.x > get_viewport().get_visible_rect().size.x + 1.0:
			_report.append({"screen": screen, "node": str(control.get_path()), "text": control.text if control is Label or control is Button else "", "x": r.position.x, "width": r.size.x})
	for child in node.get_children(): _scan(child, screen)
