extends AnimatableBody2D

@onready var character_node = $"../Player/Character"
@onready var ground_speed = character_node.GROUND_SPEED
@onready var plane_angle = character_node.plane_angle

func _ready():
	$Sprite.z_as_relative = false
	
	if self.name == "GroundEater":
		$Sprite.frame = randi_range(0, 34)

func _physics_process(delta):
	# All obstacles behave in the same way, they move along plane_angle until outside screen
	position += delta * ground_speed * Vector2.from_angle(PI - plane_angle)

	$Sprite.z_index = max(1, global_position.y)
