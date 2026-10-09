class_name TestDriveStage
extends CarPortrait
var distance: float = 0.0
func _init(model_id: String = "", vehicle: Dictionary = {}) -> void:
	super(model_id, 110, vehicle)
func _process(delta: float) -> void:
	distance = fmod(distance + delta*90.0, 90.0)
	queue_redraw()
func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color("e6ebf0") if not Game.is_night() else Color("172638"))
	draw_rect(Rect2(0, size.y*.74, size.x, size.y*.26), Color("56616b"))
	for i in range(-1, 9):
		draw_rect(Rect2(i*90-distance, size.y*.9, 36, 3), Color("f3eee0"))
	super._draw()
