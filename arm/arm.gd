extends Node2D

@export var node_line:Line2D
@export var upper_arm_length:float
@export var fore_arm_length:float
@export var shoulder_flex_speed:float
@export var elbow_flex_speed:float
@export var static_flip:bool
@export var flip_by_side:bool
@export var flip_if_short:bool

var current_shoulder_angle:float
var current_elbow_angle:float

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	move_towards_goal_point(get_local_mouse_position(), delta)
	show_current_arm()
	
func find_elbow_angle(goal:Vector2) -> float:
	var angle:float = (upper_arm_length ** 2) + (fore_arm_length ** 2) - goal.length_squared()
	angle = angle / (2 * upper_arm_length * fore_arm_length)
	angle = acos(angle)
	return angle
	
func find_shoulder_angle(goal:Vector2, elbow_angle:float) -> float:
	var premoved:Vector2 = Vector2(upper_arm_length, 0) + Vector2(-fore_arm_length, 0).rotated(elbow_angle)
	return premoved.angle_to(goal) #used dot product (which this function does internally) in original desmos

func show_perfect_arm() -> void:
	var goal:Vector2 = get_local_mouse_position()
	var elbow_angle:float = find_elbow_angle(goal)
	if (flip_by_side and goal.x > 0):
		elbow_angle = -elbow_angle
	if static_flip:
		elbow_angle = -elbow_angle
	if (flip_if_short and get_local_mouse_position().length_squared() < (upper_arm_length - fore_arm_length) ** 2):
		elbow_angle = -elbow_angle
	var shoulder_angle:float = find_shoulder_angle(goal, elbow_angle)
	var elbow_position:Vector2 = Vector2(upper_arm_length, 0).rotated(shoulder_angle)
	var hand_position:Vector2 = elbow_position + Vector2(-fore_arm_length, 0).rotated(shoulder_angle + elbow_angle)
	node_line.clear_points()
	node_line.add_point(Vector2.ZERO)
	node_line.add_point(elbow_position)
	node_line.add_point(hand_position)
	
func show_current_arm() -> void:
	var current_elbow_position:Vector2 = Vector2(upper_arm_length, 0).rotated(current_shoulder_angle)
	var current_hand_position:Vector2 = current_elbow_position + Vector2(-fore_arm_length, 0).rotated(current_shoulder_angle + current_elbow_angle)
	node_line.clear_points()
	node_line.add_point(Vector2.ZERO)
	node_line.add_point(current_elbow_position)
	node_line.add_point(current_hand_position)
	
func move_towards_goal_point(goal:Vector2, delta:float) -> void:
	var desired_elbow_angle:float = find_elbow_angle(goal)
	if (flip_by_side and goal.x > 0):
		desired_elbow_angle = -desired_elbow_angle
	if static_flip:
		desired_elbow_angle = -desired_elbow_angle
	if (flip_if_short and get_local_mouse_position().length_squared() < (upper_arm_length - fore_arm_length) ** 2):
		desired_elbow_angle = -desired_elbow_angle
	var desired_shoulder_angle:float = find_shoulder_angle(goal, desired_elbow_angle)
	current_shoulder_angle = move_toward(current_shoulder_angle, desired_shoulder_angle, shoulder_flex_speed * delta)
	current_elbow_angle = move_toward(current_elbow_angle, desired_elbow_angle, elbow_flex_speed * delta)
	print(current_shoulder_angle, " -> ", current_elbow_angle)
