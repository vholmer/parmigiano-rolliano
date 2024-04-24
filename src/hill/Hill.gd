extends Node2D

const NUM_SPAWNERS = 5
const GROUND_WIDTH = 454
const GROUND_HEIGHT = 227
const GROUND_SPAWN_POINT = Vector2(0, -29)

const CASTLE_START_Y = 158
const CASTLE_END_Y = 55

const EDGE_LAYER_ID = 1
const OBSTACLE_LAYER_ID = 2
const CROWD_LAYER_ID = 3
const PICKUP_LAYER_ID = 4

const PROGRESS_BAR_X_START = 243
const PROGRESS_BAR_X_END = 385
const PROGRESS_BAR_WIDTH = PROGRESS_BAR_X_END - PROGRESS_BAR_X_START
const SMALL_KING_Y = 9
const SMALL_JEM_Y = 22

const MAX_FLAVOR: float = 100.0

var grounds = []
var obstacles = []
var decorations = []
var pickups = []
var runners = []
var clouds = []
var gnomes = []

var castle_progress = 0

@onready var ground_scene = load("res://src/hill/Ground.tscn")

signal finished_game

# Called when the node enters the scene tree for the first time.
func _ready():
	$CloudGroup.self_modulate = Color(1, 1, 1, 0.5)
	
	$Castle.position = Vector2(640, 158)
	$Castle.scale = Vector2(0.5, 0.5)
	
	$CastleTimer.connect("timeout", reached_castle)
	
	# Start & loop music
	$Music.play()
	
	# TODO: Spawn decorations + clouds randomly
	
func reached_castle():
	var character_node = $Player/Character
	
	var edge_layer_id = 1 + log(EDGE_LAYER_ID) / log(2)
	var obstacle_layer_id = 1 + log(OBSTACLE_LAYER_ID) / log(2)
	var crowd_layer_id = 1 + log(CROWD_LAYER_ID) / log(2)
	var pickup_layer_id = 1 + log(PICKUP_LAYER_ID) / log(2)
	
	character_node.set_collision_layer_value(edge_layer_id, false)
	character_node.set_collision_layer_value(obstacle_layer_id, false)
	character_node.set_collision_layer_value(crowd_layer_id, false)
	character_node.set_collision_layer_value(pickup_layer_id, false)
	
	character_node.set_collision_mask_value(edge_layer_id, false)
	character_node.set_collision_mask_value(obstacle_layer_id, false)
	character_node.set_collision_mask_value(crowd_layer_id, false)
	character_node.set_collision_mask_value(pickup_layer_id, false)
	
	character_node.input_locked = true

	await get_tree().create_timer(2).timeout
	
	emit_signal("finished_game")

func _draw():
	if OS.is_debug_build() and false:
		# Define the starting point of the line
		var start_point = Vector2(-50, -80)  # Adjust as needed
		
		# Calculate the angle in radians
		var angle = -$"Player/Character".plane_angle  # Angle in radians
		
		# Define the length of the line
		var length = 1000  # Adjust as needed
		
		# Calculate the endpoint coordinates using trigonometry
		var end_point_x = start_point.x + length * cos(angle)
		var end_point_y = start_point.y + length * sin(angle)
		var end_point = Vector2(end_point_x, end_point_y)
		
		# Draw the line
		draw_line(start_point, end_point, Color.RED, 5)

func spawn_ground():
	while grounds.size() < 3:
		var ground = ground_scene.instantiate()
		
		ground.position = GROUND_SPAWN_POINT + Vector2(
			GROUND_SPAWN_POINT.x + GROUND_WIDTH * grounds.size(),
			GROUND_SPAWN_POINT.y + GROUND_HEIGHT * grounds.size()
		)
		
		grounds.append(ground)
		
		add_child(ground)

func _process(delta):
	castle_progress = 1 - $CastleTimer.time_left / $CastleTimer.wait_time
	
	$Control/Container/CastleProgressBar.value = castle_progress
	$Control/Container/FlavorProgressBar.value = $Player/Character.flavor
	
	$King.position.x = PROGRESS_BAR_X_START + castle_progress * PROGRESS_BAR_WIDTH
	$Jem.position.x = PROGRESS_BAR_X_START + ($Player/Character.flavor / MAX_FLAVOR) * PROGRESS_BAR_WIDTH
	
	$Castle.position.y = CASTLE_START_Y - castle_progress * (CASTLE_START_Y - CASTLE_END_Y)
	$Castle.position.x = 640
	
	$Castle.scale = Vector2(
		0.5 + 0.5 * castle_progress,
		0.5 + 0.5 * castle_progress
	)
	
	spawn_ground()
	
	# Move ground & remove grounds outside of screen
	for ground in grounds:
		ground.move_ground(delta)
		
		if ground.position.x < -GROUND_WIDTH:
			grounds.erase(ground)
			ground.queue_free()
	
	# Iterate over obstacles, queue_free any obstacle outside screen
	for obstacle in obstacles:
		if obstacle.position.x < -250:
			obstacles.erase(obstacle)
			obstacle.queue_free()
			
	# Iterate over decorations, queue_free any decoration outside screen
	for decoration in decorations:
		if decoration.position.x < -50:
			decorations.erase(decoration)
			decoration.queue_free()

	for cloud in clouds:
		if cloud.position.x < -200:
			clouds.erase(cloud)
			cloud.queue_free()
			
	for gnome in gnomes:
		if gnome.global_position.x < -100:
			gnomes.erase(gnome)
			gnome.queue_free()
			
	for pickup in pickups:
		if pickup.position.x < -100:
			pickups.erase(pickup)
			pickup.queue_free()
