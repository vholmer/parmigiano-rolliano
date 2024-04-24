extends Node2D

@export var flip_direction = false

@onready var bg_node = $"../../Background"
@onready var menu_node = $"../.."

const SPAWN_TIME_MIN = 1
const SPAWN_TIME_MAX = 3

var menu_cheese_scene = load("res://src/menu/MenuCheese.tscn")
var cheeses = []

# Called when the node enters the scene tree for the first time.
func _ready():
	$Timer.connect("timeout", spawn_menu_cheese)
	$Timer.wait_time = randf_range(SPAWN_TIME_MIN, SPAWN_TIME_MAX)
	$Timer.start()
	
func _process(delta):
	position.x -= delta * menu_node.BACKGROUND_SPEED
	
	if global_position.x < -1000:
		for cheese in cheeses:
			menu_node.cheeses.erase(cheese)
		queue_free()

func spawn_menu_cheese():
	var menu_cheese = menu_cheese_scene.instantiate()
	if menu_node.in_help:
		menu_cheese.visible = false
	menu_cheese.z_index = 1
	menu_cheese.flip_direction = flip_direction
	menu_node.cheeses.append(menu_cheese)
	cheeses.append(menu_cheese)
	add_child(menu_cheese)
	
	$Timer.wait_time = randf_range(SPAWN_TIME_MIN, SPAWN_TIME_MAX)
	$Timer.start()
