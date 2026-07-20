class_name ShipObject extends RigidBody2D

@onready var thrust_component: ThrustComponent = $ThrustComponent
@onready var gyro_component: GyroComponent = $GyroComponent
@onready var gun_component: GunComponent = $GunComponent

var x_min = -160
var y_min = -160

func _ready() -> void:
	pass

func init_ship():
	var ship_graph = ShipInfo.ship_graph
	for key in ship_graph.keys():
		var node = ship_graph.get(key)
		var part = node.part.scene.instantiate()
		var colider = preload("res://scenes/part_colider.tscn").instantiate()
		var x = x_min + node.grid_pos.x * 64
		var y = y_min + node.grid_pos.y * 64
		node.part = part
		node.colider = colider
		part.position = Vector2(x,y)
		part.rotation_degrees = node.rotation
		if node.mirrored:
			part.scale = Vector2(-1,1)
			colider.scale = Vector2(-1,1)
		colider.position = Vector2(x,y)
		add_child(part)
		add_child(colider)
		part.colider = colider
		part.dict_key = key
				
	center_of_mass_mode = RigidBody2D.CENTER_OF_MASS_MODE_AUTO
	if gyro_component:
		gyro_component.active_ship = self
	thrust_component.update_thrusters()
	gun_component.update_guns()
