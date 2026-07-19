extends RigidBody2D

var x_min = -160
var y_min = -160

@export var hull: Part
@export var thruster: Part
@export var gun: Part

var grid: Array

func _ready() -> void:
	grid = [[null,null,[hull,Vector2(3,1),0,false],[gun,Vector2(4,1),0,false],null],
			[null,[hull,Vector2(2,2),0,false],[hull,Vector2(3,2),0,false],[hull,Vector2(4,2),0,false],null],
			[null,[hull,Vector2(2,3),0,false],null,[hull,Vector2(4,3),0,false],null],
			[null,[thruster,Vector2(2,4),0,false],null,[thruster,Vector2(4,4),0,false],null],
			[null,null,null,null,null]]
	init_ship()

func init_ship():
	for i in grid:
		for j in i:
			if j != null:
				var part = j[0].scene.instantiate()
				var colider = preload("res://scenes/part_colider.tscn").instantiate()
				var x = x_min + j[1].x * 64
				var y = y_min + j[1].y * 64
				j[0] = part
				j.append(colider)
				part.position = Vector2(x,y)
				part.rotation_degrees = j[2]
				# Handle part mirroring
				if j[3]:
					part.scale = Vector2(-1,1)
					colider.scale = Vector2(-1,1)
				colider.position = Vector2(x,y)
				add_child(part)
				add_child(colider)
				part.colider = colider
	center_of_mass_mode = RigidBody2D.CENTER_OF_MASS_MODE_AUTO
	# Temporarily not focusing on any actions made by NPC ship
	#if gyro_component:
		#gyro_component.active_ship = self
	#thrust_component.update_thrusters()
	#gun_component.update_guns()
