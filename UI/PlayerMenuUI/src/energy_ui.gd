extends MarginContainer

# pips visual
const PIPS = preload("uid://cpxi6ucx8prku")


@onready var shield_pip_hbox: VBoxContainer = $VBoxContainer/HBoxContainer/ShieldEnergyContainer/MarginContainer/HBoxContainer/PipHbox
@onready var shield_energy_bar: ProgressBar = $VBoxContainer/HBoxContainer/ShieldEnergyContainer/MarginContainer/HBoxContainer/EnergyBar
@onready var movement_pip_hbox: VBoxContainer = $VBoxContainer/HBoxContainer/MovementEnergyContainer/MarginContainer/HBoxContainer/PipHbox
@onready var movement_energy_bar: ProgressBar = $VBoxContainer/HBoxContainer/MovementEnergyContainer/MarginContainer/HBoxContainer/EnergyBar
@onready var weapon_pip_hbox: VBoxContainer = $VBoxContainer/HBoxContainer/WeaponEnergyContainer/MarginContainer/HBoxContainer/PipHbox
@onready var weapon_energy_bar: ProgressBar = $VBoxContainer/HBoxContainer/WeaponEnergyContainer/MarginContainer/HBoxContainer/EnergyBar

var energy_component: EnergyComponent
var current_energy_dict: Dictionary

func init_energy_ui() -> void:
	var energy_dict: Dictionary = energy_component.energy_pips
	current_energy_dict = energy_dict
	for key in energy_dict:
		var value: Dictionary = energy_dict.get(key)
		var num_of_pips: int = value.get("pips")
		var energy_percent: float = (value.get("current_energy") / value.get("max_energy"))*100.0
		if key == energy_component.ENERGY_ROUTES.SHIELDS:
			for i in num_of_pips:
				var new_pips = PIPS.instantiate()
				shield_pip_hbox.add_child(new_pips)
			shield_energy_bar.value = energy_percent
		elif key == energy_component.ENERGY_ROUTES.MOVEMENT:
			for i in num_of_pips:
				var new_pips = PIPS.instantiate()
				movement_pip_hbox.add_child(new_pips)
			movement_energy_bar.value = energy_percent
		elif key == energy_component.ENERGY_ROUTES.WEAPONS:
			for i in num_of_pips:
				var new_pips = PIPS.instantiate()
				weapon_pip_hbox.add_child(new_pips)
			weapon_energy_bar.value = energy_percent

func update_energy_ui() -> void:
	print("updating_energy_ui")
	var energy_dict: Dictionary = energy_component.energy_pips
	current_energy_dict = energy_dict
	for key in energy_dict:
		var value: Dictionary = energy_dict.get(key)
		var num_of_pips: int = value.get("pips")
		var energy_percent: float = (value.get("current_energy") / value.get("max_energy"))*100.0
		if key == energy_component.ENERGY_ROUTES.SHIELDS:
			if num_of_pips != shield_pip_hbox.get_child_count():
				var pip_diff: int = num_of_pips - shield_pip_hbox.get_child_count()
				if pip_diff > 0:
					for i in pip_diff:
						var new_pips = PIPS.instantiate()
						shield_pip_hbox.add_child(new_pips)
				elif pip_diff < 0:
					var pips: Array[Node] = shield_pip_hbox.get_children()
					for i in abs(pip_diff):
						pips[i].queue_free()
			shield_energy_bar.value = energy_percent
		elif key == energy_component.ENERGY_ROUTES.MOVEMENT:
			if num_of_pips != movement_pip_hbox.get_child_count():
				var pip_diff: int = num_of_pips - movement_pip_hbox.get_child_count()
				if pip_diff > 0:
					for i in pip_diff:
						var new_pips = PIPS.instantiate()
						movement_pip_hbox.add_child(new_pips)
				elif pip_diff < 0:
					var pips: Array[Node] = movement_pip_hbox.get_children()
					for i in abs(pip_diff):
						pips[i].queue_free()
			movement_energy_bar.value = energy_percent
		elif key == energy_component.ENERGY_ROUTES.WEAPONS:
			if num_of_pips != weapon_pip_hbox.get_child_count():
				var pip_diff: int = num_of_pips - weapon_pip_hbox.get_child_count()
				if pip_diff > 0:
					for i in pip_diff:
						var new_pips = PIPS.instantiate()
						weapon_pip_hbox.add_child(new_pips)
				elif pip_diff < 0:
					var pips: Array[Node] = weapon_pip_hbox.get_children()
					for i in abs(pip_diff):
						pips[i].queue_free()
			weapon_energy_bar.value = energy_percent

func _process(delta: float) -> void:
	update_energy_ui()
