extends Node

var fullscreened
var hill_loaded

var menu_node
var character_node
var intro_node
var hill_node
var end_node
var game_over_node

var retry_count = 0
var flavor = 0

@export var RUN_INTRO_IN_DEBUG = false

func _ready():
	randomize()
	
	start_game()
	
	if fullscreened:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
		
func _process(delta):
	if not hill_loaded:
		if Input.is_action_just_pressed("fullscreen"):
			if !fullscreened:
				DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
				fullscreened = true
			else:
				DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
				fullscreened = false

func start_game():
	if !OS.is_debug_build() or RUN_INTRO_IN_DEBUG:
		var title = load("res://src/title/Title.tscn").instantiate()
		add_child(title)
		
		await title.title_done
		
		title.queue_free()
		
		intro_node = load("res://src/intro/Intro.tscn").instantiate()
		intro_node.connect("intro_done", intro_done)
		add_child(intro_node)
	else:
		menu_node = load("res://src/menu/Menu.tscn").instantiate()
		add_child(menu_node)

func intro_done():
	intro_node.queue_free()
	menu_node = load("res://src/menu/Menu.tscn").instantiate()
	add_child(menu_node)

func start_hill():
	if menu_node:
		menu_node.queue_free()
	
	hill_node = load("res://src/hill/Hill.tscn").instantiate()
	add_child(hill_node)

	hill_node.connect("finished_game", finished_game)
	character_node = hill_node.get_node("Player/Character")
	character_node.connect("killed", game_over)
	
	hill_loaded = true
	
func finished_game():
	flavor = character_node.flavor
	
	hill_node.queue_free()
	
	end_node = load("res://src/end/End.tscn").instantiate()
	end_node.connect("play_again", play_again)
	add_child(end_node)
	
func game_over():
	hill_node.queue_free()
	
	game_over_node = load("res://src/gameover/GameOver.tscn").instantiate()
	game_over_node.connect("retry", retry)
	add_child(game_over_node)
	
func retry():
	retry_count += 1
	game_over_node.queue_free()
	menu_node = load("res://src/menu/Menu.tscn").instantiate()
	add_child(menu_node)
	
func play_again():
	end_node.queue_free()
	
	menu_node = load("res://src/menu/Menu.tscn").instantiate()
	add_child(menu_node)
