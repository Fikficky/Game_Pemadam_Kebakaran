extends KinematicBody2D

onready var animasi = $AnimationPlayer
onready var HPbar = $HP_Bar

signal tower_hit
signal switch_state
signal get_point
signal can_refill
signal update_refill
signal main_tower_recovery

var hit : bool = false
export(String) var state

export(int) var ID
var HP = 225
var MaxHP = HP
var refill_rate = 50

func _ready():
	animasi.play(self.state)
	var HPpersen = float(HP) / MaxHP * 100
	HPbar.update_value_bar(state, HPpersen)
	HPbar.set_visible(false)

func _process(_delta):
	if hit:
		if state == "aman":
			animasi.play("bakar")
			yield(get_tree().create_timer(0.2), "timeout")
			if HP <= 0:
				HPZero()
			else:
				animasi.play(state)
		
		else:
			animasi.play("siram")
			yield(get_tree().create_timer(0.2), "timeout")
			if HP <= 0:
				HPZero()
			else:
				animasi.play(state)
		
		hit = false
		yield(get_tree().create_timer(0.2), "timeout")

func _on_refill_area_body_entered(body):
	if body.is_in_group("player") and state == "aman" and body.Water == 0:
		emit_signal("can_refill", true)
		connect("update_refill", body, "water_refill")
		body.water_refill(ID, refill_rate, true)


func _on_refill_area_body_exited(body):
	if body.is_in_group("player"):
		emit_signal("can_refill", false)
		body.water_refill(ID, refill_rate, false)

func _on_Tower_tower_hit(dmg, st):
	hit = true
	HPbar.set_visible(true)
	HP -= dmg
	var persen = float(HP) / MaxHP * 100
	HPbar.update_value_bar(st, persen)

func HPZero():
	HP = MaxHP
	var point
	if self.state == "aman":
		self.state = "terbakar"
		point = -5
		emit_signal("switch_state")
		emit_signal("update_refill", ID, refill_rate, false)
		emit_signal("can_refill", false)
	else:
		self.state = "aman"
		point = 10
	
	emit_signal("main_tower_recovery", state, float(HP)/2)
	animasi.play(self.state)
	emit_signal("get_point", point)
	HPbar.update_value_bar(state, HP)
	HPbar.set_visible(false)
