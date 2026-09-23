class_name Dialog extends Resource

enum INTERACTION_TYPE{POSITIVE, NEUTRAL, HOSTILE}

@export var interaction_type: INTERACTION_TYPE
@export var npc_name: String
@export_multiline var main_dialog_text: String
@export var options: Array[DialogOption]
