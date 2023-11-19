extends Enemy

export var shootInterval : float;
export var projectile : PackedScene;
export var comfortRadius : float

onready var gun = $Gun as Node2D;
onready var gunSprite = $Gun/Sprite as Sprite;
onready var projSpawn = $Gun/Position2D as Node2D;
onready var shootTimer = $ShootTimer as Timer;
onready var shootAnim = $ShootAnim as AnimationPlayer;

func direction() -> Vector2:
	var to_target = (target.global_position-global_position)
	var dist = to_target.length();
	to_target /= dist;
	dist-=comfortRadius;
	if abs(dist) > 10:
		return to_target*sign(dist);
	else:
		return to_target.rotated(PI/2);

func _ready():
	shootTimer.wait_time = shootInterval;
	shootTimer.connect("timeout",shootAnim,"play",["shoot"]);

func _physics_process(delta):
	sprite.offset.x = -7 if sprite.flip_h else 8;
	gunSprite.flip_v = not sprite.flip_h;
	
	gun.look_at(target.global_position);

func shoot():
	var P = projectile.instance() as Projectile
	P.direction = (target.global_position-global_position).normalized();
	P.damage = baseDamage*2
	P.global_position = projSpawn.global_position;
	get_tree().current_scene.add_child(P);
