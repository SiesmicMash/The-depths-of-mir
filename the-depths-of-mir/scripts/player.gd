extends CharacterBody2D


const SPEED = 100

var last_direction: Vector2 = Vector2.RIGHT

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D


func _physics_process(_delta: float) -> void:
	process_movement()
	process_animation()
	move_and_slide()

#region movement
func process_movement() -> void:
	# Get the input direction and handle the movement/deceleration.
	var direction := Input.get_vector("left","right", "up", "down")
	
	if direction != Vector2.ZERO:
		velocity = direction * SPEED
		last_direction = direction
	else:
		velocity = Vector2.ZERO
#endregion

#region animation
func process_animation()->void:
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
