extends Area2D

func _ready():
	$AnimatedSprite2D.animation = "animate"
	$AnimatedSprite2D.play()
	$Timer.start()

func _on_timer_timeout() -> void:
	if is_instance_valid(self):
		self.queue_free()
