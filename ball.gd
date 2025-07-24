extends CharacterBody2D

signal miss
signal wall
signal ai_move

const WALL_PADDING = 40

@export var speed = 500
var screen_size = Vector2.ZERO
var direction = Vector2(0, 0)

func setup(screen_size: Vector2, direction: Vector2) -> void:
	self.screen_size = screen_size
	self.direction = direction
	
	var half_width = floor(self.screen_size.x / 2)
	var half_height = floor(self.screen_size.y / 2)
	position = Vector2(half_width, half_height)

func _process(delta):
	var new_velocity = Vector2.ZERO
	new_velocity.x += direction.x
	new_velocity.y += direction.y

	if new_velocity.length() > 0:
		new_velocity = new_velocity.normalized() * speed
	
	position += new_velocity * delta
	position = position.clamp(Vector2.ZERO, screen_size)
	ai_move.emit()

	if is_out():
		miss.emit()
	if is_wall():
		wall.emit()

func is_out() -> bool:
	return position.x <= 0 or position.x >= screen_size.x

func is_wall() -> bool:
	return position.y <= WALL_PADDING or position.y >= screen_size.y - WALL_PADDING
