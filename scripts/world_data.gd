extends Node
signal changed
var people: Dictionary = {"resident_07": "七号住户"}
var places: Dictionary = {"lane_07": "榆灯巷 07 号"}
var orders: Array = [{"id": "order_001", "person_id": "resident_07", "place_id": "lane_07", "item": "热汤", "status": "缓存待配送"}]
var events: Array = []
func record_event(id: String, person_id: String, place_id: String, text: String) -> void:
 events.append({"id": id, "person_id": person_id, "place_id": place_id, "text": text})
 changed.emit()
func _ready() -> void:
 record_event("cache_001", "resident_07", "lane_07", "门铃没电，请敲两下。（原型缓存）")
