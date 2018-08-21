extends Node2D

export var on = false
export var frame = 0

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	$sprite.frame = frame

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass

func switch():
	on = !on
	if on:
		$sprite.texture = load("res://Sprites/CABLES_ON.png")
	if not on:
		$sprite.texture = load("res://Sprites/CABLES_OFF.png")
		#$sprite.frame -= 1