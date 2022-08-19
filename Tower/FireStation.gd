extends KinematicBody2D

onready var animasi = $AnimationPlayer
onready var HPbar = $HP_Bar

signal maintower_hit
signal switch_state
signal get_point
signal can_refill

var hit : bool = false
var can_hit : bool = false
export(String) var state
var ID = 13
var HP = 450
var MaxHP = HP
var refill_rate = 50

func _ready():
	animasi .play(state)
	var HPpersen = float(HP) / MaxHP * 100
	HPbar.update_value_bar(state, HPpersen)
	HPbar.set_visible(false)
	Global.HP_FS = HP

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

func _on_refill_area_body_entered(body):
	if body.is_in_group("player") and state == "aman" and body.Water == 0:
		print(1)
		emit_signal("can_refill", true)
		connect("update_refill", body, "water_refill")
		body.water_refill(ID, refill_rate, true)


func _on_refill_area_body_exited(body):
	if body.is_in_group("player"):
		emit_signal("can_refill", false)
		body.water_refill(ID, refill_rate, false)

func _on_main_tower_hit(dmg, st):
	hit = true
	HPbar.set_visible(true)
	HP -= dmg
	Global.HP_FS = HP
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
		emit_signal("update_refill", ID, refill_rate, false)
		emit_signal("can_refill", false)
	else:
		state = "aman"
		point = 20
	
	emit_signal("get_point", point)
	animasi.play(state)
	HP = MaxHP
	HPbar.update_value_bar(state, HP)

func _recovery(status, value):
	if HP < MaxHP:
		if status == "aman":
			HP += value
			if HP >= MaxHP:
				HP = MaxHP
		update_HP(state)
		
	if status == "terbakar":
		HP -= value
		HPbar.set_visible(true)
		update_HP(state)
