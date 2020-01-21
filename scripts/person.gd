extends KinematicBody2D

# // Variáveis com opção para exportar para serem customizadas
export(int) var walk_speed:int = 300
var tween = Tween.new()
var dirOld

onready var bullet = preload("res://scenes/bullet.tscn")

# // Variáveis básicas
var speed = 0
var dir = Vector2.ZERO

func _ready():
	add_child(tween)
	speed = walk_speed

func _physics_process(delta):
	# regras de movimentação, animação e troca de textura do player
	_move()
	# implementa o movimento no KinematicBody2D
	dir = move_and_slide(dir)

func _move()->void:
	# ////////
	
	# inicia sem movimentação
	var LEFT:bool = Input.is_action_pressed("ui_left")
	var RIGHT:bool = Input.is_action_pressed("ui_right")
	var UP:bool = Input.is_action_pressed("ui_up")
	var DOWN:bool = Input.is_action_pressed("ui_down")
	if LEFT || RIGHT || UP || DOWN:
		dir = Vector2.ZERO
		var vX:int = (int(RIGHT)-int(LEFT)) * speed
		var vY:int = (int(DOWN)-int(UP)) * speed
		
		dir.x = vX
		dir.y = vY
		
		if !tween.is_active() and dir!=dirOld:
			tween.interpolate_property($shadow, "rotation", $body.rotation, dir.angle(), .1, Tween.TRANS_LINEAR, Tween.EASE_IN)
			tween.interpolate_property($body, "rotation", $body.rotation, dir.angle(), .1, Tween.TRANS_LINEAR, Tween.EASE_IN)
			tween.start()
			
			dirOld = dir

func _unhandled_input(event):
	if event is InputEventKey:
		if event.is_action_pressed("ui_select"):
			_shoot()
			
func _shoot():
	$body/fire.frame = 0
	$body/fire.playing = true
	
	var b = bullet.instance()
	b.direction = dir if dirOld == null else dirOld
	b.rotation = $body.rotation
	b.global_position = $body/drop.global_position
	get_parent().add_child(b)

func _on_btnShoot_pressed():
	_shoot()

func _on_analog_analogChange(force, direction):
	speed = walk_speed * (force * .5)
	dir.x = (direction.x * (PI)) * speed
	dir.y = (direction.y * -(PI)) * speed
	
	tween.interpolate_property($shadow, "rotation", $body.rotation, dir.angle(), .1, Tween.TRANS_LINEAR, Tween.EASE_IN)
	tween.interpolate_property($body, "rotation", $body.rotation, dir.angle(), .1, Tween.TRANS_LINEAR, Tween.EASE_IN)
	tween.start()
	
	dirOld = dir

func _on_analog_analogRelease():
	dir = Vector2.ZERO
