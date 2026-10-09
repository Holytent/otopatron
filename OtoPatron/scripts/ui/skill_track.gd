class_name SkillTrack
extends Control
var completed: int = 0
func _init(value: int = 0) -> void:
	completed = value
	custom_minimum_size = Vector2(0, 104)
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	mouse_filter = Control.MOUSE_FILTER_IGNORE
func _draw() -> void:
	var font := ThemeDB.fallback_font
	for row in 2:
		for col in 5:
			var step := row * 5 + col
			var point := Vector2(23 + col * (size.x - 46) / 4.0, 24 + row * 54)
			if col < 4:
				draw_line(point, point + Vector2((size.x - 46) / 4.0, 0), UI.resolve(UI.C_LINE), 3, true)
			var fill := UI.C_ACCENT if step < completed else UI.resolve(UI.C_PANEL2, true)
			draw_circle(point, 19, fill, true, -1, true)
			if step == completed:
				draw_arc(point, 20, 0, TAU, 48, UI.C_ACCENT, 2, true)
			draw_string(font, point + Vector2(-5, 6), str(step + 1), HORIZONTAL_ALIGNMENT_CENTER, -1, 16, Color.WHITE if step < completed else UI.resolve(UI.C_TEXT))
