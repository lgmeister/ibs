extends Node2D

onready var animation = $AnimationPlayer
onready var fire_particles_up = $FireParticles
onready var fire_particles_down = $FireParticles2

### Nodes ###
onready var _game = Global._game ### main game scene

### Bomb ###
var damage = 2
var damage_position


func _ready():
	damage_position = position/Global.grid_size - Vector2(1.5,1.5) ## - offset and half a block. Make dynamic later
	animation.play("fire")
	var damage_grid = [int(damage_position.x),int(damage_position.y)]

	
	if _game.box_tiles.has(damage_grid):
		if is_instance_valid(_game.box_tiles[damage_grid]):
			_game.box_tiles[damage_grid].take_damage(damage)
		
	
	

	
