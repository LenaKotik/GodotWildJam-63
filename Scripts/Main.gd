extends Node2D

export var enemy : PackedScene

onready var player = $MC as Player;
onready var spawnTimer = $SpawnTimer as Timer;

func _ready():
	spawnTimer.connect("timeout",self,"spawn");
	spawn();

func spawn():
	var E = enemy.instance() as Enemy;
	E.global_position = (player.global_position) + Vector2(1024,0).rotated(rand_range(-TAU,TAU));
	E.target = player;
	add_child(E);
