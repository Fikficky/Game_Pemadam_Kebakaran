extends Area2D

#onready var animationTree = $AnimationTree
#onready var animationState = animationTree.get("parameters/playback")
var arah2
var speed = 300
var velocity
var power

func _physics_process(delta):
	set_global_position(get_global_position() + velocity * delta)
	pass


func _tembak(arah):
	if arah == Vector2(1, 0):
		$AnimationPlayer.play("tembak_idle_kanan")
	if arah == Vector2(-1, 0):
		$AnimationPlayer.play("tembak_idle_kiri")
	if arah == Vector2(0, 1):
		$AnimationPlayer.play("tembak_idle_bawah")
	if arah == Vector2(0, -1):
		$AnimationPlayer.play("tembak_idle_atas")
	velocity = arah * speed
	arah2 = arah


func _on_peluru_air_body_entered(body):
	
	if !body.is_in_group("player") :
		if arah2 == Vector2(1, 0):
			$AnimationPlayer.play("tembak_kena_kanan")
		elif arah2 == Vector2(-1, 0):
			$AnimationPlayer.play("tembak_kena_kiri")
		elif arah2 == Vector2(0, 1):
			$AnimationPlayer.play("tembak_kena_bawah")
		elif arah2 == Vector2(0, -1):
			$AnimationPlayer.play("tembak_kena_atas")
		velocity = Vector2.ZERO
		if body.is_in_group("musuh"):
			body.emit_signal("kena_hit", power)
		
		elif body.is_in_group("tower") and body.state == "terbakar":
			body.emit_signal("tower_hit", power, body.state)
		
		elif body.is_in_group("main_tower") and body.state == "terbakar" and body.can_hit:
			body.emit_signal("maintower_hit", power, body.state)
		
		elif body.is_in_group("house") and body.state == "terbakar":
			body.emit_signal("house_hit", power, body.state)
	
