extends Node2D

@onready var character_node = $"../Character"
@onready var ground_speed = character_node.GROUND_SPEED
@onready var plane_angle = character_node.plane_angle

var movable: bool = false

var offset: Vector2

# Called when the node enters the scene tree for the first time.
func _ready():
	$Left.connect("animation_finished", left_done)
	$Right.connect("animation_finished", right_done)
	$Stop.connect("animation_finished", stop_done)
	$Push.connect("animation_finished", push_done)
	$Throw.connect("animation_finished", throw_done)
	
	character_node.connect("released_left", released_left)
	character_node.connect("released_right", released_right)
	character_node.connect("released_push", released_push)
	character_node.connect("released_stop", released_stop)
	character_node.connect("jumped", jumped)
	
func _process(delta):
	if movable:
		position += delta * ground_speed * Vector2.from_angle(PI - plane_angle)

func jumped():
	if $Right.visible and $Right.animation != "despawn":
		movable = true
		$Right.play("despawn")
		
	if $Left.visible and $Left.animation != "despawn":
		movable = true
		$Left.play("despawn")
		
	if $Stop.visible and $Stop.animation != "despawn":
		movable = true
		$Stop.play("despawn")
		
	if $Push.visible and $Push.animation != "despawn":
		movable = true
		$Push.play("despawn")

func left_done():
	# We can check which animation finished here via 'animation'.
	if $Left.animation == "spawn":
		$Left.play("action")
	elif $Left.animation == "despawn":
		$Left.visible = false
	
func released_left():
	if $Left.animation == "action":
		movable = true
		$Left.play("despawn")
	
func right_done():
	if $Right.animation == "spawn":
		$Right.play("action")
	elif $Right.animation == "despawn":
		$Right.visible = false

func released_right():
	if $Right.animation == "action":
		movable = true
		$Right.play("despawn")
	
func stop_done():
	if $Stop.animation == "spawn":
		$Stop.play("start_action")
	elif $Stop.animation == "start_action":
		$Stop.play("action")
	elif $Stop.animation == "despawn":
		$Stop.visible = false
	
func released_stop():
	if $Stop.animation == "action" or $Stop.animation == "start_action":
		movable = true
		$Stop.play("despawn")
	
func push_done():
	if $Push.animation == "spawn":
		$Push.play("action")
	elif $Push.animation == "despawn":
		$Push.visible = false
	
func released_push():
	if $Push.animation == "action":
		movable = true
		$Push.play("despawn")
	
func throw_done():
	if $Throw.animation == "spawn":
		$Throw.play("action")
	elif $Throw.animation == "action":
		movable = true
		$Throw.play("despawn")
	elif $Throw.animation == "despawn":
		$Throw.visible = false
