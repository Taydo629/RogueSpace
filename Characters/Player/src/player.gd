class_name Player extends RigidBody2D

@onready var part_component: PartComponent = $PartComponent
@onready var movement_component: MovementComponent = $MovementComponent
@onready var weapon_component: WeaponComponent = $WeaponComponent
@onready var input_component: InputComponent = $InputComponent
@onready var tractorbeam_component: TractorbeamComponent = $TractorbeamComponent
@onready var player_camera: PlayerCamera = $PlayerCamera
var ship_graph: Dictionary :
	set(value):
		if value != ship_graph:
			ship_graph = value
			print("New graph incoming")
			initialise_ship.connect(init_ship)
			initialise_ship.emit()
signal initialise_ship
signal player_died

#func _ready() -> void:
	#initialise_ship.connect(init_ship)
	#part_component.graph_changed.connect(reinitialise_components)
	#part_component.ship_destroyed.connect(died)
	#input_component.fire_guns.connect(weapon_component.fire)
	#input_component.activate_thrusters.connect(movement_component.activate_thrusters)
	#input_component.deactivate_thrusters.connect(movement_component.deactivate_thrusters)
	#input_component.activate_tractorbeam.connect(tractorbeam_component.activate)
	#input_component.deactivate_tractorbeam.connect(tractorbeam_component.deactivate)
	#input_component.mouse_pos_changed.connect(movement_component.rotate_to)
	#input_component.zoom_in.connect(player_camera.zoom_in)
	#input_component.zoom_out.connect(player_camera.zoom_out)

func init_ship() -> void:
	part_component.graph_changed.connect(reinitialise_components)
	part_component.ship_destroyed.connect(died)
	input_component.fire_guns.connect(weapon_component.fire)
	input_component.activate_thrusters.connect(movement_component.activate_thrusters)
	input_component.deactivate_thrusters.connect(movement_component.deactivate_thrusters)
	input_component.activate_tractorbeam.connect(tractorbeam_component.activate)
	input_component.deactivate_tractorbeam.connect(tractorbeam_component.deactivate)
	input_component.mouse_pos_changed.connect(movement_component.rotate_to)
	input_component.zoom_in.connect(player_camera.zoom_in)
	input_component.zoom_out.connect(player_camera.zoom_out)
	part_component.ship_graph = ship_graph
	player_camera.enabled = true
	reinitialise_components()

func reinitialise_components() -> void:
	print("Re-initialise components")
	movement_component.initalise_movement(ship_graph)
	weapon_component.initalise_weapons(ship_graph)
	tractorbeam_component.initalise_tractor_beams(ship_graph)

func clear_old_ship() -> void:
	for collider in get_children():
		if collider is CollisionShape2D:
			collider.queue_free()
	for part in part_component.get_children():
		part.queue_free()

func died() -> void:
	player_died.emit()
