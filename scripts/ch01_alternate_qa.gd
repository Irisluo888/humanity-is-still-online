extends "res://scripts/ch01_qa_test.gd"
func _initialize():
 skip_1404=true;store_method="leave";ending_method="opened_door"
 super._initialize()
func capture(name: String) -> void:
 if name=="11_ending":await super.capture("19_alternate_ending")
