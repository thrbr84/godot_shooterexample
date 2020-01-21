extends Sprite

export var velocidade = 10
var direction = Vector2.ZERO

func _ready():
	if direction == Vector2.ZERO:
		direction.x = 300
		
	prints(direction)

func _process(delta):
	position += direction * velocidade * delta

func _on_visibility_screen_exited():
	queue_free()


func _on_Area2D_body_entered(body):
	if body.is_in_group("box"):
		body._die()
