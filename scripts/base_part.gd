class_name BasePart extends RigidBody2D

var max_health: int = 100

@onready var hit_sound: AudioStreamPlayer2D = $Hit_sound
@onready var polygon_2d: Polygon2D = $Polygon2D

var health: int
var dict_key: String
var is_detached: bool = false

signal part_destroyed
signal part_detached

func _ready() -> void:
	# Connect the parts destroyed signal to the player ship if possible.
	health = max_health

func take_damage(damage: int) -> void:
	var new_health = health - damage
	hit_sound.play()
	
	if new_health <= 0:
		if get_parent().has_method("part_destroyed") and is_detached:
			print("Destruction signal connected!")
			part_destroyed.connect(get_parent().part_destroyed)
			part_destroyed.emit(dict_key)
		queue_free()
	else:
		health = new_health
		var frac_hp = float(new_health)/float(max_health)
		var part_color: Color = polygon_2d.color
		if frac_hp < 0.5 and frac_hp >= 0.25:
			part_color = Color(0.89,0.4,0,1)
		elif frac_hp < 0.25:
			part_color = Color(0.53, 0.03, 0.0, 1.0)
		polygon_2d.color = part_color

func attached(new_key: String) -> void:
	dict_key = new_key
	freeze = true

func detached() -> void:
	is_detached = true
	part_detached.emit()
	freeze = false
