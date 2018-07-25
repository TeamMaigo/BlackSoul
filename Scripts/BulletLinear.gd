extends KinematicBody2D

var speed = 1
var velocity = Vector2()
var player
var degreesPerFrame = 4
var damage = 1
var frames = 0
onready var turnSpeed = deg2rad(degreesPerFrame)

func _ready():
	collision_mask = 3
	_physics_process(true)


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
		if collision.collider.is_in_group("Player"):
			hitPlayer(collision.collider.get_node("../Player"))
		elif collision.collider.is_in_group("Enemy"):
			print("Enemy hit!")
			collision.collider.queue_free()
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
