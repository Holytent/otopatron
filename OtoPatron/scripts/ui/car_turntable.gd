class_name CarTurntable
extends Control
## A complete imported vehicle rotates as one assembly on a level display plinth.
## Viewports render only when the owning visible lobby advances the angle.
const MODELS := {
 "sedan": preload("res://art/cars3d/sedan.glb"),
 "hatchback": preload("res://art/cars3d/hatchback-sports.glb"),
 "suv": preload("res://art/cars3d/suv.glb"),
 "coupe": preload("res://art/cars3d/sedan-sports.glb"),
 "sport": preload("res://art/cars3d/race.glb"),
 "pickup": preload("res://art/cars3d/truck-flat.glb"),
 "truck": preload("res://art/cars3d/truck.glb"),
 "van": preload("res://art/cars3d/van.glb")
}
const PAINT_SHADER: Shader = preload("res://shaders/car_paint.gdshader")
## Paint cluster of each imported model: hue in degrees, mean brightness of the paint, and whether
## the paint is the near-white cab (flat-bed truck) instead of a saturated colour.
const PAINT_PROFILES := {
 "sedan": {"hue": 9.0, "value": 0.90},
 "hatchback": {"hue": 153.0, "value": 0.68},
 "suv": {"hue": 152.0, "value": 0.66},
 "coupe": {"hue": 10.0, "value": 0.92},
 "sport": {"hue": 8.0, "value": 0.88},
 "pickup": {"hue": 0.0, "value": 0.93, "white": true},
 "truck": {"hue": 154.0, "value": 0.65},
 "van": {"hue": 222.0, "value": 0.80}
}
var model_id: String = "karya_nova"
## The database only knows "passenger"; class decides which of the available models is shown,
## so cars of different segments no longer all appear as the same sedan.
static func kind_for(id: String) -> String:
 var body: String = CarDB.body_type(id)
 if body != "passenger": return body if MODELS.has(body) else "sedan"
 match str(CarDB.model(id).get("cls", "mid")):
  "eco": return "hatchback"
  "lux": return "coupe"
  "com": return "van"
 return "sedan"
var angle: float = 0.0
var _tick: int = -1
var _view: SubViewport
var _pivot: Node3D
var model_bounds: AABB

func _ready() -> void:
 mouse_filter = Control.MOUSE_FILTER_IGNORE
 _view = SubViewport.new()
 _view.size = Vector2i(320, 220)
 _view.transparent_bg = true
 _view.own_world_3d = true
 _view.render_target_update_mode = SubViewport.UPDATE_ONCE
 # The 320x220 render is shown at roughly 135-160 logical pixels, so it is always minified;
 # multisample buffers only cost memory and a resolve per redraw here.
 _view.msaa_3d = Viewport.MSAA_DISABLED
 add_child(_view)
 var world := Node3D.new()
 _view.add_child(world)
 var environment := WorldEnvironment.new()
 var env := Environment.new()
 env.background_mode = Environment.BG_COLOR
 env.background_color = Color(0, 0, 0, 0)
 env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
 env.ambient_light_color = Color("d6e5ef")
 env.ambient_light_energy = 0.75
 environment.environment = env
 world.add_child(environment)
 var light := DirectionalLight3D.new()
 light.rotation_degrees = Vector3(-45, -35, 0)
 light.light_energy = 1.1
 light.shadow_enabled = false
 world.add_child(light)
 var camera := Camera3D.new()
 camera.projection = Camera3D.PROJECTION_ORTHOGONAL
 camera.size = 3.65
 camera.position = Vector3(3.8, 2.9, 4.8)
 world.add_child(camera)
 camera.look_at(Vector3(0, 0.45, 0))
 camera.current = true
 _add_platform(world)
 _pivot = Node3D.new()
 world.add_child(_pivot)
 var kind: String = kind_for(model_id)
 var scene: PackedScene = MODELS.get(kind, MODELS["sedan"])
 var vehicle: Node3D = scene.instantiate()
 _pivot.add_child(vehicle)
 model_bounds = _bounds(vehicle, Transform3D.IDENTITY)
 var scale_factor: float = 2.65 / maxf(model_bounds.size.x, model_bounds.size.z)
 vehicle.scale = Vector3.ONE * scale_factor
 vehicle.position = Vector3(-model_bounds.get_center().x, -model_bounds.position.y, -model_bounds.get_center().z) * scale_factor
 vehicle.position.y += 0.085
 _disable_shadows(vehicle)
 _apply_look(vehicle, kind)
 var picture := TextureRect.new()
 picture.texture = _view.get_texture()
 picture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
 # Keep the 320x220 aspect: the lobby sizes platforms per axis, so a narrow phone layout used to squash the car.
 picture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
 picture.mouse_filter = Control.MOUSE_FILTER_IGNORE
 add_child(picture)
 picture.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 _pivot.rotation.y = angle

func _bounds(node: Node3D, parent_transform: Transform3D) -> AABB:
 var transform_here: Transform3D = parent_transform * node.transform
 var bounds := AABB()
 var found: bool = false
 if node is MeshInstance3D:
  bounds = transform_here * node.get_aabb()
  found = true
 for child in node.get_children():
  if child is Node3D:
   var part: AABB = _bounds(child, transform_here)
   if part.size.length_squared() > 0:
    bounds = bounds.merge(part) if found else part
    found = true
 return bounds

func _disable_shadows(node: Node) -> void:
 if node is GeometryInstance3D:
  node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
 for child in node.get_children():
  _disable_shadows(child)

## Gives the model the paint and wheel style of its own catalog entry (see CarLook).
func _apply_look(vehicle: Node3D, kind: String) -> void:
 if not CarLook.has_look(model_id): return
 var profile: Dictionary = PAINT_PROFILES.get(kind, PAINT_PROFILES["sedan"])
 var paint := ShaderMaterial.new()
 paint.shader = PAINT_SHADER
 paint.set_shader_parameter("paint_color", Vector3(CarLook.paint(model_id).r, CarLook.paint(model_id).g, CarLook.paint(model_id).b))
 var base := Color.from_hsv(float(profile["hue"]) / 360.0, 1.0, 1.0)
 var mean: float = (base.r + base.g + base.b) / 3.0
 paint.set_shader_parameter("base_direction", Vector3(base.r - mean, base.g - mean, base.b - mean).normalized())
 paint.set_shader_parameter("ref_value", float(profile["value"]))
 paint.set_shader_parameter("white_paint", 1.0 if profile.get("white", false) else 0.0)
 var hub_mesh := CylinderMesh.new()
 hub_mesh.top_radius = 0.17
 hub_mesh.bottom_radius = 0.17
 hub_mesh.height = 0.03
 hub_mesh.radial_segments = CarLook.spokes(model_id)
 hub_mesh.rings = 1
 # The four wheel hubs are merged into one mesh so they cost a single extra draw call per redraw.
 var hubs := SurfaceTool.new()
 hubs.begin(Mesh.PRIMITIVE_TRIANGLES)
 for part in vehicle.get_children():
  if not part is MeshInstance3D: continue
  if String(part.name).begins_with("wheel"):
   hubs.append_from(hub_mesh, 0, part.transform * _hub_transform(part))
  else:
   _paint_parts(part, paint)
 var hub_node := MeshInstance3D.new()
 hub_node.mesh = hubs.commit()
 hub_node.material_override = _material(CarLook.RIM)
 hub_node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
 vehicle.add_child(hub_node)

func _paint_parts(node: Node, paint: ShaderMaterial) -> void:
 if node is MeshInstance3D and not String(node.name).begins_with("wheel"):
  var original: Material = node.mesh.surface_get_material(0)
  if original is StandardMaterial3D and original.albedo_texture:
   var own: ShaderMaterial = paint.duplicate()
   own.set_shader_parameter("colormap", original.albedo_texture)
   node.material_override = own
 for child in node.get_children():
  _paint_parts(child, paint)

## Outer face of a wheel, in the wheel's own space: a flat disc whose axis is the axle.
func _hub_transform(wheel: MeshInstance3D) -> Transform3D:
 var box: AABB = wheel.get_aabb()
 var outward: float = -1.0 if box.get_center().x + wheel.position.x < 0.0 else 1.0
 return Transform3D(Basis.from_euler(Vector3(0, 0, PI / 2.0)), box.get_center() + Vector3(outward * (box.size.x * 0.5 + 0.004), 0, 0))

func _material(color: Color) -> StandardMaterial3D:
 var material := StandardMaterial3D.new()
 material.albedo_color = color
 material.roughness = 0.8
 return material

func _add_platform(world: Node3D) -> void:
 var plinth := MeshInstance3D.new()
 var mesh := CylinderMesh.new()
 mesh.top_radius = 1.65
 mesh.bottom_radius = 1.65
 mesh.height = 0.08
 mesh.radial_segments = 48
 plinth.mesh = mesh
 plinth.position.y = 0.04
 plinth.material_override = _material(Color("172d42"))
 plinth.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
 world.add_child(plinth)
 for radius in [1.6, 1.47]:
  var ring := MeshInstance3D.new()
  var torus := TorusMesh.new()
  torus.inner_radius = radius - 0.016
  torus.outer_radius = radius + 0.016
  torus.rings = 48
  torus.ring_segments = 6
  ring.mesh = torus
  ring.position.y = 0.087
  ring.material_override = _material(Color("edc16b") if radius > 1.5 else Color("59ddce"))
  ring.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
  world.add_child(ring)

func set_angle(value: float) -> void:
 angle = value
 var tick: int = int(value * 100)
 if tick == _tick or not is_instance_valid(_pivot): return
 _tick = tick
 _pivot.rotation.y = angle
 _view.render_target_update_mode = SubViewport.UPDATE_ONCE
