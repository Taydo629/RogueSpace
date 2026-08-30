extends BasePart

var activation_key: String

var part:Part:
	set(value):
		sprite = value.image
		max_health = value.max_health
		health = max_health
		part = value
