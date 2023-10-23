extends CharacterBody2D


@export var timeToWaitForIgnoring : float
@export var instructions : Label
@export var shoutPlayer : AudioStreamPlayer
@export var soundPlayer : AudioStreamPlayer2D
@export var headAnimationPlayer : AnimationPlayer
@export var bodyAnimationPlayer : AnimationPlayer
@export var body : Node2D
@export var deathParticle : CPUParticles2D
@export var pauseMenu : Control
@export var transition : AnimationPlayer
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
# a boolean for whether or not the level has been finished
var stopShouting : bool

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
#checkpoint variables
var checkpointLocation : Vector2

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta * 1.5
		if (coyoteTimer > 0):
			coyoteTimer -= delta
	elif (!stopShouting): #do this next part if you haven't won the level yet
		coyoteTimer = coyoteTime
		if (movingRight != wantToMoveRight):
			scale.x *= -1
			bodyAnimationPlayer.play("walking")
		elif (moving != wantToMove):
			moving = wantToMove
			if (moving):
				bodyAnimationPlayer.play("walking")
			else:
				bodyAnimationPlayer.play("RESET")
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
			addCommand(3) #3 means jump

	# Get the input direction and handle the desired movement
	if Input.is_action_just_pressed("ui_right"):
		if (!commandList.has(1)):
			addCommand(1) #1 means right
	elif Input.is_action_just_pressed("ui_left"):
		if (!commandList.has(2)):
			addCommand(2) #2 means left
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
			addCommand(4) #4 means stop
	#actually jump if want to jump :D
	if (wantToJump && coyoteTimer > 0):
		wantToJump = false
		velocity.y = JUMP_VELOCITY
		coyoteTimer = 0
	
	move_and_slide()
	
	
	#if not speaking and next command then shout it
	if (!shoutPlayer.playing && commandList.size() > 0 && !stopShouting):
		#actually apply the inputs now. finally.
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


func addCommand(num : int):
	if (commandList.size() > 0 && num != 3):
		# if there's a jump, then there's probably some strategy going on
		# I don't want to interrupt that
		if (commandList[commandList.size()-1] == 3):
			commandList.push_back(num)
			return
	#so now cancel out all commands that are before since they're not jumps
	commandList.pop_back()
	commandList.push_back(num)


func disableControl():
	stopShouting = true

func setLastCheckpointLocation(location : Vector2):
	checkpointLocation = location

func die():
	#make sure you don't move when you die
	moving = false
	wantToMove = false
	stopShouting = true
	bodyAnimationPlayer.play("RESET")
	
	#emit particles, disable pause menu
	body.hide()
	deathParticle.emitting = true
	soundPlayer.set_stream(load("res://Sounds/death.ogg"))
	soundPlayer.play()
	pauseMenu.process_mode = Node.PROCESS_MODE_DISABLED
	
	#play transition
	transition.play("deathReset")
	await transition.animation_finished
	
	#move and slide
	body.show()
	position = checkpointLocation
	transition.play("deathResetUncover")
	await transition.animation_finished
	#reenable pausing
	pauseMenu.process_mode = Node.PROCESS_MODE_ALWAYS
	stopShouting = false
