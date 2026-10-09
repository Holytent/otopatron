class_name AvatarBadge
extends TextureRect
static var _atlas: Texture2D
static var _shader: Shader
var index: int = 0
func _init(id: int = 0, side: float = 60) -> void:
	index = clampi(id, 0, 7)
	if _atlas == null:
		_atlas = load("res://art/portraits.png")
	if _shader == null:
		_shader = Shader.new()
		_shader.code = "shader_type canvas_item; uniform vec2 mask_size = vec2(60.0); varying vec2 local_uv; void vertex(){ local_uv = VERTEX / mask_size; } void fragment(){ float d=length(local_uv-vec2(0.5)); COLOR.a *= 1.0-smoothstep(0.475,0.5,d); }"
	var cell := Vector2(_atlas.get_width() / 4.0, _atlas.get_height() / 2.0)
	var photo := AtlasTexture.new()
	photo.atlas = _atlas
	photo.region = Rect2(Vector2(float(index % 4), float(index >> 2)) * cell, cell)
	photo.filter_clip = true
	texture = photo
	var mat := ShaderMaterial.new()
	mat.shader = _shader
	mat.set_shader_parameter("mask_size", Vector2(side, side))
	material = mat
	size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	size_flags_vertical = Control.SIZE_SHRINK_CENTER
	custom_minimum_size = Vector2(side, side)
	expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	stretch_mode = TextureRect.STRETCH_SCALE
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	mouse_filter = Control.MOUSE_FILTER_IGNORE
