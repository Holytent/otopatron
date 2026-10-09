extends SceneTree
func _initialize() -> void:
	var svg: String = FileAccess.get_file_as_string("res://art/app_icon.svg")
	for dimension in [512, 1024]:
		var image := Image.new()
		var error: int = image.load_svg_from_string(svg, float(dimension) / 512.0)
		if error != OK:
			push_error("Brand render failed")
			quit(1)
			return
		image.convert(Image.FORMAT_RGB8)
		image.save_png("res://icon.png" if dimension == 512 else "res://icon_1024.png")
	quit()
