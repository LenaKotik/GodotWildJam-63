extends KinematicBody2D
class_name Enemy

signal death(pos,value);

export var baseDamage : float
export var speed : float;
export var softCollisionForce : float;
export var maxHealthPoints : float
export var pointValue : int;

onready var hurtbox = $Hurtbox as Area2D;
onready var softCollision = $SoftCollision as SoftCollision;
onready var sprite = $Sprite as AnimatedSprite;
onready var hurtAnim = $HurtAnim as AnimationPlayer;
onready var happyAnim = $HappyAnim as AnimationPlayer;
onready var rageTimer = $RageTimer as Timer;

var target : Node2D
var healthPoints : float setget set_HP;
var rageCount = 0;

func set_HP(v):
	healthPoints = max(v, 0);
	if healthPoints == 0: # если ХП кончилось умераем
		die();

func die():
	emit_signal("death", global_position, pointValue);
	happyAnim.play("disapear");
	set_physics_process(false);
	hurtbox.set_deferred("monitorable",false);
	hurtbox.set_deferred("monitoring", false);

func _ready():
	healthPoints = maxHealthPoints;
	hurtbox.connect("area_entered", self, "hurtbox_collision");
	rageTimer.connect("timeout",self,"rage");

func hurtbox_collision(area):
	if area is PlayerProjectile:
		self.healthPoints -= area.damage;
		hurtAnim.play("hurt");

func rage():
	rageCount += 1;
	speed += speed/4
	#if rageCount == 2:
	#	rageTimer.stop();

func direction() -> Vector2: # это ИИ передвижения, 
	# в самом простом враге это тупо "идти в сторону игрока"
	return (target.global_position-global_position);

func _physics_process(delta):
	var velocity = direction().normalized() * speed; # получаем направление от ИИ, нормализуем и множим на скорость
	sprite.flip_h = (target.global_position-global_position).x > 0;
	var pushVector = softCollision.get_push_vector() * softCollisionForce;
	
	move_and_slide(velocity+pushVector);
