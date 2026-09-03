class_name BuyItemGrid extends AspectRatioContainer

@onready var texture_rect: TextureRect = $MarginContainer/HBoxContainer/TextureRect
@onready var part_description_label: Label = $MarginContainer/HBoxContainer/PartDescriptionLabel
@onready var part_cost_label: Label = $MarginContainer/HBoxContainer/PartCostLabel


@export var hover_scale: Vector2 = Vector2(1.2,1.2)
@export var hover_anim_dur: float = 0.1
var part: Part
var selected: bool = false

signal grid_hovered(BuyItemGrid)
signal grid_clicked(BuyItemGrid)

func _ready() -> void:
	if part != null:
		part_description_label.text = part.name
		part_cost_label.text = "%s CR" % str(part.buy_price)
		texture_rect.texture = part.image

func _on_mouse_entered() -> void:
	var tween = create_tween()
	tween.tween_property(self, "scale", hover_scale,hover_anim_dur)
	grid_hovered.emit(self)
	#scale = Vector2(1.2,1.2)

func _on_mouse_exited() -> void:
	if not selected:
		var tween = create_tween()
		tween.tween_property(self, "scale", Vector2(1.,1.),hover_anim_dur)

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		print("clicked")
		grid_clicked.emit(self)
		selected = true

func unselect() -> void:
	selected = false
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1.,1.),hover_anim_dur)
