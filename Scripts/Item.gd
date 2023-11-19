extends Area2D
class_name Item

signal pickedUp

export var itemID : int
export var itemName : String;
export var itemDescription : String;

onready var sprite = $Sprite;
onready var lifetimer = $Lifetimer as Timer;
onready var blinkAnim = $BlinkAnim as AnimationPlayer;

var has_player : bool = false;

func _ready():
	lifetimer.connect("timeout",blinkAnim,"play",["Disapear"]);
	self.connect("body_entered",self,"entered")
	self.connect("body_exited",self,"exited")

func entered(body):
	if body is Player:
		has_player = true;

func exited(body):
	if body is Player:
		has_player = false;

func _unhandled_key_input(event):
	if event.is_action_pressed("pickup") and has_player:
		emit_signal("pickedUp");
		call_deferred("queue_free");

func get_texture():
	return sprite.texture;
