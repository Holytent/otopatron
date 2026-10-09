extends Node
var checks := 0
var failures := 0
func check(ok: bool, label: String) -> void:
	checks += 1
	if not ok: failures += 1
	print("PASS " if ok else "FAIL ",label)
func _ready() -> void:
	run.call_deferred()
func run() -> void:
	Game.new_game("Hours", "34")
	Game.set_process(false)
	Game.money = 10000000
	check(Game.minute==420 and not Game.shop_closed(),"New shop opens at 07:00")
	check(DealerExpansion.staff_limit()==1 and Game.security_limit()==1,"Starting slots")
	Game.flags["team"]={"cleaner":true,"mechanic":false}
	check(DealerExpansion.count("cleaner")==1 and DealerExpansion.wages()==650,"Legacy boolean staff remains hired")
	var before: int = Game.money
	check(DealerExpansion.hire("cleaner")=="gone" and Game.money==before,"Capacity blocks extra hire without charge")
	Game.garage_cap = 8
	check(DealerExpansion.staff_limit()==2 and DealerExpansion.hire("cleaner")=="ok" and DealerExpansion.count("cleaner")==2,"Expanded gallery hires second cleaner")
	check(DealerExpansion.wages()==1300,"Two cleaners pay two wages")
	DealerExpansion.dismiss("cleaner")
	check(DealerExpansion.count("cleaner")==1,"Dismiss removes one employee")
	check(Game.upgrade_security() and Game.upgrade_security(),"Hire two guards in expanded gallery")
	before=Game.money
	check(not Game.upgrade_security() and Game.money==before,"Guard limit rejects without charge")
	check(Game.security_wages()==1800,"Two guards have daily wages")
	Game.flags["security"]=5
	Game.garage_cap=5
	check(Game.security_wages()==4500 and not Game.upgrade_security(),"Legacy security retained despite smaller gallery")
	Game.flags["security"]=2
	Game.garage_cap=8
	var snapshot := Game.to_dict().duplicate(true)
	Game.from_dict(snapshot)
	check(DealerExpansion.count("cleaner")==1 and int(Game.flags["security"])==2,"Staff and guards survive save migration")
	Game.minute=1379
	Game.advance(30)
	check(Game.minute==1380 and Game.shop_closed(),"Time stops at 23:00")
	Game.advance(100)
	check(Game.minute==1380,"Closed time does not auto advance")
	before=Game.money
	check(not Game.wait_minutes(60) and Game.money==before,"Night rejects paid waiting")
	var billing := BusinessLedger.charges(Game.level,Game.garage_cap,Game.listing_rank,Game.business_owned)
	check(billing["security"]==1800 and billing["team"]==650,"Ledger records all salaries")
	var old_day: int = Game.day
	before=Game.money
	check(Game.end_day() and Game.day==old_day+1 and Game.minute==420,"Free sleep reaches next 07:00")
	check(Game.money==before-BusinessLedger.total(billing),"Sleep only deducts regular daily bills")
	before=Game.money
	check(not Game.end_day() and Game.money==before,"Repeated sleep cannot double charge")
	Game.minute=120
	old_day=Game.day
	check(Game.end_day() and Game.day==old_day and Game.minute==420 and Game.money==before,"Old after-midnight save opens without extra daily bill")
	Game.minute=1370
	var quote: int=Game.wait_cost(180)
	before=Game.money
	check(Game.wait_minutes(180) and Game.minute==1380 and Game.money==before-quote,"Paid waiting clips to closing time and quote")
	var main=get_parent()
	main.show_screen("home",{})
	await get_tree().process_frame
	check(main._sleep_button.visible,"Sleep button visible when closed")
	main._build_chrome()
	check(is_instance_valid(main._sleep_button) and main._sleep_button.get_parent()==main._root_v,"Sleep button survives theme rebuild")
	print("HOURS_AUDIT_COMPLETE ",checks," checks ",failures," failures")
	get_tree().quit(1 if failures>0 else 0)
