extends Control
export var seconds = 0
var minutes = 0
var milliSec = 0
var paused = false

signal countdownFinished

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	while seconds > 60:
		minutes += 1
		seconds -= 60

func _process(delta):
	# Called every frame. Delta is time since last frame.
	# Update game logic here.
	if not paused:
		if seconds > 0:
			seconds -= delta
			if seconds <= 0 and minutes > 0:
				seconds = 60
				minutes -= 1
		else:
			seconds = 0
			emit_signal("countdownFinished")
		updateLabel()

func updateLabel():
	milliSec = seconds * 1000
	var milliSecText
	if seconds > 1:
		milliSecText = ("%0.2f" % (milliSec)).substr(2, 2)
	else:
		milliSecText = ("%0.2f" % (milliSec)).substr(0, 2)
	$label.text = "%02.0d" % minutes + ":" + "%02.0d" % seconds + ":" + milliSecText