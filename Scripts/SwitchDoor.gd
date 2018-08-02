extends StaticBody2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
var collisionL = self.collision_layer

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass
func _onActivate():
	show()
	collision_layer = collisionL

func _onDeactivate():
	hide()
	collision_layer = 0
