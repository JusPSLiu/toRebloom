extends CharacterBody2D


@export var timeToWaitForIgnoring : float


const SPEED = 300.0
@export var JUMP_VELOCITY = -400.0

#inertia variables
var moving : bool = false
var movingRight : bool = false

#more directly controlled variables
var wantToMoveRight : bool = false
var wantToMove : bool = false

var timer : float = 0
var prevPositionx = 0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")


func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		#if on the ground, then can change direction
		moving = wantToMove
		movingRight = wantToMoveRight
	
	#if moving then move
	if moving:
		if movingRight:
			velocity.x = SPEED
		else:
			velocity.x = -SPEED
	else:
		velocity.x = 0
	
	#decrement timer
	if (timer > 0):
		timer -= delta
		#but dont let it get too smol
		if (timer < 0):
			timer = 0

	# Handle Jump.
	if Input.is_action_just_pressed("ui_up") and is_on_floor():
		if (timer > 0):
			velocity.y = JUMP_VELOCITY
		else:
			timer = timeToWaitForIgnoring

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	if Input.is_action_just_pressed("ui_right"):
		if (timer > 0):
			wantToMove = true
			wantToMoveRight = true
		else:
			timer = timeToWaitForIgnoring
	elif Input.is_action_just_pressed("ui_left"):
		if (timer > 0):
			wantToMove = true
			wantToMoveRight = false
		else:
			timer = timeToWaitForIgnoring
	elif moving && wantToMove:
		if (position.x == prevPositionx):
			wantToMove = false
		else:
			prevPositionx = position.x
	
	if Input.is_action_just_pressed("ui_down"):
		wantToMove = false

	move_and_slide()
