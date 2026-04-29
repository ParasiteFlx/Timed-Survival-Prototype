extends StaticBody3D

@onready var win_overlay = get_tree().root.find_child("Escape", true, false)

func _on_body_entered(body: Node3D):
	if body.is_in_group("Player"):
		execute_win_sequence(body)

func execute_win_sequence(player: Node3D):
	
	player.set_physics_process(false)
	if "is_already_dead" in player:
		player.is_already_dead = true # Prevenim declanșarea morții simultan
	
	get_tree().call_group("Enemies", "set_physics_process", false)
	
	# Fade to White
	if win_overlay:
		print("Overlay găsit, pornesc fade-ul!")
		win_overlay.visible = true
		win_overlay.modulate.a = 0.0 
		
		var tween = create_tween()
	
		tween.tween_property(win_overlay, "modulate:a", 1.0, 4.0)
		var ambient = get_tree().root.find_child("BackgroundMusic", true, false)
		var chase = get_tree().root.find_child("ChaseMusic", true, false)
		if ambient and chase:
			var t_audio = create_tween().set_parallel(true)
			t_audio.tween_property(ambient, "volume_db", -80.0, 4.0)
			t_audio.tween_property(chase, "volume_db", -80.0, 4.0)
		
		tween.finished.connect(func():
			await get_tree().create_timer(2.0).timeout 
			print("Ai evadat din simulare!")
			get_tree().quit()
		)
