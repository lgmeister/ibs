extends StaticBody2D

export(Resource) var Block setget _setBlock

### Static Scenes ###
onready var _game = Global._game### main game scene

### Load Scenes ###
var type
var block_repo =\
	{
		"box":"res://resources/blocks/repo/test_box.tres",
		"wall":"res://resources/blocks/repo/test_wall.tres",
		"floor":"res://resources/blocks/repo/test_floor.tres",	
	}

### Block Info to Load ###
var block_name
var block_image
var block_frame
var block_max_health = 10
var block_passthrough



### Dynamic Block Info ###
var block_surround = {}
var row
var column



### Nodes ###
onready var block_texture = $BlockTexture
onready var block_collision = $BlockCollision
onready var health_bar = $Health/HealthBar
onready var explode_sprite = $ExplodeSprite


onready var nav_poly= $NavPoly


### Globals ###
onready var grid = Global.grid_size
onready var half_grid = grid/2

### Info ###
var block_health
var active = true



func _ready():
	add_to_group("block_"+type)
	self.Block = load(block_repo[type])
	load_block()


func _setBlock(newBlock : Resource):
	Block = newBlock
	
	block_name = Block.get_Name()
	block_image = Block.get_Image()
	block_frame = Block.get_Frame()
	block_passthrough = Block.get_Passthrough()
	
	
func load_block():
	block_texture.texture = block_image

	
	block_texture.hframes = block_image.get_size().x/grid
	block_texture.vframes = block_image.get_size().y/grid
	block_texture.frame = block_frame
	
	
	if block_passthrough:
		block_collision.disabled = true
	
	if type == "box":
		block_health = block_max_health
		health_bar.max_value = block_max_health
		health_bar.value = block_health

		z_index = 5
		
	if type == "wall":
		z_index = 7
#	
	if type == "floor":
		nav_allowed(true)
		
	
func nav_allowed(choice): ### Is navigation polygon active? allowing for nav on this tile
	nav_poly.enabled = choice
	
	
	
func take_damage(damage):
	block_health -= damage
	health_bar.value = block_health
	
	if block_health < block_max_health:
		health_bar.show()
		
	if block_health <= 0:
		active = false
		explode_sprite.playing = true
		_game.box_tile_nodes.erase(self)
		block_texture.hide()
		health_bar.hide()
		
		Global.box_0_destroyed += 1 ### make dynamic based on type of box
		yield(explode_sprite,"animation_finished")
		_game.floor_tiles[[row,column]].nav_allowed(true) ## Turns on nav polygon on floortile
		_game.box_tiles.erase([row,column])
		get_tree().call_group("block_box","_check_surroundings")
		_game.num_of_boxes -= 1
		queue_free()
	

func _check_surroundings():	
	var check_walls = [[row - 1, column],[row + 1, column],[row,column-1],[row,column+1]]
	for check in check_walls:
		
		if check[0] == 0 or check[1] == 0: ### Also need to add last row
			continue

		if not check in _game.wall_tiles and not check in _game.box_tiles:
			block_surround[check] = false
		else:
			block_surround[check] = true
#
#
#	print(block_surround)

