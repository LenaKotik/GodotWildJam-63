extends Area2D
class_name GroundAttack

export var damage : float;

onready var timer = $Timer as Timer
onready var anim = $Anim as AnimationPlayer

func _ready():
	timer.connect("timeout",anim,"play",["Attack"])
