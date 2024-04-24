extends RemoteTransform2D

@onready var target_node = $".."
@onready var timer_node = $"../../JumpTimer"

var initial_ground_position = 0

func _physics_process(delta):
	position.x = target_node.position.x
	
	# Calculate height based on distance to target_node (the shadow's) position.y.
	var height = target_node.position.y - position.y
	
	# If the ground's position has changed since the last frame
	if target_node.position.y != initial_ground_position:
		# Calculate the change in position
		var ground_movement = target_node.position.y - initial_ground_position
		
		# Update the initial_ground_position to match the new ground position
		initial_ground_position = target_node.position.y
		
		# Adjust the RemoteTransform2D's position by the same amount
		position.y += ground_movement
	
	if height < 0 and target_node.is_in_air and timer_node.time_left == 0:
		position.y = target_node.position.y
		target_node.is_in_air = false
		target_node.current_jump_speed = 0
	elif target_node.current_jump_speed == 0 and not target_node.is_in_air:
		position.y = target_node.position.y
	else:
		position.y += delta * target_node.current_jump_speed
