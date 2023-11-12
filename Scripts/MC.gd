extends KinematicBody2D
class_name Player

export var maxHealthPoints : float;
export var invulnerabilityTime : float
export var speed : float;

onready var sprite : Sprite = $Sprite;
onready var weapon : Weapon = $Weapon;
onready var hurtbox : Area2D = $Hurtbox;
onready var hurtboxColl : CollisionShape2D = $Hurtbox/CollisionShape2D;
onready var invulnerabilityTimer : Timer = $IFrameTimer;
onready var invulnerabilityAnim : AnimationPlayer = $IFrameAnim;

var healthPoints : float setget set_HP;

func set_HP(v):
	healthPoints = max(v, 0);
	if healthPoints == 0:
		get_tree().quit(0); # выход из игры при смерти

func _ready():
	healthPoints = maxHealthPoints;
	hurtbox.connect("area_entered", self, "hurtbox_collision");
	invulnerabilityTimer.connect("timeout", self, "invulnerability_end");

func _physics_process(delta) -> void:
	var velocity = Vector2((Input.get_action_strength("right") - Input.get_action_strength("left")),
	(Input.get_action_strength("down") - Input.get_action_strength("up"))).normalized() * speed;
	
	move_and_slide(velocity);

func take_damage(v : float):
	self.healthPoints -= v;
	hurtboxColl.set_deferred("disabled", true);
	invulnerabilityAnim.play("iframes");
	invulnerabilityTimer.start(invulnerabilityTime);

func invulnerability_end():
	invulnerabilityAnim.play("RESET");
	hurtboxColl.set_deferred("disabled", false);

func hurtbox_collision(area):
	take_damage(area.get_parent().baseDamage);
