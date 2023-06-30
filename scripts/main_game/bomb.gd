extends Node2D

onready var sprite = $Sprite
onready var explode_sprite = $ExplodeSprite
onready var animation = $AnimationPlayer
onready var fire_particles = $Sprite/FireParticles

onready var fire_scene = load("res://resources/scenes/main_game/bomb_fire.tscn")


### Bomb ###
var explode_time = 2
var damage = 5


### Nodes ###
var box_node
onready var _game = Global._game### main game scene


### Misc ###
var click_number = 0
var click_number_max = 10

func _ready():
	
	fire_particles.emitting = true
	animation.play("pulse")
	yield(get_tree().create_timer(explode_time),"timeout")
	explode()
	

func explode():
	explode_sprite.playing = true

#	if is_instance_valid(box_node):
#		box_node.take_damage(damage)
	sprite.hide()

	
	
	var surround_areas = [
		[Vector2(global_position.x - Global.grid_size, global_position.y),0],
		[Vector2(global_position.x + Global.grid_size, global_position.y),360],
		[Vector2(global_position.x, global_position.y - Global.grid_size),90],
		[Vector2(global_position.x, global_position.y + Global.grid_size),270],
	] ### Position, Turn degrees
	
	
	for area in surround_areas:
		var scene = fire_scene.instance()
		scene.position = area[0]
		scene.rotation_degrees = area[1]
		scene.damage = damage
		_game.add_child(scene)
		
	yield(explode_sprite,"animation_finished")
	queue_free()



func _on_BombButton_pressed():
	if click_number == click_number_max: return
	z_index = 12
	click_number += 1
	
	self.scale += Vector2(.1,.1)
	damage += 1 ### Make dynamic to 10% at some point
