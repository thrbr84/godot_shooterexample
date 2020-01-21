extends Node2D

const INACTIVE_IDX = -1;
export var isDynamicallyShowing = false
export var typeAnalogic = "directions_4" #360, directions_4, directions_8

var local_paused = false
var directions = ["right", "down_right", "down", "down_left", "left", "up_left", "up", "up_right"]
var ball
var bg 
var animation_player
var parent
var listenerNode

var currentForce2:float = 0.0
var centerPoint = Vector2(0,0)
var currentForce = Vector2(0,0)
var halfSize = Vector2()
var ballPos = Vector2()
var squaredHalfSizeLenght = 0
var currentPointerIDX = INACTIVE_IDX;

# Aqui criamos um signal que pode ser escutado por qualquer node
signal analogChange
signal analogPressed
signal analogRelease

func _ready():
	set_process_input(true)
	bg = $bg
	ball = $ball
	animation_player = $anim
	parent = get_parent();
	
	#halfSize = bg.get_item_rect().size/2;
	halfSize = bg.texture.get_size()/2;
	squaredHalfSizeLenght = halfSize.x*halfSize.y;
	
#	isDynamicallyShowing = isDynamicallyShowing and parent is Control
	if isDynamicallyShowing:
		modulate.a = 0
	else:
		modulate.a = 1


func _convertType(pos):
	if local_paused:return
	var angle = Vector2(pos.x, -pos.y).angle() + .5
	if angle < 0:
		angle += 2 * PI
	var index = round(angle / PI * 4)
	var animation = directions[index-1]
	return animation

func get_force():
	if local_paused:return
	return currentForce
	
func _input(event):
	if local_paused:return
	var incomingPointer = extractPointerIdx(event)
	if incomingPointer == INACTIVE_IDX:
		return

	if need2ChangeActivePointer(event):
		if (currentPointerIDX != incomingPointer) and event.is_pressed():
			currentPointerIDX = incomingPointer;
			if event is InputEventMouseMotion or event is InputEventMouseButton:
				print(event.position)
				showAtPos(event.position);

	var theSamePointer = currentPointerIDX == incomingPointer
	if isActive() and theSamePointer:
		process_input(event)


func need2ChangeActivePointer(event): #touch down inside analog
	if local_paused:return
	var mouseButton = event is InputEventMouseButton
	var touch = event is InputEventScreenTouch
	
	if event is InputEventMouseMotion or event is InputEventMouseButton:
		# Mouse motion or mouse button event
		var mouse_event_pos = event.position

		if mouseButton or touch:
			if isDynamicallyShowing:
				return mouse_event_pos
			else:
				var lenght = (get_global_position() - Vector2(mouse_event_pos.x, mouse_event_pos.y)).length_squared();
				return lenght < squaredHalfSizeLenght
		else:
		 return false
	else:
		return false

func isActive():
	if local_paused:return
	return currentPointerIDX != INACTIVE_IDX

func extractPointerIdx(event):
	if local_paused:return
	var touch = event is InputEventScreenTouch
	var drag = event is InputEventScreenDrag
	var mouseButton = event is InputEventMouseButton
	var mouseMove = event is InputEventMouseMotion
	
	if touch or drag:
		return event.index
	elif mouseButton or mouseMove:
		#plog("SOMETHING IS VERYWRONG??, I HAVE MOUSE ON TOUCH DEVICE")
		return 0
	else:
		return INACTIVE_IDX
		
func process_input(event):
	if local_paused:return
	var mouseButton = event is InputEventMouseButton
	var mouseMove = event is InputEventMouseMotion
	
	if mouseMove or mouseButton:
		calculateForce(event.position.x - self.get_global_position().x, event.position.y - self.get_global_position().y)
	updateBallPos()
	
	var isReleased = isReleased(event)
	if isReleased:
		reset()
	else:
		# toda vez que o analógico movimentar, é emitido o sinal com as coordenadas
		#hud.analogPressed = true
		emit_signal("analogPressed", true)
		
		var ret
		var ret2
		if typeAnalogic == "360":
			#ret = currentForce
			ret = currentForce2
			ret2 = _convertType(currentForce)
		elif typeAnalogic == "360_vector2":
			#ret = currentForce
			ret = currentForce2
			ret2 = currentForce
		elif typeAnalogic == "directions_4":
			ret = _convertType(currentForce)
			if not ret in ['left', 'right', 'up', 'down']:
				ret = ''
				
		elif typeAnalogic == "directions_8":
			ret = currentForce2
			ret2 = _convertType(currentForce)

		emit_signal("analogChange", ret, ret2)


func reset():
	#if dialogue.is_open:return
	#if map.is_open:return
	#if local_paused:return
	emit_signal("analogRelease")
	currentPointerIDX = INACTIVE_IDX
	calculateForce(0, 0)

	if isDynamicallyShowing:
		hide()
	else:
		updateBallPos()

func showAtPos(pos):
	if local_paused:return
	if isDynamicallyShowing:
		animation_player.play("alpha_in")
		self.set_global_position(pos)
	
func hide():
	animation_player.play("alpha_out") 
	emit_signal("analogPressed", false)
	#hud.analogPressed = false
	#hud._closeAttack()

func updateBallPos():
	if local_paused:return
	ballPos.x = halfSize.x * currentForce.x #+ halfSize.x
	ballPos.y = halfSize.y * -currentForce.y #+ halfSize.y
	ball.set_position(ballPos)
	
	currentForce2 = (centerPoint.distance_to(ballPos) * 100.0 / 64.0) / 100.0


func calculateForce(var x, var y):
	if local_paused:return
	#get direction
	currentForce.x = (x - centerPoint.x)/halfSize.x
	currentForce.y = -(y - centerPoint.y)/halfSize.y
	
	
	
	
	#limit 
	if currentForce.length_squared()>1:
		currentForce=currentForce/currentForce.length()
	
	
func isPressed(event):
	if local_paused:return
	if event is InputEventMouseMotion:
		return (event.button_mask==1)
	elif event is InputEventScreenTouch:
		return event.pressed

func isReleased(event):
	if event is InputEventScreenTouch:
		return !event.pressed
	elif event is InputEventMouseButton:
		return !event.pressed

func pause():
	local_paused = true
	hide()
	
func unpause():
	local_paused = false
