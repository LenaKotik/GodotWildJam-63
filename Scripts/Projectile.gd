extends Area2D
class_name Projectile

export var color : Color;
export var crit : bool;
export var damage : float;
export var pierce  : int = 1;
export var moveSpeed : float;
export var lifetime : int;
export var rotat: float;
export var startCountdownOutsideScreen : bool

onready var visNotifier = $VisibilityNotifier as VisibilityNotifier2D;
onready var collShape = $CollisionShape2D as CollisionShape2D;
onready var lifetimer = $Lifetime as Timer;
onready var critThing = $CritThing as Sprite;

onready var particles = $Particles2D as CPUParticles2D;
onready var sprite = $Sprite as Sprite;

var direction : Vector2;

func _ready():
	self.connect("area_entered", self, "collided");
	
	sprite.modulate = color;
	particles.color = color;
	
	critThing.visible = crit;
	if crit:
		collShape.shape.radius = 14;
	
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
	if crit: critThing.rotation_degrees+=rotat;
