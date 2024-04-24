extends Node2D

var logo_playing_forwards

var menu_positions_left = [
	Vector2(258, 255),
	Vector2(259, 283),
	Vector2(261, 311)
]

var menu_positions_right = [
	Vector2(379, 255),
	Vector2(359, 283),
	Vector2(357, 311)
]

const BACKGROUND_SPEED = 80

var bgs = []
var cheeses = []

var menu_index = 0

var in_help = false

@onready var main_node = $".."

func _ready():
	logo_playing_forwards = true
	
	$Logo.play()
	$Logo.connect("animation_finished", start_logo_timer)
	$LogoTimer.connect("timeout", loop_logo_animation)
	
	$LeftSelect.play()
	$RightSelect.play()
	
	$Music.connect("finished", loop_music)
	$Music.play()
	
	$Background.connect("spawn_bg", spawn_new_background)
	$Background.connect("moved_two_lanes", $SpawnerSpawner1.spawn)
	$Background.connect("moved_two_lanes", $SpawnerSpawner2.spawn)
	bgs.append($Background)
	
func loop_music():
	$Music.play()

func spawn_new_background():
	# Spawn new background at position 1560 - 640!
	var new_bg = load("res://src/menu/Background.tscn").instantiate()
	new_bg.global_position.x = 1560 - 640 - 1
	new_bg.z_index = 0
	new_bg.z_as_relative = false
	new_bg.connect("spawn_bg", spawn_new_background)
	new_bg.connect("moved_two_lanes", $SpawnerSpawner1.spawn)
	new_bg.connect("moved_two_lanes", $SpawnerSpawner2.spawn)
	bgs.append(new_bg)
	add_child(new_bg)

func _process(delta):
	var lowest_x = INF
	var lowest_bg
	
	for bg in bgs:
		if bg.global_position.x < lowest_x:
			lowest_bg = bg
			lowest_x = bg.global_position.x
	
	if lowest_bg:
		lowest_bg.is_spawn_master = true
	
	for bg in bgs:
		if bg.global_position.x <= -1560 * 2:
			bgs.erase(bg)
			bg.queue_free()
	
	if Input.is_action_pressed("exit") and OS.is_debug_build():
		get_tree().quit()
	
	var choice = fposmod(menu_index, 3)
	
	if Input.is_action_just_pressed("turn_left"): # Up
		if not in_help:
			menu_index -= 1
			$Menu.play()
	elif Input.is_action_just_pressed("turn_right"): # Down
		if not in_help:
			menu_index += 1
			$Menu.play()
	elif Input.is_action_just_pressed("jump"): # Select
		$Select.play()
		if in_help:
			for cheese in cheeses:
				cheese.visible = true
			$Sublogo.visible = true
			$Logo.visible = true
			$LeftSelect.visible = true
			$RightSelect.visible = true
			$Help.visible = false
			$CollectJem.visible = false
			in_help = false
		else:
			if choice == 0: # Start
				main_node.start_hill()
			elif choice == 1: # Help
				# Hide all cheeses in help screen
				for cheese in cheeses:
					cheese.visible = false
				$Sublogo.visible = false
				$Logo.visible = false
				$LeftSelect.visible = false
				$RightSelect.visible = false
				$Help.visible = true
				$CollectJem.visible = true
				in_help = true
			elif choice == 2: # Quit
				get_tree().quit()
	
	$LeftSelect.position = menu_positions_left[choice]
	$RightSelect.position = menu_positions_right[choice]
func start_logo_timer():
	logo_playing_forwards = not logo_playing_forwards
	$LogoTimer.start()

func loop_logo_animation():
	if logo_playing_forwards:
		$Logo.play()
	else:
		$Logo.play_backwards()
