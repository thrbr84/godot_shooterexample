extends KinematicBody2D

onready var bullet = preload("res://scenes/bullet.tscn")
# // Variáveis com opção para exportar para serem customizadas
export(int) var walk_speed:int = 300

# // Variáveis básicas
var speed = 0
var dir = Vector2.ZERO
var tween = Tween.new()
var dirOld
var arrShot = []

func _ready():
	add_child(tween)
	speed = walk_speed

func _physics_process(delta):
	# regras de movimentação
	_move()
	# implementa o movimento no KinematicBody2D
	dir = move_and_slide(dir)

func _move()->void:
	# Movimentação pelo teclado
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
	# Atirar apertando o espaço do teclado
	if event is InputEventKey:
		if !event.is_pressed():
			dir = Vector2.ZERO
		if event.is_action_pressed("ui_select"):
			_shoot()
			
func _shoot():
	# Função para atirar
	$body/fire.frame = 0
	$body/fire.playing = true
	
	# audio da bala
	var ashot = AudioStreamPlayer.new()
	add_child(ashot)
	ashot.stream = load("res://assets/audio/shot.ogg")
	ashot.volume_db = -10
	ashot.connect("finished", self, "_on_end_ashot")
	arrShot.append(ashot)
	ashot.play()

	
	var b = bullet.instance()
	b.direction = dir if dirOld == null else dirOld
	b.rotation = $body.rotation
	b.global_position = $body/drop.global_position
	get_parent().add_child(b)

func _on_btnShoot_pressed():
	# Atirar pelo botão
	_shoot()

func _on_analog_analogChange(force, direction):
	# Movimentação pelo analógico
	speed = walk_speed * (force * .5)
	dir.x = (direction.x * (PI)) * speed
	dir.y = (direction.y * -(PI)) * speed
	
	$body.rotation = dir.angle()
	$shadow.rotation = dir.angle()
	
	dirOld = dir

func _on_analog_analogRelease():
	# quando soltar o analógico para de movimentar
	dir = Vector2.ZERO

func _on_end_ashot():
	# Libera os audios da memoria
	if arrShot.size() > 0:
		if weakref(arrShot[0]).get_ref():
			arrShot[0].queue_free()
		arrShot.remove(0)
