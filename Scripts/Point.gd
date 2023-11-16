extends Sprite
class_name Point

signal collected;

export var hitRadius : float;
export var accel : float;
export var rotat : float;

var target : Node2D;
var fullDistance : float;
var speed : float = 0;

func _ready():
	fullDistance = (target.global_position-global_position).length();

func _physics_process(delta):
	var direction = (target.global_position-global_position);
	var distance = direction.length();
	
	if (distance <= hitRadius):
		emit_signal("collected");
		queue_free();
	
	direction /= distance;
	
	speed += accel;
	rotation_degrees += rotat;
	
	global_position += direction * speed * delta;
