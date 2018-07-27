extends Node
# This script holds all options and any property can be referenced anywhere by typing Global.property

var masterMusic = 0
var masterSound = 0
var destroyedObjects = []
var currentScene = "LabA"

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	BGMPlayer.playing = true

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass



