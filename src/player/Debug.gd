extends Sprite2D

@onready var target_node = $"../Character"
@onready var start_offset = self.transform.origin - target_node.transform.origin

func _process(delta):
	self.transform.origin = target_node.transform.origin + start_offset
	self.rotation = target_node.rotation
