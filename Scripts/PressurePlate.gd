extends Node2D

export var time = 10 # in seconds
var pressed = false
onready var timer = $timer

signal counterFinished
signal steppedOn

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass

func timer(sec):
	timer.set_wait_time(sec) # Set Timer's delay to "sec" seconds
	timer.start() # Start the Timer counting down
	yield(timer, "timeout") # Wait for the timer to wind down
	emit_signal("counterFinished")

func _on_area2D_body_entered(body):
	if body.is_in_group("Player"):
		if not pressed:
			emit_signal("steppedOn")
			pressed = true
			timer(time)