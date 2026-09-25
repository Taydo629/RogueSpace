class_name InventoryBar extends HBoxContainer

@onready var credit_label: Label = $CreditVbox/CreditLabel
@onready var ammo_label: Label = $AmmoVbox/AmmoLabel
@onready var explosive_label: Label = $ExplosiveVbox/ExplosiveLabel

var template_str: String = ":%s"

func _on_visibility_changed() -> void:
	_init_inventory_bar()

func _init_inventory_bar() -> void:
	if not Inventory.credit_changed.is_connected(_update_credit_label):
		Inventory.credit_changed.connect(_update_credit_label)
	if not Inventory.ammo_changed.is_connected(_update_ammo_label):
		Inventory.ammo_changed.connect(_update_ammo_label)
	if not Inventory.explosives_changed.is_connected(_update_explosive_label):
		Inventory.explosives_changed.connect(_update_explosive_label)
	_update_credit_label(Inventory.wallet)
	_update_ammo_label(Inventory.ammo)
	_update_explosive_label(Inventory.explosives)

func _update_credit_label(new_credit: int) -> void:
	credit_label.text = template_str % new_credit

func _update_ammo_label(new_ammo: int) -> void:
	ammo_label.text = template_str % new_ammo

func _update_explosive_label(new_explosives: int) -> void:
	explosive_label.text = template_str % new_explosives
