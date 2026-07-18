class_name GunComponent extends Node

@export var ship : RigidBody2D
@export var bullet : PackedScene
@onready var timer: Timer = $"../Timer"

var guns : Array
var muzzle_offset: Vector2 = Vector2(0,-32)
var gun_ready: bool = true

func _ready() -> void:
	var temp_guns = get_tree().get_nodes_in_group("gun")
	for i in temp_guns:
		if i.get_parent() == get_parent():
			guns.append(i)

func update_guns() -> void:
	var temp_guns = get_tree().get_nodes_in_group("gun")
	for i in temp_guns:
		if i.get_parent() == get_parent():
			guns.append(i)

func _physics_process(_delta: float) -> void:
	if Input.is_action_pressed("left_click") and gun_ready:
		for node in guns:
			if not node is Node2D:
				continue
			var gun_direction = Vector2.UP.rotated(node.global_rotation)
			var new_bullet:StaticBody2D = bullet.instantiate()
			new_bullet.global_position = (node.global_position + muzzle_offset.rotated(node.global_rotation))
			new_bullet.rotation = ship.rotation
			add_child(new_bullet)
			timer.start()
			gun_ready = false
			
func _on_timer_timeout() -> void:
	# Cooldown ended gun is ready again
	gun_ready = true
