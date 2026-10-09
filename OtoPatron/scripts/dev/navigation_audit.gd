extends Node
func _ready() -> void:
	_run.call_deferred()
func settle() -> void:
	for frame in range(4): await get_tree().process_frame
func _run() -> void:
	Game.set_process(false)
	Game.settings["music"] = 0.0
	Game.settings["sfx"] = 0.0
	Game.settings["vibe"] = false
	Game.new_game("Gezinti Denetimi","34")
	Game.money = 20000000
	Game.buy_listing(Game.market.back(),int(Game.market.back()["ask"]))
	var main := get_parent()
	var routes := ["home","profile","workshop","market","training","listings","shop","settings","finance","loans","listing","car"]
	var baseline_nodes := 0
	var baseline_resources := 0
	for step in range(264):
		var route: String = routes[step%routes.size()]
		var params := {"id":int(Game.market[0]["id"])} if route=="listing" else ({"uid":int(Game.cars[0]["uid"])} if route=="car" else {})
		main.show_screen(route,params)
		await settle()
		if step==23:
			baseline_nodes = int(Performance.get_monitor(Performance.OBJECT_NODE_COUNT))
			baseline_resources = int(Performance.get_monitor(Performance.OBJECT_RESOURCE_COUNT))
	var nodes := int(Performance.get_monitor(Performance.OBJECT_NODE_COUNT))
	var resources := int(Performance.get_monitor(Performance.OBJECT_RESOURCE_COUNT))
	var report := {"transitions":240,"node_growth":nodes-baseline_nodes,"resource_growth":resources-baseline_resources,"texture_cache":CarDB._texture_cache.size()}
	var passed := nodes-baseline_nodes<=15 and resources-baseline_resources<=50 and CarDB._texture_cache.size()<=8
	report["passed"] = passed
	var f := FileAccess.open(ProjectSettings.globalize_path("res://../../build_tools/navigation-audit.json"),FileAccess.WRITE)
	f.store_string(JSON.stringify(report,"  "))
	f.close()
	print("NAVIGATION_AUDIT_COMPLETE ",JSON.stringify(report))
	get_tree().quit(0 if passed else 1)
