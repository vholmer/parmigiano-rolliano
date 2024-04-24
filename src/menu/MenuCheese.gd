extends Node2D

@export var flip_direction: bool

const MENU_CHEESE_SPEED = 100

var cheesuz = [
	load("res://gfx/menu/menuCheese_camembert.png"),
	load("res://gfx/menu/menuCheese_edamer.png"),
	load("res://gfx/menu/menuCheese_edamerOpen.png"),
	load("res://gfx/menu/menuCheese_parmesan.png")
]

var screen_rect = Rect2(-100, -100, 840, 560) # 640 x 360 + 100 pixel radius around it

# Called when the node enters the scene tree for the first time.
func _ready():
	$Sprite.texture = cheesuz.pick_random()

func _process(delta):
	if flip_direction:
		position.x += delta * MENU_CHEESE_SPEED# - delta * bg_speed
		position.y -= delta * MENU_CHEESE_SPEED
	else:
		position.x -= delta * MENU_CHEESE_SPEED# + delta * bg_speed
		position.y += delta * MENU_CHEESE_SPEED
