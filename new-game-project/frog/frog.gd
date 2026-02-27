extends CharacterBody2D

@export var node_trajectory:Line2D
@export var node_sprite:Sprite2D
@export var node_ray:RayCast2D
@export var node_collision:CollisionShape2D
@export var a:float = -9.8
@export var speed:float = 1

var state:StringName = &"Sit" #Sit, Jump
var u:Vector2 = Vector2.ZERO

func _physics_process(delta: float) -> void:
	match state:
		&"Sit":
			if get_local_mouse_position().angle() > -0.5 * PI and get_local_mouse_position().angle() < 0:
				show_trajectory()
		&"Jump":
			#speed affects both so it follows the same trajectory. make sure you factor this in with t though
			move_and_collide(velocity * delta * speed)
			velocity.y -= a * delta * speed
		
func _input(event: InputEvent) -> void:
	if event.is_action("jump"):
		if state == &"Sit" and get_local_mouse_position().angle() > -0.5 * PI and get_local_mouse_position().angle() < 0:
			jump()
			
func jump():
	var flip_tween:Tween = create_tween()
	var flip_count:int
	var t:float
	u = get_local_mouse_position().normalized() * min(get_local_mouse_position().length() * 0.2, 50)
	velocity = u
	u.y = -u.y
	node_trajectory.visible = false
	state = &"Jump"
	var peak:Vector2 = get_peak(u)
	t = get_t(u, find_end(peak))
	flip_count = floori(t)
	flip_tween.tween_property(node_sprite, "rotation", TAU * flip_count, t)
	await flip_tween.finished
	node_sprite.rotation = 0
	state = &"Sit"
	node_trajectory.visible = true
	node_collision.disabled = false
	await get_tree().physics_frame
	node_collision.disabled = true
	
func get_peak(u:Vector2) -> Vector2:
	var s:Vector2
	var t:float #time of peak
	s.y = ((u.y ** 2) / (2 * -a))
	#1/2at^2 - u.yt + s
	t = solve_quadratic((0.5 * -a),-u.y,s.y)
	s.x = t * u.x
	return s
	
func find_end(peak:Vector2, resolution:float = 1) -> Vector2:
	#print(peak)
	var found:bool = false
	var distance:float = 5
	while not found and distance <= 1000:
		node_ray.position = Vector2(distance, get_from_jump_quadratic(peak, distance))
		node_ray.force_raycast_update()
		if node_ray.is_colliding():
			found = true
		else:
			distance += resolution
	if found:
		return to_local(node_ray.get_collision_point())
	else:
		return node_ray.position
		
	
func get_t(u:Vector2, end:Vector2) -> float:
	print(end.x / u.x)
	return (end.x / u.x) / speed
	
	
func show_trajectory():
	var s:Vector2
	var t:float #time of peak
	u = get_local_mouse_position().normalized() * min(get_local_mouse_position().length() * 0.2, 50)
	u.y = -u.y
	s = get_peak(u)
	node_trajectory.clear_points()
	var x:float
	for p in range(11):
		x = ((find_end(s).x) / 10) * p
		node_trajectory.add_point(Vector2(x, get_from_jump_quadratic(s, x)))
	#print(find_end(s))
	#print("s:%s, u:%s, t:%s" % [s, u, t])
	


func solve_quadratic(aq:float, b:float, c:float) -> float: #returns positive/higher root
	var disc:float = max((b*b) - (4 * aq * c), 0)
	#if disc < 0:
		#print("a:%s, b:%s, c:%s" % [aq, b, c])
	return (-b + sqrt(disc)) / (2.0 * aq)
	
func get_from_jump_quadratic(peak:Vector2, x:float) -> float:
	return ((x * (x - (2 * peak.x))) / (peak.x ** 2)) * peak.y
	
