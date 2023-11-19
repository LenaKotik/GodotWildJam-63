extends Node2D
class_name Weapon
signal AMMOupdate(ammo)

export var projectile : PackedScene # сцена запускаемого снаряда (далее проджектайла)
export var damage : float
export var critDamgeMultiplier : float = 1;
export(int, 0, 100) var critChance;
export var attackSpeed : float = 1;
export var reloadSpeed : float = 1;
export var projectileScale : float = 1
export var projectilePierce : int = 1;
export var maxAmmo : int;

onready var spawnPos = $ProjSpawnPos as Position2D;
onready var shootAnim = $ShootAnim as AnimationPlayer;
onready var reloadAnim = $ReloadAnim as AnimationPlayer;
onready var shootSnd = $ShootSnd as AudioStreamPlayer2D

var autoShoot = false;
var ammo : int setget set_ammo;

func set_ammo(v):
	ammo = max(0, min(maxAmmo,v))
	emit_signal("AMMOupdate", ammo);

func _ready():
	shootAnim.playback_speed = attackSpeed;
	reloadAnim.playback_speed = reloadSpeed;
	self.ammo = maxAmmo;
	
func _physics_process(delta):
	
	shootAnim.playback_speed = attackSpeed;
	reloadAnim.playback_speed = reloadSpeed;
	
	var mousePos = get_global_mouse_position();
	look_at(mousePos);
	
	if (Input.is_action_just_pressed("shoot") or autoShoot)and not shootAnim.is_playing() and not reloadAnim.is_playing():
		if ammo > 0:
			shootAnim.play("shooting");
		else:
			reloadAnim.play("reloading");
	if (Input.is_action_just_pressed("autoshoot")):
		autoShoot = not autoShoot;

func reloadOctave():
	self.ammo += ceil(float(maxAmmo)/8.0)

func shoot(): # функция стрельбы
	self.ammo -= 1;
	var P = projectile.instance() as PlayerProjectile;
	P.direction = (get_global_mouse_position()-global_position).normalized(); 
	P.scale = Vector2(projectileScale, projectileScale); 
	P.pierce = projectilePierce;
	P.damage = damage;
	if (randi()%100)<critChance:
		P.damage *= critDamgeMultiplier;
		P.crit = true;
	P.moveSpeed *= attackSpeed;
	P.global_position = spawnPos.global_position;
	get_tree().current_scene.add_child(P); 
