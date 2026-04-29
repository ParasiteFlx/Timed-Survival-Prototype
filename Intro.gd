extends RichTextLabel

@export var seconds_per_character: float = 0.05 
@export var wait_before_fade: float = 3.0 
@export var fade_duration: float = 3

func _ready():

	visible_ratio = 0.0
	play_typewriter()

func play_typewriter():
	var tween = create_tween()

	var total_typing_time = get_total_character_count() * seconds_per_character
	tween.tween_property(self, "visible_ratio", 1.0, total_typing_time)
	
	tween.tween_interval(wait_before_fade)
	
	tween.tween_property(self, "modulate:a", 0.0, fade_duration)
