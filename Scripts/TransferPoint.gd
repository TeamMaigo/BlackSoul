extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
export(String) var newScene = "Room1"
export var transferGoalTemp = "A"
var transferGoal
var transfering = false

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	transferGoal = "TransferGoal" + transferGoalTemp

func _on_Area2D_body_entered(body):
	if not transfering:
		if body.is_in_group("Player"):	#Check for player
			body.get_node("./").playerControlEnabled = false
			transfering = true
			newScene = "res://Scenes/Rooms/" + newScene + ".tscn"
			get_node("/root/World/").goto_scene(newScene, transferGoal)