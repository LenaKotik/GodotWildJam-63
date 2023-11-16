extends Area2D
class_name SoftCollision

func get_push_vector():
	var result = Vector2.ZERO;
	for area in get_overlapping_areas():
		result += (global_position-area.global_position);
	return result.normalized();
