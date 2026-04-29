extends RichTextLabel

# Căutăm Timer-ul în scenă (ajustează calea dacă nu e direct sub Main)
@onready var exit_timer = $"../../ExitTimer"

func _process(_delta):
	if exit_timer and not exit_timer.is_stopped():
		var time_left = exit_timer.time_left
		var minutes = int(time_left) / 60
		var seconds = int(time_left) % 60
		
		# Updatează propriul text
		text = "%02d:%02d" % [minutes, seconds]
