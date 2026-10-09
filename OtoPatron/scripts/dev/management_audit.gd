extends Node
func _ready() -> void:
	_run.call_deferred()
func settle() -> void:
	for frame in range(5): await get_tree().process_frame
func descendants(node: Node) -> Array:
	var result: Array = [node]
	for child in node.get_children(): result.append_array(descendants(child))
	return result
func _run() -> void:
	Game.set_process(false)
	Game.new_game("Yönetim Kontrolü", "34")
	var main := get_parent()
	main.show_screen("home", {})
	await settle()
	for node in descendants(main._current): assert(not node is Button)
	assert(main.NAV.size() == 5)
	main.show_screen("management", {})
	await settle()
	var routes := ["workshop","staff","street","finance","loans","business_account","profile","shop","rewards","settings"]
	for index in routes.size():
		main.show_screen("management", {})
		await settle()
		var buttons: Array = descendants(main._current).filter(func(n): return n is Button)
		# Header back button precedes the eight directory entries.
		buttons[index+1].pressed.emit()
		await settle()
		assert(main.cur_name == routes[index])
		var back: Array = descendants(main._current).filter(func(n): return n is Button)
		back[0].pressed.emit()
		await settle()
		assert(main.cur_name == "management")
	main.show_screen("workshop", {})
	await settle()
	for node in descendants(main._current): assert(not node is ConversationActor)
	var baseline_nodes := 0
	var baseline_resources := 0
	var paths := ["home","management","garage","workshop","street","finance"]
	for step in range(132):
		var route: String = paths[step%paths.size()]
		main.show_screen(route,{})
		await settle()
		if route == "finance":
			for section in ["market","savings","holdings","overview"]:
				main._current._section = section
				main._current.rebuild()
				await settle()
		if step == 11:
			baseline_nodes = int(Performance.get_monitor(Performance.OBJECT_NODE_COUNT))
			baseline_resources = int(Performance.get_monitor(Performance.OBJECT_RESOURCE_COUNT))
	var growth := int(Performance.get_monitor(Performance.OBJECT_NODE_COUNT))-baseline_nodes
	var resources := int(Performance.get_monitor(Performance.OBJECT_RESOURCE_COUNT))-baseline_resources
	assert(growth <= 15)
	assert(resources <= 50)
	print("MANAGEMENT_AUDIT_COMPLETE: summary only; five tabs; ten directory destinations and back links; decor isolated; 120 transitions; node growth ",growth," resource growth ",resources)
	get_tree().quit()
