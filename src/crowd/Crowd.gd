extends Node2D

const RUNNER_COUNT = 100
const SPAWN_RADIUS = 50
const MIN_NEIGHBOR_DISTANCE = 10
const MAX_SPAWN_ATTEMPTS = 10

@onready var hill_node = $".."
@onready var spawn_location = $"../RunnerSpawnPath/RunnerSpawnLocation"

var runner_scene = load("res://src/crowd/Runner.tscn")

func get_random_pos_in_circle(origin: Vector2, radius: float) -> Vector2:
	var r = sqrt(randf_range(0.0, 1.0)) * radius
	var t = randf_range(0.0, 1.0) * TAU
	var random_pos = Vector2(r * cos(t), r * sin(t))
	return origin + random_pos

func loop_cheer():
	$Cheer.stop()
	$Cheer.seek(0.6)
	$Cheer.stream_paused = false
	$Cheer.play()

func _process(delta):
	var playback_pos = $Cheer.get_playback_position()
	
	if playback_pos >= 19:
		loop_cheer()

func _ready():
	var attempts = 0
	
	while hill_node.runners.size() < RUNNER_COUNT:
		spawn_location.progress_ratio = randf()
		
		var runner = runner_scene.instantiate()
		
		var spawn_location = get_random_pos_in_circle(spawn_location.global_position, SPAWN_RADIUS)
		
		
		# Check distance to other runners, max 10 attempts
		var found_good_spot = false
		
		for existing_runner in hill_node.runners:
			var distance = existing_runner.position.distance_to(spawn_location)
			
			if distance < MIN_NEIGHBOR_DISTANCE:
				attempts += 1
				continue
			else:
				found_good_spot = true
		
		if found_good_spot or hill_node.runners.size() == 0:
			runner.position = spawn_location
			hill_node.runners.append(runner)
			add_child(runner)
			attempts = 0
				
		if attempts == MAX_SPAWN_ATTEMPTS:
			break
