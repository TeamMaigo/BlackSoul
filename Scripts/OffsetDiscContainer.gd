extends Sprite

export(Array, float) var degree_offsets
export var radius = 100

var expectedChildren

func _ready():
	expectedChildren = len(get_children())
	
	var offsetsLength = 0
	if degree_offsets != null:
		offsetsLength = len(degree_offsets)
		
	for i in range(0, expectedChildren):
		var obj = get_children()[i]
		obj.global_position = global_position
		obj.position.x += radius
		
		if offsetsLength > 0:
			var rad = deg2rad(degree_offsets[i % offsetsLength])
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
