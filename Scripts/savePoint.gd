extends Node2D

#export(String) var newScene = "Room1"
#export var transferGoalTemp = "A"
#var transferGoal
#var transfering = false

func _ready():
	pass
	# Called every time the node is added to the scene.
	# Initialization here
#	transferGoal = "TransferGoal" + transferGoalTemp

func _on_Area2D_body_entered(body):
	if body.is_in_group("Player"):
		var player = body.get_node("./")
		player.setHealth(player.maxHealth)
		Global.save_game()