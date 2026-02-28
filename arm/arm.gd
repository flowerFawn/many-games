extends Node2D

@export var node_line:Line2D
@export var upper_arm_length:float
@export var fore_arm_length:float
@export var static_flip:bool
@export var flip_by_side:bool

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	show_arm()
	
func find_elbow_angle(goal:Vector2) -> float:
	var angle:float = (upper_arm_length ** 2) + (fore_arm_length ** 2) - goal.length_squared()
	angle = angle / (2 * upper_arm_length * fore_arm_length)
	angle = acos(angle)
	return angle
	
func find_shoulder_angle(goal:Vector2, elbow_angle:float) -> float:
	var premoved:Vector2 = Vector2(upper_arm_length, 0) + Vector2(-fore_arm_length, 0).rotated(elbow_angle)
	return premoved.angle_to(goal) #used dot product (which this function does internally) in original desmos

func show_arm() -> void:
	var goal:Vector2 = get_local_mouse_position()
	var elbow_angle:float = find_elbow_angle(goal)
	if (flip_by_side and goal.x > 0) or static_flip:
		elbow_angle = -elbow_angle
	var shoulder_angle:float = find_shoulder_angle(goal, elbow_angle)
	var elbow_position:Vector2 = Vector2(upper_arm_length, 0).rotated(shoulder_angle)
	var hand_position:Vector2 = elbow_position + Vector2(-fore_arm_length, 0). rotated(shoulder_angle + elbow_angle)
	node_line.clear_points()
	node_line.add_point(Vector2.ZERO)
	node_line.add_point(elbow_position)
	node_line.add_point(hand_position)
	
