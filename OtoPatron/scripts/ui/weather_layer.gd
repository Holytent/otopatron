class_name WeatherLayer
extends Control
var weather_id:=""
var _particles: Array[Node2D]=[]
var _clock:=0.0
class Drop extends Node2D:
	var snow:=false
	func _draw() -> void:
		if snow: draw_circle(Vector2.ZERO,1.8,Color(.95,.98,1,.65),true,-1,true)
		else: draw_line(Vector2.ZERO,Vector2(-3,12),Color(.75,.88,1,.42),1.2,true)
func _ready() -> void:
	clip_contents=true
	mouse_filter=Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_to_group("light_animations")
	_sync()
func _sync() -> void:
	var next: String=str(Game.weather.get("id","sunny"))
	if next==weather_id: return
	weather_id=next
	for particle in _particles: particle.queue_free()
	_particles.clear()
	if weather_id in ["rain","snow"]:
		for i in 24:
			var drop:=Drop.new()
			drop.snow=weather_id=="snow"
			add_child(drop)
			_particles.append(drop)
	queue_redraw()
func animation_visible() -> bool:
	if _particles.is_empty() or Game._web_hidden or not is_visible_in_tree(): return false
	if is_instance_valid(UI.overlay) and UI.overlay.get_child_count()>0: return false
	var rect:=get_global_rect().intersection(get_viewport_rect())
	var ancestor:=get_parent()
	while ancestor!=null:
		if ancestor is Control and ancestor.clip_contents: rect=rect.intersection(ancestor.get_global_rect())
		ancestor=ancestor.get_parent()
	return rect.has_area()
func _process(dt: float) -> void:
	_sync()
	if not animation_visible(): return
	_clock+=minf(dt,.067)
	for i in _particles.size():
		_particles[i].position=Vector2(fposmod(i*37.0-_clock*12,maxf(1,size.x)),fposmod(i*29.0+_clock*(38 if weather_id=="snow" else 180),maxf(1,size.y)))
func _draw() -> void:
	if weather_id in ["rain","cloudy","snow"]: draw_rect(Rect2(Vector2.ZERO,size),Color(.18,.28,.37,.12))
	if weather_id=="fog":
		for i in 5: draw_rect(Rect2(0,size.y*(.18+i*.14),size.x,size.y*.12),Color(.83,.90,.94,.18))
