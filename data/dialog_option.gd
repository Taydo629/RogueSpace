class_name DialogOption extends Resource

enum REWARD_TYPE{PART, CREDIT, REPAIRS, AMMO}
enum PENALTY_TYPE{PART, CREDIT, DAMAGE, AMMO}

@export var option_text: String
@export var rewards: Array[REWARD_TYPE]
@export var penalties: Array[PENALTY_TYPE]
@export_multiline var option_response: String
@export var possible_credit_reward: int
@export var possible_part_rewards: Array[Part]
@export var possible_ammo_rewards: int
@export_range(0,1,0.1) var possible_repair_rewards: float
@export var possible_credit_penalty: int
@export var possible_part_penalty: int
@export var possible_ammo_penalty: int
@export_range(0,1,0.1) var possible_damage_penalty: float
