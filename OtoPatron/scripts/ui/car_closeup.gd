class_name CarCloseup
extends CarPortrait
var zoom: float = 1.0
var focus: float = .5
func _init(model_id: String = "", vehicle: Dictionary = {}) -> void:
	super(model_id, 230, vehicle)
	clip_contents = true
func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), UI.resolve(UI.C_PANEL2))
	if texture == null: return
	var width: float = minf(size.x, size.y*2.0)*zoom
	var rect := Rect2(size.x*.5-width*focus, (size.y-width*.5)*.5, width, width*.5)
	draw_texture_rect(texture, rect, false)
	draw_condition(self, rect, car)
