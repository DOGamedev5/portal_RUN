extends PlayerBase

onready var sprite = $Sprite
onready var animation = $AnimationTree
onready var playback = animation["parameters/playback"]
onready var attackComponents = [$attackPunch, $attackSpeed, $attackRoll]
onready var currentCollision = $CollisionShape2D
onready var attackDelay = $StateMachine/ATTACK/attackDelay

export(float) var runningVelocity := 550.0

var running := false
var canAttackTimer := .0
var attackTime := 20.0
var attackVelocity := 800.0
var isRolling := false
var canAttack := true


onready var collisionShapes := [
	{shape = CapsuleShape2D.new(), position = Vector2(0, -28), onWall = [true, true, true]},
	{shape = CircleShape2D.new(), position = Vector2(0, -16), onWall = [false, true, true]}
]

func _ready():
	
	collisionShapes[0].shape.radius = 16
	collisionShapes[0].shape.height = 24
	collisionShapes[1].shape.radius = 15
	
func _physics_process(delta):
	if not active: return
	
	_coyoteTimer()
	setFlipConfig()
	setAttack()
	
	animation["parameters/RUN/TimeScale/scale"] = max(0.5, (abs(motion.x) / MAXSPEED) * 3)
	
	if active:
		move(!isRolling)
	
	$a/Label.text = str(motion.x)

	$speedEffect.visible = running
	if running:
		var velocity = motion.x
		if onSlope():
			velocity = sqrt(pow(motion.x, 2) + pow(motion.y, 2))
		 
		$speedEffect.modulate.a = max((velocity - MAXSPEED) / (runningVelocity - MAXSPEED-100), 0.65)
		
	if attackDelay.is_stopped():
		canAttack = true
	else:
		canAttack = false

func stoppedRunning():
	var velocity = motion.x
	if onSlope():
		velocity = sqrt(pow(motion.x, 2) + pow(motion.y, 2))
		
	if running and abs(velocity) <= MAXSPEED:
		running = false

func detectRunning():
	var velocity = motion.x
	if onSlope():
		velocity = sqrt(pow(motion.x, 2) + pow(motion.y, 2))
	
	running = abs(velocity) > MAXSPEED

func setFlipConfig():
	if stunned: return
	
	flipObject(attackComponents)
	
	$speedEffect.position.x = 28 * (1 - 2 * int(fliped))
	$speedEffect.flip_h = fliped
	
	sprite.flip_h = fliped

func setAttack():
	if running and not isRolling:
		if sqrt(pow(motion.x, 2) + pow(motion.y, 2)) < 725:
			attackComponents[1].setDamage(1)
		else:
			attackComponents[1].setDamage(2)
	
	else:
		attackComponents[1].setDamage(0)
		
	attackComponents[2].setDamage(int(isRolling))

func setCollision(ID := 0):
	active = false
	currentCollision.set_deferred("position", collisionShapes[ID].position)
	currentCollision.set_deferred("shape", collisionShapes[ID].shape)
	currentCollision.set_deferred("custom_solver_bias", 0.2)
	
	for ray in range(3):
		onWallRayCast[ray].enabled = collisionShapes[ID].onWall[ray]
	
	active = true
