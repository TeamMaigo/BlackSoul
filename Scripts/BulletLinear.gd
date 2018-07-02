extends KinematicBody2D

var speed = 1
var velocity = Vector2()
var player

func _ready():
	_physics_process(true)

func start(pos, dir, bulletSpeed):
	position = pos
	rotation = dir
	speed = bulletSpeed
	velocity = Vector2(speed, 0).rotated(dir).normalized()

func _physics_process(delta):
	#position += velocity * delta
	var movedir = velocity
	var motion = movedir.normalized() * speed
	var collision = move_and_collide(motion)#, Vector2(0,0))
	if collision:
		if collision.collider.is_in_group("Player"):
			player = collision.collider.get_node("../Player")
			player.takeDamage(1)
			queue_free()	#Destroys the bullet
		elif collision.collider.is_in_group("Enemy"):
			print("Enemy hit!")
			queue_free()
		elif collision.collider.is_class("TileMap"):
			print("Wall hit")
			queue_free()
		else:
			print("What was that? Hit: ", collision.collider)
			queue_free()
	
	
func setDirection(directionVector):
	velocity = directionVector
	rotation_degrees = rad2deg(directionVector.angle())
	
	
func _on_Bullet_body_entered(body):
	queue_free()