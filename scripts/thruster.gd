extends Node2D

@onready var rigid_body_2d: RigidBody2D = $RigidBody2D

func _ready() -> void:
	rigid_body_2d.constant_force = Vector2(10,10)
	print(get_node)

func _physics_process(delta: float) -> void:
	#print(rigid_body_2d.constant_force)
	pass
	
