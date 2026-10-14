extends Node
## Weekly gallery goals: targets, progress from real sales, one-time rewards, saves and week changes.
var checks := 0
var failures := 0

func check(ok: bool, label: String) -> void:
	checks += 1
	if not ok: failures += 1
	print("PASS " if ok else "FAIL ", label)

func _ready() -> void:
	run.call_deferred()

func sale(profit: int, on_day: int = -999) -> void:
	var history: Array = Game.flags.get("sales_history", [])
	history.append({"model": "veltra_taro", "year": 2015, "price": 300000 + profit, "bought": 300000, "invested": 0, "bonus": 0, "profit": profit, "day": Game.day if on_day == -999 else on_day, "minute": 600, "buyer": "Test"})
	Game.flags["sales_history"] = history

func fresh_game() -> void:
	Game.new_game("Hedef", "34")
	Game.set_process(false)
	Game.settings["music"] = 0.0
	Game.settings["sfx"] = 0.0
	Game.news = {"cm": {}, "dm": 1.0}
	Game.money = 1000000
	Game.level = 1

func reload() -> void:
	Game.from_dict(JSON.parse_string(JSON.stringify(Game.to_dict())))

func run() -> void:
	fresh_game()
	var t1 := WeeklyGoals.targets(1)
	var t5 := WeeklyGoals.targets(5)
	var t10 := WeeklyGoals.targets(10)
	check(t1 == {"sold": 2, "profit": 35000, "best": 10000}, "Level 1 targets are small and round")
	check(t5["sold"] >= t1["sold"] and t10["profit"] > t5["profit"] and t5["profit"] > t1["profit"] and t10["best"] > t5["best"] and t5["best"] > t1["best"], "Targets grow with the level")
	check(WeeklyGoals.targets(99)["sold"] <= 8, "The sales target is capped")
	check(WeeklyGoals.week() == 0 and WeeklyGoals.days_left() == 7, "A new game starts in week 0 with 7 days left")
	check(WeeklyGoals.week_of(1) == 0 and WeeklyGoals.week_of(7) == 0 and WeeklyGoals.week_of(8) == 1, "The goal week matches the weekly auction week")
	var saved := WeeklyGoals.state()
	check(saved["claimed"].is_empty() and saved["level"] == 1 and saved["bonus"] == false, "A new week starts with nothing claimed")
	check(WeeklyGoals.claimable_count() == 0 and Game.next_goal()["key"] != "goal_weekly", "No goal is claimable and no hint is shown at the start")
	var money_before := Game.money
	check(Game.claim_weekly_goal("sold").is_empty() and Game.money == money_before, "An incomplete goal cannot be claimed")
	check(Game.claim_weekly_goal("nonsense").is_empty(), "An unknown goal id is rejected")
	# progress counts profitable sales of this week only
	sale(20000); sale(30000); sale(-5000); sale(90000, -20)
	var progress := WeeklyGoals.progress()
	check(progress == {"sold": 2, "profit": 50000, "best": 30000}, "Progress counts profitable sales of this week only")
	check(WeeklyGoals.claimable_count() == 3 and Game.next_goal()["key"] == "goal_weekly", "Three goals are claimable and the hint points to the rewards")
	# one-time payment
	var reward := WeeklyGoals.reward(1)
	var xp_before := Game.xp
	var diamonds_before := Game.diamonds
	var stats_before: Dictionary = Game.stats.duplicate()
	var result := Game.claim_weekly_goal("sold")
	check(not result.is_empty() and Game.money == money_before + int(reward["money"]) and int(result["diamonds"]) == 0 and Game.diamonds == diamonds_before, "A goal pays its cash reward and no diamonds")
	check(Game.xp > xp_before or Game.level > 1, "A goal pays XP")
	var money_after := Game.money
	check(Game.claim_weekly_goal("sold").is_empty() and Game.money == money_after, "A second tap on the same goal pays nothing")
	check(Game.stats == stats_before, "Claiming does not touch the sales statistics")
	reload()
	check(Game.claim_weekly_goal("sold").is_empty() and Game.money == money_after, "Reloading the save cannot pay the claimed goal again")
	check(WeeklyGoals.state()["claimed"] == ["sold"], "The claimed goal is stored in the save")
	# level stays fixed within the week
	var level_in_week: int = WeeklyGoals.state()["level"]
	Game.level += 3
	check(WeeklyGoals.state()["level"] == level_in_week and WeeklyGoals.targets(int(WeeklyGoals.state()["level"])) == t1, "Levelling up mid week keeps the week's targets")
	Game.level -= 3
	# all three goals: bonus diamonds exactly once
	var d0 := Game.diamonds
	var second := Game.claim_weekly_goal("profit")
	check(not second.is_empty() and int(second["diamonds"]) == 0 and Game.diamonds == d0, "The second goal has no bonus yet")
	var third := Game.claim_weekly_goal("best")
	check(not third.is_empty() and int(third["diamonds"]) == WeeklyGoals.BONUS_DIAMONDS and Game.diamonds == d0 + WeeklyGoals.BONUS_DIAMONDS, "Finishing all three pays the diamond bonus once")
	check(Game.claim_weekly_goal("best").is_empty() and Game.diamonds == d0 + WeeklyGoals.BONUS_DIAMONDS, "The bonus cannot be paid twice")
	# same week, later day: still claimed
	Game.day += 2
	check(WeeklyGoals.state()["claimed"].size() == 3 and WeeklyGoals.claimable_count() == 0, "Later days of the same week keep the claims")
	# next week starts clean
	Game.day = 8
	var next_state := WeeklyGoals.state()
	check(next_state["week"] == 1 and next_state["claimed"].is_empty() and next_state["bonus"] == false, "A new game week resets the claims")
	check(WeeklyGoals.progress() == {"sold": 0, "profit": 0, "best": 0} and WeeklyGoals.claimable_count() == 0, "A new week starts with no progress")
	check(Game.claim_weekly_goal("sold").is_empty(), "Last week's sales cannot pay this week's goal")
	sale(40000); sale(15000)
	check(WeeklyGoals.progress()["sold"] == 2 and not Game.claim_weekly_goal("sold").is_empty(), "New sales this week can be claimed")
	# old save without the field, and damaged fields
	Game.flags.erase("weekly_goals")
	reload()
	check(WeeklyGoals.state()["claimed"].is_empty() and WeeklyGoals.state()["week"] == WeeklyGoals.week(), "An old save without weekly goal data starts the current week")
	for bad in ["text", 5, {"week": "x", "claimed": "no"}, {"week": WeeklyGoals.week(), "claimed": ["sold", "sold", "evil", 7], "level": "high", "bonus": true}]:
		Game.flags["weekly_goals"] = bad
		var repaired := WeeklyGoals.state()
		check(repaired["claimed"].size() <= 1 and repaired["level"] >= 1 and repaired["bonus"] == false, "Damaged weekly goal data is repaired safely")
	# the save format stays at 7
	check(Game.SAVE_VERSION == 7 and int(Game.to_dict()["version"]) == 7, "Save format version is still 7")
	# a loss-making sale never counts, even if repeated
	fresh_game()
	for i in 10: sale(-12000)
	check(WeeklyGoals.progress() == {"sold": 0, "profit": 0, "best": 0}, "Selling at a loss never counts toward a goal")
	var failed := failures
	print("WEEKLY_AUDIT_COMPLETE ", checks, " checks; ", failed, " failures")
	await Fx.release_audio()
	get_tree().quit(1 if failed > 0 else 0)
