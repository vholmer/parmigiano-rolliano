extends Node2D

var slides = []

var slide_index = -1

const SECONDS_PER_SLIDE_CHANGE = 1
const SECONDS_PER_SLIDE = 5

var just_skipped = false
var transitioning = false

signal skip
signal intro_done

# Called when the node enters the scene tree for the first time.
func _ready():
	slides = [
		$Intro1,
		$Intro2,
		$Intro3,
		$Intro4,
		$Intro5,
		$Intro6
	]
	
	$Intro1.modulate.a = 0
	$Intro2.modulate.a = 0
	$Intro3.modulate.a = 0
	$Intro4.modulate.a = 0
	$Intro5.modulate.a = 0
	$Intro6.modulate.a = 0
	$SlideTimer.connect("timeout", next_slide)
	
	self.connect("skip", skip_slide)
	
	next_slide()
	
func skip_slide():
	if not transitioning and not just_skipped:
		just_skipped = true
			
		$SlideTimer.stop()
		$SlideTimer.wait_time = SECONDS_PER_SLIDE
		
		slides[0].modulate.a = 0
		
		if slide_index < slides.size() - 1:
			next_slide()
		else:
			emit_signal("intro_done")
	
func _process(delta):
	if Input.is_action_just_pressed("jump"):
		emit_signal("skip")

func next_slide():
	# If not first slide, fade out the previous slide.
	if slide_index > -1 and not just_skipped:
		var tween = create_tween()
		tween.tween_property(slides[slide_index - 1], "modulate:a", 0, SECONDS_PER_SLIDE_CHANGE)
		tween.play()
		transitioning = true
		await tween.finished
		transitioning = false

	if just_skipped:
		just_skipped = false
	
	$SlideTimer.wait_time = SECONDS_PER_SLIDE
	
	# If not the last slide, fade in the next slide.
	if slide_index < slides.size() - 1:
		slide_index += 1
		
		var tween = create_tween()
		tween.tween_property(slides[slide_index], "modulate:a", 1, SECONDS_PER_SLIDE_CHANGE)
		tween.play()
		transitioning = true
		await tween.finished
		transitioning = false
	
		$SlideTimer.start()
	else: # Final slide
		for slide in slides:
			if slide.modulate.a != 0:
				var tween = create_tween()
				tween.tween_property(slide, "modulate:a", 0, SECONDS_PER_SLIDE_CHANGE)
				tween.play()
		
		var musictween = create_tween()
		musictween.tween_property($Music, "volume_db", -80, SECONDS_PER_SLIDE_CHANGE)
		musictween.play()
		
		await musictween.finished
		
		emit_signal("intro_done")
