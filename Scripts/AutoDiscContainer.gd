extends Sprite

var expectedChildren
export var radius = 100

func _ready():
	expectedChildren = len(get_children())
	var radianOffset = 0
	if expectedChildren > 0:
		radianOffset = (2 * PI) / expectedChildren

	for i in range(expectedChildren):
		var obj = get_children()[i]
		obj.global_position = global_position
		obj.position.x += radius
		var rad = i * radianOffset
		obj.position = obj.position.rotated(rad)
		obj.rotation += rad

func _process(delta):
	#Remove unexpected children
	while len(get_children()) > expectedChildren:
		var obj = get_children()[-1]
		var pos = obj.global_position
		remove_child(obj)
		get_parent().add_child(obj)
		obj.global_position = pos
	

