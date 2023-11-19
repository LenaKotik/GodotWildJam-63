extends Enemy

export var ball : PackedScene
export var groundAttack : PackedScene

onready var ballTimer = $BallTimer as Timer;
onready var shootPos = $ShootPos as Position2D;

onready var attackTimer = $AttackTimer as Timer
onready var attackAnim = $AttackAnim as AnimationPlayer
onready var HPBar = $ProgressBar as ProgressBar

var is_attacking : bool;

func _ready():
	attackTimer.connect("timeout",self,"startAttack")
	HPBar.max_value = maxHealthPoints;
	
	ballTimer.connect("timeout",self,"shootBall");

func die():
	emit_signal("death", global_position, pointValue);
	attackAnim.stop()
	endAttack()
	happyAnim.play("disapear");
	set_physics_process(false);
	hurtbox.set_deferred("monitorable",false);
	hurtbox.set_deferred("monitoring", false);

func direction():
	if is_attacking:
		return Vector2.ZERO;
	return (target.global_position-global_position).normalized();

func startAttack():
	is_attacking = true;
	attackAnim.play("Attack");

func endAttack():
	is_attacking = false;
	sprite.offset = Vector2.ZERO;

func stopBalls():
	ballTimer.stop();

func randomAttack():
	match (randi()%3):
		0:
			ballTimer.start();
		1:
			var shapePlus = [
				Vector2.ZERO,
				Vector2(-64,0),
				Vector2(64,0),
				Vector2(0,-64),
				Vector2(0,64)
				];
			var shapeX = [
				Vector2.ZERO,
				Vector2(-64,64),
				Vector2(64,-64),
				Vector2(-64,-64),
				Vector2(64,64)
			]
			var shape = [];
			if randi()%2==0:
				shape = shapePlus;
			else:
				shape = shapeX;
			for v in shape:
				attackGround(target.global_position+v);
		2:
			for i in range(0,10):
				attackGround((target.global_position-global_position).normalized()*i*64+global_position)
			

func _physics_process(delta):
	HPBar.value = round(healthPoints);

func shootBall():
	var B = ball.instance() as Projectile;
	B.global_position = shootPos.global_position;
	B.direction = (target.global_position-shootPos.global_position).normalized().rotated(rand_range(-PI/6.0,PI/6.0))
	B.moveSpeed *= 2;
	B.damage = baseDamage*2;
	get_tree().current_scene.add_child(B);

func attackGround(pos):
	var A = groundAttack.instance() as GroundAttack
	A.global_position = pos;
	A.damage = baseDamage * 2.5
	get_tree().current_scene.add_child(A);
