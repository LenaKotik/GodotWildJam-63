extends KinematicBody2D
class_name Player

signal HPupdate(hp);
signal XPupdate(xp);
signal levelUp(lvl);

export var maxHealthPoints : float;
export var invulnerabilityTime : float
export var speed : float;

onready var sprite : AnimatedSprite = $Sprite;
onready var weaponSprite : AnimatedSprite = $WeaponSprite;
onready var eyesSprite : Sprite = $Eyes
onready var eyesReference : Position2D = $EyesReference;
onready var weapon : Weapon = $Weapon;
onready var hurtbox : Area2D = $Hurtbox;
onready var hurtboxColl : CollisionShape2D = $Hurtbox/CollisionShape2D;
onready var invulnerabilityTimer : Timer = $IFrameTimer;
onready var invulnerabilityAnim : AnimationPlayer = $IFrameAnim;
onready var soupParticles : CPUParticles2D = $SoupParticles;

var healthPoints : float setget set_HP;
var experiencePoints : int = 0 setget set_XP;
var level : int = 0;

func set_HP(v):
	healthPoints = max(v, 0);
	emit_signal("HPupdate", healthPoints);
	if healthPoints == 0:
		get_tree().quit(0); # выход из игры при смерти

func set_XP(v):
	experiencePoints = v;
	var toNext = XPtoLevel(level+1);
	if experiencePoints >= toNext:
		level += 1;
		set_XP(experiencePoints - toNext);
		emit_signal("levelUp", level);
	emit_signal("XPupdate", experiencePoints);

func XPtoLevel(n):
	#return round(max(10 * 1.25 * (n-1), 10));
	return 10;

func addXP(n):
	self.experiencePoints += n;

func _ready():
	healthPoints = maxHealthPoints;
	hurtbox.connect("area_entered", self, "hurtbox_collision");
	invulnerabilityTimer.connect("timeout", self, "invulnerability_end");

func _physics_process(delta) -> void:
	var velocity = Vector2((Input.get_action_strength("right") - Input.get_action_strength("left")),
	(Input.get_action_strength("down") - Input.get_action_strength("up"))).normalized() * speed
	if velocity == Vector2.ZERO:
		sprite.playing = false;
		sprite.frame = 0;
	else:
		sprite.playing = true;
	
	var to_mouse = (get_global_mouse_position()-eyesReference.global_position).normalized();
	eyesSprite.offset = to_mouse * 0.5;
	eyesSprite.flip_h = to_mouse.x < 0;
	sprite.flip_h = to_mouse.x < 0;
	weaponSprite.flip_h = to_mouse.x < 0;
	soupParticles.position.x = -4 * sign(to_mouse.x);
	
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
