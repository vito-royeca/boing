extends Node2D

const SPEED = 600
const AI_SPEED = 600
var screen_half_width = 0.0
var screen_half_height = 0.0
var screen_size
var ai_offset = 0

@export var impact_scene: PackedScene

func _ready():
	screen_size = get_viewport_rect().size
	screen_half_width = floor(screen_size.x / 2)
	screen_half_height = floor(screen_size.y / 2)
	start(Vector2(-1,0))

func start(direction: Vector2) -> void:
	$Bat0.setup(screen_size, 0, false, SPEED)
	$Bat1.setup(screen_size, 1, true, AI_SPEED)
	$Ball.setup(screen_size, direction)

func ball_hit() -> void:
	var new_direction = Vector2($Ball.direction)
	var new_position = Vector2($Ball.position)
	var ball_position = Vector2($Ball.position)
	var difference_y = 0

	if $Bat0.overlaps_body($Ball):
		difference_y = new_position.y - $Bat0.position.y
		ball_position.x += $Bat0.WIDTH/2
	if $Bat1.overlaps_body($Ball):
		difference_y = new_position.y - $Bat1.position.y
		ball_position.x -= $Bat1.WIDTH/2

	new_direction.x = -new_direction.x
	new_direction.y += difference_y / 128.0
	new_direction.y = min(max(new_direction.y, -1), 1)
	new_direction = new_direction.normalized()
	
	$Ball.speed += 1
	$Ball.direction = new_direction
	ai_offset = randi_range(-10, 10)
	
	#$AudioPlayer.get_stream_playback()
	show_impact(ball_position)
	
func ball_miss() -> void:
	var ball_direction = Vector2.ZERO
	
	if $Ball.position.x >= screen_size.x:
		$Bat0.set_miss_ball()
		ball_direction = Vector2(1,0)
	elif $Ball.position.x <= screen_size.x:
		$Bat1.set_miss_ball()
		ball_direction = Vector2(-1,0)
	
	start(ball_direction)

func ball_wall() -> void:
	var new_direction = Vector2($Ball.direction)
	var new_position = Vector2($Ball.position)
	
	new_direction.y = -new_direction.y
	new_position.y += new_direction.y

	$Ball.direction = new_direction
	$Ball.position = new_position
	show_impact($Ball.position)

func ai_move():
	if !$Bat0.is_human:
		$Bat0.ai_y = calculate_ai_move($Bat0.position)
	if !$Bat1.is_human:
		$Bat1.ai_y = calculate_ai_move($Bat1.position)

func calculate_ai_move(position: Vector2) -> float:
	var x_distance = abs($Ball.position.x - position.x)
	var target_y_1 = screen_half_height
	var target_y_2 = $Ball.position.y + ai_offset
	var weight1 = min(1, x_distance / screen_half_width)
	var weight2 = 1 - weight1
	var target_y = (weight1 * target_y_1) + (weight2 * target_y_2)
	var ai_y = min(AI_SPEED, max(-AI_SPEED, target_y - position.y))
	return ai_y


func show_impact(position: Vector2) -> void:
	print("impact ", position)
	var impact = impact_scene.instantiate()
#
	impact.position = position
	add_child(impact)
