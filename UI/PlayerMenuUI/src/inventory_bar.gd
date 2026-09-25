class_name InventoryBar extends HBoxContainer

@onready var credit_label: Label = $CreditVbox/CreditLabel
@onready var ammo_label: Label = $AmmoVbox/AmmoLabel
@onready var explosive_label: Label = $ExplosiveVbox/ExplosiveLabel

var template_str: String = ":%s"

func _on_visibility_changed() -> void:
	_init_inventory_bar()

func _init_inventory_bar() -> void:
	if Inventory.credit_changed.is_connected(_update_credit_label):
		Inventory.credit_changed.connect(_update_credit_label)
	_update_credit_label(Inventory.wallet)


func _update_credit_label(new_credit: int) -> void:
	credit_label.text = template_str % new_credit
