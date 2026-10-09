class_name CallPulse
extends Control
var elapsed: float = 0
func _init() -> void:
	custom_minimum_size = Vector2(0, 155)
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	mouse_filter = Control.MOUSE_FILTER_IGNORE
var _redraw_timer: float = 0.0
func _process(dt: float) -> void:
	elapsed += dt
	if is_visible_in_tree(): _redraw_timer += dt
	if _redraw_timer >= 0.05:
		_redraw_timer = fmod(_redraw_timer, 0.05)
		queue_redraw()
func _draw() -> void:
	var c := Vector2(size.x/2,77)
	for ring in 3:
		var phase := fposmod(elapsed*.65+ring/3.0,1.0)
		var col := UI.resolve(UI.C_ACCENT)
		col.a = (1-phase)*.45
		draw_arc(c,36+phase*37,0,TAU,64,col,2,true)
	draw_circle(c,36,UI.C_ACCENT,true,-1,true)
	draw_set_transform(c, sin(elapsed*22)*.055, Vector2.ONE)
	draw_rect(Rect2(-12,-23,24,46),Color.WHITE,false,3)
	draw_line(Vector2(-5,-17),Vector2(5,-17),Color.WHITE,2,true)
	draw_circle(Vector2(0,16),2,Color.WHITE,true,-1,true)
