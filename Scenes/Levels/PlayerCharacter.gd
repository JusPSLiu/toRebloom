extends CharacterBody2D


@export var timeToWaitForIgnoring : float
@export var instructions : Label
@export var shoutPlayer : AudioStreamPlayer
@export var headAnimationPlayer : AnimationPlayer
@export var bodyAnimationPlayer : AnimationPlayer
@export var JUMP_VELOCITY = -600.0
@export var coyoteTime = 0.4
const SPEED = 300.0

#inertia variables
var moving : bool = false
var movingRight : bool = true
var coyoteTimer : float = 0

#more directly controlled variables
var wantToMoveRight : bool = true
var wantToMove : bool = false
var wantToJump : bool = false

var timer : float = 0
var prevPositionx = 0
var deletedPrompt = false
# make a queue for unfinished commands
var commandList : Array[int]

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")


func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta * 1.5
		if (coyoteTimer > 0):
			coyoteTimer -= delta
	else:
		coyoteTimer = coyoteTime
		if (movingRight != wantToMoveRight):
			scale.x *= -1
			bodyAnimationPlayer.play("walking")
		elif (moving != wantToMove):
			moving = wantToMove
			if (moving):
				bodyAnimationPlayer.play("walking")
			else:
				bodyAnimationPlayer.stop()
		#if on the ground, then can change direction
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
			headAnimationPlayer.play("turnHeadAway")

	# Handle Jump.
	if Input.is_action_just_pressed("ui_up"):
		if (!commandList.has(3)):
			commandList.push_back(3) #3 means jump

	# Get the input direction and handle the desired movement
	if Input.is_action_just_pressed("ui_right"):
		if (!commandList.has(1)):
			commandList.push_back(1) #1 means right
	elif Input.is_action_just_pressed("ui_left"):
		if (!commandList.has(2)):
			commandList.push_back(2) #2 means left
	#elif moving && wantToMove: #this part was frustrating so I removed it
		#if (position.x == prevPositionx && is_on_floor()):
			#wantToMove = false
		#else:
			#prevPositionx = position.x
	# if stop then immediately stop
	# it would be even more tedious if he were to keep going
	if Input.is_action_just_pressed("ui_down"):
		#as long as the last thing wasn't stop then you can add it
		if (commandList.size() == 0 || !commandList[commandList.size()-1] == 4):
			commandList.push_back(4) #4 means stop
	#actually jump if want to jump :D
	if (wantToJump && coyoteTimer > 0):
		wantToJump = false
		velocity.y = JUMP_VELOCITY
	
	move_and_slide()
	
	
	#if not speaking and next command then shout it
	if (!shoutPlayer.playing && commandList.size() > 0):
		match(commandList[0]):
			1: # 1 means right
				#if paying attention then move right
				if (timer > 0):
					#shout
					shoutPlayer.set_stream(load("res://Sounds/orders/righth.ogg"))
					#make him want to move
					wantToMove = true
					wantToMoveRight = true
					#if prompt not deleted then delete it
					if (!deletedPrompt):
						instructions.queue_free()
						deletedPrompt = true
				else:
					headAnimationPlayer.play("turnHeadToward")
					shoutPlayer.set_stream(load("res://Sounds/orders/rightc.ogg"))
				#now he's paying attention
				timer = timeToWaitForIgnoring
				shoutPlayer.play()
			2: # 2 means left
				#if paying attention then move left
				if (timer > 0):
					#play sound
					shoutPlayer.set_stream(load("res://Sounds/orders/lefth.ogg"))
					#make him want to move
					wantToMove = true
					wantToMoveRight = false
					#if prompt not deleted then delete it
					if (!deletedPrompt):
						instructions.queue_free()
						deletedPrompt = true
				else:
					headAnimationPlayer.play("turnHeadToward")
					shoutPlayer.set_stream(load("res://Sounds/orders/leftc.ogg"))
				#now he's paying attention
				timer = timeToWaitForIgnoring
				shoutPlayer.play()
			3: # 3 means jump
				#if paying attention make him jump
				if (timer > 0):
					shoutPlayer.set_stream(load("res://Sounds/orders/jumph.ogg"))
					wantToJump = true
				else:
					headAnimationPlayer.play("turnHeadToward")
					shoutPlayer.set_stream(load("res://Sounds/orders/jumpc.ogg"))
				timer = timeToWaitForIgnoring
				shoutPlayer.play()
			4: # 4 means stop
				if (timer <= 0):
					headAnimationPlayer.play("turnHeadToward")
				shoutPlayer.set_stream(load("res://Sounds/orders/stop.ogg"))
				shoutPlayer.play()
				wantToMove = false
				timer = timeToWaitForIgnoring
		commandList.pop_front()
