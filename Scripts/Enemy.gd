extends KinematicBody2D
class_name Enemy

signal death;

export var baseDamage : float
export var speed : float;
export var maxHealthPoints : float

onready var hurtbox = $Hurtbox as Area2D;

var target : Node2D
var healthPoints : float setget set_HP;

func set_HP(v):
	healthPoints = max(v, 0);
	if healthPoints == 0: # если ХП кончилось умераем
		die();

func die():
	emit_signal("death");
	queue_free(); # TODO: добавить эффект какой нибудь

func _ready():
	healthPoints = maxHealthPoints;
	hurtbox.connect("area_entered", self, "hurtbox_collision");

func hurtbox_collision(area):
	if area is Projectile:
		self.healthPoints -= area.damage;

func direction() -> Vector2: # это ИИ передвижения, 
	# в самом простом враге это тупо "идти в сторону игрока"
	return (target.global_position-global_position);

func _physics_process(delta):
	var velocity = direction().normalized() * speed; # получаем направление от ИИ, нормализуем и множим на скорость
	
	move_and_slide(velocity);
