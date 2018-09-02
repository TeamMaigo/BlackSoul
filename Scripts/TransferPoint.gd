extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
export(String) var newScene = "LabA"
export var transferGoalTemp = "A"
export var unlocked = true
var transferGoal
var transfering = false
export var relocks = false
export var finalTransition = false

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	if Global.currentScene+name in Global.unlockedThings:
		unlocked = true
	if unlocked:
		$Sprite.frame = 1
	else:
		$Sprite.frame = 0
	transferGoal = "TransferGoal" + transferGoalTemp

func _on_Area2D_body_entered(body):
	if not transfering and unlocked:
		if body.is_in_group("Player"):	#Check for player
			$animationPlayer.play("open")
			body.get_node("./").playerControlEnabled = false
			transfering = true
			newScene = "res://Scenes/Rooms/" + newScene + ".tscn"
			if finalTransition:
				get_tree().change_scene("res://Scenes/GameFinished.tscn")
			else:
				get_node("/root/World/").goto_scene(newScene, transferGoal)

func switch(power):
	if power:
		unlocked = true
		$Sprite.frame = 1
		if not relocks:
			Global.unlockedThings.append(Global.currentScene+name)
	else:
		unlocked = false
		$Sprite.frame = 0