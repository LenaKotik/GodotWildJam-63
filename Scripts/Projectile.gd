extends Area2D
class_name Projectile

export var damage : float
export var pierce  : int = 1;
export var moveSpeed : float;
export var lifetime : int;
export var startCountdownOutsideScreen : bool

onready var visNotifier = $VisibilityNotifier as VisibilityNotifier2D;
onready var lifetimer = $Lifetime as Timer;

var direction : Vector2;

func _ready():
	self.connect("area_entered", self, "collided");
	
	lifetimer.connect("timeout",self,"queue_free");
	lifetimer.wait_time = lifetime;
	rotate(direction.angle());
	if not startCountdownOutsideScreen:
		lifetimer.autostart = true;
	else:
		visNotifier.connect("screen_exited", self, "startTimer");

func collided(_area):
	pierce -= 1;
	if pierce == 0: queue_free()

func startTimer():
	if (lifetimer.is_inside_tree()): lifetimer.start();

func _physics_process(delta):
	global_position += direction*moveSpeed*delta;
