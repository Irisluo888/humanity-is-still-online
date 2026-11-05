extends "res://ui/phone/list_item.gd"
func contact(id: String,title: String,description: String):
 setup(id,title,description)
 set_meta("contact_id",id)
