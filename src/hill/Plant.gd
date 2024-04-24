extends Node2D

@onready var hill_node = $".."
@onready var character_node = $"../Player/Character"
@onready var ground_speed = character_node.GROUND_SPEED
@onready var plane_angle = character_node.plane_angle

var sprites = [
	load("res://gfx/hill/sprGrass1.png"),
	load("res://gfx/hill/sprGrass2.png"),
	load("res://gfx/hill/sprFlowers_blue.png"),
	load("res://gfx/hill/sprFlowers_pink.png"),
	load("res://gfx/hill/sprFlowers_yellow.png"),
	load("res://gfx/hill/sprFlowers_variant.png")
]

var probabilities = [
	0.35,
	0.35,
	0.075,
	0.075,
	0.075,
	0.075
]

func normalize_probabilities(probabilities: Array) -> Array:
	var total_probability = 0.0
	for probability in probabilities:
		total_probability += probability
	
	if total_probability != 1.0:
		for i in range(probabilities.size()):
			probabilities[i] /= total_probability
	
	return probabilities

func weighted_random_choice(items: Array, probabilities: Array) -> Variant:
	var normalized_probabilities = normalize_probabilities(probabilities)
	
	var total_probability = 0.0
	for probability in normalized_probabilities:
		total_probability += probability
	
	var random_number = randf() * total_probability
	var cumulative_probability = 0.0
	for i in range(items.size()):
		cumulative_probability += normalized_probabilities[i]
		if random_number < cumulative_probability:
			return items[i]
	
	return items[items.size() - 1]

# Called when the node enters the scene tree for the first time.
func _ready():
	$Sprite.z_as_relative = false
	$Sprite.texture = weighted_random_choice(sprites, probabilities)
	# $Sprite.flip_h = randi() % 2 == 0
	$Sprite.z_index = 1

func _physics_process(delta):
	# All obstacles behave in the same way, they move along plane_angle until outside screen
	position += delta * ground_speed * Vector2.from_angle(PI - plane_angle)
