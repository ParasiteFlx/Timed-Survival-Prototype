extends CharacterBody3D

@onready var anim = $"Y Bot/AnimationPlayer"
const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const SPRINT_SPEED = 8.0
var is_already_dead = false

func die_in_vrs():
	if is_already_dead:
		return
	else:
		is_already_dead = true
		
	set_physics_process(false)
	
	var overlay = $"../../UI/DeathOverlay"
	
	if overlay:
		var tween = create_tween()
		# Fade to black în 5 secunde
		tween.tween_property(overlay, "modulate:a", 1.0, 5.0)
		
		# Când e complet negru, închidem jocul
		tween.finished.connect(func(): 
			await get_tree().create_timer(3.0).timeout # Mai stă o secundă pe negru
			get_tree().quit() 
			)



func _physics_process(delta: float) -> void:
	
	
	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("CharacterJump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		anim.play("YPlayerModel/jump", 0.0) 
		anim.seek(0.1, true)

		

	var input_dir := Input.get_vector("CharMoveLeft", "CharMoveRight", "CharMoveForward", "CharMoveBackward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	var current_speed = SPEED
	if Input.is_action_pressed("CharacterSprint"): 
		if current_speed != SPRINT_SPEED:
			current_speed = SPRINT_SPEED
		else:
			current_speed = SPEED
	
	if direction:
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)


	if is_on_floor():
		
		if anim.current_animation != "YPlayerModel/jump" or not anim.is_playing():
			if direction:
				if Input.is_action_pressed("CharacterSprint"):
					anim.play("YPlayerModel/run", 0.3) 
				else:
					anim.play("YPlayerModel/walk", 0.3)
			else:
				anim.play("YPlayerModel/idle", 0.2)
	else:
		pass
		
	move_and_slide()
