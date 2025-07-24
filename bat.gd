extends Area2D

signal hit

const WIDTH = 40
const HEIGHT = 80
enum Status {
	 READY,
	 HIT,
	 MISS
}

@onready var sprite  = $AnimatedSprite2D

var screen_size = Vector2.ZERO
var player_number = 0
var is_human = false
var speed = 0
var status = Status.READY
var ai_y = 0
	
func setup(screen_size: Vector2, player_number: int, is_human: bool, speed: int) -> void:
	self.screen_size = screen_size
	self.player_number = player_number
	self.is_human = is_human
	self.speed = speed
	status = Status.READY
	ai_y = 0
	center_position()

func center_position() -> void:
	var half_height = floor(self.screen_size.y / 2)
	if player_number == 0:
		position = Vector2(WIDTH, half_height)
	else:
		position = Vector2(screen_size.x - WIDTH, half_height)

func set_miss_ball() -> void:
	status = Status.MISS
	update_animations()	

func _process(delta: float) -> void:	
	var new_velocity = Vector2.ZERO
	
	if is_human:
		if Input.is_action_pressed("ui_down"):
			new_velocity.y += 1
		if Input.is_action_pressed("ui_up"):
			new_velocity.y -= 1
	else:
		if abs(new_velocity.y - ai_y) >= 5: # for smoother animation
			new_velocity.y += ai_y

	if new_velocity.length() > 0:
		new_velocity = new_velocity.normalized() * speed	

	position += new_velocity * delta
	position.y = clamp(position.y, HEIGHT, screen_size.y - HEIGHT)
	
	update_animations()
	
func _on_body_entered(_body: Node2D) -> void:
	status = Status.HIT
	update_animations()	
	hit.emit()

func _on_body_exited(_body: Node2D) -> void:
	status = Status.READY
	update_animations()	

func update_animations():
	var string = str("bat_", player_number, "_")
	match status:
		Status.READY:
			string = str(string, "ready")
		Status.HIT:
			string = str(string, "hit")
		Status.MISS:
			string = str(string, "miss")
	sprite.animation = string
	sprite.play()
	sprite.stop()
