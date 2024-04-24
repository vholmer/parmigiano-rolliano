extends Node2D

@onready var character_node = $"../Player/Character"
@onready var ground_speed = character_node.GROUND_SPEED
@onready var plane_angle = character_node.plane_angle

func move_ground(delta):
	position += delta * ground_speed * Vector2.from_angle(PI - plane_angle)
