class_name GalleryStyle
extends RefCounted
const PARTS: Array[String] = ["sign", "floor", "decor"]
const OPTIONS: Array[String] = ["classic", "modern", "luxury"]
const PACKAGES: Array[String] = ["classic", "modern", "luxury", "prestige"]
const PRICES: Dictionary = {"classic":0, "modern":200000, "luxury":500000, "prestige":1000000}
const CAPACITIES: Dictionary = {"classic":5, "modern":8, "luxury":12, "prestige":18}
static func package_owned(choice: String) -> bool:
	return choice == "classic" or choice in Game.flags.get("gallery_packages", [])
static func package_selected() -> String:
	return str(Game.flags.get("gallery_package", "classic"))
static func buy_package(choice: String) -> bool:
	if choice not in PACKAGES: return false
	var amount: int = 0 if package_owned(choice) else int(PRICES[choice])
	if Game.money < amount:
		Game.toast(Loc.t("err_no_money"), "bad")
		return false
	Game.money -= amount
	var owned_packages: Array = Game.flags.get("gallery_packages", []).duplicate()
	if choice not in owned_packages: owned_packages.append(choice)
	Game.flags["gallery_packages"] = owned_packages
	Game.flags["gallery_package"] = choice
	Game.flags["gallery_style"] = {"sign":choice,"floor":choice,"decor":choice}
	Game.garage_cap = maxi(Game.garage_cap,int(CAPACITIES[choice]))
	Game.save_game()
	Game.changed.emit()
	return true
static func cost(part: String, choice: String) -> int:
	if choice == "classic": return 0
	return (5000 if choice == "modern" else 15000) * (2 if part == "decor" else 1)
static func selected(part: String) -> String:
	return str(Game.flags.get("gallery_style", {}).get(part, "classic"))
static func owned(part: String, choice: String) -> bool:
	return choice == "classic" or (part + ":" + choice) in Game.flags.get("gallery_owned", [])
static func select(part: String, choice: String) -> bool:
	if part not in PARTS or choice not in OPTIONS: return false
	var amount: int = 0 if owned(part, choice) else cost(part, choice)
	if Game.money < amount:
		Game.toast(Loc.t("err_no_money"), "bad")
		return false
	Game.money -= amount
	var unlocked: Array = Game.flags.get("gallery_owned", []).duplicate()
	if amount > 0: unlocked.append(part + ":" + choice)
	Game.flags["gallery_owned"] = unlocked
	var styles: Dictionary = Game.flags.get("gallery_style", {}).duplicate()
	styles[part] = choice
	Game.flags["gallery_style"] = styles
	Game.save_game()
	Game.changed.emit()
	return true
static func title() -> String:
	return str(Game.flags.get("gallery_name", "OTOPATRON"))
static func rename(text: String) -> void:
	var clean := text.strip_edges().left(24)
	if clean.is_empty(): clean = "OTOPATRON"
	Game.flags["gallery_name"] = clean
	Game.save_game()
	Game.changed.emit()
