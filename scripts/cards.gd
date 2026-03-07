extends Node


# Card definities
const CARDS = [
	{
		"name": "The Flash",
		"description": "+50 movement speed",
		"icon": "res://assets/free frames pack by batareya/base 9.png",  # Optioneel
		"effect": "speed"
	},
	{
		"name": "Bunny",
		"description": "Jump higher!",
		"icon": "res://assets/free frames pack by batareya/base 18.png",
		"effect": "jump"
	},
	{
		"name": "Glas Cannon",
		"description": "+5 attack damage",
		"icon": "res://assets/free frames pack by batareya/base 16.png",
		"effect": "damage"
	},
	{
		"name": "Shield",
		"description": "Block 1 attack",
		"icon": "res://assets/free frames pack by batareya/base 4.png",
		"effect": "shield"
	},
	{
		"name": "Life Steal",
		"description": "Heal on hit",
		"icon": "res://assets/free frames pack by batareya/base 14.png",
		"effect": "lifesteal"
	}
]

# Kies 3 random kaarten
func get_random_cards(count: int = 3) -> Array:
	var available = CARDS.duplicate()
	var selected = []
	
	for i in range(min(count, available.size())):
		var random_index = randi() % available.size()
		selected.append(available[random_index])
		available.remove_at(random_index)
	
	return selected
