extends Node2D

const FILL_PERCENTAGE: float = 0.2
const LADDER_CHANCE: float = 0.1
const ROCK_SCENE = preload("res://scenes/rock.tscn")
const LADDER_SCENE = preload("res://scenes/ladder.tscn")

@export var rock_types: Array[RockData] = []

@onready var rock_container: Node2D = $RockContainer
@onready var current_map: Node2D = $Map
@onready var player: Player = $Player

var current_depth: int = 1
var down_ladder: Area2D
var rocks_remaining: int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_generate_rocks()
	_position_objects()
	
func _position_objects() ->void:
	var player_spawn: Marker2D = current_map.get_node("PlayerSpawn")
	player.reset(player_spawn.position)
	
func _generate_rocks() -> void:
	# clear existing rocks
	for child in rock_container.get_children():
		child.queue_free()
	
	# get tile map layers from current map
	var ground_layer:TileMapLayer = current_map.get_node("ground")
	var decor_layer:TileMapLayer = current_map.get_node("decor")
	var ground_cells:= ground_layer.get_used_cells()
	var available_cells := []
	
	for cell in ground_cells:
		# get tile data at coords
		var tile_data = ground_layer.get_cell_tile_data(cell)
		
		# check if there is decor on tiles
		#get_cell_source_id returns -1 if cell i empty
		
		if decor_layer.get_cell_source_id(cell) != -1:
			continue
		
		# check for can spawn rocks property
		if tile_data and tile_data.get_custom_data("can_spawn_rocks") == true:
			available_cells.append(cell)
	
	available_cells.shuffle()
	
	var num_rocks := int (available_cells.size() * FILL_PERCENTAGE)
	rocks_remaining = num_rocks
	
	var valid_rocks: Array[RockData] = []
	for rock in rock_types:
		if current_depth >= rock.min_depth:
			valid_rocks.append(rock)
	
	for i in range (num_rocks):
		var cell = available_cells[i]
		var rock = ROCK_SCENE.instantiate()
		
		rock.data = get_random_rock(valid_rocks)
		
		#get local position from tilemap
		var local_position = ground_layer.map_to_local(cell)
		
		rock.global_position = local_position
		rock_container.add_child(rock)
		rock.broken.connect(_on_rock_broken)
	
func get_random_rock(options: Array[RockData]) -> RockData:
	var total_weight: int = 0
	
	for rock in options:
		total_weight += rock.rarity
		
	var roll = randi_range(0, total_weight - 1)
	var current_sum: int = 0
	
	for rock in options:
		current_sum += rock.rarity
		if roll < current_sum:
			return rock
	
	return options[0] #fallback to stone if nothing else is picked

func _on_rock_broken(pos: Vector2) -> void:
	rocks_remaining -= 1
	if down_ladder != null:
		return
	var drop_ladder := randf() < LADDER_CHANCE
	if drop_ladder or rocks_remaining == 0:
		_create_down_ladder(pos)

func _create_down_ladder(pos: Vector2) -> void:
	down_ladder = LADDER_SCENE.instantiate()
	down_ladder.position = pos
	add_child(down_ladder)
	down_ladder.ladder_used.connect(_on_down_ladder_used)
	
func _on_down_ladder_used() -> void:
	print("move to next level")
