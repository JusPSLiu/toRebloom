extends Sprite2D

@export var timerLength : float = 4
@export var animationPlayer : AnimationPlayer
@export var audioPlayer : AnimationPlayer

var timer : float
var bweeOn : bool = false
var playerBody : Node2D
var playerIsHere : bool = false
var blinking : bool = false
var loaded : bool = false
var manualActivation = false

# Called when the node enters the scene tree for the first time.
func _ready():
	timer = 0


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if (loaded):
		timer -= delta
		if (timer > 0):
			if (playerIsHere and timer < timerLength-0.1):
				playerBody.die()
				playerIsHere = false
			if (!bweeOn):
				animationPlayer.play("Bwee")
				#play the sound if not manually activated
				if (!manualActivation):
					audioPlayer.play("Bwee")
				bweeOn = true
				blinking = false
		elif (timer > -timerLength):
			if (bweeOn):
				animationPlayer.play("fadeBweeOut")
				#play the sound if not manually activated
				if (!manualActivation):
					audioPlayer.play("fadeBweeOut")
				bweeOn = false
			elif (!blinking && timer <= 2-timerLength):
				animationPlayer.play("blinkyStarting")
				blinking = true
		else:
			timer = timerLength


func _on_area_2d_body_entered(body):
	if body is CharacterBody2D:
		playerBody = body
		playerIsHere = true

func _on_laser_hitbox_body_exited(body):
	if body is CharacterBody2D:
		playerBody = body
		playerIsHere = false

func _on_load(area):
	if !manualActivation and area.is_in_group("loadedRegion"):
		loaded = true
		animationPlayer.play("RESET")


func _on_unload(area):
	if !manualActivation and area.is_in_group("loadedRegion"):
		loaded = false

func activate_manual_mode():
	manualActivation = true
