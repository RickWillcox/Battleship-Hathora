extends Node2D

var reload_timer : float = 5.0
var big_explosion_counter : int = 0
var dead : bool = false
var new_position : Vector2 = Vector2(-30, -30)
var new_rotation : float = 0.0
var ship_colour_index : int

export var turn_speed : int = 5
export var move_speed : int = 180

# Nodes
onready var sprite : Sprite = get_node("Sprite")
onready var effect_position : Position2D = get_node("EffectPosition")
onready var big_explosion_timer : Timer = get_node("BigExplosionTimer")
onready var animation_player : AnimationPlayer = get_node("YellowGlowCircle/AnimationPlayer")

# Ships
onready var ship_colours : Array = [
	preload("res://Assets/Ships/black_ship.png"),
	preload("res://Assets/Ships/blue_ship.png"),
	preload("res://Assets/Ships/green_ship.png"),
	preload("res://Assets/Ships/red_ship.png"),
	preload("res://Assets/Ships/white_ship.png"),
	preload("res://Assets/Ships/yellow_ship.png")	
]

onready var black_ship : Resource = preload("res://Assets/Ships/black_ship.png")
onready var blue_ship : Resource = preload("res://Assets/Ships/blue_ship.png")
onready var green_ship : Resource = preload("res://Assets/Ships/green_ship.png")
onready var red_ship : Resource = preload("res://Assets/Ships/red_ship.png")
onready var white_ship : Resource = preload("res://Assets/Ships/white_ship.png")
onready var yellow_ship : Resource = preload("res://Assets/Ships/yellow_ship.png")

# Effects
onready var explosion : Resource = preload("res://Scenes/Explosion.tscn")

# Server Data
var id : String
var hit_count : int = 0
var hit_count_set : bool = false

func _physics_process(delta):
	if !dead:
		position = position.move_toward(new_position, delta * move_speed)
		rotation = lerp_angle(rotation, new_rotation, delta * turn_speed)
	
func update_ship(data):
	if data.has("x"):
		new_position.x = data.x
	if data.has("y"):
		new_position.y = data.y
	if data.has("angle"):
		new_rotation = data.angle
	if data.has("hitCount"):
		if !dead:
			if hit_count_set:
				var tmp_hc
				if hit_count <  data.hitCount:
					hit_count = data.hitCount
					_on_hit()
			else:
				hit_count_set = true 
				hit_count = data.hitCount

func _ready():
	# Logic for setting the ships sprite
	animation_player.play("Circle")
	sprite.texture = ship_colours[ship_colour_index]
	
func _on_hit():
	play_explosion_animation()
	if hit_count < 3:
		sprite.frame += 1
	else:
		sprite.frame = 3
		dead = true
		big_explosion_timer.start()
		play_explosion_animation()
			
func play_explosion_animation():
	var explosion_instance = explosion.instance()
	explosion_instance.position.x = effect_position.position.x + rand_range(-15, 15) 
	explosion_instance.position.y = effect_position.position.y + rand_range(-15, 15) 
	add_child(explosion_instance)
			
func _on_BigExplostionTimer_timeout():
	big_explosion_counter += 1
	var big_explosion_instance = explosion.instance()
	var rand_scale = rand_range(0.5, 1.3)
	
	big_explosion_instance.position.x = effect_position.position.x + rand_range(-15, 15) 
	big_explosion_instance.position.y = effect_position.position.y + rand_range(-15, 15)
	
	big_explosion_instance.scale.x = rand_scale
	big_explosion_instance.scale.y = rand_scale
	
	add_child(big_explosion_instance)
	if (big_explosion_counter >= 5):
		big_explosion_timer.stop()
