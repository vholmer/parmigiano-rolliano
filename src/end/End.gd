extends Node2D

var flavor = 0
var emitted = false
var played_sound = false

var start_time_ms

signal play_again

# Called when the node enters the scene tree for the first time.
func _ready():
	start_time_ms = Time.get_ticks_msec()
	
	$Music.connect("finished", loop_music)
	$Music.play()
	
	$Accept.modulate.a = 0
	$AcceptText.modulate.a = 0
	$Reject.modulate.a = 0
	$RejectText.modulate.a = 0
	$Dead.modulate.a = 0
	$DeadText.modulate.a = 0
	
	$Thanks.modulate.a = 0
	
	$Accept.connect("animation_finished", show_accept_text)
	$Reject.connect("animation_finished", show_reject_text)
	$Dead.connect("animation_finished", show_dead_text)
	
	flavor = $"..".flavor
	
	if flavor < 33:
		$Dead.modulate.a = 1
		$Dead.frame = 11
		await get_tree().create_timer(4).timeout
		$Dead.frame = 0
		$Dead.play()
	elif flavor < 80:
		$Reject.modulate.a = 1
		await get_tree().create_timer(4).timeout
		$Reject.play()
	elif flavor >= 80:
		$Accept.modulate.a = 1
		$Accept.frame = 28
		await get_tree().create_timer(4).timeout
		$Accept.frame = 0
		$Accept.play()

func show_accept_text():
	$AcceptText.modulate.a = 1
	$Thanks.modulate.a = 1
	
func show_dead_text():
	$DeadText.modulate.a = 1
	$Thanks.modulate.a = 1
	
func show_reject_text():
	$RejectText.modulate.a = 1
	$Thanks.modulate.a = 1

func loop_music():
	$Music.play()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if $Dead.frame == 5 and not played_sound:
		$Splat.play()
		played_sound = true
		
	if $Reject.frame == 23 and not played_sound:
		$Splat.play()
		played_sound = true
		
	if $Accept.frame == 20 and not played_sound:
		$Fanfare.play()
		played_sound = true
	
	if Input.is_action_just_pressed("jump") and played_sound:
		if not emitted:
			play_again.emit()
