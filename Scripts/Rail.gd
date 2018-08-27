extends KinematicBody2D

export (Vector2) var railStart = Vector2(0.0,0.0)
export (Vector2) var railEnd = Vector2(50.0,0.0)
export (bool) var multiPoint = false
export (Array) var railPoints
var currentDestinationPoint = 0 # Current destination
export (bool) var backtrack = true
# if true, goes back and forth along rail; false, goes in a ring cycling through all points in order
export var railSpeed = 2

var componentCount = 2		# (e.g. sprite, collisionShape2D)

var velocity = Vector2()
var dVector = Vector2()
export var traversingForwards = true # true = going from start to end, false = back from end to start

# Use if more than two waypoints
var lastPointReached = 0 # 0 is start, 1 is the next point from start, and so on and so forth

func _ready():
	set_physics_process(true)
	
	#Initialize global positions of rail locations
	railStart += global_position
	railEnd += global_position
	for i in range(railPoints.size()):
		railPoints[i] += global_position
	print(railPoints)
	if len(get_children()) > componentCount:
		var obj = get_children()[componentCount] #The item after the last component should be a container
		obj.global_position = global_position #Place the container at the Rail
	pass

func _process(delta):
	# Test print statements
	#print("New frame")
	#print(railStart)
	#print(railEnd)
	#print(global_position)
	
	#Remove unexpected children
	while len(get_children()) > componentCount + 1: #Allow for components and one container
		var obj = get_children()[-1]
		var pos = obj.global_position
		remove_child(obj)
		get_parent().add_child(obj)
		obj.global_position = pos
	
	if(multiPoint):
		if(traversingForwards and (railPoints[currentDestinationPoint] == global_position)):
			currentDestinationPoint += 1
		elif(!traversingForwards and (railPoints[currentDestinationPoint] == global_position)):
			currentDestinationPoint -= 1
		if(traversingForwards and currentDestinationPoint >= railPoints.size()):
			if(backtrack):
				currentDestinationPoint = railPoints.size() - 2
				traversingForwards = false
			else:
				currentDestinationPoint = 0
		elif(!traversingForwards and currentDestinationPoint < 0):
			if(backtrack):
				currentDestinationPoint = 1
				traversingForwards = true
			else:
				currentDestinationPoint = railPoints.size() - 1
		
		# Get direction vector (not yet normalized)
		dVector = railPoints[currentDestinationPoint] - global_position
#		print("New frame!")
#		print(dVector)
#		print(railPoints)
#		print(currentDestinationPoint)
#		print(global_position)
	else:
		# Check if destination has been reached yet; change direction if so
		if(traversingForwards and (railEnd == global_position)):
			traversingForwards = false
		elif(!traversingForwards and (railStart == global_position)):
			traversingForwards = true
			
		# Get direction vector (not yet normalized)
		if(traversingForwards):
			dVector = railEnd - global_position
		else:
			dVector = railStart - global_position
	
	# Code relating to vectors that isn't directly dependent on other variables
	# If destination won't be reached next frame, normalize the vector and move by railSpeed
	if(dVector.length() > railSpeed):
		dVector = dVector.normalized() * railSpeed
	print(dVector)
	# Set velocity
	velocity = dVector
	global_position += velocity

#func _physics_process(delta):
#	move_and_slide(velocity)

func changeDirection():
	if traversingForwards:
		traversingForwards = false
	else:
		traversingForwards = true