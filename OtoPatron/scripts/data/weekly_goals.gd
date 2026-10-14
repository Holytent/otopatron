class_name WeeklyGoals
extends RefCounted
## Weekly gallery goals: sell cars at a profit, earn profit, make one strong sale.
##
## Progress is derived from the sales history, so nothing can be counted twice. Only the claimed goals and the
## player's level at the start of the week are stored (Game.flags["weekly_goals"]); an old save without it
## simply starts the current week. The week is the game week the weekly auction already uses.
const IDS: Array = ["sold", "profit", "best"]
const BONUS_DIAMONDS := 2


static func week_of(d: int) -> int:
	return int((d - 1) / 7)


static func week() -> int:
	return week_of(Game.day)


static func days_left() -> int:
	return week() * 7 + 7 - Game.day


static func _round_5k(value: float) -> int:
	return int(round(value / 5000.0)) * 5000


## Targets for a player level. Sales that lose money never count, so goals cannot be farmed with buy-and-sell loops.
static func targets(level: int) -> Dictionary:
	return {"sold": clampi(2 + level / 4, 2, 8), "profit": _round_5k(25000 + level * 9000), "best": _round_5k(8000 + level * 3500)}


## Per goal reward: half of the level cash reward plus XP; the same for each goal of the week.
static func reward(level: int) -> Dictionary:
	return {"money": Game.r500(Game.cash_reward(level) * 0.5), "xp": 10 + level * 3}


static func progress() -> Dictionary:
	var current := week()
	var out := {"sold": 0, "profit": 0, "best": 0}
	for entry in Game.sales_history():
		if week_of(int(entry["day"])) != current: continue
		var profit := int(entry["profit"])
		if profit <= 0: continue
		out["sold"] = int(out["sold"]) + 1
		out["profit"] = int(out["profit"]) + profit
		out["best"] = maxi(int(out["best"]), profit)
	return out


## The saved state for the current week, repaired if it is damaged and restarted when the week changed.
static func state() -> Dictionary:
	var raw: Variant = Game.flags.get("weekly_goals", {})
	var current := week()
	var fresh := {"week": current, "level": maxi(1, Game.level), "claimed": [], "bonus": false}
	if not raw is Dictionary or not (raw.get("week") is int or raw.get("week") is float) or int(raw["week"]) != current:
		Game.flags["weekly_goals"] = fresh
		return fresh
	var claimed: Array = []
	if raw.get("claimed") is Array:
		for id in raw["claimed"]:
			if IDS.has(str(id)) and not claimed.has(str(id)): claimed.append(str(id))
	var level := clampi(int(raw["level"]) if (raw.get("level") is int or raw.get("level") is float) else Game.level, 1, 99)
	var repaired := {"week": current, "level": level, "claimed": claimed, "bonus": bool(raw.get("bonus", false)) and claimed.size() == IDS.size()}
	Game.flags["weekly_goals"] = repaired
	return repaired


static func is_complete(id: String, saved: Dictionary) -> bool:
	return IDS.has(id) and int(progress()[id]) >= int(targets(int(saved["level"]))[id])


static func claimable_count() -> int:
	var saved := state()
	var count := 0
	for id in IDS:
		if not (saved["claimed"] as Array).has(id) and is_complete(id, saved): count += 1
	return count
