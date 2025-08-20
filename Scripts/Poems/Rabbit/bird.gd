extends CharacterBody2D

const GRAVITY : int = 1000
const MAX_VEL : int = 600
const FLAP_SPEED : int = -500
var flying : bool = false
var falling : bool = false
const START_POS = Vector2(132, 266)   # Match Monkey node Bird position

func _ready():
	reset()

func reset():
	falling = false
	flying = false
	velocity = Vector2.ZERO
	position = START_POS
	rotation = 0
	$AnimatedSprite2D.stop()
	print("Bird reset at Y:", position.y)

func _physics_process(delta):
	if flying or falling:
		velocity.y += GRAVITY * delta
		if velocity.y > MAX_VEL:
			velocity.y = MAX_VEL
		
		if flying:
			rotation = deg_to_rad(velocity.y * 0.05)
			$AnimatedSprite2D.play()
		elif falling:
			rotation = PI/2
			$AnimatedSprite2D.stop()
		
		move_and_collide(velocity * delta)
	else:
		$AnimatedSprite2D.stop()

func flap():
	velocity.y = FLAP_SPEED
