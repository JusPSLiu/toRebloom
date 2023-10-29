extends Control

@export var titleScreen : Control
@export var levelSelect : Control
@export var buttonSound : AudioStreamPlayer
@export var transition : AnimationPlayer
@export var levelSelectButtons : Array[Button]

@export var musicPlayer : AudioStreamPlayer

# Called when the node enters the scene tree for the first time.
func _ready():
	for num in GlobalVariables.unlockedLevel:
		levelSelectButtons[num].show()

func _on_start_button_pressed():
	buttonSound.play()
	if (GlobalVariables.unlockedLevel > 0):
		transition.play("fastDeathReset")
		await(transition.animation_finished)
		titleScreen.hide()
		levelSelect.show()
		transition.play("deathResetUncover")
	else:
		#play sound and make music and sounds fade out
		buttonSound.play()
		musicPlayer.fadeOut()
		#transition
		transition.play("SlideToBlack")
		await(transition.animation_finished)
		#change scene
		get_tree().change_scene_to_file("res://Scenes/Levels/garden_level.tscn")

func _on_level_selected(level : int):
	#play sound and make music and sounds fade out
	buttonSound.play()
	musicPlayer.fadeOut()
	#transition
	transition.play("SlideToBlack")
	await(transition.animation_finished)
	#change scene
	match(level):
		1:
			get_tree().change_scene_to_file("res://Scenes/Levels/first_level.tscn")
		2:
			get_tree().change_scene_to_file("res://Scenes/Levels/second_level.tscn")
		_:
			get_tree().change_scene_to_file("res://Scenes/Levels/garden_level.tscn")


func _on_back_button_pressed():
	buttonSound.play()
	transition.play("fastDeathReset")
	await(transition.animation_finished)
	titleScreen.show()
	levelSelect.hide()
	transition.play("deathResetUncover")
