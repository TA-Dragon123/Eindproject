extends Camera2D

var shake_amount = 0.0
@onready var playercamara = get_parent().get_node("Player")


func _process(delta):
	if shake_amount > 0:
		offset = Vector2(
			randf_range(-shake_amount, shake_amount),
			randf_range(-shake_amount, shake_amount)
		)
		shake_amount = lerp(shake_amount, 0.0, delta * 10.0)  
	else:
		offset = Vector2.ZERO

func shake(amount):
	var one = 1
	shake_amount = float(amount)  
func playercam(player):
	if player == "p1":
		playercamara = get_parent().get_node("Player2")
	elif player == "p2":
		playercamara = get_parent().get_node("Player")
func _physics_process(delta):
		self.position = playercamara.position
		
