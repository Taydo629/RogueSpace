class_name ShipObject extends RigidBody2D
@onready var thrust_component: ThrustComponent = $ThrustComponent
@onready var gyro_component: GyroComponent = $GyroComponent

var x_min = -160
var y_min = -160

func _ready() -> void:
	pass

func init_ship():
	var grid = ShipInfo.grid
	for i in grid:
		for j in i:
			if j != null:
				var part = j[0].instantiate()
				var colider = preload("res://scenes/part_colider.tscn").instantiate()
				var x = x_min + j[1] * 64
				var y = y_min + j[2] * 64
				add_child(part)
				add_child(colider)
				part.position = Vector2(x,y)
				colider.position = Vector2(x,y)
	center_of_mass_mode = RigidBody2D.CENTER_OF_MASS_MODE_AUTO
	if gyro_component:
		gyro_component.active_ship = self
	thrust_component.update_thrusters()
