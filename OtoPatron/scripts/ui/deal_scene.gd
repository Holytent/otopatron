class_name DealScene
extends Control
var car: Dictionary={}
var delivery:=false
var elapsed:=0.0
var reaction:=""
var _vehicle: Control
var _buyer: GalleryCustomer
var _caption: Label
var _key: Label
func _init() -> void:
	custom_minimum_size=Vector2(0,150)
	size_flags_horizontal=Control.SIZE_EXPAND_FILL
	clip_contents=true
	mouse_filter=Control.MOUSE_FILTER_IGNORE
func _ready() -> void:
	add_to_group("light_animations")
	_vehicle=UI.car_image(str(car.get("model","karya_pico")),65,car)
	_vehicle.mouse_filter=Control.MOUSE_FILTER_IGNORE
	add_child(_vehicle)
	_buyer=GalleryCustomer.new()
	_buyer.mouse_filter=Control.MOUSE_FILTER_IGNORE
	add_child(_buyer)
	_caption=UI.lbl("",13,Color("e6eff8"),HORIZONTAL_ALIGNMENT_CENTER)
	_caption.mouse_filter=Control.MOUSE_FILTER_IGNORE
	add_child(_caption)
	_key=UI.lbl("",14,Color("f1ce7a"),HORIZONTAL_ALIGNMENT_CENTER,true)
	_key.mouse_filter=Control.MOUSE_FILTER_IGNORE
	add_child(_key)
	_animate()
func respond(kind: String) -> void:
	reaction=kind
	_animate()
func animation_visible() -> bool:
	return is_visible_in_tree() and get_global_rect().intersects(get_viewport_rect()) and not Game._web_hidden
func _process(dt: float) -> void:
	if not animation_visible(): return
	elapsed+=minf(dt,.067)
	_animate()
func _animate() -> void:
	if not is_instance_valid(_vehicle): return
	var width: float=minf(210,size.x*.60)
	_vehicle.size=Vector2(width,65)
	var x: float=(size.x-width)*.5
	var departure: float=clampf((elapsed-3.3)/2.6,0,1) if delivery else 0.0
	_vehicle.position=Vector2(x+departure*(size.x+width),59)
	_buyer.position=Vector2(lerpf(15,x+width*.60,minf(elapsed/2.0,1)),78)
	_buyer.animate(elapsed,elapsed<2)
	_buyer.visible=not delivery or elapsed<3.3
	_caption.position=Vector2(8,10)
	_caption.size=Vector2(maxf(20,size.x-16),36)
	var key: String="life_delivery_keys" if delivery and elapsed<3.3 else ("life_delivery_depart" if delivery else "life_inspecting")
	if not delivery and not reaction.is_empty(): key="life_reaction_"+reaction
	elif not delivery and elapsed>=2: key="life_offer_wait"
	_caption.text=Loc.t(key)
	_key.position=Vector2(x+width*.6,52)
	_key.size=Vector2(50,25)
	_key.text=Loc.t("life_key") if delivery and elapsed>=2 and elapsed<3.3 else ""
func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO,size),Color("172b3a"))
	for i in 5:
		var x: float=i*size.x/5
		draw_rect(Rect2(x+4,44,size.x/5-8,50),Color("345263"))
		draw_line(Vector2(x+6,45),Vector2(x+35,75),Color("688b9a"),2,true)
	draw_rect(Rect2(0,109,size.x,41),Color("4a5e6c"))
	draw_line(Vector2(0,139),Vector2(size.x,139),Color("d1dae1"),2,true)
