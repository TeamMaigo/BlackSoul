extends "res://Scripts/HealthPickup.gd"
var collected = false


func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass

func applyEffect(player):
	if not collected:
		collected = true
		player.piecesOfHeart += 1
		player.updateHealthUpProgress()
		emit_signal("collected")
		if not respawnable:
			Global.destroyedObjects.append(Global.currentScene+name)
		queue_free()