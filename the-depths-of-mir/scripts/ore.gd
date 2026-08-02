extends Area2D

var ore_data: OreData
@onready var sprite_2d: Sprite2D = $Sprite2D


func _ready() -> void:
	sprite_2d.texture = ore_data.texture



func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		if body.add_ore(ore_data):
			queue_free()
