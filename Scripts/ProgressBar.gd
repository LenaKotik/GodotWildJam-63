extends TextureProgress

export var label : PackedScene

func _make_custom_tooltip(for_text):
	var L = label.instance() as Label
	L.text = for_text;
	return L;
