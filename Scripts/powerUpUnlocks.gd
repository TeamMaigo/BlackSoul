extends Area2D

# class member variables go here, for example:

export(String, "dashUnlocked", "barrierUnlocked", "swapUnlocked") var unlockType
export(String) var objectToShow

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass


func _on_area2D_body_entered(body):
	if body.is_in_group("Player"):
		if not body.get(String(unlockType)):
			body.set(String(unlockType), true)
			if objectToShow:
				get_node("../"+objectToShow).show()
		queue_free()