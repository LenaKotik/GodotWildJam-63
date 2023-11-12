extends KinematicBody2D

export var speed : float;
export var maxSpeed : float;
export(float,0,1) var friction : float;

onready var spr : Sprite = $Sprite;

var velocity : Vector2 = Vector2.ZERO;

func _process(_delta : float) -> void:
	velocity += Vector2((Input.get_action_strength("right") - Input.get_action_strength("left")),
	(Input.get_action_strength("down") - Input.get_action_strength("up"))) * speed;
	
	var curSpeed =  velocity.length()+0.01;
	var cappedSpeed = min(curSpeed,maxSpeed);
	print(cappedSpeed)
	
	velocity = velocity/curSpeed*cappedSpeed;
	
	var curFriction = clamp(friction*(100/cappedSpeed),0,1)
	velocity = lerp(velocity, Vector2.ZERO, curFriction);
	
	move_and_slide(velocity);
