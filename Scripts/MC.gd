extends KinematicBody2D
class_name Player
signal dead;

signal HPupdate(hp);
signal XPupdate(xp);
signal levelUp(lvl);

export var maxHealthPoints : float;
export var invulnerabilityTime : float
export var speed : float;
export var defense : float;

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
onready var deathAnim : AnimationPlayer = $DeathAnim;
onready var hitSnd : AudioStreamPlayer2D = $HitSnd;
onready var pickUpSnd : AudioStreamPlayer2D = $PickUp 
onready var coolhat = $Coolhat as Sprite;

var healthPoints : float setget set_HP;
var experiencePoints : int = 0 setget set_XP;
var level : int = 0;
var is_invulnerable : bool = false;
var dead : bool = false;

func set_HP(v):
	if dead: return;
	healthPoints = max(min(v,maxHealthPoints), 0);
	emit_signal("HPupdate", healthPoints);
	if healthPoints == 0:
		invulnerabilityAnim.play("RESET")
		deathAnim.play("death");
		dead = true;
		weapon.set_physics_process(false);
		emit_signal("dead");

func set_XP(v):
	if dead: return;
	experiencePoints = v;
	var toNext = XPtoLevel(level+1);
	if experiencePoints >= toNext:
		level += 1;
		set_XP(experiencePoints - toNext);
		emit_signal("levelUp", level);
	emit_signal("XPupdate", experiencePoints);

func XPtoLevel(n):
	#return round(max(10 * 1.25 * (n-1), 10));
	return 5 + n;

func addXP(n):
	pickUpSnd.play()
	self.experiencePoints += n;

func addHP(hp):
	pickUpSnd.play()
	self.healthPoints += hp;

func _ready():
	healthPoints = maxHealthPoints;
	hurtbox.connect("area_entered", self, "hurtbox_collision");
	invulnerabilityTimer.connect("timeout", self, "invulnerability_end");

func _physics_process(delta) -> void:
	if dead: return
	var velocity = Vector2((Input.get_action_strength("right") - Input.get_action_strength("left")),
	(Input.get_action_strength("down") - Input.get_action_strength("up"))).normalized() * speed
	if is_invulnerable:
		velocity *= 2;
	if velocity == Vector2.ZERO:
		sprite.playing = false;
		sprite.frame = 0;
	else:
		sprite.playing = true;
	
	var to_mouse = (get_global_mouse_position()-eyesReference.global_position).normalized();
	if weapon.reloadAnim.is_playing():
		eyesSprite.offset = Vector2.DOWN * 0.5;
	else:
		eyesSprite.offset = to_mouse * 0.5;
	eyesSprite.flip_h = to_mouse.x < 0;
	
	sprite.flip_h = to_mouse.x < 0;
	coolhat.flip_h = not sprite.flip_h;
	weaponSprite.flip_h = to_mouse.x < 0;
	soupParticles.position.x = -4 * sign(to_mouse.x);
	
	move_and_slide(velocity);

func take_damage(v : float):
	if dead: return
	self.healthPoints -= (v*(1-defense));
	hitSnd.play();
	invulnerabilityAnim.play("iframes");
	invulnerabilityTimer.start(invulnerabilityTime);
	hurtboxColl.set_deferred("disabled",true)
	is_invulnerable = true;

func invulnerability_end():
	invulnerabilityAnim.play("RESET");
	hurtboxColl.set_deferred("disabled", false);
	is_invulnerable = false;

func hurtbox_collision(area):
	if dead: return
	if area is Projectile:
		take_damage(area.damage)
	elif area is GroundAttack:
		take_damage(area.damage)
	else:
		take_damage(area.get_parent().baseDamage);
