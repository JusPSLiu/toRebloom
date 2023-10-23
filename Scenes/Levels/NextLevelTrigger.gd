extends Area2D

@export var nextLevelName : String = "garden"
@export var transition : AnimationPlayer
@export var musicAnimator : AnimationPlayer
@export var pauseMenu : Control

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_body_entered(body):
	if (body is CharacterBody2D):
		body.disableControl()
		#disable the pause menu
		pauseMenu.process_mode = Node.PROCESS_MODE_DISABLED
		#make the music fade out
		musicAnimator.play("fadeOut")
		#transition to the next level
		transition.play("SlideToBlack")
		await transition.animation_finished
		get_tree().change_scene_to_file("res://Scenes/Levels/"+nextLevelName+"_level.tscn")
