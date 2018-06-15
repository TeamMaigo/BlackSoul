extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
export(String) var newScene = "Room1"
export var transferGoal = "TransferGoalA"

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	newScene = get_parent().get_parent().sceneName
	transferGoal = get_parent().get_parent().transferGoal

func _on_Area2D_body_entered(body):
	if body.is_in_group("Player"):	#Check for player
		newScene = "res://Scenes/" + newScene + ".tscn"
		get_node("/root/World/").goto_scene(newScene, transferGoal)