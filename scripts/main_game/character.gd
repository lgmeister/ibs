extends KinematicBody2D

export(Resource) var Character setget _setCharacter


### Scenes ###
onready var _game = Global._game### main game scene
onready var bomb_scene = load("res://resources/scenes/main_game/bomb.tscn")

### Nodes ####
onready var animated_sprite = $AnimatedSprite
onready var _agent = $NavigationAgent2D
onready var bomb_timer = $BombTimer
onready var check_timer = $CheckTimer
onready var _test_agent = $TestNavAgent



### Bools ###
var bomb_dropped = true
var box_reachable = false


### Info ###
var speed = 100
var velocity = Vector2(0,0)
var bomb_wait_time = 2 ### How much time between bomb being allowed to drop

var box_node
var move_location = Vector2(366,366)


### Character Info ###
var char_name
var char_image


func _ready():
	add_to_group("character")
	self.Character = load("res://resources/characters/repo/test_character.tres")
	load_character()
	find_nearest_box(null,false)
	bomb_timer.start()
	check_timer.start()
	
	

func _physics_process(_delta): ### Change to process?
	if _agent.is_navigation_finished():
		drop_bomb()
		return
		


	_agent.set_target_location(move_location)
	var direction = global_position.direction_to(_agent.get_next_location())
	velocity = move_and_slide(speed * direction, Vector2.UP)
	
#
#	if velocity == Vector2(0,0):
#		animated_sprite.animation = "idle"
#		animated_sprite.playing = false
#		animated_sprite.speed_scale = 2
#	else:
	animated_sprite.animation = "moving"
	animated_sprite.playing = true
	animated_sprite.speed_scale = 2
	
	if abs(velocity.x) > abs(velocity.y):
		if velocity.x > 0: animated_sprite.flip_h = false
		else: animated_sprite.flip_h = true
	else:
		if velocity.y > 0: animated_sprite.flip_h = false
		else: animated_sprite.flip_h = true
		
func _setCharacter(newCharacter : Resource):
	Character = newCharacter
	
	char_name = Character.get_Name()
	char_image = Character.get_Image()


func load_character():
	animated_sprite.frames = char_image

		
func find_nearest_box(PreviousBox,Random):

	if _game.box_tile_nodes.size() == 0: return
	
	var nodes = {}
	var node_distance = []
	

	for box in _game.box_tiles.values():
		if is_instance_valid(box):
			nodes[global_position.distance_to(box.global_position)] = box
		
	if nodes.empty(): return	
		
	for distance in nodes:
		node_distance.append(distance)
		
	if not Random:
		node_distance.sort()
	else:
		node_distance.shuffle()
	
	if nodes[node_distance.front()] == PreviousBox:
		if node_distance.size() > 1:
			node_distance.pop_front()
			box_node = nodes[node_distance.front()]
			
			print("finding new box: ", box_node)
			
		else:
			print("last box")
			box_node = nodes[node_distance.front()]
	else:
#		print("here")		
		box_node = nodes[node_distance.front()]
		
		
	var not_check = 0
	
	for surround_area in box_node.block_surround:
		var test_move_location = Vector2(surround_area[0],surround_area[1]) * Global.grid_size
		test_move_location += Vector2(Global.grid_size*1.5,Global.grid_size*1.5) 
		
		_test_agent.set_target_location(test_move_location)
		yield(get_tree().create_timer(.1),"timeout")
		if not is_instance_valid(box_node): return
		if not _test_agent.is_target_reachable():
			not_check += 1
			if not_check == box_node.block_surround.size():
				print("Blocked: trying to find next nearest box")

				find_nearest_box(box_node,true)
			continue
		else:
			pass
#			print(test_move_location/Global.grid_size - Vector2(1.5,1.5) , " REACHABLE")
		
		
#		print(surround_area, box_node.block_surround)
		
		if not is_instance_valid(box_node): 
			print("NOW THIS")
			return
		if not surround_area in box_node.block_surround:
			return
			
		if box_node.block_surround[surround_area] == false:
			box_node.block_surround[surround_area] = true
			move_location = Vector2(surround_area[0],surround_area[1]) * Global.grid_size
			### below is offset from game, make dynamic later
			move_location += Vector2(Global.grid_size*1.5,Global.grid_size*1.5) 
						
			_agent.set_target_location(move_location)
			
			yield(get_tree().create_timer(.1),"timeout")
		
			box_reachable = true

			return
		else:
			if not Random:
				find_nearest_box(null,true)
#				print("cant find anywhere to go")
			else:
				print("REALLY cant find anywhere to go")



func drop_bomb():
	if bomb_dropped or not box_reachable: return
	
	if not is_instance_valid(box_node):
		find_nearest_box(null,true)
		return
	else:
		if box_node.active == false: return
		
	bomb_dropped = true
	var scene = bomb_scene.instance()
		
	scene.box_node = box_node
	scene.position = move_location
#	print("Dropping bomb on: ", move_location.x/Global.grid_size - 1.5, ", " , move_location.y/Global.grid_size - 1.5)
	
	
	_game.add_child(scene)
	
	if _game.box_tiles.size() > 1:
		find_nearest_box(box_node,false)

	bomb_timer.start(bomb_wait_time)

func _on_BombTimer_timeout():
	bomb_dropped = false


func _on_CheckTimer_timeout():
	find_nearest_box(null,true)
