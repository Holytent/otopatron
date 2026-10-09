extends Node
## Web text entry uses a visible HTML editor above the iOS keyboard.
var _original: String=""
var _field: Control
var _callback: JavaScriptObject
var _pending: Array[Control] = []

func _ready() -> void:
	if not OS.has_feature("web"): return
	_callback = JavaScriptBridge.create_callback(_commit)
	get_tree().node_added.connect(_added)

func _added(node: Node) -> void:
	if node is LineEdit or node is TextEdit:
		_pending.append(node)

func _process(_delta: float) -> void:
	for field in _pending:
		if not is_instance_valid(field): continue
		field.virtual_keyboard_enabled = false
		field.gui_input.connect(_tap.bind(field))
	_pending.clear()

func _open(field: Control) -> void:
	_field = field
	_original = field.text
	field.release_focus()
	var editor: JavaScriptObject = JavaScriptBridge.get_interface("otoEditor")
	if editor == null: return
	var numeric: bool = field.get_parent() is SpinBox
	var title: String = field.placeholder_text if not field.placeholder_text.is_empty() else ("Fiyat" if numeric else "Bilgi")
	editor.open(field.text, title, field is TextEdit, numeric, _callback)

func _commit(args: Array) -> void:
	if not is_instance_valid(_field) or args.size() < 2: return
	if bool(args[1]):
		var text: String = str(args[0])
		if _field is LineEdit and _field.max_length > 0: text = text.left(_field.max_length)
		if _field.get_parent() is SpinBox:
			var number: String = text.replace(" ", "").replace(",", ".")
			if number.is_valid_float(): _field.get_parent().value = float(number)
		else:
			_field.text = text
			if _field is LineEdit: _field.text_changed.emit(text)
			else: _field.text_changed.emit()
	else:
		_field.text = _original
	_field.queue_redraw()
	_field.release_focus()
	_field = null

func _tap(event: InputEvent, field: Control) -> void:
	if is_instance_valid(_field): return
	if Time.get_ticks_msec()<MobileScroll._block_release_until or MobileScroll._dragging: return
	if (event is InputEventMouseButton and event.button_index==MOUSE_BUTTON_LEFT and not event.pressed) or (event is InputEventScreenTouch and not event.pressed and not event.canceled):
		_open(field)
	elif event is InputEventKey and event.pressed and event.keycode==KEY_ENTER:
		_open(field)
