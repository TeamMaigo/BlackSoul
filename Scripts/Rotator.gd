extends KinematicBody2D

export var degreesPerFrame = 4
var componentCount = 2

func _ready():
	if len(get_children()) > componentCount:
		var obj = get_children()[componentCount] #The item after the last component should be a container
		obj.global_position = global_position #Place the container at the Rotator

func _process(delta):
	#Remove unexpected children
	while len(get_children()) > componentCount + 1: #Allow for components and one container
		var obj = get_children()[-1]
		var pos = obj.global_position
		remove_child(obj)
		get_parent().add_child(obj)
		obj.global_position = pos
	rotation_degrees += degreesPerFrame
