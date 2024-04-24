extends Node2D

signal title_done

var extra_cheese_timer
var darkness_timer
var time_one_way

func _ready():
	time_one_way = 2.5

	$Splash.modulate.a = 0
	$NewSplash.modulate.a = 0

	$ExtraCheese.stream = load("res://sfx/extra_cheese.wav")
	
	await get_tree().create_timer(time_one_way).timeout
	
	var tween = create_tween()
	tween.tween_property($Splash, "modulate:a", 1, time_one_way)
	tween.play()
	await tween.finished
	await get_tree().create_timer(1).timeout
	await create_tween().tween_property($NewSplash, "modulate:a", 1, time_one_way).finished
	$ExtraCheese.play()
	$Splash.modulate.a = 0
	$Splash.visible = false
	await get_tree().create_timer(2).timeout
	await create_tween().tween_property($NewSplash, "modulate:a", 0, time_one_way).finished
	emit_signal("title_done")
