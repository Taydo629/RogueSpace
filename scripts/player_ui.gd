extends Control

@onready var h_box_container: HBoxContainer = $HBoxContainer
@onready var direction_indicator: Control = $DirectionIndicator
@onready var station_ui: TabContainer = $Station_UI
@onready var credit_ui: Label = $CreditUI
var player: ShipObject

func _ready() -> void:
	var siblings = get_parent().get_parent().get_children()
	print(siblings)
	for sibling in siblings:
		if sibling.is_in_group("player_ship"):
			player = sibling
	Inventory.credit_changed.connect(update_credit_ui)
	update_credit_ui(Inventory.wallet)

func update_credit_ui(wallet: int):
	credit_ui.text = str("CR ", wallet)

func item_pickup(part: Part) -> void:
	h_box_container.pickup_notif(part)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("e"):
		if player.docking_available:
			station_ui.visible = !station_ui.visible
			print("docking available")
			if station_ui.visible:
				player.get_tree().paused = true
			else:
				player.get_tree().paused = false
		else:
			print("docking unavailable")
