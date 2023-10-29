extends CharacterBody2D


@export var timeToWaitForIgnoring : float
@export var instructions : Label
@export var shoutPlayer : AudioStreamPlayer
@export var soundPlayer : AudioStreamPlayer2D
@export var headAnimationPlayer : AnimationPlayer
@export var bodyAnimationPlayer : AnimationPlayer
@export var body : Node2D
@export var deathParticle : CPUParticles2D
@export var Camera : Camera2D
@export var pauseMenu : Control
@export var pauseButton : Button
@export var transition : AnimationPlayer
@export var JUMP_VELOCITY = -600.0
@export var coyoteTime = 0.4
# a boolean for whether or not the level has been finished
@export var stopShouting : bool
const SPEED = 300.0

#inertia variables
var moving : bool = false
var movingRight : bool = true
var coyoteTimer : float = 0

#more directly controlled variables
var wantToMoveRight : bool = true
var wantToMove : bool = false
var wantToJump : bool = false
var headTurnedTowards : bool = true

var timer : float = 0
var prevPositionx = 0
var deletedPrompt = false
# make a queue for unfinished commands
var commandList : Array[int]

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
#checkpoint variables
var checkpointLocation : Vector2

func _ready():
	checkpointLocation = position

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
		if (timer < 0.2):
			if (headTurnedTowards):
				headAnimationPlayer.play("turnHeadAway")
				headTurnedTowards = false
			
			if (timer < 0):
				timer = 0
	elif (headTurnedTowards):
		headAnimationPlayer.play("turnHeadAway")
		headTurnedTowards = false
	# Handle Jump.
	if Input.is_action_just_pressed("ui_up"):
		if (!commandList.has(3)):
			commandList.push_back(3) #3 means jump
			#do it without the function because then i don't have to write any if statements for this edge case

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
					shoutPlayer.set_stream(load("res://Sounds/orders/rightc.ogg"))
				if (!headTurnedTowards):
					headAnimationPlayer.play("turnHeadToward")
					headTurnedTowards = true
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
					shoutPlayer.set_stream(load("res://Sounds/orders/leftc.ogg"))
				if (!headTurnedTowards):
					headAnimationPlayer.play("turnHeadToward")
					headTurnedTowards = true
				#now he's paying attention
				timer = timeToWaitForIgnoring
				shoutPlayer.play()
			3: # 3 means jump
				#if paying attention make him jump
				if (timer > 0):
					shoutPlayer.set_stream(load("res://Sounds/orders/jumph.ogg"))
					wantToJump = true
				else:
					shoutPlayer.set_stream(load("res://Sounds/orders/jumpc.ogg"))
				if (!headTurnedTowards):
					headAnimationPlayer.play("turnHeadToward")
					headTurnedTowards = true
				timer = timeToWaitForIgnoring
				shoutPlayer.play()
			4: # 4 means stop
				if (!headTurnedTowards):
					headAnimationPlayer.play("turnHeadToward")
					headTurnedTowards = true
				shoutPlayer.set_stream(load("res://Sounds/orders/stop.ogg"))
				shoutPlayer.play()
				wantToMove = false
				timer = timeToWaitForIgnoring
		commandList.pop_front()


func addCommand(num : int):
	if (commandList.size() > 0):
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
	#if not dead and not exiting level, set new checkpoint
	if (!stopShouting):
		checkpointLocation = location

func die():
	#make sure you don't move when you die
	#RESET EVERYTHING
	moving = false
	wantToMove = false
	wantToJump = false
	stopShouting = true
	wantToMoveRight = true
	set_physics_process(false)
	if (!movingRight):
		movingRight = true
		scale.x *= -1
	bodyAnimationPlayer.play("RESET")
	for num in commandList.size():
		commandList.remove_at(0)
	
	#emit particles, disable pause menu
	body.hide()
	deathParticle.emitting = true
	soundPlayer.set_stream(load("res://Sounds/death.ogg"))
	soundPlayer.play()
	pauseMenu.disablePausing = true
	pauseMenu.process_mode = Node.PROCESS_MODE_DISABLED
	pauseButton.process_mode = Node.PROCESS_MODE_DISABLED
	pauseButton.hide()
	
	#play transition
	transition.play("deathReset")
	await transition.animation_finished
	
	#move and slide
	body.show()
	pauseButton.show()
	Camera.position_smoothing_enabled = false
	position = checkpointLocation
	Camera.position_smoothing_enabled = false
	transition.play("deathResetUncover")
	await transition.animation_finished
	#reenable pausing
	pauseMenu.process_mode = Node.PROCESS_MODE_ALWAYS
	pauseButton.process_mode = Node.PROCESS_MODE_ALWAYS
	pauseMenu.disablePausing = false
	stopShouting = false
	set_physics_process(true)
