extends Node2D

export var time = 10 # in seconds
var pressed = false
onready var timer = $timer
enum PALETTETYPE { lab,acid,core }
export(PALETTETYPE) var paletteType = PALETTETYPE.lab
var blinked = false
var blinking = false

signal counterFinished
signal steppedOn

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	if paletteType == PALETTETYPE.lab:
		$sprite.frame = 0
	if paletteType == PALETTETYPE.acid:
		$sprite.frame = 2

func timer(sec):
	timer.set_wait_time(sec) # Set Timer's delay to "sec" seconds
	timer.start() # Start the Timer counting down
	yield(timer, "timeout") # Wait for the timer to wind down
	emit_signal("counterFinished")
	blinking = false

func blinkTimer():
	$blinkTimer.set_wait_time(1)
	$blinkTimer.start()
	yield($blinkTimer, "timeout")
	if blinked:
		$sprite.self_modulate = Color(1, 1, 1)
	else:
		$sprite.self_modulate = Color(1, 180.0/255.0, 1)
	blinked = not blinked
	if blinking:
		blinkTimer()

func _on_area2D_body_entered(body):
	if body.is_in_group("Player"):
		if not pressed:
			emit_signal("steppedOn")
			blinking = true
			pressed = true
			$sprite.frame += 1
			timer(time)
			blinkTimer()