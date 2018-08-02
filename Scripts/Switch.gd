extends StaticBody2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
export var on = false

signal turn_on
signal turn_off

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass

func switch():
	on = !on
	if on:
		emit_signal("turn_on")
	if not on:
		emit_signal("turn_off")