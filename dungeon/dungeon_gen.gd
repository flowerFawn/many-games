extends Node2D


@export var node_tiles:TileMapLayer
var dungeon:DungeonLayout

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	generate()
	
func generate() -> void:
	dungeon = DungeonLayout.new(5, 5, Vector2i(0, 0), Vector2i(4, 4))
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
		set_empty_grid()
		generate_grid()
		
	func set_empty_grid() -> void:
		var y_axis:Array[DungeonRoom]
		y_axis.resize(y_size)
		room_grid = []
		room_grid.resize(x_size)
		for i:int in range(y_size):
			room_grid[i] = y_axis.duplicate()
		print(room_grid)
		
	func generate_grid() -> void:
		var current_position:Vector2i = start
		var next_move:Vector2i
		while current_position != end:
			current_position += next_move
			if current_position == end:
				set_room(current_position.x, current_position.y, DungeonRoom.new(false, false, false, false))
				return
			if r.randf() <= 0.5 and end.x != current_position.x:
				#on x
				next_move = Vector2(1, 0) * ((end.x -current_position.x) / abs(end.x -current_position.x))
			elif end.y != current_position.y:
				#on y
				next_move = Vector2i(0, 1) * ((end.y -current_position.y) / abs(end.y -current_position.y))
			else:
				#on x again
				next_move = Vector2(1, 0) * ((end.x -current_position.x) / abs(end.x -current_position.x))
			set_room(current_position.x, current_position.y, DungeonRoom.new(false, false, false, false))
			#for x:int in range(x_size):
				#for y:int in range(y_size):
					#set_room(x, y, DungeonRoom.new())
		print(room_grid)
		
	func set_room(x:int, y:int, value:DungeonRoom) -> void:
		room_grid[x][y] = value
	
	func get_room(x:int, y:int) -> DungeonRoom:
		assert(x < x_size and start.y < y_size and start.x >= 0 and start.y >= 0, "OOB")
		return room_grid[x][y]

class DungeonRoom:
	var door_north:bool
	var door_east:bool
	var door_south:bool
	var door_west:bool
	func _init(pn:bool, pe:bool, ps:bool, pw:bool):
		door_north = pn
		door_east = pe
		door_south = ps
		door_west = pw
