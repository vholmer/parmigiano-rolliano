extends AnimatedSprite2D

@onready var character_node = $"../../Character"

func _ready():
	autoplay = "roll"

func _process(delta):
	z_index = max(1, character_node.z_index)
