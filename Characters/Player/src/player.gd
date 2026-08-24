class_name Player extends RigidBody2D

@onready var part_component: PartComponent = $PartComponent
@onready var movement_component: MovementComponent = $MovementComponent
@onready var weapon_component: WeaponComponent = $WeaponComponent
@onready var input_component: InputComponent = $InputComponent
@onready var tractorbeam_component: TractorbeamComponent = $TractorbeamComponent
@onready var player_camera: Camera2D = $PlayerCamera
#@onready var player_ui_layer: CanvasLayer = $PlayerUILayer

#var enemy_array: Array[RigidBody2D]
#var station: StaticBody2D

func _ready() -> void:
	ShipInfo.ship_updated.connect(init_ship)
	part_component.graph_changed.connect(reinitialise_components)
	input_component.fire_guns.connect(weapon_component.fire)
	input_component.activate_thrusters.connect(movement_component.activate_thrusters)
	input_component.deactivate_thrusters.connect(movement_component.deactivate_thrusters)
	input_component.activate_tractorbeam.connect(tractorbeam_component.activate)
	input_component.deactivate_tractorbeam.connect(tractorbeam_component.deactivate)
	input_component.mouse_pos_changed.connect(movement_component.rotate_to)

func init_ship(ship_graph, grid_dim) -> void:
	clear_old_ship()
	part_component.ship_graph = ship_graph
	part_component.grid_size = grid_dim
	player_camera.enabled = true
	part_component.initialise_ship()

func reinitialise_components() -> void:
	print("Re-initialise components")
	ShipInfo.update_ship(part_component.ship_graph)
	movement_component.initalise_movement(ShipInfo.ship_graph)
	weapon_component.initalise_weapons(ShipInfo.ship_graph)
	tractorbeam_component.initalise_tractor_beams(ShipInfo.ship_graph)

#func new_level(level: int, new_npc_array: Array[RigidBody2D], new_station: StaticBody2D) -> void:
	#enemy_array = new_npc_array
	#station = new_station
	##player_ui_layer.update_sector_label(level)
	##player_ui_layer.update_hud()

func clear_old_ship() -> void:
	for collider in get_children():
		if collider is CollisionShape2D:
			collider.queue_free()
	for part in part_component.get_children():
		part.queue_free()
