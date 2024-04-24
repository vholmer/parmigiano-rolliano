extends Node2D

var cheese_spawner_scene = load("res://src/menu/MenuCheeseSpawner.tscn")

var last_spawn_time = 0

@onready var menu_node = $".."

const MAX_SPAWN_MS = 1000

func spawn():
	var cheese_spawner = cheese_spawner_scene.instantiate()
	cheese_spawner.z_index = 1
	cheese_spawner.flip_direction = global_position.y > 360
	add_child(cheese_spawner)
