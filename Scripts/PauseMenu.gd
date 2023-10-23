extends Control
signal close_settings

@export var sound_slider_stop_time := 0.5
@export var soundSlider : HSlider
@export var soundPlayer : AudioStreamPlayer
@export var buttonSoundPlayer : AudioStreamPlayer
@export var musicSlider : HSlider
@export var pauseButton : Button
@export var transition : AnimationPlayer

#settingUp variable so when loading, doesn't play sounds
var settingUp : bool = true
var timer : float = 0

func _ready():
	#make music and sound variables
	var musicVolume : float = AudioServer.get_bus_volume_db(1)
	var soundVolume : float = AudioServer.get_bus_volume_db(2)
	#set to music and sound variables iff not null
	if (musicVolume != null):
		musicSlider.value = (db_to_linear(musicVolume))
	if (soundVolume != null):
		soundSlider.value = (db_to_linear(soundVolume))

func _on_h_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(1, linear_to_db(value))


func _on_sound_slider_value_changed(value):
	AudioServer.set_bus_volume_db(2, linear_to_db(value))
	if (settingUp):
		settingUp = false
	else:
		timer = sound_slider_stop_time
		soundPlayer.volume_db = 16;
		if (!soundPlayer.playing):
			soundPlayer.play()

func _on_pause_menu_pressed() -> void:
	emit_signal("close_settings")
	visible

func _process(delta):
	if (timer > 0):
		timer -= delta;
	elif (soundPlayer.playing):
		if (soundPlayer.volume_db > -60):
			soundPlayer.volume_db -= delta*100;
		else:
			soundPlayer.stop()

func _input(event: InputEvent) -> void:
	if event is InputEventKey and !event.is_echo():
		if (event.keycode == KEY_ESCAPE):
			if event.pressed:
				togglePauseFall();

func togglePauseFall():
	buttonSoundPlayer.play()
	get_tree().paused = !get_tree().paused
	visible = !visible
	if (get_tree().paused):
		pauseButton.text = ">"
	else:
		pauseButton.text = "II"


func _on_title_pressed():
	get_tree().paused = false
	transition.play("SlideToBlack")
	await transition.animation_finished
	get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")

func actvatePauseButton():
	pauseButton.show();
	pauseButton.process_mode = Node.PROCESS_MODE_ALWAYS
