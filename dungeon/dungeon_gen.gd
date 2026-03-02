extends Node2D


@export var node_tiles:TileMapLayer
var dungeon:DungeonLayout

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	generate()
	
func generate() -> void:
	dungeon = DungeonLayout.new(6, 6, Vector2i(0, 0), Vector2i(5, 5))
	draw_dungeon()

func draw_dungeon() -> void:
	const EMPTY:Vector2i = Vector2i(0, 0)
	const ROOM:Vector2i = Vector2i(1, 0)
	for x in range(dungeon.x_size):
		for y in range(dungeon.y_size):
			if dungeon.get_room(x, y) == null:
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
		print(room_grid)
		
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
		while current_position != end:
			move = get_valid_moves(validity_grid, current_position).pick_random()
			set_room(current_position.x, current_position.y, DungeonRoom.new(-move))
			validity_grid[current_position.x][current_position.y] = false
			current_position += move
			#for x:int in range(x_size):
				#for y:int in range(y_size):
					#set_room(x, y, DungeonRoom.new())
		print(room_grid)
		
	func set_room(x:int, y:int, value:DungeonRoom) -> void:
		room_grid[x][y] = value
	
	func get_room(x:int, y:int) -> DungeonRoom:
		assert(x < x_size and start.y < y_size and start.x >= 0 and start.y >= 0, "OOB")
		return room_grid[x][y]
		
	func get_position_validity(validity_grid:Array[Array], room:Vector2i) -> bool:
		if not is_position_in_bounds(room):
			return false
		else:
			return validity_grid[room.x][room.y]
		
	func get_valid_moves(validity_grid:Array[Array], from_room:Vector2i) -> Array[Vector2i]:
		var valid_moves:Array[Vector2i]
		var checked:Vector2i
		#north
		print(validity_grid)
		checked = from_room + Vector2i(0, 1)
		if is_position_in_bounds(checked):
			if validity_grid[checked.x][checked.y]:
				valid_moves.append(Vector2i(0, 1))
		#east
		checked = from_room + Vector2i(1, 0)
		if is_position_in_bounds(checked):
			if validity_grid[checked.x][checked.y]:
				valid_moves.append(Vector2i(1, 0))
		#south
		checked = from_room + Vector2i(0, -1)
		if is_position_in_bounds(checked):
			if validity_grid[checked.x][checked.y]:
				valid_moves.append(Vector2i(0, -1))
		#west
		checked = from_room + Vector2i(-1, 0)
		if is_position_in_bounds(checked):
			if validity_grid[checked.x][checked.y]:
				valid_moves.append(Vector2i(-1, 0))
		print(valid_moves)
		return valid_moves
		
	func is_position_in_bounds(point:Vector2i) -> bool:
		if point.x < 0 or point.x >= x_size or point.y < 0 or point.y >= y_size:
			return false
		else:
			return true
	

class DungeonRoom:
	var backtrack:Vector2i
	func _init(given_backtrack:Vector2i):
		backtrack = given_backtrack
