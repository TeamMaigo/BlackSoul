extends StaticBody2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
export var on = false
export(String) var connectedGroup

signal turn_on
signal turn_off

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
    if connectedGroup != null:
        for item in get_tree().get_nodes_in_group(connectedGroup):
            self.connect("turn_off", item, "switch")
            self.connect("turn_on", item, "switch")

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass

func switch():
	on = !on
	if on:
		$Sprite.frame += 1
		emit_signal("turn_on")
	if not on:
		$Sprite.frame -= 1
		emit_signal("turn_off")