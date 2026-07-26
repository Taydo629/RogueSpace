extends Node2D

@onready var rich_text_label: RichTextLabel = $Control/RichTextLabel
@onready var texture_rect: TextureRect = $Control/TextureRect

var current_page: int = 1
var guide_dict = {
	"1" : {
		"text": "The aim of the game is to progress to as many sectors as possible without your ship being destroyed.",
		"icon": null
	},
	"2" : {
		"text": "Before you proceed to the level you must build your ship! \n Here is some information of all the various parts.",
		"icon": null
	},
	"3" : {
		"text": "The Core.\n 
		This part serves as the heart of your ship! Any part which is no longer connected to the core will be detached! \n
		When this part is destroyed so is your ship.\n
		Once you have enough parts you may want to protect the core!",
		"icon": preload("uid://dwhx2m8ppv0ne")
	},
	"4" : {
		"text": "The Hull.\n 
		Hull is a simple block serving as a structural part of your ship.\n
		This part can also be used as armor around other parts (Get Creative!)",
		"icon": preload("uid://d2eronkpe7nyd")
	},
	"5" : {
		"text": "The Gun.\n 
		The gun is self-explanatory. It shoots projectiles which only hit on non-player blocks.\n
		If you are left without a gun and there are still enemies left you may not be able to leave the sector!\n
		Guns can be used with left click.",
		"icon": preload("uid://c3veeunyicgoe")
	},
	"6" : {
		"text": "The Thruster.\n 
		The thruster is the only form of propulsion you ship has, so be careful with them!\n
		The more thrusters the faster you will be able to move around.\n
		Thursters can be activated with SpaceBar.",
		"icon": preload("uid://cbqqgjxuknwxd")
	},
	"7" : {
		"text": "The Tractor Beam.\n 
		The tractor beam is the only way you will be able to pick up and store detached parts from your foes!\n
		Activate the tractor beam using RightMouseButton and detached parts will be attracted to the ship.",
		"icon": preload("uid://pef7qu3o521a")
	},
	"8" : {
		"text": "When in a sector your ship will pick up enemy signatures.\n 
		These signatures will show on your hud with the icon above to direct you to enemies!\n
		Once all enemies are destroyed the station will allow docking!",
		"icon": preload("uid://bnoqx3qdl0nj6")
	},
	"9" : {
		"text": "The Station.\n 
		The station refuses docking services until all combat in the sector seizes!\n
		Once docking is available you will be able to access all services the station has to offer!\n
		The station will be marked on your hud with the icon above once all enemies have been terminated.",
		"icon": preload("uid://cfnjuioesg0ip")
	}
	
}

func _ready() -> void:
	var page = guide_dict.get(str(current_page))
	rich_text_label.text = page.text
	texture_rect.texture = page.icon

func _on_next_button_pressed() -> void:
	current_page += 1
	if str(current_page) in guide_dict.keys():
		var page = guide_dict.get(str(current_page))
		rich_text_label.text = page.text
		texture_rect.texture = page.icon
	else:
		print("guide end")
