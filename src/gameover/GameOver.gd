extends Node2D

signal retry

var retried = false

func _ready():
	$Music.connect("finished", loop_music)
	$Music.play()
	
func loop_music():
	$Music.play()

func _process(delta):
	if Input.is_action_just_pressed("jump") and not retried:
		retried = true
		emit_signal("retry")
