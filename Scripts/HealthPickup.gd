extends StaticBody2D

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass

func applyEffect(player):
	player.health = player.maxHealth
	print("Health restored to " + str(player.maxHealth) + "!")
	queue_free()
	pass
