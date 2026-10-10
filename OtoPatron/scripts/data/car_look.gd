class_name CarLook
extends RefCounted
## Showroom paint and wheel style per catalog car. The values are read from each car's own
## art/cars/<id>.svg (paint gradient and spoke count), so the market card, close-up and
## the 3D showroom show the same car. Regenerate with tools/gen_car_look.py after art changes.

const RIM: Color = Color("8798a4")

## id: [paint colour, wheel spokes]
const LOOKS: Dictionary = {
	"karya_pico": ["#718999", 6],
	"orvan_dot": ["#a2a7a4", 7],
	"aldora_kesa": ["#b39769", 8],
	"aldora_brix": ["#5d7d76", 6],
	"tivora_lune": ["#b34c49", 7],
	"veltra_orin": ["#52647f", 8],
	"brenor_city": ["#d1d3d0", 6],
	"veltra_taro": ["#667564", 7],
	"tivora_grano": ["#8a3245", 8],
	"kordan_zeph": ["#394a55", 6],
	"lavin_station": ["#b7b0a0", 7],
	"kordan_mavo": ["#9c784f", 8],
	"sorvik_bora": ["#718999", 6],
	"marlen_sora": ["#a2a7a4", 7],
	"kordan_rally": ["#b39769", 8],
	"marlen_drift": ["#5d7d76", 6],
	"veltra_cabra": ["#b34c49", 7],
	"sorvik_hale": ["#52647f", 8],
	"nyvo_ion": ["#d1d3d0", 6],
	"auren_vesta": ["#667564", 7],
	"dalmor_rex": ["#8a3245", 8],
	"marlen_gran": ["#394a55", 6],
	"auren_kyro": ["#b7b0a0", 7],
	"nyvo_arc": ["#9c784f", 8],
	"sorvik_ridge": ["#718999", 6],
	"dalmor_volt": ["#a2a7a4", 7],
	"auren_solis": ["#b39769", 8],
	"veltra_regalia": ["#5d7d76", 6],
	"valtorre_gt": ["#b34c49", 7],
	"kordan_atlas": ["#52647f", 8],
	"aurelia_prestige": ["#d1d3d0", 6],
	"nyvo_halo": ["#667564", 7],
	"zephyra_one": ["#8a3245", 8],
	"imperion_royale": ["#394a55", 6],
	"ravena_rova": ["#b7b0a0", 7],
	"aldora_trail": ["#9c784f", 8],
	"karya_bora": ["#718999", 6],
	"orvan_trek": ["#a2a7a4", 7],
	"nyvo_terra": ["#b39769", 8],
	"auren_stride": ["#5d7d76", 6],
	"dalmor_peak": ["#b34c49", 7],
	"imperion_range": ["#52647f", 8],
	"brenor_cargo": ["#d1d3d0", 6],
	"dalmor_haul": ["#667564", 7],
	"dalmor_titan": ["#8a3245", 8],
	"orvan_pulse": ["#394a55", 6],
	"valtorre_sprint": ["#b7b0a0", 7],
	"sorvik_canyon": ["#9c784f", 8],
	"karya_nova": ["#718999", 6],
	"tivora_aven": ["#a2a7a4", 7],
	"orvan_vera": ["#b39769", 8],
	"ravena_koru": ["#5d7d76", 6],
	"valtorre_solis": ["#b34c49", 7],
	"brenor_work": ["#52647f", 8],
}


static func has_look(id: String) -> bool:
	return LOOKS.has(id)


static func paint(id: String, fallback: Color = Color.WHITE) -> Color:
	return Color(str(LOOKS[id][0])) if LOOKS.has(id) else fallback


static func spokes(id: String) -> int:
	return int(LOOKS[id][1]) if LOOKS.has(id) else 6
