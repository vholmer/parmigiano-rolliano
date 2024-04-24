extends Node2D

signal spawn_bg
signal moved_two_lanes

var is_spawn_master = false
var emitted = false
var prev_pos_x
var diff_x = 0

@onready var background_speed = $"..".BACKGROUND_SPEED

const LANE_WIDTH = 130

func _ready():
	prev_pos_x = global_position.x

func _process(delta):
	position.x -= background_speed * delta
	
	diff_x = prev_pos_x - global_position.x

	if global_position.x <= -640 and not emitted:
		spawn_bg.emit()
		emitted = true
	
	var width = 1560
	var screen_width = 640
	var extra = 1560 - 640
	
	if diff_x >= 2 * LANE_WIDTH and is_spawn_master:
		moved_two_lanes.emit()
		prev_pos_x = global_position.x
