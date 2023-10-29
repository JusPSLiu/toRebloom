extends TextureRect


@export var otherBackgrounds : Array[TextureRect]
@export var timeToSwop : float = 2

var currHue : float = 0
var timerForSwop : float = 0
var currBack : int = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	timerForSwop = 0


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	modulate.h += delta*0.01
	if (timerForSwop < 0):
		timerForSwop = timeToSwop
		if (currBack >= otherBackgrounds.size()):
			otherBackgrounds[currBack%otherBackgrounds.size()].hide()
			currBack = 0
		else:
			otherBackgrounds[currBack-1].show()
			otherBackgrounds[currBack].show()
			currBack+=1
	else:
		timerForSwop -= delta
