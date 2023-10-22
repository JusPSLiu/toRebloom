extends Node

var unlockedLevel : int = 0


func _ready():
	var save_file = FileAccess.open("user://rebloom_game.save", FileAccess.READ)
	if (save_file != null):
		unlockedLevel = save_file.get_as_text().to_int()

func write_save_data():
	var save_file = FileAccess.open("user://rebloom_game.save", FileAccess.WRITE)
	save_file.store_string("%s" % unlockedLevel)

