extends Node2D


@export var node_tiles:TileMapLayer
var dungeon:DungeonLayout

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	generate()
	
func generate() -> void:
	dungeon = DungeonLayout.new(20, 20, Vector2i(0, 0), Vector2i(19, 19))
	draw_dungeon()

func draw_dungeon() -> void:
	const EMPTY:Vector2i = Vector2i(0, 0)
	const ROOM:Vector2i = Vector2i(1, 0)
	for x in range(dungeon.x_size):
		for y in range(dungeon.y_size):
			if dungeon.get_room(Vector2i(x, y)) == null:
				node_tiles.set_cell(Vector2i(x, y), 0, EMPTY)
			else:
				node_tiles.set_cell(Vector2i(x,y), 0, ROOM)
			

class DungeonLayout:
	var r:RandomNumberGenerator = RandomNumberGenerator.new()
	var x_size:int
	var y_size:int
	var start:Vector2i
	var end:Vector2i
	var room_grid:Array[Array]
	func _init(given_x_size:int, given_y_size:int, given_start:Vector2i, given_end:Vector2i) -> void:
		x_size = given_x_size
		y_size = given_y_size
		start = given_start
		end = given_end
		assert(start.x < x_size and start.y < y_size and start.x >= 0 and start.y >= 0, "start OOB")
		assert(end.x < x_size and end.y < y_size and end.x >= 0 and end.y >= 0, "end OOB")
		generate_grid()
		
	func set_empty_grid() -> void:
		var y_axis:Array[DungeonRoom]
		y_axis.resize(y_size)
		room_grid = []
		room_grid.resize(x_size)
		for i:int in range(y_size):
			room_grid[i] = y_axis.duplicate()
		
	func get_validity_grid() -> Array[Array]:
		var validity_grid:Array[Array] = []
		var y_axis:Array[bool]
		y_axis.resize(y_size)
		y_axis.fill(true)
		validity_grid = []
		validity_grid.resize(x_size)
		validity_grid.duplicate()
		for i:int in range(y_size):
			validity_grid[i] = y_axis.duplicate()
		return validity_grid
		
	func generate_grid() -> void:
		set_empty_grid()
		var validity_grid:Array[Array] = get_validity_grid()
		var current_position:Vector2i = start
		var move:Vector2i
		var moves:Array[Vector2i]
		var revalidify:Vector2i
		set_room(current_position, DungeonRoom.new(Vector2i.ZERO))
		while current_position != end:
			moves = get_valid_moves(validity_grid, current_position)
			if current_position == start:
				validity_grid = get_validity_grid()
			if moves.is_empty():
				move = -get_room(current_position).direction
				set_room(current_position, null)
				current_position += move
			else:
				validity_grid[revalidify.x][revalidify.y] = true
				move = moves.pick_random()
				current_position += move
			if get_room(current_position) == null:
				set_room(current_position, DungeonRoom.new(move))
				validity_grid[current_position.x][current_position.y] = false
		print(room_grid)
		
	func set_room(pos:Vector2i, value:DungeonRoom) -> void:
		room_grid[pos.x][pos.y] = value
	
	func get_room(pos:Vector2i) -> DungeonRoom:
		assert(pos.x < x_size and pos.y < y_size and pos.x >= 0 and pos.y >= 0, "OOB")
		return room_grid[pos.x][pos.y]
		
	func get_position_validity(validity_grid:Array[Array], room:Vector2i) -> bool:
		if not is_position_in_bounds(room):
			return false
		else:
			return validity_grid[room.x][room.y]
		
	func get_valid_moves(validity_grid:Array[Array], from_room:Vector2i) -> Array[Vector2i]:
		var valid_moves:Array[Vector2i]
		var checked:Vector2i
		#north
		checked = from_room + Vector2i(0, 1)
		if get_position_validity(validity_grid, checked):
			valid_moves.append(Vector2i(0, 1))
		#east
		checked = from_room + Vector2i(1, 0)
		if get_position_validity(validity_grid, checked):
			valid_moves.append(Vector2i(1, 0))
		#south
		checked = from_room + Vector2i(0, -1)
		if get_position_validity(validity_grid, checked):
			valid_moves.append(Vector2i(0, -1))
		#west
		checked = from_room + Vector2i(-1, 0)
		if get_position_validity(validity_grid, checked):
			valid_moves.append(Vector2i(-1, 0))
		return valid_moves
		
	func is_position_in_bounds(point:Vector2i) -> bool:
		if point.x < 0 or point.x >= x_size or point.y < 0 or point.y >= y_size:
			return false
		else:
			return true
	

class DungeonRoom:
	var direction:Vector2i
	func _init(given_direction:Vector2i):
		direction = given_direction
