extends ColorRect

@export var buttonSounds : AudioStreamPlayer
@export var text : RichTextLabel
@export var speakerName : Label
@export var dialoguePlayer : AudioStreamPlayer
@export var lettersPerSecond : float
@export var currentDialogue : int
@export var PauseMenu : Control

var textCurrentlyDisplayed : float
var loadingIn : bool


# Called when the node enters the scene tree for the first time.
func _ready():
	get_tree().paused = true
	changeCurrentDialogue()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# if still loading in, then make the visible characters go up
	if (loadingIn):
		textCurrentlyDisplayed += delta
		text.set_visible_characters(round(textCurrentlyDisplayed*lettersPerSecond))
		if (text.visible_characters >= text.get_total_character_count()):
			loadingIn = false

func _input(event : InputEvent):
	if (event is InputEventKey and event.is_action_released("ui_accept")):
		if (loadingIn):
			textCurrentlyDisplayed = text.visible_characters * 0.4
		else:
			buttonSounds.play()
			currentDialogue += 1
			changeCurrentDialogue()

func setSpeaker(speaker : int):
	match(speaker):
		0:
			speakerName.text = "Commander"
		1:
			speakerName.text = "Robertson"
		2, 3:
			speakerName.text = "Scientist"

func closeDialogue():
	#activate the UI
	PauseMenu.process_mode = Node.PROCESS_MODE_ALWAYS
	PauseMenu.actvatePauseButton()
	
	#unpause the game
	get_tree().paused = false
	queue_free()

# giant monstrous switch case for the dialogue
# I don't know how godot implements it so for all I know it's as intensive as an if-else, but it should be fine
# probably.
func changeCurrentDialogue():
	#tell process that it's loading in
	loadingIn = true
	#reset the visibility
	text.visible_characters = 0
	textCurrentlyDisplayed = 0
	
	# update the dialogue
	match(currentDialogue):
		0:
			text.text = "Robertson. Come in, Robertson."
			setSpeaker(0)
		1:
			text.text = "Huh? Yeah?"
			setSpeaker(1)
		2:
			text.text = "You have to complete this mission."
			setSpeaker(0)
		3:
			text.text = "You've done the least of all of us, on account of your hearing problems, and as such you're not on their watchlist."
			setSpeaker(0)
		4:
			text.text = "Listen, I don't like this any more than you do, but at this point, we have little other choice."
			setSpeaker(0)
		5:
			text.text = "Head out there, for the fate of the world rests upon your back."
			setSpeaker(0)
		6:
			text.text = "Alright then."
			setSpeaker(1)
		7:
			closeDialogue()


