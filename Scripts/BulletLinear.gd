extends KinematicBody2D

# Required to pass editor info to collider child of object

var speed = 1
var velocity = Vector2()

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
	move_and_collide(motion)#, Vector2(0,0))
	
	
func _on_Bullet_body_entered(body):
	queue_free()