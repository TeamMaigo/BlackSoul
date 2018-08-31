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
		player.get_node("PlayerAudio").stream = load("res://Audio/ItemPickup.wav")
		player.get_node("PlayerAudio").playing = true
		player.get_node("PlayerAudio").volume_db = Global.masterSound
		if not respawnable:
			Global.destroyedObjects.append(Global.currentScene+name)
		queue_free()