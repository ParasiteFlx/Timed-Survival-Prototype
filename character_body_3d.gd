extends CharacterBody3D

const SPEED = 9
var player = null
var has_activated = false 
var can_move = false
var is_seeker = false # Daca e true, vine direct dupa player cum se spawneaza

@onready var anim_player = $AnimationPlayer
@onready var nav_agent = $NavigationAgent3D 

func _ready():
	add_to_group("Enemies")
	player = get_tree().get_first_node_in_group("Player")
	
	if anim_player:
		anim_player.animation_finished.connect(_on_animation_finished)
		
		if anim_player.has_animation("Idle"):
			anim_player.play("Idle")
			anim_player.advance(0)
			anim_player.pause()
	
	if randf() < 0.15:
		is_seeker = true
		activate_robot()

func activate_robot():
	if not has_activated:
		has_activated = true
		if anim_player:
			anim_player.play("Idle") # Asta va declansa apoi Walk via _on_animation_finished

# --- SEMNALE AREA3D ---

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):
		fade_music(true) 
		if not has_activated:
			has_activated = true
			if anim_player:
				anim_player.play("Idle")

func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.is_in_group("Player"):
		check_for_other_enemies()

# --- LOGICA DE MUZICĂ ---

func fade_music(is_chase: bool):
	var ambient = get_tree().get_root().find_child("BackgroundMusic", true, false)
	var chase = get_tree().get_root().find_child("ChaseMusic", true, false)
	
	if ambient and chase:
		# Tween modifica gradual valorile.
		var tween = create_tween().set_parallel(true)
		if is_chase:
			tween.tween_property(ambient, "volume_db", -15.0, 1.0)
			tween.tween_property(chase, "volume_db", 0.0, 1.0)
		else:
			tween.tween_property(ambient, "volume_db", 0.0, 1.5)
			tween.tween_property(chase, "volume_db", -80.0, 1.5)

func check_for_other_enemies():
	var enemies = get_tree().get_nodes_in_group("Enemies")
	var player_still_in_danger = false
	
	for enemy in enemies:
		var area = enemy.get_node_or_null("Area3D")
		if area and area.has_overlapping_bodies():
			for b in area.get_overlapping_bodies():
				if b.is_in_group("Player"):
					player_still_in_danger = true
					break
		if player_still_in_danger:
			break
	
	if not player_still_in_danger:
		fade_music(false)

# --- ANIMAȚII ȘI MIȘCARE ---

func _on_animation_finished(anim_name: String) -> void:
	if anim_name == "Idle":
		can_move = true
		if anim_player.has_animation("Walk"):
			anim_player.get_animation("Walk").loop_mode = Animation.LOOP_LINEAR
			anim_player.play("Walk")

func _physics_process(delta: float) -> void:

	if not is_on_floor():
		velocity += get_gravity() * delta

	if player and can_move:
		# pozitie player
		nav_agent.target_position = player.global_position
		
		# Logica de pathing pentru enemies
		if not nav_agent.is_navigation_finished():
		
			var next_path_pos = nav_agent.get_next_path_position()
			var direction = (next_path_pos - global_position).normalized()
			# Cream un punct la aceeași înălțime cu robotul pentru a evita rotațiile ciudate pe axa X
			var look_target = Vector3(next_path_pos.x, global_position.y, next_path_pos.z)
			# Robotul se uită spre punctul în care merge (next_path_pos), nu prin pereți
			if global_position.distance_to(look_target) > 0.1:
				look_at(look_target, Vector3.UP)
				rotate_y(PI)
				
			velocity.x = direction.x * SPEED
			velocity.z = direction.z * SPEED
		else:
			velocity.x = 0
			velocity.z = 0
	else:
		# Robotul este în Idle sau nu are player in fata
		velocity.x = 0
		velocity.z = 0
	move_and_slide()
	
	if global_position.distance_to(player.global_position) < 2.5:
		if player.has_method("die_in_vrs"):
			player.die_in_vrs()
			var ambient = get_tree().get_root().find_child("BackgroundMusic", true, false)
			var chase = get_tree().get_root().find_child("ChaseMusic", true, false)
			if ambient and chase:
				var tween_audio = create_tween().set_parallel(true)
				tween_audio.tween_property(ambient, "volume_db", -80.0, 2.5)
				tween_audio.tween_property(chase, "volume_db", -80.0, 2.5)
			
	
