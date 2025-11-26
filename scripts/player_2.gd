extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -300.0
var player_hp = 0
var last_diraction = 1
var is_stunned = false
var is_attacking = false 
var stun_duration = 1.0
var is_blocking = false
var SP = false

# Parry System
var block_window = 0.0
var parry_window_duration = 0.2  # 0.2 seconden voor perfect parry

# Combo System
var combo_count = 0
var combo_timer = 0.0
var combo_window = 1.5  # 1.5 seconden om combo voort te zetten

@onready var player: CharacterBody2D = $"."
@onready var collision_main: CollisionShape2D = $CollisionShape2D
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var attack_hitbox_right: Area2D = $attack_hitbox_right
@onready var collision_shape_2d_right: CollisionShape2D = $attack_hitbox_right/CollisionShape2D_right
@onready var attack_hitbox_left: Area2D = $attack_hitbox_left
@onready var collision_shape_2d_left: CollisionShape2D = $attack_hitbox_left/CollisionShape2D_left

# Preload hit effect (maak dit later aan!)
# var hit_effect_scene = preload("res://hit_effect.tscn")

func _physics_process(delta: float) -> void:
	# Update combo timer
	if combo_timer > 0:
		combo_timer -= delta
	else:
		if combo_count > 0:
			print("Combo ended at x" + str(combo_count))
		combo_count = 0
	
	# Update parry window
	if block_window > 0:
		block_window -= delta
	
	if is_stunned:
		if not is_on_floor():
			velocity += get_gravity() * delta
		else:
			# BELANGRIJK: Stop horizontal movement when landing!
			velocity.x = move_toward(velocity.x, 0, SPEED * delta * 10)  # Snel afremmen
		move_and_slide()
		return
		
	if is_attacking:
		move_and_slide()
		return
		
	var direction := Input.get_axis("move_left_2", "move_right_2")
	if direction == 1:
		last_diraction = 1
	elif direction == -1:
		last_diraction = -1
	
	if Input.is_action_just_pressed("attack_2") and last_diraction == 1 and is_on_floor():
		attack_right()
		return
	elif Input.is_action_just_pressed("attack_2") and last_diraction == -1 and is_on_floor():
		attack_left()
		return
		

	
	# Perfect Parry Window
	if Input.is_action_just_pressed("block_2"):
		block_window = parry_window_duration
		print("Parry window active!")
	
	if Input.is_action_pressed("block_2"):
		is_blocking = true
		animated_sprite.play("block")
		velocity.x = 0
		move_and_slide()
		return
	else:
		is_blocking = false
	
	if not is_on_floor():
		animated_sprite.play("fall")
		velocity += get_gravity() * delta
	
	if Input.is_action_just_pressed("jump_2") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	if Input.is_action_pressed("move_down_2") and is_on_floor():
		direction = 0
	
	if direction > 0:
		animated_sprite.flip_h = false
	elif direction < 0:
		animated_sprite.flip_h = true
	
	if is_on_floor():
		if direction == 0:
			if Input.is_action_pressed("move_up_2"):
				animated_sprite.play("up")
			elif Input.is_action_pressed("move_down_2"):
				animated_sprite.play("down")
			else:
				animated_sprite.play("idle")
		elif Input.is_action_pressed("move_left_2") or Input.is_action_pressed("move_right_2"):
			animated_sprite.play("run")
	else:
		animated_sprite.play("jump")
	
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	move_and_slide()

func attack_right():
	# Update combo
	combo_count += 1
	combo_timer = combo_window
	
	is_attacking = true
	animated_sprite.play("attack")
	
	collision_shape_2d_right.disabled = false
	
	await get_tree().create_timer(0.3).timeout
	
	var hit_bodies = attack_hitbox_right.get_overlapping_bodies()
	
	for body in hit_bodies:
		if body != self and body.has_method("get_stunned"):
			# Calculate damage with combo multiplier
			var base_damage = 5
			var combo_multiplier = 1.0 + (combo_count - 1) * 0.2  # +20% per combo
			var total_damage = int(base_damage * combo_multiplier)
			
			# Visual feedback
			get_node("/root/Game/Camera2D").shake(3 + combo_count)
			
			# Hitstop (longer for higher combos)
			var hitstop_duration = 0.05 + (combo_count * 0.01)
			Engine.time_scale = 0.1
			await get_tree().create_timer(hitstop_duration).timeout
			Engine.time_scale = 1.0
			
			# Show combo
			if combo_count > 1:
				print("COMBO x" + str(combo_count) + "!")
			
			# Spawn hit effect
			spawn_hit_effect(body.global_position)
			
			# Deal damage
			body.get_stunned(1, total_damage)  # 1 = knockback naar rechts
			player_hp -= total_damage
			print("Hit player!! Damage: " + str(total_damage))
			print("Player2 HP: " + str(player_hp))
			if player_hp <= 0:
				get_tree().reload_current_scene()
	
	collision_shape_2d_right.disabled = true
	await get_tree().create_timer(0.5).timeout
	is_attacking = false

func attack_left():
	# Update combo
	combo_count += 1
	combo_timer = combo_window
	
	is_attacking = true
	animated_sprite.play("attack")
	
	collision_shape_2d_left.disabled = false
	
	await get_tree().create_timer(0.5).timeout
	
	var hit_bodies = attack_hitbox_left.get_overlapping_bodies()
	
	for body in hit_bodies:
		if body != self and body.has_method("get_stunned"):
			# Calculate damage with combo multiplier
			var base_damage = 5
			var combo_multiplier = 1.0 + (combo_count - 1) * 0.2
			var total_damage = int(base_damage * combo_multiplier)
			
			# Visual feedback
			get_node("/root/Game/Camera2D").shake(3 + combo_count)
			
			# Hitstop
			var hitstop_duration = 0.05 + (combo_count * 0.01)
			Engine.time_scale = 0.1
			await get_tree().create_timer(hitstop_duration).timeout
			Engine.time_scale = 1.0
			
			if combo_count > 1:
				print("COMBO x" + str(combo_count) + "!")
			
			# Spawn hit effect
			spawn_hit_effect(body.global_position)
			
			# Deal damage
			body.get_stunned(-1, total_damage)  # -1 = knockback naar links
			player_hp += total_damage
			print("Hit player!! Damage: " + str(total_damage))
			print("Player2 HP: " + str(player_hp))
			
	
	collision_shape_2d_left.disabled = true
	await get_tree().create_timer(0.5).timeout
	is_attacking = false

func get_stunned(knockback_direction, damage = 5,SP = false):
	# Perfect Parry!
	if block_window > 0:
		print("✨ PERFECT PARRY! ✨")
		block_window = 0
		
		# Flash effect
		animated_sprite.modulate = Color(1, 1, 0)  # Geel flash
		await get_tree().create_timer(0.1).timeout
		animated_sprite.modulate = Color(1, 1, 1)
		
		# Spawn parry effect
		spawn_parry_effect(global_position)
		
		# Stun de aanvaller terug! (optional)
		# get_parent().get_node("OtherPlayer").get_counter_stunned()
		return
	
	# Normal Block
	if is_blocking:
		print("Attack blocked!")
		
		# Small pushback on block
		velocity.x = knockback_direction * 50
		
		# Block effect
		animated_sprite.modulate = Color(0.7, 0.7, 1)  # Blauw flash
		await get_tree().create_timer(0.1).timeout
		animated_sprite.modulate = Color(1, 1, 1)
		
		return
	
	# Normal Hit
	is_stunned = true
	animated_sprite.play("hit")
	
	# Knockback (stronger with more damage)
	var knockback_force = 150 + (damage * 10 * (player_hp/10))
	if SP == true:
		knockback_force = 250 + (damage * 10* (player_hp/10))
		SP = false
	velocity.x = knockback_direction * knockback_force
	velocity.y = -100
	
	# Hit flash effect
	animated_sprite.modulate = Color(1, 0.3, 0.3)  # Rood flash
	await get_tree().create_timer(0.1).timeout
	animated_sprite.modulate = Color(1, 1, 1)
	
	await get_tree().create_timer(stun_duration).timeout
	
	is_stunned = false
	animated_sprite.play("idle")
	player_hp += damage
	print("Hit player!! Damage: " + str(damage))
	print("Player2 HP: " + str(player_hp))
	

func spawn_hit_effect(position: Vector2):
	# Simpel particle effect met modulate
	var effect = Sprite2D.new()
	effect.texture = animated_sprite.sprite_frames.get_frame_texture("idle", 0)  # Gebruik een frame
	effect.global_position = position
	effect.modulate = Color(1, 0, 0, 0.7)  # Rood semi-transparant
	effect.scale = Vector2(0.5, 0.5)
	get_parent().add_child(effect)
	
	# Fade out en verwijder
	var tween = create_tween()
	tween.tween_property(effect, "modulate:a", 0.0, 0.3)
	tween.tween_property(effect, "scale", Vector2(1.5, 1.5), 0.3)
	tween.tween_callback(effect.queue_free)
	
	print("💥 Hit effect spawned!")

func spawn_parry_effect(position: Vector2):
	# Gouden cirkel effect voor parry
	var effect = Sprite2D.new()
	effect.texture = animated_sprite.sprite_frames.get_frame_texture("idle", 0)
	effect.global_position = position
	effect.modulate = Color(1, 1, 0, 1)  # Geel
	effect.scale = Vector2(0.3, 0.3)
	get_parent().add_child(effect)
	
	# Expand en fade
	var tween = create_tween()
	tween.tween_property(effect, "scale", Vector2(2, 2), 0.4)
	tween.parallel().tween_property(effect, "modulate:a", 0.0, 0.4)
	tween.tween_callback(effect.queue_free)
	
	print("✨ Parry effect spawned!")
