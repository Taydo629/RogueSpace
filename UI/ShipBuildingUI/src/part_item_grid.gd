class_name PartItemGrid extends AspectRatioContainer

@onready var texture_rect: TextureRect = $MarginContainer/TextureRect
@onready var progress_bar: ProgressBar = $MarginContainer2/ProgressBar

@export var hover_scale: Vector2 = Vector2(1.2,1.2)
@export var hover_anim_dur: float = 0.1
var part: Part

signal grid_hovered(PartItemGrid)
signal grid_not_hovered(PartItemGrid)

func _ready() -> void:
	if part != null:
		var health_frac: float = (float(part.current_health)/float(part.max_health)) * 100.
		progress_bar.value = health_frac
		texture_rect.texture = part.image

func _on_mouse_entered() -> void:
	var tween = create_tween()
	tween.tween_property(self, "scale", hover_scale,hover_anim_dur)
	grid_hovered.emit(self)
	#scale = Vector2(1.2,1.2)

func _on_mouse_exited() -> void:
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1.,1.),hover_anim_dur)
	grid_not_hovered.emit(self)
