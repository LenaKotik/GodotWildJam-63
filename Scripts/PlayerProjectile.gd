extends Projectile
class_name PlayerProjectile

export var color : Color;
export var crit : bool;
export var rotat: float;

onready var critThing = $CritThing as Sprite;
onready var particles = $Particles2D as CPUParticles2D;
onready var sprite = $Sprite as Sprite;

func _ready():
		
	sprite.modulate = color;
	particles.color = color;
		
	critThing.visible = crit;
	if crit:
		collShape.shape.radius = 14;
func _physics_process(delta):
	if crit: critThing.rotation_degrees+=rotat;
