class_name BusinessLedger
extends RefCounted
static func charges(level: int, capacity: int, rank: int, owned: bool) -> Dictionary:
	return {"rent": 0 if owned else 650 + level * 65 + capacity * 40,
		"power": 100 + level * 20 + capacity * 15,
		"staff": maxi(0, level - 4) * 35 + maxi(0, capacity - 5) * 60,
		"security": Game.security_wages(), "team": DealerExpansion.wages(), "advertising": rank * 120, "maintenance": 200 + level * 15 if owned else 0}
static func total(items: Dictionary) -> int:
	var amount := 0
	for v in items.values():
		amount += int(v)
	return amount
