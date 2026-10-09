extends Node
func _ready() -> void:
	_run.call_deferred()
func _run() -> void:
	Game.set_process(false)
	Game.settings["music"] = 0.0
	Game.settings["sfx"] = 0.0
	var road := RoadAnim.new()
	add_child(road)
	road.size = Vector2(432,190)
	road.set_process(false)
	assert(road._cars.size()==6)
	for fps in [30,60,120]:
		road._t = 0.0
		road._layout_cars()
		var origin: float = road._cars[0].position.x
		var previous: float = origin
		for frame in fps:
			road._process(1.0/fps)
			assert(road._cars[0].position.x>previous)
			previous = road._cars[0].position.x
		assert(absf(road._cars[0].position.x-origin-53.0)<0.01)
	var before: float = road._cars[0].position.x
	road.hide()
	road._process(1.0)
	assert(road._cars[0].position.x==before)
	road.show()
	road._process(20.0)
	assert(road._cars[0].position.x-before<4.0)
	for width in [320,432,540,1280]:
		road.size.x = width
		road._layout_cars()
		for sprite in road._cars:
			assert(sprite.size.x>0 and sprite.position.y>=0 and sprite.texture!=null)
	Game.new_game("Denetim","34")
	Game.set_process(false)
	var snapshot := Game.to_dict().duplicate(true)
	snapshot["player_name"] = "BarÄ±ÅŸ"
	snapshot["market"][0]["seller"] = "GÃ¼l"
	snapshot["flags"]["gallery_title"] = "AyÅŸe Oto"
	Game.from_dict(snapshot)
	assert(Game.player_name=="Barış")
	assert(Game.market[0]["seller"]=="Gül")
	assert(Game.flags["gallery_title"]=="Ayşe Oto")
	assert(Loc.display_text("GÃ¼l · AyÅŸe") == "Gül · Ayşe")
	assert(Loc.repair_text("Ramazan ÖZKESKİN · Sudenur GÜVEZ") == "Ramazan ÖZKESKİN · Sudenur GÜVEZ")
	assert(Loc.repair_text("Türkçe Français العربية") == "Türkçe Français العربية")
	print("LEGACY_NAMES_AUDIT_COMPLETE: saved seller/player/gallery names repaired; correct Turkish/French/Arabic unchanged")
	var saved_minute: int = Game.minute
	for entry in [{"minute":1199,"night":false},{"minute":1200,"night":true},{"minute":419,"night":true},{"minute":420,"night":false}]:
		Game.minute = int(entry["minute"])
		road._sync_lighting()
		assert(road._night == bool(entry["night"]))
		for car in road._cars: assert(car.get_node("Headlights").visible == bool(entry["night"]))
		var revision: int = road.lighting_revision
		for step in 100: road._sync_lighting()
		assert(road.lighting_revision == revision)
	Game.minute = saved_minute
	print("LIGHTING_AUDIT_COMPLETE: same 07:00/20:00 boundaries as gallery; headlights; background changes only at phase transition")
	print("ROAD_AUDIT_COMPLETE: six cached sprites, every-frame motion at 30/60/120 FPS, stable speed, hidden pause, resume clamp, four widths")
	get_tree().quit()
