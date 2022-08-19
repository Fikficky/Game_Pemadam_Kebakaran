extends KinematicBody2D

onready var animasi = $AnimationPlayer
onready var HPbar = $HP_Bar

signal maintower_hit
signal switch_state
signal get_point

var hit : bool = false
var can_hit : bool = false
export(String) var state
var ID = 14
var HP = 450
var MaxHP = HP
var satu = 0

func _ready():
	animasi .play(state)
	var HPpersen = float(HP) / MaxHP * 100
	HPbar.update_value_bar(state, HPpersen)
	HPbar.set_visible(false)
	Global.HP_FL = HP

func _process(_delta):
	if hit:
		if state == "aman":
			animasi .play("bakar")
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


func _on_main_tower_hit(dmg, st):
	hit = true
	HPbar.set_visible(true)
	HP -= dmg
	Global.HP_FL = HP
	update_HP(st)
	pass # Replace with function body.

func update_HP(st):
	var persen = float(HP) / MaxHP * 100
	HPbar.update_value_bar(st, persen)

func HPZero():
	var point
	if state == "aman":
		state = "terbakar"
		point = -10
		emit_signal("switch_state")
	else:
		state = "aman"
		point = 20
	
	emit_signal("get_point", point)
	HP = MaxHP
	animasi.play(state)
	HPbar.update_value_bar(state, HP)
	HPbar.set_visible(false)

func _recovery(status, value):
	if HP < MaxHP:
		if status == "terbakar":
			HP += value
			if HP >= MaxHP:
				HP = MaxHP
		else:
			HP -= value
		update_HP(state)
