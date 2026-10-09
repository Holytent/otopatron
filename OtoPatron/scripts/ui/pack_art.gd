class_name PackArt
extends Control
var elapsed: float = 0
var gems: bool
var tier: int
func _init(is_gem: bool = true, rank: int = 0) -> void:
	gems = is_gem
	tier = rank
	custom_minimum_size = Vector2(0, 90)
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
	var center := Vector2(size.x / 2, 44)
	var count := tier + 1
	for i in count:
		var x := center.x + (i - (count - 1) / 2.0) * 60
		if gems:
			var pts := PackedVector2Array([Vector2(x-18,38),Vector2(x-10,23),Vector2(x+12,23),Vector2(x+21,38),Vector2(x,72)])
			draw_colored_polygon(pts, Color("c32b3c"))
			draw_polyline(PackedVector2Array([Vector2(x-18,38),Vector2(x+21,38),Vector2(x,72),Vector2(x-10,23)]), Color("ffadb5").lightened(0.12 * (1.0 + sin(elapsed * 2))), 2, true)
		else:
			draw_rect(Rect2(x-22,31 + i*3,44,38), Color("b18b44"))
			draw_rect(Rect2(x-18,35 + i*3,36,30), Color("f3d291"))
			draw_circle(Vector2(x,50+i*3),8,Color("b18b44"),true,-1,true)
	draw_line(Vector2(center.x-95,81),Vector2(center.x+95,81),UI.resolve(UI.C_LINE),2,true)
