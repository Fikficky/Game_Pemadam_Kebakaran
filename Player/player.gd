extends KinematicBody2D

#scene yang digunakan
var PeluruAir = preload("res://Player/peluru_air.tscn")

#state yang digunakan
var can_fire : bool = true
var can_move : bool = true
var hit : bool = false
var mati : bool = false
var refill : bool = false

#variabel yang dugnakan
var arah = Vector2(1, 0)
var HP = 150
var MaxHP = HP
var ATK = 15
var ATK_SPD = 2
var Water = 300
var MaxWater = Water
var refill_rate
const speed = 200
var velocity = Vector2.ZERO
var ID_Refill = 0

#signal yang digunakan
signal player_hit
signal update_HP
signal update_Water
signal update_point
signal mati
signal refill

#node yang digunakan
onready var animationPlayer = $AnimationPlayer
onready var animationTree = $AnimationTree
onready var animationState = animationTree.get("parameters/playback")
onready var refillTime = $refill

func _ready():						#fungsi yang pertama dieksekusi
	Global.HP_player = HP
	refillTime.set_wait_time(1)
	
func _physics_process(_delta):		#fungsi loop yang akan terus dieksekusi
	#menentukan arah gerakan player sesuai inputnya
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	
	#menentukan arah player akan menghadap untuk arah tembakan
	if Input.is_action_pressed("ui_right"):
		arah = Vector2(1, 0)
	if Input.is_action_pressed("ui_left"):
		arah = Vector2(-1, 0)
	if Input.is_action_pressed("ui_up"):
		arah = Vector2(0, -1)
	if Input.is_action_pressed("ui_down"):
		arah = Vector2(0, 1)
	
	input_vector = input_vector.normalized()
	
	#saat player mati
	if HP <= 0:
		can_move = false
		can_fire = false
		animationTree.set("parameters/mati/blend_position", arah)
		animationState.travel("mati")
		yield(get_tree().create_timer(0.7), "timeout")
		emit_signal("mati")
	
	#saat player hidup
	else:
		#saat player bisa bergerak dan ada input navigasi
		if can_move and input_vector != Vector2.ZERO:
			animationTree.set("parameters/idle/blend_position", input_vector)
			animationTree.set("parameters/jalan/blend_position", input_vector)
			animationState.travel("jalan")
			velocity = input_vector * speed
		
		#saat player diam
		else :
			animationState.travel("idle")
			velocity = Vector2.ZERO
		
		#saat tombol tembak ditekan
		if Input.is_action_pressed("tembak") and Water > 0:
			_shoot()
		
		#saat tombol tembak dilepas
		if Input.is_action_just_released("tembak"):
			can_move = true
		
		#saat player terkena hit
		if hit:
			animationTree.set("parameters/hit/blend_position", arah)
			animationState.travel("hit")
			hit = false
			yield(get_tree().create_timer(0.2), "timeout")
			can_move = true
		
		#saat player mengisi ulang air
		if Input.is_action_just_released("refill") and refill and Water == 0:
			refillTime.start()
			_refill()
			refillTime.stop()
		
		#fungsi untuk menggerakkan player (built-in godot)
		move_and_slide(velocity)

#fungsi tembak
func _shoot():
	var cost = 10																#jmlah air yang berkurang saat menembak
	animationTree.set("parameters/tembak/blend_position", arah)
	animationState.travel("tembak")
	
	#saat bisa menembak
	if can_fire:
		var peluruBaru = PeluruAir.instance() 									#membuat node baru berdasarkan scene peluru_air 
		peluruBaru.power = ATK
		#posisi bidikan air
		if arah == Vector2(1, 0):
			$Senjata.position = Vector2(34.057, -12.402)
		if arah == Vector2(-1, 0):
			$Senjata.position = Vector2(-34.057, -12.402)
		if arah == Vector2(0, 1):
			$Senjata.position = Vector2(0, 10.328)
		if arah == Vector2(0, -1):
			$Senjata.position = Vector2(0, -10.328)
		peluruBaru.global_position = position + $Senjata.position
		
		peluruBaru._tembak(arah)												#peluru digerakkan
		get_tree().current_scene.get_node("Map").add_child(peluruBaru)			#memposisikan node ke dalam scene utama
		
		#player diam dan tak bisa bergerak saat menembak
		velocity = Vector2.ZERO
		can_move = false
		can_fire = false														#berhenti / cooldown menembak
		Water -= cost
		var persen = float(Water) / MaxWater * 100
		emit_signal("update_Water", persen)										#signal untuk update WATER bar player pada GUI
		yield(get_tree().create_timer(float(1)/ATK_SPD), "timeout")				#durasi cooldown menembak sesuai atk spd
		can_fire = true

#fungsi mengisi air
func _refill():
	var persen = float(Water) / MaxWater * 100
	emit_signal("refill", persen, true)
	
	#mengisi air setiap detik
	while (Water < MaxWater) and refill:
		#cooldown player diam dan tak bisa bergerak saat mengisi air dan tidak bisa menembak
		can_move = false
		can_fire = false
		Water += refill_rate
		persen = float(Water) / MaxWater * 100
		emit_signal("update_Water", persen)										#signal untuk update WATER bar player pada GUI
		yield(get_tree().create_timer(1), "timeout")							#durasi cooldown pengisian 1 detik
	
	if Water >= MaxWater:
		Water = MaxWater
	
	emit_signal("refill", persen, false)											#signal untuk untuk animasi pengisian
	can_move = true
	can_fire = true

#fungsi saat player terkena hit
func _player_hit(dmg):
	hit = true
	can_move = false
	HP -= dmg
	var persen = float(HP) / MaxHP * 100
	emit_signal("update_HP", persen)
	var hit_point = -10
	emit_signal("update_point", hit_point)

#fungsi perubahan state refill
func water_refill(IDTower, rate, state):
	refill_rate = rate
	if state:
		ID_Refill = IDTower
		refill = state
	else:
		if ID_Refill == IDTower:
			refill = state
	
