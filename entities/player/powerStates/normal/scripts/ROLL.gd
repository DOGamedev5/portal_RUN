extends State

onready var particle = $"../../runningParticle"
var direction := 1.0

func enter(_lastState):
	parent.setParticle(0, true)
	parent.setParticle(1, false)
	parent.snapDesatived = false
	parent.playback.travel("ROLL")
	particle.emitting = true

	direction = sign(parent.getSlopeNormal().x)
	if direction == 0 and parent.motion.x:
		direction = sign(parent.motion.x)
	elif direction == 0:
		direction = 1 - (int(parent.fliped)*2)

	parent.isRolling = true
	parent.setCollision(1)

func process_state():
	if parent.onWall():
		return "WALL"
		
	elif parent.canJump and Input.is_action_pressed("ui_jump") and parent.couldUncounch():
		return "JUMP"

	return null

func process_physics(_delta):
	var detect = sign(parent.getSlopeNormal().x)
	if detect:
		direction = detect
	elif parent.onWallRayCast[2].is_colliding():
		direction = sign(parent.onWallRayCast[2].get_collision_normal().x)
		
	parent.motion.x = parent.MAXSPEED * direction
	parent.motion.y = parent.MAXSPEED

func exit():
	parent.setParticle(0, false)
	parent.setCollision(0)
	parent.isRolling = false
