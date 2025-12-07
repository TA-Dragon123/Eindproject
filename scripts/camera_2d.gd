extends Camera2D

var shake_amount = 0.0

func _process(delta):
	if shake_amount > 0:
		offset = Vector2(
			randf_range(-shake_amount, shake_amount),
			randf_range(-shake_amount, shake_amount)
		)
		shake_amount = lerp(shake_amount, 0.0, delta * 10.0)  # ← 0.0 en 10.0 (niet 0 en 10)
	else:
		offset = Vector2.ZERO

func shake(amount):
	shake_amount = float(amount)  # ← Converteer naar float
