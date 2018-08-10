extends KinematicBody2D

var speed = 1
var velocity = Vector2()
var player
var damage = 1
var frames = 0
var angleBulletUpdateDelay = 1 # seconds
var rotationSpeed = 1.0 # how fast it rotates
var bulletDecayTime = 10
var maxRotationDiff = 40.0
onready var turnSpeed = deg2rad(rotationSpeed)
var reflectedRecently = false
onready var reflectionTimer = $ReflectionTimer
var reflectionTime = 1 # in seconds

func _ready():
	collision_mask = 3
	_physics_process(true)
	$animationPlayer.play("default")


func setTarget(target): #TODO: Arrange bullet objects better so we can delete this function
	return

func start(pos, dir, bulletSpeed):
	position = pos
	rotation = dir
	speed = bulletSpeed
	velocity = Vector2(speed, 0).rotated(dir).normalized()

func _physics_process(delta):
	#position += velocity * delta
	if frames == 15: #TODO
#		$CollisionShape2D.disabled = false
		collision_mask = 7 
		frames += 1
	else:
		frames += 1
	var collision = movementLoop()
	if collision:
		collide(collision.collider)
	
func collide(collider):
	if collider.has_method("shatterParams"):
		collider.shatterParams(global_position, rotation, speed)
	if collider.has_method("takeDamage"):
		if collider.is_in_group("Player") and reflectedRecently:
			pass # Don't hit the player
		else:
			collider.takeDamage(damage)
	if collider.has_method("switch"):
		collider.switch()
	queue_free()
	
func movementLoop():
	var movedir = velocity
	var motion = movedir.normalized() * speed
	return move_and_collide(motion)

func setDirection(directionVector):
	velocity = directionVector
	rotation_degrees = rad2deg(directionVector.angle())
	
func hitPlayer(player):
		player.takeDamage(damage)
		queue_free()	#Destroys the bullet

func waitToReflect():
	reflectionTimer.set_wait_time(reflectionTime) # Set Timer's delay to "sec" seconds
	reflectionTimer.start() # Start the Timer counting down
	yield(reflectionTimer, "timeout") # Wait for the timer to wind down
	reflectedRecently = false