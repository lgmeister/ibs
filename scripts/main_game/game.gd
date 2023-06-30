extends Node2D

### Nodes ###
onready var gridlines = $Gridlines
onready var navigation = $Navigation


### Scenes ###
onready var block_scene = load("res://resources/scenes/main_game/block.tscn")
onready var character_scene = load("res://resources/scenes/main_game/character.tscn")


### Game Info ###
onready var grid_square_size = Global.grid_size
onready var window_size = get_viewport().size
var field_size = Vector2(17,17)
var field_offset = Vector2(1,1)


### Level Info ###
var level_started = false
var level_cleared = false
var num_of_boxes = 0

### Obstacle ### ### Eventually make this dynamic
var _obstacle_type = "pattern"
var obIteration = 0
var obstacles = [1,0] ### Change the pattern of the obstacles

### Game Field ###
var floor_tiles = {}
var wall_tiles = {}
var box_tiles = {}

var box_tile_nodes = [] ## Scene nodes



func _ready():
	Global._game = self
	create_grid()
	create_blocks()
	
	reset_level()

func _process(_delta):
	if level_started:
		if num_of_boxes <= 0:
			print("Level Cleared")
			level_started = false
			reset_level()


func reset_level():
	num_of_boxes = 0
	
	get_tree().call_group("character","queue_free")
	create_all_boxes()
	
	create_characters()
	create_characters()
	create_characters()
	create_characters()
	
	get_tree().call_group("block_box","_check_surroundings")
	level_started = true


func create_grid():
	var column = window_size.x/grid_square_size
	var row = window_size.y/grid_square_size
	
	for number in column:
		var line = Line2D.new()
		line.width = 2
		line.add_point(Vector2(number*grid_square_size,0))
		line.add_point(Vector2(number*grid_square_size,window_size.y))
		gridlines.add_child(line)
		
	for number in row:
		var line = Line2D.new()
		line.width = 2
		line.add_point(Vector2(0,number*grid_square_size))
		line.add_point(Vector2(window_size.x,number*grid_square_size))
		gridlines.add_child(line)
		
		
func create_blocks():
	var scene
	var grid = Global.grid_size
	var row_odd
	var _column_odd
	
	for row in range(field_size.x):
		if row % 2 == 1: row_odd = true
		else: row_odd = false
		
		for column in range(field_size.y):
			if column % 2 == 1: _column_odd = true
			else: _column_odd = false
			
			
			if row == 0 or row == field_size.x - 1\
			or column == 0 or column == field_size.y - 1:
				scene = block_scene.instance()
				wall_tiles[[row,column]] = scene
				scene.type = "wall"
			else:
				if obstacles[obIteration] == 1 and row_odd == false:
					scene = block_scene.instance()
					wall_tiles[[row,column]] = scene
					scene.type = "wall"
				else:
					scene = block_scene.instance()
					floor_tiles[[row,column]] = scene
					scene.type = "floor"
					
					
				obIteration += 1	
				if obIteration == obstacles.size():
					obIteration = 0	
			
			scene.row = row
			scene.column = column
			
			scene.position =\
			Vector2(row * grid + grid/2, column * grid + grid/2) + (field_offset * grid)
			navigation.add_child(scene)
			
func create_all_boxes():
	var open_tiles = []
	for tile in wall_tiles:
		
		if not tile in floor_tiles:
			open_tiles.append([tile[0]+1,tile[1]+1])

	for open in open_tiles:
		if not open[0] >= 7 and not open[1] >= 7:
			create_box(open[0],open[1])
			
func create_box(row,column):
	var scene = block_scene.instance()
	var grid = Global.grid_size
	
	scene.type = "box"
	scene.position =\
	Vector2(row * grid + grid/2, column * grid + grid/2) + (field_offset * grid)
	
	
	box_tiles[[row,column]] = scene

	
	var check_walls = [[row - 1, column],[row + 1, column],[row,column-1],[row,column+1]]
	for check in check_walls:
		if not check in wall_tiles:
			scene.block_surround[check] = false
			
	scene.row = row
	scene.column = column
	
	floor_tiles[[row,column]].nav_allowed(false) ## Turns off nav polygon on floortile
	
	num_of_boxes += 1
	box_tile_nodes.append(scene)
	navigation.add_child(scene)
			
func create_characters():
	var grid = Global.grid_size
	var scene = character_scene.instance()
	scene.position = Vector2(12 * grid, 12 * grid)
	navigation.add_child(scene)

