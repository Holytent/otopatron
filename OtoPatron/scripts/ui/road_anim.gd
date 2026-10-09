class_name RoadAnim
extends Control
## Cached road and six retained sprites: move transforms each frame, not the entire drawing.
var home_scene: bool = false
var progress: float = 0.0
var loading: bool = true
var _t: float = 0.0
var _cars: Array[TextureRect] = []
var _web_check: float = 0.0
var _web_active: bool = true
var _night: bool = false
var _lighting_ready: bool = false
var lighting_revision: int = 0

func _ready() -> void:
	add_to_group("light_animations")
	if not home_scene: custom_minimum_size = Vector2(0, 190)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	clip_contents = true
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	for id in ["karya_nova", "ravena_koru", "valtorre_solis", "tivora_aven", "karya_pico", "brenor_work"]:
		var sprite := TextureRect.new()
		sprite.texture = CarDB.texture(id)
		sprite.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		sprite.stretch_mode = TextureRect.STRETCH_SCALE
		sprite.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(sprite)
		var beam := Polygon2D.new()
		beam.color = Color(1.0,0.91,0.65,0.18)
		beam.name = "Headlights"
		sprite.add_child(beam)
		_cars.append(sprite)
	resized.connect(_layout_cars)
	Game.theme_changed.connect(queue_redraw)
	_layout_cars()
	_sync_lighting()
	if home_scene: add_child(WeatherLayer.new())

func _sync_lighting() -> void:
	var next_night: bool = Game.is_night()
	if _lighting_ready and next_night == _night: return
	_lighting_ready = true
	_night = next_night
	lighting_revision += 1
	for car in _cars:
		car.modulate = Color("cbd5e7") if _night else Color.WHITE
		car.get_node("Headlights").visible = _night
	queue_redraw()

func animation_visible() -> bool:
	if not is_visible_in_tree() or not _web_active: return false
	if is_instance_valid(UI.overlay) and UI.overlay.get_child_count() > 0: return false
	var rect := get_global_rect()
	if not rect.intersects(get_viewport_rect()): return false
	var ancestor := get_parent()
	while ancestor != null:
		if ancestor is Control and ancestor.clip_contents and not rect.intersects(ancestor.get_global_rect()): return false
		ancestor = ancestor.get_parent()
	return true

func _process(delta: float) -> void:
	_sync_lighting()
	if not is_visible_in_tree():
		return
	if OS.has_feature("web"):
		_web_check -= delta
		if _web_check <= 0.0:
			_web_check = 0.25
			_web_active = bool(JavaScriptBridge.eval("!document.hidden", true))
	if not animation_visible():
		return
	# Resume without jumping across the road after a long suspended frame.
	_t += minf(delta, 1.0 / 15.0)
	_layout_cars()

func _layout_cars() -> void:
	var horizon := size.y * 0.34
	var lane_height := (size.y - horizon) / 2.0
	var car_width := minf(156.0, lane_height * 1.7)
	var spacing := maxf(car_width + 100.0, (size.x + car_width) / 3.0)
	var span := spacing * 3.0
	for lane in 2:
		var speed := 53.0 if lane == 0 else 76.0
		for slot in 3:
			var index := lane * 3 + slot
			if index >= _cars.size(): continue
			if _cars[index].size != Vector2(car_width, car_width * 0.5):
				_cars[index].size = Vector2(car_width, car_width * 0.5)
				var beam: Polygon2D = _cars[index].get_node("Headlights")
				beam.polygon = PackedVector2Array([Vector2(car_width*0.86,car_width*0.30),Vector2(car_width*1.35,car_width*0.20),Vector2(car_width*1.35,car_width*0.44),Vector2(car_width*0.86,car_width*0.35)])
			_cars[index].position = Vector2(fposmod(slot * spacing + _t * speed + lane * spacing * 0.45, span) - car_width, horizon + lane * lane_height + (lane_height - car_width * 0.5) * 0.5)

func _draw() -> void:
	var w: float = size.x
	var h: float = size.y
	var horizon: float = h * 0.34
	var sky: Color = Color("111d32") if _night else Color("dcecf5")
	draw_rect(Rect2(0,0,w,h),sky)
	draw_rect(Rect2(0,horizon*.55,w,horizon*.45),Color("1c2b43") if _night else Color("edf4f8"))
	if _night:
		for star in 22:
			draw_circle(Vector2(fposmod(star*47.0+13,w),5+fposmod(star*13.0,maxf(8,horizon-10))),0.7,Color("b9cbe3"))
	draw_circle(Vector2(w*.84,horizon*.34),9,Color("e7efff") if _night else Color("f4cb76"),true,-1,true)
	# Static two-layer skyline and lit windows update only when day/night changes.
	for i in 20:
		var bx: float = i*35.0-16
		var bh: float = 10+float((i*17)%25)
		draw_rect(Rect2(bx,horizon-bh,26,bh),Color("263852") if _night else Color("c6d6e1"))
	for i in 16:
		var bh: float = 17.0 + float((i * 23) % 35)
		var bx: float = i*42.0-12
		draw_rect(Rect2(bx,horizon-bh,28,bh),Color("34445d") if _night else Color("b6c9d7"))
		for row in 2:
			for k in 3:
				var lit: bool = (i+k+row)%3 != 0
				draw_rect(Rect2(bx+5+k*7,horizon-bh+7+row*9,3,4),Color("f4ce85") if _night and lit else (Color("223149") if _night else Color("eaf3f8")))
	draw_rect(Rect2(0,horizon,w,h-horizon),Color("354354") if _night else Color("dce3ea"))
	draw_rect(Rect2(0,horizon,w,4),Color("718095") if _night else Color("b2c2cf"))
	var lane_height: float = (h - horizon) / 2.0
	for i in range(-1,int(w/56)+2):
		draw_rect(Rect2(i*56,horizon+lane_height-1,28,2),Color("94a3b7") if _night else Color.WHITE)
	# Lamps and pools of light are part of the cached background, never per-frame redraws.
	for fraction in [0.16,0.62]:
		var x: float = w*fraction
		draw_line(Vector2(x,horizon+3),Vector2(x,horizon-20),Color("566b7e"),2,true)
		draw_line(Vector2(x,horizon-20),Vector2(x+10,horizon-20),Color("566b7e"),2,true)
		if _night:
			draw_colored_polygon(PackedVector2Array([Vector2(x+10,horizon-19),Vector2(x-12,horizon+24),Vector2(x+32,horizon+24)]),Color(1,.84,.5,.09))
			draw_circle(Vector2(x+10,horizon-20),2.5,Color("ffe0a0"),true,-1,true)
