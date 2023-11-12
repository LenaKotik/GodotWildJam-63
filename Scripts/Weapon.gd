extends Node2D
class_name Weapon

export var projectile : PackedScene # сцена запускаемого снаряда (далее проджектайла)
export var cooldown : float
export var projectileScale : float = 1

onready var spawnPos = $ProjSpawnPos as Position2D;
onready var shootAnim = $ShootAnim as AnimationPlayer;
onready var cdTimer = $CoolDown as Timer;

var autoShoot = false;

func _physics_process(delta):
	look_at(get_global_mouse_position()); # буквально смотрим на мышку
	if (Input.is_action_just_pressed("shoot") or autoShoot)and cdTimer.is_stopped():
		shootAnim.play("shooting");
	if (Input.is_action_just_pressed("autoshoot")):
		autoShoot = not autoShoot;

func shoot(): # функция стрельбы
	var P = projectile.instance() as Projectile; # создаем экземпляр projectile
	P.direction = (get_global_mouse_position()-global_position).normalized(); # устанавливаем направление (используя свойства векторов получаем направление в сторону мышки) 
	P.scale = Vector2(projectileScale, projectileScale); # меняем размер проджектайла использовать scale на collision shape это плохо, но мне насрать
	P.global_position = spawnPos.global_position; # устанавлиеваем позицию
	get_tree().current_scene.add_child(P); # добавляем проджектайл как дитя корня сцены
	cdTimer.start(cooldown);
