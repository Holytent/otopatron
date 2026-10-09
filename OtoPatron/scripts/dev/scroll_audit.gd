extends Node
func _ready() -> void:
	_run.call_deferred()
func _run() -> void:
	var sc := ScrollContainer.new()
	sc.position = Vector2(10,10)
	sc.size = Vector2(280,400)
	get_tree().root.add_child(sc)
	var contents := VBoxContainer.new()
	contents.custom_minimum_size = Vector2(250,3000)
	sc.add_child(contents)
	for frame in range(5): await get_tree().process_frame
	for fps in [30,60,120]:
		sc.scroll_vertical = 0
		MobileScroll._target = sc
		MobileScroll._value = 0
		MobileScroll._wheel_goal = 140
		MobileScroll._wheel_active = true
		assert(MobileScroll.is_interacting())
		var previous := 0
		for frame in range(fps):
			MobileScroll._process(1.0 / fps)
			assert(sc.scroll_vertical >= previous and sc.scroll_vertical <= 140)
			previous = sc.scroll_vertical
		assert(sc.scroll_vertical == 140)
		assert(not MobileScroll._wheel_active)
	sc.scroll_vertical = 100
	var touch := InputEventScreenTouch.new()
	touch.index = 0
	touch.position = Vector2(120,200)
	touch.pressed = true
	MobileScroll._input(touch)
	var drag := InputEventScreenDrag.new()
	drag.index = 0
	drag.position = Vector2(120,140)
	MobileScroll._input(drag)
	assert(MobileScroll._dragging)
	assert(sc.scroll_vertical > 100)
	touch.pressed = false
	touch.position = drag.position
	MobileScroll._input(touch)
	assert(MobileScroll._coasting)
	var start := sc.scroll_vertical
	for frame in range(60): MobileScroll._process(1.0/60)
	assert(sc.scroll_vertical >= start and sc.scroll_vertical <= MobileScroll._limit(sc))
	MobileScroll._target = sc
	MobileScroll._wheel_active = true
	sc.queue_free()
	await get_tree().process_frame
	MobileScroll._process(1.0/60)
	assert(not MobileScroll._wheel_active)
	print("SCROLL_AUDIT_COMPLETE: wheel convergence at 30/60/120 FPS, no overshoot; touch drag and coast; freed page cancels movement")
	get_tree().quit()
