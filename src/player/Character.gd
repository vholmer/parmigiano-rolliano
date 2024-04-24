extends CharacterBody2D

const ROTATION_DRIFT_SPEED = 1 # how quickly rotation drifts to plane angle
const JUMP_SPEED = -300 # jump impulse speed
const UPHILL_SPEED = 80 # speed of player drifting uphill
const GROUND_SPEED = 300 # speed of the ground rushing past
const GRAVITY = 600
const SPEED = 300 # speed of player movement
const DECELERATION_SPEED = -0.5 # speed of player deceleration
const ROTATION_SPEED = 3
const DAMAGE_PER_OBSTACLE_HIT = 10
const BOUNCE_STRENGTH = 10
const VICTORY_SPEED = SPEED * 2

const OBSTACLE_LAYER_ID = 2
const CROWD_LAYER_ID = 3
const PICKUP_LAYER_ID = 4

# Plane angle in radians
var plane_angle = -0.46365

var min_rotation_dir = -PI/6 - plane_angle
var max_rotation_dir = PI/4 - plane_angle

var fullscreened = false
var is_in_air = false
var current_jump_speed = 0

var accelerating = false
var decelerating = false
var input_locked = false
var fanfare_played = false

var rotation_direction = 0

var gnome_transforms = []

var obstacle_collision_sounds = [
	load("res://sfx/misc/bonk1.wav"),
	load("res://sfx/misc/bonk2.wav"),
	load("res://sfx/misc/bonk3.wav"),
	load("res://sfx/misc/bonk4.wav"),
	load("res://sfx/misc/bonk5.wav"),
	load("res://sfx/misc/bonk6.wav"),
	load("res://sfx/misc/bonk7.wav"),
	# load("res://sfx/misc/bonk8.wav"), # Identical to 14
	load("res://sfx/misc/bonk9.wav"),
	load("res://sfx/misc/bonk10.wav"),
	# load("res://sfx/misc/bonk12.wav"), # Doesn't fit other sounds
	load("res://sfx/misc/bonk13.wav"),
	load("res://sfx/misc/bonk14.wav"),
	load("res://sfx/misc/bonk15.wav"),
	# load("res://sfx/misc/bonk16.wav"), # Identical to 18
	load("res://sfx/misc/bonk17.wav"),
	# load("res://sfx/misc/bonk18.wav"), # Doesn't fit other sounds
	load("res://sfx/misc/bonk19.wav")
]

var pickup_sounds = [
	load("res://sfx/misc/splat.wav"),
	load("res://sfx/misc/splat2.wav")
]

var jump_sounds = [
	load("res://sfx/gnomes/gnome1.wav"),
	load("res://sfx/gnomes/gnome2.wav"),
	load("res://sfx/gnomes/gnome3.wav"),
	load("res://sfx/gnomes/gnome4.wav"),
	load("res://sfx/gnomes/gnome5.wav"),
	load("res://sfx/gnomes/gnome6.wav"),
	load("res://sfx/gnomes/gnome7.wav"),
	load("res://sfx/gnomes/gnome8.wav"),
	load("res://sfx/gnomes/gnome9.wav"),
	load("res://sfx/gnomes/gnome10.wav")
]

var blink_visible
var invincible
var flavor: float

@onready var blink_timer = $"../BlinkTimer"
@onready var inv_timer = $"../InvincibilityTimer"
@onready var cheese_sprite = $"../Cheese/Sprite"
@onready var shadow_sprite = $"../Shadow"
@onready var transform_node = $"Transform"
@onready var main_node = $"../../.."
@onready var hill_node = $"../.."
@onready var player_node = $".."

var gnome_scene = load("res://src/player/Gnome.tscn")

var sent_killed_signal = false

signal released_left
signal released_right
signal released_push
signal released_stop
signal jumped

signal killed

# Called when the node enters the scene tree for the first time.
func _ready():
	shadow_sprite.modulate.a = 0.7
	
	if OS.is_debug_build():
		$"../Debug".visible = false
	else:
		$"../Debug".visible = false
	
	rotation = PI/8
	
	blink_visible = true
	invincible = false
	flavor = 0
	
	blink_timer.connect("timeout", toggle_blink)
	inv_timer.connect("timeout", disable_invincibility)
	
	if fullscreened:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)

func toggle_blink():
	if blink_visible:
		cheese_sprite.modulate.a = 0
		blink_visible = false
	else:
		cheese_sprite.modulate.a = 1
		blink_visible = true
	blink_timer.start()
	
func disable_invincibility():
	invincible = false
	blink_visible = true
	blink_timer.stop()
	blink_timer.wait_time = 0.1
	cheese_sprite.modulate.a = 1

func spawn_gnome(gnome_scene, sprite_name, num_gnomes, offsets, flips = []):
	for i in range(num_gnomes):
		
		var gnome = gnome_scene.instantiate()
		var sprite = gnome.get_node(sprite_name)
		
		var offset = offsets[i]
		
		gnome.offset = offset
		
		sprite.visible = true
		sprite.z_index = z_index + offset.y
		sprite.play("spawn")
		
		if flips:
			sprite.flip_h = flips[i]
		
		hill_node.gnomes.append(gnome)
		player_node.add_child(gnome)
		
		var transform = RemoteTransform2D.new()
		
		add_child(transform)
		
		transform.update_position = true
		transform.update_rotation = false
		transform.use_global_coordinates = false
		transform.remote_path = str(gnome.get_path())
		
		transform.position = position + Vector2(offset.x, offset.y)
		
		gnome_transforms.append(transform)
		

func get_input():
	if input_locked:
		return
	
	if Input.is_action_pressed("exit") and OS.is_debug_build():
		get_tree().quit()
	
	if Input.is_action_just_pressed("fullscreen"):
		if !fullscreened:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
			fullscreened = true
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			fullscreened = false
	
	if not invincible:
		if Input.is_action_pressed("turn_left"):
			if cheese_sprite.animation != "left" and not is_in_air and not invincible:
				cheese_sprite.play("left")
				
				spawn_gnome(gnome_scene, "Left", 1, [Vector2(10, 20)])
			rotation_direction = -1
		elif Input.is_action_pressed("turn_right"):
			if cheese_sprite.animation != "right" and not is_in_air and not invincible:
				cheese_sprite.play("right")
				
				spawn_gnome(gnome_scene, "Right", 1, [Vector2(10, 15)])
			rotation_direction = 1
		elif Input.is_action_pressed("accelerate"):
			if not accelerating and not decelerating and not is_in_air and not invincible:
				accelerating = true
				decelerating = false
				spawn_gnome(gnome_scene, "Push", 1, [Vector2(-20, 2)])
		elif Input.is_action_pressed("decelerate"):
			if not accelerating and not decelerating and not is_in_air and not invincible:
				accelerating = false
				decelerating = true
				spawn_gnome(gnome_scene, "Stop", 1, [Vector2(14, 8)])
		elif not Input.is_anything_pressed():
			emit_signal("jumped") # Despawn all gnomes
			if cheese_sprite.animation != "roll":
				cheese_sprite.play("roll")
			rotation_direction = 0
			
		if Input.is_action_just_released("turn_left"):
			if cheese_sprite.animation == "left":
				cheese_sprite.play("roll")
			emit_signal("released_left")
		elif Input.is_action_just_released("turn_right"):
			if cheese_sprite.animation == "right":
				cheese_sprite.play("roll")
			emit_signal("released_right")
		elif Input.is_action_just_released("accelerate"):
			accelerating = false
			emit_signal("released_push")
		elif Input.is_action_just_released("decelerate"):
			decelerating = false
			emit_signal("released_stop")
			
		if Input.is_action_just_pressed("jump") and not is_in_air and $"../../InitialJumpTimer".time_left == 0:
			emit_signal("jumped")
			
			$"../JumpTimer".start()
			current_jump_speed = JUMP_SPEED
			is_in_air = true
			
			var jump_sound = jump_sounds.pick_random()
			$JumpSound.stream = jump_sound
			$JumpSound.play()
			
			var offsets = [
				Vector2(-10, -2),
				Vector2(18, 5)
			]
			
			spawn_gnome(gnome_scene, "Throw", 2, offsets, [false, true])
	
	if not invincible:
		var movement_x = clamp(Input.get_axis("decelerate", "accelerate"), DECELERATION_SPEED, 1)
		var movement_y = Input.get_axis("turn_left", "turn_right")
			
		velocity = transform.x * movement_x * SPEED + Vector2.from_angle(-plane_angle) * transform.y * movement_y * SPEED
	else:
		# Stuns the player while invincible
		velocity = transform.x

func _process(delta):
	z_index = max(1, global_position.y)
	
	# Convert bitwise layer 2^(layer_id - 1) to actual layer id
	var layer_id = 1 + log(OBSTACLE_LAYER_ID) / log(2)
	
	# If in air, then the shadow can move through any obstacle.
	if not input_locked:
		if is_in_air:
			set_collision_layer_value(layer_id, false)
			set_collision_mask_value(layer_id, false)
		else:
			set_collision_layer_value(layer_id, true)
			set_collision_mask_value(layer_id, true)
		
	for transform in gnome_transforms:
		if not has_node(transform.remote_path):
			gnome_transforms.erase(transform)
			transform.queue_free()

func _physics_process(delta):
	get_input()
	
	for transform in gnome_transforms:
		if has_node(transform.remote_path):
			var gnome = get_node(transform.remote_path)
			if not gnome.movable:
				transform.position = position + gnome.offset
	 
	if is_in_air:
		current_jump_speed += delta * GRAVITY
		
	if $"../JumpTimer".time_left == 0:
		var jump_tolerance = 0.01
		
		var jump_diff = abs(position.y - transform_node.position.y)
		
		if is_in_air and jump_diff <= jump_tolerance:
			current_jump_speed = 0
			is_in_air = false
	
	# Drift uphill slowly
	var corner_vec = Vector2.from_angle(PI - plane_angle).normalized()
	
	velocity += UPHILL_SPEED * corner_vec
	
	# Check collisions
	var collided_with_ids = []
	
	for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		
		var collider_name = collider.name
		
		# Convert bitwise layer 2^(layer_id - 1) to actual layer id
		var layer_id = 1 + log(collider.collision_layer) / log(2)
		
		var crowd_collision = layer_id == CROWD_LAYER_ID
		var obstacle_collision = layer_id == OBSTACLE_LAYER_ID
		var pickup_collision = layer_id == PICKUP_LAYER_ID
		
		if not is_in_air and not invincible and not input_locked:
			if obstacle_collision:
				# Play randomized sound here for collision
				var collision_sound = obstacle_collision_sounds.pick_random()
				$CollisionSound.stream = collision_sound
				$CollisionSound.play()
				
				# Subtract from flavor
				flavor = max(0, flavor - DAMAGE_PER_OBSTACLE_HIT)
				
				# Blink + invincibility
				blink_timer.start()
				inv_timer.start()
				invincible = true
				
				# Despawn all gnomes by emitting jumped signal, despawns all gnomes always
				emit_signal("jumped")
				
			if crowd_collision:
				if not sent_killed_signal:
					emit_signal("killed")
					sent_killed_signal = true
				
			if pickup_collision:
				if collider.get_instance_id() in collided_with_ids:
					continue
				else:
					collided_with_ids.append(collider.get_instance_id())
					flavor = min(hill_node.MAX_FLAVOR, flavor + 15)
					
					var pickup_sound = pickup_sounds.pick_random()
					$PickupSound.stream = pickup_sound
					$PickupSound.play()
					
					hill_node.pickups.erase(collider)
					hill_node.remove_child(collider)
					collider.queue_free()
	
	# Move
	if input_locked:
		if not fanfare_played:
			fanfare_played = true
			$Fanfare.play()
			inv_timer.wait_time = 20
			blink_timer.start()
			inv_timer.start()
			invincible = true
				
		if cheese_sprite.animation != "roll":
			cheese_sprite.play("roll")
		velocity = VICTORY_SPEED * Vector2.from_angle(-plane_angle)
	
	move_and_slide()
