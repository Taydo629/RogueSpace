extends HBoxContainer

@onready var texture_rect: TextureRect = $TextureRect
@onready var label: Label = $Label
var notif_lifetime: int = 1
var timer: Timer

func _ready() -> void:
	timer = Timer.new()
	add_child(timer)
	timer.timeout.connect(_reset_notif)
	timer.wait_time = notif_lifetime
	Inventory.item_pickup.connect(pickup_notif)

func pickup_notif(part: Part) -> void:
	timer.start()
	texture_rect.texture = part.sprite
	label.text = part.name

func _reset_notif() -> void:
	texture_rect.texture = null
	label.text = ""
	
