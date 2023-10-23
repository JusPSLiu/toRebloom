extends Sprite2D

@export var timerLength : float = 4
@export var laserLight : ColorRect
@export var audioFader : AnimationPlayer

var timer : float
var bweeOn : bool = true
var playerBody : Node2D
var playerIsHere : bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	timer = timerLength


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	timer -= delta
	if (timer > 0):
		if (playerIsHere and timer > 0.1 and timer < timerLength-0.1):
			playerBody.die()
			playerIsHere = false
		if (!bweeOn):
			audioFader.play("Bwee")
			bweeOn = true
		laserLight.show()
	elif (timer > -timerLength):
		if (bweeOn):
			audioFader.play("fadeBweeOut")
			bweeOn = false
		laserLight.hide()
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
