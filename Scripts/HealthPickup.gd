extends StaticBody2D

export var respawnable = true

signal collected

func _ready():
	if has_node("animationPlayer"):
		$animationPlayer.play("Default")
	if Global.currentScene+name in Global.destroyedObjects:
		queue_free()

func applyEffect(player):
	emit_signal("collected")
	player.setHealth(player.maxHealth)
	player.get_node("PlayerAudio").stream = load("res://Audio/ItemPickup.wav")
	player.get_node("PlayerAudio").playing = true
	player.get_node("PlayerAudio").volume_db = Global.masterSound
	if not respawnable:
		Global.destroyedObjects.append(Global.currentScene+name)
	queue_free()