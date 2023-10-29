extends Sprite2D

@export var timerLength : float = 4
@export var animationPlayer : AnimationPlayer
@export var numOfLasers : int
@export var direction : Vector2 = Vector2(1, 0)

const laser = preload("res://Scenes/Effectors/laserblock.tscn")
var timer : float
var bweeOn : bool = false
var playerBody : Node2D
var playerIsHere : bool = false
var blinking : bool = false
var loaded : bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	timer = 0
	for num in numOfLasers:
		var newKid = laser.instantiate()
		newKid.activate_manual_mode()
		add_child(newKid)
		newKid.position += direction * (64*(num+1))
		newKid.timerLength = timerLength


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
				bweeOn = true
				blinking = false
		elif (timer > -timerLength):
			if (bweeOn):
				animationPlayer.play("fadeBweeOut")
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
	if area.is_in_group("loadedRegion"):
		loaded = true
		animationPlayer.play("RESET")
		for kid in get_children():
			if (kid.is_in_group("Effector")):
				kid.loaded = true
				kid.timer = timer

func _on_unload(area):
	if area.is_in_group("loadedRegion"):
		loaded = false
		for kid in get_children():
			if (kid.is_in_group("Effector")):
				kid.loaded = false
