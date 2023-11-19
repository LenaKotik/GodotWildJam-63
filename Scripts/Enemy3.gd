extends Enemy

func direction():
	var to_target = (target.global_position-global_position)
	var dist = to_target.length();
	to_target /= dist;
	
	return to_target.rotated(PI/4.0);
