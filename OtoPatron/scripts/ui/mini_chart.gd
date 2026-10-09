class_name MiniChart
extends Control
var points: Array = []
func _init() -> void:
	custom_minimum_size = Vector2(0, 64)
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	mouse_filter = Control.MOUSE_FILTER_IGNORE
func _draw() -> void:
	var data := points.duplicate()
	if data.size() < 2:
		data = [float(data[0]) if not data.is_empty() else 1.0, float(data[0]) if not data.is_empty() else 1.0]
	var low: float = float(data.min())
	var high: float = float(data.max())
	var path := PackedVector2Array()
	for i in data.size():
		path.append(Vector2(4 + i * (size.x - 8) / (data.size() - 1), size.y - 8 - ((float(data[i]) - low) / (high - low) if high - low > 0.01 else 0.5) * (size.y - 16)))
	for i in 3:
		draw_line(Vector2(0, 10 + i * 22), Vector2(size.x, 10 + i * 22), UI.C_LINE, 1)
	draw_circle(path[-1], 3.5, UI.C_ACCENT, true, -1, true)
	draw_polyline(path, UI.C_GOOD if float(data[-1]) >= float(data[0]) else UI.C_BAD, 2.5, true)
