extends KinematicBody2D

var railStart = Vector2(0.0,0.0)
var railEnd = Vector2(0.0,0.0)
export (Array, Vector2) var railPoints
var currentDestinationPoint = 0 # Current destination
export (bool) var backtrack = true
# if true, goes back and forth along rail; false, goes in a ring cycling through all points in order
export var railSpeed = 2
onready var initPos = global_position
var componentCount = 2		# (e.g. sprite, collisionShape2D)

var velocity = Vector2()
var target = Vector2()
var directionModifier = 1 #either 1 or -1 to decide direction
# Use if more than two waypoints

func _ready():
	set_physics_process(true)
	for child in len(railPoints):
		railPoints[child] = railPoints[child]
	updateGoal()
	
	#Initialize global positions of rail locations
	if len(get_children()) > componentCount:
		var obj = get_children()[componentCount] #The item after the last component should be a container
		obj.position = Vector2(0,0) #Place the container at the Rail


func _process(delta):
	#Remove unexpected children
	while len(get_children()) > componentCount + 1: #Allow for components and one container
		var obj = get_children()[-1]
		var pos = obj.global_position
		remove_child(obj)
		get_parent().add_child(obj)
		obj.global_position = pos

	if(target - position).length() < 10:
		if currentDestinationPoint == railPoints.size()-1 or (currentDestinationPoint == 0 and directionModifier == -1):
			if(backtrack):
				directionModifier *= -1
				currentDestinationPoint += directionModifier
			else:
				currentDestinationPoint = 0
		else:
			currentDestinationPoint += directionModifier
		updateGoal()
	
	var motion = (target-position).normalized() * railSpeed
	move_and_slide(motion)

func updateGoal(): #New target
	target = railPoints[currentDestinationPoint] + initPos