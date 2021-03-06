extends "res://Scripts/BulletLinear.gd"

var canRotate = false
onready var timer = get_node("timer")
#var target
onready var linearDecayTimer = $LinearDecayTimer
onready var trackingDelayTimer = $TrackingDelayTimer
var decayed = false # Decides whether bullet is now a linear bullet

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	bulletDecay(bulletDecayTime)
	if not target:
		target = get_tree().get_root().get_node("World/Player")
	waitToRotate()
	waitToTrack()

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass

func setTarget(target):
	self.target = target

func movementLoop():
	var movedir = velocity
	var motion = movedir.normalized() * speed
	if canRotate:
		determineRotation()
	return move_and_collide(motion)

func waitToRotate():
	timer.set_wait_time(angleBulletUpdateDelay) # Set Timer's delay to "sec" seconds
	timer.start() # Start the Timer counting down
	yield(timer, "timeout") # Wait for the timer to wind down
	canRotate = true

func determineRotation():
	if target and not decayed:
		var angleToTarget = Vector2(target.position.x - position.x, target.position.y - position.y).angle() - rotation
		if abs(angleToTarget) > PI:
			angleToTarget = angleToTarget - (sign(angleToTarget) * PI*2)
		rotation += min(abs(angleToTarget), rotationSpeed) * sign(angleToTarget)

		velocity = Vector2(speed, 0).rotated(rotation)

		waitToRotate()
		canRotate = false

func bulletDecay(sec):
	linearDecayTimer.set_wait_time(sec) # Set Timer's delay to "sec" seconds
	linearDecayTimer.start() # Start the Timer counting down
	yield(linearDecayTimer, "timeout") # Wait for the timer to wind down
	decayed = true

func waitToTrack():
	trackingDelayTimer.set_wait_time(trackingDelayTime) # Set Timer's delay to "sec" seconds
	trackingDelayTimer.start() # Start the Timer counting down
	yield(trackingDelayTimer, "timeout") # Wait for the timer to wind down
	target = get_tree().get_root().get_node("World/Player")