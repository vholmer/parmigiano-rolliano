extends Node2D

const CLOUD_MIN_Y = 4
const CLOUD_MAX_Y = 154
const CLOUD_MIN_SCALE = 0.2
const CLOUD_BASE_SPEED = 100

var cloud_speed

@onready var hill_node = $"../.."

# Called when the node enters the scene tree for the first time.
func _ready():
	# Make clouds smaller the lower their y-value
	var weight = (position.y - CLOUD_MIN_Y) / (CLOUD_MAX_Y - CLOUD_MIN_Y)
	var cloud_scale = lerp(1.0, CLOUD_MIN_SCALE, weight)
	
	$Sprite.z_index = -1
	$Sprite.flip_h = randi() % 2 == 0
	$Sprite.scale = Vector2(cloud_scale, cloud_scale)
	
	cloud_speed = cloud_scale * CLOUD_BASE_SPEED

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position.x -= delta * cloud_speed
