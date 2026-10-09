extends Node
## Geliştirici aracı: ekran görüntüsü alır. xvfb-run godot --path . -- --shots
func run(main: Node) -> void:
	DirAccess.make_dir_recursive_absolute("/tmp/shots")
	await get_tree().create_timer(0.9).timeout
	_snap("splash_loading")
	await get_tree().create_timer(2.6).timeout
	_snap("splash_menu")
	main._current._on_new()
	await get_tree().create_timer(0.5).timeout
	_snap("newgame")
	UI.pick_city("34", func(_c): pass)
	await get_tree().create_timer(0.5).timeout
	_snap("citypicker")
	for n in UI.overlay.get_children():
		n.queue_free()
	Game.new_game("Ramazan", "06")
	main.show_screen("home", {})
	await get_tree().create_timer(0.5).timeout
	_snap("home")
	# araç al, ilana koy, müşteri üret
	Game.money = 400000
	var l: Dictionary = Game.market[0]
	var car: Dictionary = l["car"]
	Game.buy_listing(l, int(l["ask"]))
	Game.set_listed(car, true, Game.suggested_price(car))
	Game._make_visit(car)
	await get_tree().create_timer(0.6).timeout
	_snap("banner")
	main.show_screen("garage", {})
	await get_tree().create_timer(0.5).timeout
	_snap("garage")
	main._current._open_visit(Game.visits[0])
	await get_tree().create_timer(0.5).timeout
	Game.visits[0]["mood"] = 35.0
	main._current._send_counter()
	await get_tree().create_timer(2.4).timeout
	_snap("visit_dialog")
	for n in UI.overlay.get_children():
		n.queue_free()
	Game.start_training("market")
	main.show_screen("training", {})
	await get_tree().create_timer(0.5).timeout
	_snap("training")
	main.show_screen("loans", {})
	await get_tree().create_timer(0.5).timeout
	_snap("loans")
	get_tree().quit()

func _snap(n: String) -> void:
	get_viewport().get_texture().get_image().save_png("/tmp/shots/%s.png" % n)
