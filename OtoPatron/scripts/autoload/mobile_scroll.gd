extends Node
## Capture swipe gestures before child cards/buttons consume their GUI input.
## Scrollbars and editable controls retain their ordinary interaction.
const GROUP := "mobile_scroll_areas"
const THRESHOLD: float = 10.0
const SWIPE_GAIN: float = 1.08
var _target: ScrollContainer
var _finger: int = -1
var _origin: Vector2
var _last: Vector2
var _dragging: bool = false
var _value: float = 0.0
var _velocity: float = 0.0
var _last_motion: int = 0
var _block_release_until: int = 0
var _coasting: bool = false
var _wheel_active: bool = false
var _wheel_goal: float = 0.0
var _active_until: int = 0

func is_interacting() -> bool:
	return _dragging or _coasting or _wheel_active or Time.get_ticks_msec() < _active_until

func _ready() -> void:
	get_tree().node_added.connect(_node_added)
	_register_tree(get_tree().root)

func _register_tree(node: Node) -> void:
	_node_added(node)
	for child in node.get_children():
		_register_tree(child)

func _node_added(node: Node) -> void:
	if node is ScrollContainer:
		var sc: ScrollContainer = node
		sc.add_to_group(GROUP)
		# The gesture controller owns panning; children still receive taps.
		sc.mouse_filter = Control.MOUSE_FILTER_IGNORE
		sc.scroll_deadzone = int(THRESHOLD)

func _limit(sc: ScrollContainer) -> float:
	var bar := sc.get_v_scroll_bar()
	return maxf(0.0, bar.max_value - bar.page)

func _inside_clips(sc: Control, point: Vector2) -> bool:
	var parent: Node = sc
	while parent != null:
		if parent is Control and parent.clip_contents and not parent.get_global_rect().has_point(point):
			return false
		parent = parent.get_parent()
	return true

func _pick(point: Vector2) -> ScrollContainer:
	var chosen: ScrollContainer = null
	for node in get_tree().get_nodes_in_group(GROUP):
		var sc: ScrollContainer = node
		if not sc.is_visible_in_tree() or _limit(sc) <= 0 or not sc.get_global_rect().has_point(point) or not _inside_clips(sc, point):
			continue
		if is_instance_valid(UI.overlay) and UI.overlay.get_child_count() > 0 and not UI.overlay.is_ancestor_of(sc):
			continue
		if chosen == null or chosen.is_ancestor_of(sc) or not sc.is_ancestor_of(chosen):
			chosen = sc
	return chosen

func _editing_at(node: Node, point: Vector2) -> bool:
	if node is Control and (not node.is_visible_in_tree() or (node.clip_contents and not node.get_global_rect().has_point(point))):
		return false
	if (not OS.has_feature("web") and (node is LineEdit or node is TextEdit)) or node is Slider or node is ScrollBar:
		return node.get_global_rect().has_point(point)
	for child in node.get_children():
		if _editing_at(child, point): return true
	return false

func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed:
			if _finger != -1: return
			_target = _pick(event.position)
			_coasting = false
			_wheel_active = false
			_active_until = Time.get_ticks_msec() + 350
			_velocity = 0.0
			_block_release_until = 0
			if not is_instance_valid(_target) or _editing_at(_target, event.position):
				_target = null
				return
			_finger = event.index
			_origin = event.position
			_last = event.position
			_value = _target.scroll_vertical
			_last_motion = Time.get_ticks_msec()
			_dragging = false
		elif event.index == _finger:
			if _dragging:
				_block_release_until = Time.get_ticks_msec() + 150
				get_viewport().set_input_as_handled()
				if is_instance_valid(_target):
					_target.propagate_notification(Control.NOTIFICATION_SCROLL_END)
					_target.scroll_ended.emit()
				_coasting = not event.canceled and Time.get_ticks_msec() - _last_motion < 100
			_finger = -1
			_dragging = false
	elif event is InputEventScreenDrag and event.index == _finger:
		if not is_instance_valid(_target):
			_finger = -1
			return
		var now := Time.get_ticks_msec()
		_active_until = now + 350
		var movement: float = (_last.y - event.position.y) * SWIPE_GAIN
		if not _dragging and absf(event.position.y - _origin.y) > THRESHOLD:
			_dragging = true
			_target.propagate_notification(Control.NOTIFICATION_SCROLL_BEGIN)
			_target.scroll_started.emit()
		if _dragging:
			_value = clampf(_value + movement, 0.0, _limit(_target))
			_target.scroll_vertical = int(round(_value))
			var seconds: float = maxf(0.008, (now - _last_motion) / 1000.0)
			_velocity = lerpf(_velocity, clampf(movement / seconds, -2400.0, 2400.0), 0.45)
			get_viewport().set_input_as_handled()
		_last = event.position
		_last_motion = now
	elif event is InputEventMouseMotion and _dragging:
		get_viewport().set_input_as_handled()
	elif event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and not event.pressed and Time.get_ticks_msec() < _block_release_until:
			get_viewport().set_input_as_handled()
		elif event.pressed and event.button_index in [MOUSE_BUTTON_WHEEL_UP, MOUSE_BUTTON_WHEEL_DOWN]:
			var sc := _pick(event.position)
			if sc != null and not _editing_at(sc, event.position):
				_coasting = false
				if not _wheel_active or _target != sc:
					_target = sc
					_value = sc.scroll_vertical
					_wheel_goal = _value
				var direction: float = -1.0 if event.button_index == MOUSE_BUTTON_WHEEL_UP else 1.0
				_wheel_goal = clampf(_wheel_goal + direction * 70.0 * event.factor, 0, _limit(sc))
				_wheel_active = true
				_active_until = Time.get_ticks_msec() + 350
				get_viewport().set_input_as_handled()

func _process(delta: float) -> void:
	if _wheel_active:
		if not is_instance_valid(_target) or not _target.is_visible_in_tree():
			_wheel_active = false
			return
		_wheel_goal = clampf(_wheel_goal, 0, _limit(_target))
		_value = lerpf(_value, _wheel_goal, 1.0 - exp(-18.0 * minf(delta, 0.05)))
		if absf(_value - _wheel_goal) < 0.5:
			_value = _wheel_goal
			_wheel_active = false
		_target.scroll_vertical = int(round(_value))
		return
	if not _coasting: return
	if not is_instance_valid(_target) or not _target.is_visible_in_tree() or absf(_velocity) < 12:
		_coasting = false
		return
	var next: float = clampf(_value + _velocity * minf(delta, 0.05), 0, _limit(_target))
	if is_equal_approx(next, _value):
		_coasting = false
		return
	_value = next
	_target.scroll_vertical = int(round(_value))
	_velocity *= exp(-6.7 * delta)
