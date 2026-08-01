extends CharacterBody2D


const SPEED = 100

var last_direction: Vector2 = Vector2.RIGHT
var is_mining: bool = false
var hitbox_offset: Vector2 = Vector2.RIGHT
var detected_rocks: Array = []
var pickaxe_strength: int = 1

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var hitbox: Area2D = $hitbox
@onready var hitbox_collision_shape_2d: CollisionShape2D = $hitbox/CollisionShape2D


func _ready() -> void:
	hitbox_offset = hitbox.position # initialize hitbox offset

func _physics_process(_delta: float) -> void:
	
	#handle mining input
	if Input.is_action_just_pressed("use_pickaxe"):
		use_pickaxe()
	# skip movement if mining
	if is_mining:
		velocity = Vector2.ZERO
		return
		
	process_movement()
	process_animation()
	move_and_slide()

#region movement and animation
func process_movement() -> void:
	# Get the input direction and handle the movement/deceleration.
	var direction := Input.get_vector("left","right", "up", "down")
	
	if direction != Vector2.ZERO:
		velocity = direction * SPEED
		last_direction = direction
		update_hitbox_position()
	else:
		velocity = Vector2.ZERO

func process_animation()->void:
	#disable hitbox until pickaxe is swung
	hitbox.monitoring = false
	if velocity != Vector2.ZERO:
		play_animation("run", last_direction)
	else:
		play_animation("idle", last_direction)

func play_animation(prefix: String, dir: Vector2) -> void:
	if dir.x != 0:
		animated_sprite_2d.flip_h = dir.x < 0
		animated_sprite_2d.play(prefix + "_right")
	if dir.y < 0:
		animated_sprite_2d.play(prefix + "_up")
	if dir.y > 0:
		animated_sprite_2d.play(prefix + "_down")

#endregion

#region hitbox offset
func update_hitbox_position() -> void:
	var x:= hitbox_offset.x
	var y: = hitbox_offset.y
	
	match last_direction:
		Vector2.LEFT:
			hitbox.position = Vector2(-x, y)
			hitbox_collision_shape_2d.rotation_degrees = 0
		Vector2.RIGHT:
			hitbox.position = Vector2(x, y)
			hitbox_collision_shape_2d.rotation_degrees = 0
		Vector2.UP:
			hitbox.position = Vector2(y, -x)
			hitbox_collision_shape_2d.rotation_degrees = 90
		Vector2.DOWN:
			hitbox.position = Vector2(y, x)
			hitbox_collision_shape_2d.rotation_degrees = 90

#endregion


#region Mining
func use_pickaxe() -> void:
	detected_rocks.clear()
	is_mining = true
	hitbox.monitoring = true
	play_animation("swing_pickaxe", last_direction)
	
func _on_animated_sprite_2d_animation_finished() -> void:
	if is_mining:
		is_mining = false
		if detected_rocks.size() > 0:
			var rock_to_hit = get_most_overlapping_rock()
			rock_to_hit.take_damage(pickaxe_strength)
			
func get_most_overlapping_rock() -> Rock:
	var best_rock = detected_rocks[0]
	var best_dist = hitbox.global_position.distance_to(best_rock.global_position)
	
	for rock in detected_rocks:
		var dist = hitbox.global_position.distance_to(rock.global_position)
		if dist < best_dist:
			best_dist = dist
			best_rock = rock
	
	return best_rock

func _on_hitbox_body_entered(body: Node2D) -> void:
	if body is Rock:
		detected_rocks.append(body)
#endregion 
