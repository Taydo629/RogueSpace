extends BasePart

var activation_key: String

var part:Part:
	set(value):
		max_health = value.max_health
		health = max_health
		part = value
