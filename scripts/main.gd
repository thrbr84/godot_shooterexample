extends Node2D

var totalBoxShot = 0

func _on_boxSpawn_timeout():
	if $person.dir != Vector2.ZERO:
		var gpos = $person.global_position
		var boxPos = gpos * randf() * (PI * 2) * 1
		
		var box = load("res://scenes/box.tscn").instance()
		box.global_position = boxPos
		box.connect("explode", self, "_on_box_shot")
		add_child(box)

func _on_box_shot():
	totalBoxShot += 1
	$ui/boxCount.text = str(totalBoxShot)
