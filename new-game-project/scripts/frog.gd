extends CharacterBody2D

@export var node_trajectory:Line2D
@export var a:float = -9.8

var state:StringName = &"Sit" #Sit, Jump
var u:Vector2

func _physics_process(delta: float) -> void:
	if get_local_mouse_position().angle() > -0.5 * PI and get_local_mouse_position().angle() < 0:
		show_trajectory()
		
func _input(event: InputEvent) -> void:
	if event.is_action("jump"):
		if state == &"Sit":
			jump()
			
func jump():
	pass
	
func show_trajectory():
	var s:Vector2
	var t:float #time of peak
	u = get_local_mouse_position().normalized()
	u = u * min(get_local_mouse_position().length() * 0.2, 50)
	u.y = -u.y
	s.y = ((u.y ** 2) / (2 * -a))
	#1/2at^2 - u.yt + s
	t = solve_quadratic((0.5 * -a),-u.y,s.y)
	s.x = t * u.x
	s.y = -s.y
	node_trajectory.clear_points()
	var x:float
	for p in range(11):
		x = ((2 * s.x) / 10) * p
		node_trajectory.add_point(Vector2(x, -get_from_jump_quadratic(s, x)))
	print("s:%s, u:%s, t:%s" % [s, u, t])
	


func solve_quadratic(aq:float, b:float, c:float) -> float: #returns positive/higher root
	var disc:float = max((b*b) - (4 * aq * c), 0)
	if disc < 0:
		print("a:%s, b:%s, c:%s" % [aq, b, c])
	return (-b + sqrt(disc)) / (2.0 * aq)
	
func get_from_jump_quadratic(peak:Vector2, x:float) -> float:
	return ((x * (x - (2 * peak.x))) / peak.x ** 2) * peak.y
	
