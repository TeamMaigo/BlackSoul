extends KinematicBody2D

var speed = 1
var velocity = Vector2()
var player
var target #Should be a Node2D
var damage = 1
var degreesPerFrame = 1
onready var rotationSpeed = deg2rad(degreesPerFrame)
export var maxRotationDiff = 40
var frames = 0
var collided = false
onready var linearDecayTimer = $LinearDecayTimer
var decayed = false # Decides whether bullet is now a linear bullet
var bulletDecayTime = 10

func _ready():
	collision_mask = 3
	_physics_process(true)
	$animationPlayer.play("default")
	bulletDecay(bulletDecayTime)

func start(pos, dir, bulletSpeed):
	position = pos
	rotation = dir
	speed = bulletSpeed
	velocity = Vector2(speed, 0).rotated(dir).normalized()

func setTarget(target):
	self.target = target

func _physics_process(delta):
	if frames == 15: #TODO
		if not target:
			target = get_tree().get_root().get_node("World/Player")
		collision_mask = 7 
		frames += 1
	else:
		frames += 1
	if target and not decayed:
		var angleToTarget = Vector2(target.position.x - position.x, target.position.y - position.y).angle() - rotation
		if abs(angleToTarget) > PI:
			angleToTarget = angleToTarget - (sign(angleToTarget) * PI*2)
		if rad2deg(angleToTarget) < maxRotationDiff and rad2deg(angleToTarget) > -maxRotationDiff:
			rotation += min(abs(angleToTarget), rotationSpeed) * sign(angleToTarget)
		
		velocity = Vector2(speed, 0).rotated(rotation)
		
	#position += velocity * delta
	var movedir = velocity
	var motion = movedir.normalized() * speed
	var collision = move_and_collide(motion)#, Vector2(0,0))
	if collision:
		collide(collision.collider)

func collide(collider):
	if !collided:
		collided = true
		if collider.has_method("takeDamage"):
			collider.takeDamage(damage)
		queue_free()

func setDirection(directionVector):
	velocity = directionVector
	rotation_degrees = rad2deg(directionVector.angle())

func hitPlayer(player):
		player.takeDamage(damage)
		queue_free()	#Destroys the bullet

func bulletDecay(sec):
	linearDecayTimer.set_wait_time(sec) # Set Timer's delay to "sec" seconds
	linearDecayTimer.start() # Start the Timer counting down
	yield(linearDecayTimer, "timeout") # Wait for the timer to wind down
	decayed = true
