extends Sprite2D

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	rotation = 0.02 * PI * sin(Time.get_unix_time_from_system())
