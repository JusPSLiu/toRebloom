extends Control

@export var titleScreen : Control
@export var buttonSound : AudioStreamPlayer
@export var transition : AnimationPlayer

@export var musicPlayer : AudioStreamPlayer

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func _on_start_button_pressed():
	#play sound and make music and sounds fade out
	buttonSound.play()
	musicPlayer.fadeOut()
	#transition
	transition.play("SlideToBlack")
	await(transition.animation_finished)
	#change scene
	get_tree().change_scene_to_file("res://Scenes/Levels/garden_level.tscn")
