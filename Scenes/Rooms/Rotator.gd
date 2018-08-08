extends KinematicBody2D


func _ready():
	if len(get_children()) > 2:
		var obj = get_children()[2]
		obj.global_position = global_position

func _process(delta):
	#Remove unexpected children
	while len(get_children()) > 3:
		var obj = get_children()[-1]
		var pos = obj.global_position
		remove_child(obj)
		get_parent().add_child(obj)
		obj.global_position = pos
	rotation_degrees += 4
