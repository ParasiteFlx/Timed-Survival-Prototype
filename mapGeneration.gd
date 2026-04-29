extends Node3D

@export var wall_scene: PackedScene
@export var enemy_scene: PackedScene
@export var safety_platform: Node3D 
@export var fill_percent: int = 45
@export var max_enemies: int = 25


var grid = []
var map_width: int
var map_height: int
var current_enemy_count: int = 0

func _ready():
	# Așteptăm un cadru pentru a ne asigura că nodurile sunt inițializate
	await get_tree().process_frame
	
	if not safety_platform:
		print("Eroare: Nu ai asignat Floor în Inspector!")
		return
		
	generate_level()
	spawn_enemies(10)

func generate_level():
	# abs() pentru ca valorile sunt negative
	map_width = int(abs(safety_platform.scale.x))
	map_height = int(abs(safety_platform.scale.z))
	
	randomize()
	setup_grid() #setup initial grid.
	
	for i in range(5): #numarul de cate ori trebuie facut refine mai trebuie modificat
		refine_grid()
	
	draw_grid()

func setup_grid():
	grid.clear()
	for x in range(map_width):
		grid.append([])
		for z in range(map_height):
			# Pereți pe marginea grilei
			if x == 0 or x == map_width - 1 or z == 0 or z == map_height - 1:
				grid[x].append(1)
			else:
				grid[x].append(1 if randi() % 100 < fill_percent else 0) #Umplerea gridului in functie de fill_percent stabilit

func refine_grid():
	var new_grid = grid.duplicate(true)
	for x in range(1, map_width - 1):
		for z in range(1, map_height - 1):
			var neighbors = get_neighbor_count(x, z)
			if neighbors > 4: #daca sunt peste 4 ne asiguram ca e perete acolo  ca sa nu avem zone in care mijlocul e gol
				new_grid[x][z] = 1
			elif neighbors < 4: #Daca sunt prea putini veciini inseamna ca peretele e singur, si poate fi drum pe acolo
				new_grid[x][z] = 0
	grid = new_grid

func get_neighbor_count(x, z):
	var count = 0
	for i in range(x - 1, x + 2):
		for j in range(z - 1, z + 2):
			if i != x or j != z:
				count += grid[i][j]
	return count

func draw_grid():
	# Curățăm pereții anteriori
	for child in get_children():
		if child is StaticBody3D:
			child.queue_free()

	# Plasam obiectele
	for x in range(map_width):
		for z in range(map_height):
			if grid[x][z] == 1:
				# Scădem 0.5 pentru a centra cubul bucata lui din grid
				var pos_x = (x - map_width / 2.0) + 0.5
				var pos_z = (z - map_height / 2.0) + 0.5
				
				if Vector2(pos_x, pos_z).length() < 3.0: # Safeguard ca sa nu apara un perete in player la rulare
					continue
				
				var wall = wall_scene.instantiate()
				add_child(wall)
				
				var height = randf_range(2, 5)
				wall.scale = Vector3(1, height, 1) 
				
				var y_pos = safety_platform.position.y + (height / 2.0)
				wall.position = Vector3(pos_x, y_pos, pos_z)

func spawn_enemies(count: int):
	var spacious_spots = []
	
	for x in range(1, map_width - 1):
		for z in range(1, map_height - 1):
			#Daca celula curentă e podea
			if grid[x][z] == 0:
				# 2. Verificăm vecinii (un pătrat de 3x3 de spațiu liber)
				if is_area_clear(x, z):
					var pos_x = (x - map_width / 2.0) + 0.5
					var pos_z = (z - map_height / 2.0) + 0.5
					var pos_3d = Vector3(pos_x, 1.0, pos_z)
					
					if pos_3d.length() > 10.0:
						spacious_spots.append(pos_3d)
	
	spacious_spots.shuffle()
	
	var actual_spawned = 0
	for spot in spacious_spots:
		if actual_spawned >= count:
			break
			
		
		var is_too_crowded = false
		for existing_enemy in get_tree().get_nodes_in_group("Enemies"):
			if spot.distance_to(existing_enemy.global_position) < 4.0: # Distanță de 4 metri între ei
				is_too_crowded = true
				break
		
		if not is_too_crowded:
			var enemy = enemy_scene.instantiate()
			enemy.add_to_group("Enemies") 
			add_child(enemy)
			enemy.position = spot
			actual_spawned += 1
	
	current_enemy_count += actual_spawned


func is_area_clear(x, z) -> bool:
	for i in range(x - 1, x + 2):
		for j in range(z - 1, z + 2):
			if grid[i][j] == 1: # Dacă găsim măcar un perete în jur
				return false
	return true

func _on_spawn_timer_timeout():
	if current_enemy_count < max_enemies:
		# Calculăm câți mai putem adăuga fără să depășim limita
		var space_left = max_enemies - current_enemy_count
		var to_spawn = min(5, space_left) # Adăugăm 5 sau cât a mai rămas până la 25
		
		spawn_enemies(to_spawn)
		print("Val de inamici! Total: ", current_enemy_count)
	else:
		print("Limita de inamici atinsă!")
