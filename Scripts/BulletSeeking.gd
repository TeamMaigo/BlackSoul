extends KinematicBody2D

var speed = 1
var velocity = Vector2()
var player
var target #Should be a Node2D
export var damage = 1
export var degreesPerFrame = 4
onready var rotationSpeed = deg2rad(degreesPerFrame)
export var maxRotationDiff = 20

func _ready():
	_physics_process(true)

func start(pos, dir, bulletSpeed):
	position = pos
	rotation = dir
	speed = bulletSpeed
	velocity = Vector2(speed, 0).rotated(dir).normalized()

func setTarget(target):
	self.target = target

func _physics_process(delta):
	if target:
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
		if collision.collider.is_in_group("Player"):
			hitPlayer(collision.collider.get_node("../Player"))
		elif collision.collider.is_in_group("Enemy"):
			print("Enemy hit!")
			queue_free()
		elif collision.collider.is_in_group("Breakable"):
			print("BREAK!")
			collision.collider.queue_free()
			queue_free()
		elif collision.collider.is_class("TileMap"):
			#print("Wall hit")
			queue_free()
		else:
			print("What was that? Hit: ", collision.collider)
			queue_free()


func setDirection(directionVector):
	velocity = directionVector
	rotation_degrees = rad2deg(directionVector.angle())

func hitPlayer(player):
		player.takeDamage(damage)
		queue_free()	#Destroys the bullet
