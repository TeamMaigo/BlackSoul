extends Control
export var seconds = 0
var minutes = 0
var milliSec = 0
var paused = true

onready var traumaTimer = $traumaClock
onready var player = get_tree().get_root().get_node("World/Player")
onready var audioPlayer = $audioStreamPlayer2D

signal countdownFinished

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass

func start():
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
			paused = true
			hide()
		updateLabel()

func updateLabel():
	milliSec = seconds * 1000
	var milliSecText
	if seconds > 1:
		milliSecText = ("%0.2f" % (milliSec)).substr(2, 2)
	elif seconds == 0:
		milliSecText = "%0.2f" % 0
	else:
		milliSecText = ("%0.2f" % (milliSec)).substr(0, 2)
	$label.text = "%02.0d" % minutes + ":" + "%02.0d" % seconds + ":" + milliSecText

func waitToShake(sec):
	traumaTimer.set_wait_time(sec) # Set Timer's delay to "sec" seconds
	traumaTimer.start() # Start the Timer counting down
	yield(traumaTimer, "timeout") # Wait for the timer to wind down
	waitToShake(randi()%10+5)
	#if not paused: #Moved to new function on different delay: waitToScream
	#	audioPlayer.stream = load("res://Audio/Wilhelm-Scream.wav")
	#	audioPlayer.volume_db = Global.masterSound
	#	audioPlayer.play()
	#	player.trauma = 150

func waitToScream(sec):
	traumaTimer.set_wait_time(sec) # Set Timer's delay to "sec" seconds
	traumaTimer.start() # Start the Timer counting down
	yield(traumaTimer, "timeout") # Wait for the timer to wind down
	waitToScream(randi()%30+30)
	if not paused:
		audioPlayer.stream = load("res://Audio/Wilhelm-Scream.wav")
		audioPlayer.volume_db = Global.masterSound
		audioPlayer.play()
		player.trauma = 150