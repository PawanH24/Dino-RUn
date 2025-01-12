extends CharacterBody2D


const GRAVITY = 10000.0
const JUMP_SPEED = -3000.0

func _physics_process(delta):
	velocity.y+=GRAVITY * delta
	if is_on_floor():
		if not get_parent().game_running:
			$AnimatedSprite2D.play("idle")
		else:
			$RunCol.disabled=false
			if Input.is_action_pressed("ui_accept"):
				velocity.y=JUMP_SPEED
				$JumpSound.play()
			elif Input.is_action_pressed("ui_down"):
				$AnimatedSprite2D.play("duck")
				$RunCol.disabled=true
			else:
				$AnimatedSprite2D.play("run")
	else:
		$AnimatedSprite2D.play("jump")
		
	move_and_slide()
