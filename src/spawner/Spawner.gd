extends Node2D

@onready var cloud_spawn_location = $"../CloudSpawnPath/CloudSpawnLocation"
@onready var spawn_location = $"../SpawnPath/SpawnLocation"
@onready var hill_node = $".."
@onready var obstacle_scenes = [
	load("res://src/obstacles/Rock.tscn"),
	load("res://src/obstacles/Bush.tscn"),
	load("res://src/obstacles/Tree.tscn"),
	load("res://src/obstacles/Log.tscn"),
	load("res://src/obstacles/GroundEater.tscn")
]
@onready var decoration_scenes = [
	load("res://src/hill/Plant.tscn")
]
@onready var pickup_scenes = [
	# load("res://src/pickups/Kex.tscn"),
	load("res://src/pickups/Jem.tscn")
]
@onready var cloud_scene = load("res://src/hill/Cloud.tscn")

var obstacle_probabilities = [
	0.2375, # Rock
	0.2375, # Bush
	0.2375, # Tree
	0.2375, # Log
	0.05 # GroundEater
]

const CLOSEST_SPAWN_DISTANCE = 50
const CLOSEST_SPAWN_DISTANCE_GROUNDEATER = 160

const CLOUD_TIMER_LOWER_WAIT = 1
const CLOUD_TIMER_UPPER_WAIT = 1.5

const OBSTACLE_SPAWN_TIME_UPPER_WAIT = 0.7
const DECORATION_SPAWN_TIME_UPPER_WAIT = 0.2

const PICKUP_SPAWN_TIME_LOWER_WAIT = 2
const PICKUP_SPAWN_TIME_UPPER_WAIT = 7

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

func _ready():
	$ObstacleTimer.timeout.connect(spawn_obstacle)
	$DecorationTimer.timeout.connect(spawn_decoration)
	$CloudTimer.timeout.connect(spawn_cloud)
	$PickupTimer.timeout.connect(spawn_pickup)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	clear_overlapping_decorations_pickups()
	
	if $ObstacleTimer.time_left == 0:
		$ObstacleTimer.wait_time = randf_range(0, OBSTACLE_SPAWN_TIME_UPPER_WAIT)
		
		$ObstacleTimer.start()
		
	if $DecorationTimer.time_left == 0:
		$DecorationTimer.wait_time = randf_range(0, DECORATION_SPAWN_TIME_UPPER_WAIT)
		
		$DecorationTimer.start()
		
	if $PickupTimer.time_left == 0:
		$PickupTimer.wait_time = randf_range(PICKUP_SPAWN_TIME_LOWER_WAIT, PICKUP_SPAWN_TIME_UPPER_WAIT)
		
		$PickupTimer.start()
		
	if $CloudTimer.time_left == 0:
		$CloudTimer.wait_time = randf_range(CLOUD_TIMER_LOWER_WAIT, CLOUD_TIMER_UPPER_WAIT)
		
		$CloudTimer.start()
		
func clear_overlapping_decorations_pickups():
	for obstacle in hill_node.obstacles:
		var closest_dist = CLOSEST_SPAWN_DISTANCE
		
		if obstacle.name == "GroundEater":
			closest_dist = CLOSEST_SPAWN_DISTANCE_GROUNDEATER
		
		for decoration in hill_node.decorations:
			var distance = obstacle.position.distance_to(decoration.position)
			
			if distance < closest_dist:
				hill_node.decorations.erase(decoration)
				decoration.queue_free()
					
		for pickup in hill_node.pickups:
			var distance = obstacle.position.distance_to(pickup.position)
			
			if distance < closest_dist:
				hill_node.pickups.erase(pickup)
				pickup.queue_free()

func spawn_cloud():
	cloud_spawn_location.progress_ratio = randf()
	
	var spawn_position = cloud_spawn_location.global_position
	
	var cloud = cloud_scene.instantiate()
	cloud.position = spawn_position
	
	hill_node.clouds.append(cloud)
	hill_node.get_node("CloudGroup").add_child(cloud)

func spawn_pickup():
	spawn_location.progress_ratio = randf()
	
	var spawn_position = spawn_location.global_position
	
	for decoration in hill_node.decorations:
		var distance = spawn_position.distance_to(decoration.position)
		
		if distance < CLOSEST_SPAWN_DISTANCE:
			hill_node.decorations.erase(decoration)
			decoration.queue_free()
	
	for existing_pickup in hill_node.pickups:
		var distance = spawn_position.distance_to(existing_pickup.position)
		
		if distance < CLOSEST_SPAWN_DISTANCE:
			return
	
	# Create the decoration and add to scene tree
	var pickup = pickup_scenes.pick_random().instantiate()
	
	pickup.position = spawn_position
	
	# Add it to list of decorations in Hill scene
	hill_node.pickups.append(pickup)
	
	hill_node.add_child(pickup)

func spawn_decoration():
	spawn_location.progress_ratio = randf()
	
	var spawn_position = spawn_location.global_position
	
	for existing_decoration in hill_node.decorations:
		var distance = spawn_position.distance_to(existing_decoration.position)
		
		if distance < CLOSEST_SPAWN_DISTANCE:
			return
	
	for existing_pickup in hill_node.pickups:
		var distance = spawn_position.distance_to(existing_pickup.position)
		
		if distance < CLOSEST_SPAWN_DISTANCE:
			return
	
	# Create the decoration and add to scene tree
	var decoration = decoration_scenes.pick_random().instantiate()
	
	decoration.position = spawn_position
	
	# Add it to list of decorations in Hill scene
	hill_node.decorations.append(decoration)
	
	hill_node.add_child(decoration)

func spawn_obstacle():
	spawn_location.progress_ratio = randf()
	
	var obstacle = weighted_random_choice(obstacle_scenes, obstacle_probabilities).instantiate()
	
	var spawn_position = spawn_location.global_position
	
	var closest_dist = CLOSEST_SPAWN_DISTANCE
	
	if obstacle.name == "GroundEater":
		closest_dist = CLOSEST_SPAWN_DISTANCE_GROUNDEATER
	
	for existing_obstacle in hill_node.obstacles:
		if obstacle.name == "GroundEater" or existing_obstacle.name == "GroundEater":
			closest_dist = CLOSEST_SPAWN_DISTANCE_GROUNDEATER
		
		var distance = spawn_position.distance_to(existing_obstacle.position)
		
		if distance < closest_dist:
			return
	
	if obstacle.name != "GroundEater":
		closest_dist = CLOSEST_SPAWN_DISTANCE
	
	# Check distance to decorations, if too close, destroy the decoration
	for decoration in hill_node.decorations:
		var distance = spawn_position.distance_to(decoration.position)
		
		if distance < closest_dist:
			hill_node.decorations.erase(decoration)
			decoration.queue_free()
			
	for pickup in hill_node.pickups:
		var distance = spawn_position.distance_to(pickup.position)
		
		if distance < closest_dist:
			hill_node.pickups.erase(pickup)
			pickup.queue_free()
	
	obstacle.position = spawn_position
	
	# Add it to list of obstacles in Hill scene
	hill_node.obstacles.append(obstacle)
	
	hill_node.add_child(obstacle)
