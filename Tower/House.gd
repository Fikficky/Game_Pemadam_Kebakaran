extends KinematicBody2D

onready var animasi = $AnimationPlayer
onready var HPbar = $HP_Bar

signal house_hit
signal switch_state
signal get_point
signal main_tower_recovery


var hit : bool = false
export(String) var state
export(int) var ID
var HP = 75
var MaxHP = HP
var satu = 0

func _ready():
	animasi.play(state)
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


func _on_house_hit(dmg, st):
	hit = true
	$HP_Bar.set_visible(true)
	HP -= dmg
	var persen = float(HP) / MaxHP * 100
	$HP_Bar.update_value_bar(st, persen)
	pass # Replace with function body.

func HPZero():
	HP = MaxHP
	var point
	if state == "aman":
		state = "terbakar"
		point = -3
		emit_signal("switch_state")
	else:
		state = "aman"
		point = 5
	
	emit_signal("main_tower_recovery", state, float(HP)/2)
	emit_signal("get_point", point)
	animasi.play(state)
	$HP_Bar.update_value_bar(state, HP)
	$HP_Bar.set_visible(false)
