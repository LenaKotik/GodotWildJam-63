extends TextureRect
class_name Frame

export var itemDescription : String
export var itemTexture : Texture;

export var tooltipLabel : PackedScene

onready var itemRect = $Item as TextureRect;
onready var countLabel = $Count as Label;

func _make_custom_tooltip(_for_text):
	var L = tooltipLabel.instance() as Label
	L.text = itemDescription;
	return L;

func set_count(count):
	countLabel.text = "x" +  str(count);

func _ready():
	itemRect.texture = itemTexture;
