extends CharacterBody2D

var animations = [
	"blue",
	"pink",
	"yellow"
]

func _ready():
	var random_animation = animations.pick_random()
	var num_frames = $Sprite.sprite_frames.get_frame_count(random_animation)
	$Sprite.speed_scale = randf_range(0.3, 1)
	var scale = randf_range(0.5, 1.1)
	$Sprite.scale = Vector2(scale, scale)
	$Sprite.set_frame_and_progress(randi_range(0, num_frames - 1), 0)
	$Sprite.play(random_animation)

func _process(delta):
	z_index = max(1, global_position.y)
