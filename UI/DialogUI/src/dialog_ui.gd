class_name DialogUI extends Control

var player: Player
var dialog_res_dir: String = "res://data/Dialog/"
var dialog_list: Array[Dialog]
var options_dict: Dictionary[Button,DialogOption]

signal interaction_end(bool)

@onready var dialog_text: RichTextLabel = $DialogBoxBG/VBoxContainer/DialogBoxContainer/DialogText
@onready var button_container: VBoxContainer = $DialogBoxBG/VBoxContainer/DialogBoxContainer/ButtonContainer
@onready var npc_name_label: Label = $DialogBoxBG/VBoxContainer/NPCNameLabel
@onready var warp_button: Button = $WarpButton
@onready var credit_ui: Label = $CreditUI

func _ready() -> void:
	_load_all_dialog()

func init_dialog_ui() -> void:
	# Get a random dialog
	var selected_dialog: Dialog = dialog_list.pick_random()
	
	# Set up connections with Inventory
	if not Inventory.credit_changed.is_connected(_update_credit_ui):
		Inventory.credit_changed.connect(_update_credit_ui)
	_update_credit_ui(Inventory.wallet)
	
	# Set up dialog box
	npc_name_label.text = selected_dialog.npc_name
	dialog_text.text = selected_dialog.main_dialog_text
	for option: DialogOption in selected_dialog.options:
		# If any options which have penalties evaluate if this option is possible
		var is_button_disabled:= false
		if not option.penalties.is_empty():
			for penalty in option.penalties:
				if penalty == DialogOption.PENALTY_TYPE.PART:
					if Inventory.inventory.is_empty():
						is_button_disabled = true
				elif penalty == DialogOption.PENALTY_TYPE.CREDIT:
					if Inventory.wallet < option.possible_credit_penalty:
						is_button_disabled = true
				elif penalty == DialogOption.PENALTY_TYPE.AMMO:
					# Add ammo logic here once it is added.
					pass
		var new_option_button: Button = Button.new()
		new_option_button.text = option.option_text
		if is_button_disabled:
			new_option_button.disabled = true
		else:
			new_option_button.pressed.connect(_option_button_pressed.bind(new_option_button))
		options_dict.set(new_option_button, option)
		button_container.add_child(new_option_button)
	# Set up scene with player and NPC (WIP)
	if not player.player_died.is_connected(_player_died):
		player.player_died.connect(_player_died)
	player.freeze = true
	player.player_camera.enabled = false
	print(get_viewport_rect())
	
	var current_viewport_rect:= get_viewport_rect()
	var player_offset:= current_viewport_rect.size/4.0
	player.position = player_offset
	player.rotation_degrees = 90
	# NPC orientation
	#var npc_offset:= Vector2(current_viewport_rect.size.x - player_offset.x, player_offset.y)
	#NPC.position = npc_offset
	#NPC.rotation_degrees = -90

func _update_credit_ui(wallet: int):
	credit_ui.text = str("CR ", wallet)

func _option_button_pressed(button: Button) -> void:
	var selected_option: DialogOption = options_dict.get(button)
	dialog_text.text = selected_option.option_response
	# Make all buttons disabled:
	for child:Button in button_container.get_children():
		child.disabled = true
	# Code related to recieving rewards and penalties.
	if not selected_option.rewards.is_empty():
		# Code recieving rewards
		for reward: DialogOption.REWARD_TYPE in selected_option.rewards:
			if reward == DialogOption.REWARD_TYPE.PART:
				var part_rewards: Array[Part] = selected_option.possible_part_rewards
				Inventory.add_item(part_rewards.pick_random())
			elif reward == DialogOption.REWARD_TYPE.CREDIT:
				Inventory.deposit_to_wallet(selected_option.possible_credit_reward)
			elif reward == DialogOption.REWARD_TYPE.AMMO:
				# No current ammo inventory
				pass
			elif reward == DialogOption.REWARD_TYPE.REPAIRS:
				# Repairs may need more work thus leaving empty
				pass
	if not selected_option.rewards.is_empty():
		# Code recieving penalties
		pass
	warp_button.visible = true

func _load_all_dialog() -> void:
	for resource in ResourceLoader.list_directory(dialog_res_dir):
		dialog_list.append(load(str(dialog_res_dir,resource)))

func _player_died() -> void:
	interaction_end.emit(false)

func _on_warp_button_pressed() -> void:
	_clear_dialog()
	player.freeze = false
	player.position = Vector2.ZERO
	player.rotation_degrees = 0
	player.player_camera.enabled = true
	interaction_end.emit(true)

func _clear_dialog() -> void:
	for child:Button in button_container.get_children():
		child.queue_free()
	options_dict.clear()
