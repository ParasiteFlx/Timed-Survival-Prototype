extends RichTextLabel

@export var fade_in_duration: float = 1.5   
@export var seconds_per_character: float = 0.05 
@export var wait_before_fade: float = 3.0 
@export var fade_out_duration: float = 10.0 

func _ready():
	modulate.a = 0.0
	visible_ratio = 0.0

func play_full_sequence():
	var tween = create_tween()

	tween.tween_property(self, "modulate:a", 1.0, fade_in_duration)
	
	var total_typing_time = get_total_character_count() * seconds_per_character
	tween.tween_property(self, "visible_ratio", 1.0, total_typing_time)
	
	tween.tween_interval(wait_before_fade)
	
	tween.tween_property(self, "modulate:a", 0.0, fade_out_duration)
