class_name CarPortrait
extends Control
## Static vehicle art and exterior condition. No timer, extra texture or animation.
var texture: Texture2D
var car: Dictionary = {}
func _init(model_id: String = "", height: int = 150, vehicle: Dictionary = {}) -> void:
	texture = CarDB.texture(model_id) if not model_id.is_empty() else null
	car = vehicle
	custom_minimum_size = Vector2(0, height)
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	mouse_filter = Control.MOUSE_FILTER_IGNORE
func _draw() -> void:
	if texture == null: return
	var width: float = minf(size.x, size.y * 2.0)
	var rect := Rect2((size.x-width)*.5, (size.y-width*.5)*.5, width, width*.5)
	draw_texture_rect(texture, rect, false)
	draw_condition(self, rect, car)
static func draw_condition(canvas: CanvasItem, rect: Rect2, vehicle: Dictionary) -> void:
	if vehicle.is_empty(): return
	var dirt: float = clampf((100.0-float(vehicle.get("clean",100.0)))/100.0,0,1)
	var body: float = float(vehicle.get("parts",{}).get("body",100.0))
	var damage: float = clampf((85.0-body)/85.0,0,1)
	var scale: Vector2 = rect.size / Vector2(640,320)
	# Broad dust, lower-panel mud and wheel deposits make washing visibly useful.
	# All marks are static and deterministic; a clean car has no dirt overlay.
	if dirt > .015:
		var haze := PackedVector2Array()
		for point in [Vector2(176,183),Vector2(241,179),Vector2(297,186),Vector2(353,182),Vector2(420,191),Vector2(407,223),Vector2(201,225),Vector2(179,210)]:
			haze.append(rect.position+point*scale)
		canvas.draw_colored_polygon(haze,Color(.67,.53,.35,dirt*.43))
		var mud := PackedVector2Array()
		for point in [Vector2(195,214),Vector2(220,207),Vector2(249,216),Vector2(273,209),Vector2(311,215),Vector2(343,208),Vector2(392,213),Vector2(408,225),Vector2(194,226)]:
			mud.append(rect.position+point*scale)
		canvas.draw_colored_polygon(mud,Color(.29,.22,.14,dirt*.72))
		for i in int(dirt*28.0):
			var pos := rect.position + Vector2(187+(i*43)%222,188+(i*17)%33)*scale
			canvas.draw_circle(pos,(4+i%7)*scale.x,Color(.39,.29,.17,dirt*.56),true,-1,true)
		for i in int(dirt*7.0):
			var pos := rect.position+Vector2(212+i*27,184+(i*7)%12)*scale
			canvas.draw_line(pos,pos+Vector2(-3,21+i%5)*scale,Color(.56,.43,.27,dirt*.50),maxf(.6,2.5*scale.x),true)
		var wheels := _wheels(str(vehicle.get("model","")))
		for x in [wheels.x,wheels.y]:
			var center := rect.position+Vector2(x,235)*scale
			canvas.draw_arc(center,(wheels.z+4)*scale.x,PI,TAU,20,Color(.40,.30,.19,dirt*.78),maxf(1,7*scale.x),true)
			canvas.draw_circle(center,(wheels.z-9)*scale.x,Color(.60,.48,.31,dirt*.35),true,-1,true)
	for i in int(ceil(damage*6.0)):
		var pos := rect.position + Vector2(204+i*27,190+(i*13)%22)*scale
		canvas.draw_line(pos,pos+Vector2(23,-4)*scale,Color(.16,.22,.25,damage*.8),maxf(1,scale.x*2),true)
		canvas.draw_line(pos+Vector2(0,2)*scale,pos+Vector2(22,-2)*scale,Color(.85,.89,.9,damage*.75),maxf(.6,scale.x),true)
static func _wheels(model_id: String) -> Vector3:
	var body_type := CarDB.body_type(model_id)
	if model_id == "tivora_grano": return Vector3(135,477,44)
	if body_type == "suv": return Vector3(139,478,47)
	if body_type == "pickup": return Vector3(140,475,46)
	if body_type == "truck": return Vector3(135,490,46)
	if body_type == "sport": return Vector3(150,483,42)
	if model_id == "lavin_station": return Vector3(137,478,42)
	if model_id in ["karya_pico","orvan_dot","aldora_kesa","tivora_lune","veltra_orin","brenor_city","nyvo_ion","karya_nova"]: return Vector3(145,443,42)
	return Vector3(147,480,42)
