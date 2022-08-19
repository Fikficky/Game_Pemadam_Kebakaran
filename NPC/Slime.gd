extends KinematicBody2D

var PeluruApi = preload("res://NPC/peluru_api.tscn")

onready var animationPlayer = $AnimationPlayer
onready var animationTree = $AnimationTree
onready var animationState = animationTree.get("parameters/playback")
onready var attackTime = $AttackTime
onready var lifeTime = $LifeTime
onready var Best = $Best
onready var HPbar = $HP_Bar
onready var bidikan = $shoot_point
onready var H_Area = $H_area
onready var V_Area = $V_area
onready var raycasts = {'kanan': $raycast_kanan,
						'kiri': $raycast_kiri,
						'atas': $raycast_atas,
						'bawah': $raycast_bawah}

var ID = 1
var velocity = Vector2.ZERO
var HP = 100
var MaxHP = HP
var ATK = 15
var ATK_spd = 2
var speed = 80
var arah = 'kiri'
var pos_target
const point = 20
var nav
var path = []
var macam_arah = {'kanan': Vector2(1, 0),
				  'kiri': Vector2(-1, 0),
				  'atas': Vector2(0, -1),
				  'bawah': Vector2(0, 1)}

var state : String
var cooldown_tembak : bool = false
var kejar : bool = false
var kabur : bool = false
var lifetimer : int = 0
var attacking_timer : int = 0
var resul_print : bool = true
var passedBuilding : int = 0
var target = {"tipe" : "kosong", "ID" : 0}

signal kena_hit
signal mati

func _ready():
	state = "jalan"
	var HPpersen = float(HP) / MaxHP * 100
	HPbar.update_value_bar("enemy", HPpersen)
	HPbar.set_visible(false)
	lifeTime.set_wait_time(1)
	attackTime.set_wait_time(1)
	lifeTime.start()
	if Global.best:
		Best.visible = Global.best

func _physics_process(_delta):
	randomize()
	animationTree.set("parameters/idle/blend_position", velocity)
	animationTree.set("parameters/jalan/blend_position", velocity)
	animationTree.set("parameters/hit/blend_position", macam_arah[arah])
	animationTree.set("parameters/mati/blend_position", macam_arah[arah])
	animationTree.set("parameters/tembak/blend_position", pos_target)
	
	if HP <= 0:
		state = "mati"
	
	animationState.travel("idle")
	match state:
		"jalan" :
			if not move_and_slide(velocity):
				ubah_arah()
			jalan()
			
		
		"tembak" :
			var target = raycasts[pos_target].get_collider()
			if target == null or !target.is_in_group('tile'):
				if !cooldown_tembak:
					shoot()
			
			else :
				state = "jalan"
		
		"hit" :
			kabur = true
			animationState.travel("hit")
			yield(get_tree().create_timer(0.2), "timeout")
			ubah_arah()
			kabur = false
			state = "jalan"
		
		"mati" :
			mati()



func jalan():
	animationState.travel("jalan")
	if kejar:
		if path.size() > 0:
			_kejar()
	else:
		velocity = macam_arah[arah].normalized() * speed
	
	velocity = move_and_slide(velocity)

func ubah_arah():
	randomize()
	animationState.travel("idle")
	
	var arah_baru = []
	var vec_asal = macam_arah[arah] * -1
	var arah_asal
	var arah_sekarang
	for i in raycasts:
		if not raycasts[i].is_colliding():
			arah_baru.push_back(i)
		if vec_asal == macam_arah[i]:
			arah_asal = i
	
	if arah_baru.size() < 2:
		arah_sekarang = arah
		arah = macam_arah.keys()[int(rand_range(0, macam_arah.size()))]
	
	else:
		arah = arah_baru[int(rand_range(0, arah_baru.size()))]
		if kabur:
			while arah == pos_target:
				arah = arah_baru[int(rand_range(0, arah_baru.size()))]
		elif arah_baru.size() >= 2:
			while arah == arah_asal:
				arah = arah_baru[int(rand_range(0, arah_baru.size()))]
	
#	print(arah)
	
func shoot():
	animationState.travel("tembak")
	
	var peluruBaru = PeluruApi.instance()
	peluruBaru.power = ATK
	peluruBaru.npcID = ID
	
	if pos_target == 'kanan':
		bidikan.position = Vector2(1.323, -5.598)
	if pos_target == 'kiri':
		bidikan.position = Vector2(-1.323, -5.598)
	if pos_target == 'atas' or pos_target == 'bawah':
		bidikan.position = Vector2(0, -4.233)
	
	velocity = pos_target
	peluruBaru.global_position = position + bidikan.position
	peluruBaru._tembak(macam_arah[pos_target])
	get_tree().current_scene.get_node("Map").add_child(peluruBaru)
	
	velocity = Vector2.ZERO
	cooldown_tembak = true
	yield(get_tree().create_timer(float(1)/ATK_spd), "timeout")
	cooldown_tembak = false
	if target["tipe"] == "kosong":
		state = "jalan"

func _kena_tembak(dmg):
	state = "hit"
	HPbar.set_visible(true)
	
	HP -= dmg
	var persen = float(HP) / MaxHP * 100
	HPbar.update_value_bar("terbakar", persen)

func mati():
	lifeTime.stop()
	Global.npcLifetime[ID] = {"life_time" : lifetimer, "attack_state_time" : attacking_timer, "passed_building" : passedBuilding}
	
	if resul_print:
		print("NPC", ID ," waktu hidup = ",lifetimer , ", total waktu penyerangan = ", attacking_timer, " jumlah bangunan yang dilewati = ", passedBuilding)
		resul_print = false
		emit_signal("mati", point)
	
	animationState.travel("mati")

func _kejar():
	if position.distance_to(path[0]) < 16:
		path.remove(0)
		if raycasts[arah].is_colliding():
			var body = raycasts[arah].get_collider()
			if body.is_in_group("player"):
				state = "tembak"
	else:
		velocity = position.direction_to(path[0])
		velocity = velocity * speed

func get_target_path(target_pos):
	kejar = true
	path = nav.get_simple_path(position, target_pos, false)

func kejar_off(_p, _state):
	kejar = false

func ubah_target():
	state = "jalan"
	kejar = false
	target["tipe"] = "kosong"

func _on_H_area_body_entered(body):
	if attackTime.is_stopped() and target["tipe"] == "kosong":
		if body.is_in_group('player'):
			if body.global_position.x < global_position.x:
				pos_target = 'kiri'
			else:
				pos_target = 'kanan'
				
			if body.Water <=0:
				kejar = false
				target["tipe"] = 'player'
				
			else:
				kabur = true
				ubah_arah()
				
		elif body.get_collision_layer_bit(4):
			if target["ID"] != body.ID:
				passedBuilding += 1
			target["ID"] = body.ID
			
			if body.state == "aman":
				body.connect("switch_state", self, "ubah_target")
				
				if body.global_position.x < global_position.x:
					pos_target = 'kiri'
				else:
					pos_target = 'kanan'
				
				if body.is_in_group('main_tower') and body.can_hit:
					target["tipe"] = 'main_tower'
				elif body.is_in_group('tower'):
					target["tipe"] = 'tower'
	#				Global.potHit[ID]["tower"] = body.MaxHP / ATK
				elif body.is_in_group('house'):
					target["tipe"] = 'house'
	#				Global.potHit[ID]['house'] = body.MaxHP / ATK
			
		if target["tipe"] != "kosong":
			state = "tembak"
			attackTime.start()

func _on_V_area_body_entered(body):
	if attackTime.is_stopped() and target["tipe"] == "kosong":
		if body.is_in_group('player'):
			if body.global_position.y < global_position.y:
				pos_target = 'atas'
			else:
				pos_target = 'bawah'
				
			if body.Water <=0:
				kejar = false
				target["tipe"] = 'player'
			
			else:
				kabur = true
				ubah_arah()
		
		elif body.get_collision_layer_bit(4):
			if target["ID"] != body.ID:
				passedBuilding += 1
			target["ID"] = body.ID
			
			if body.state == "aman":
				body.connect("switch_state", self, "ubah_target")
				
				if body.global_position.y < global_position.y:
					pos_target = 'atas'
					
					if body.is_in_group('main_tower') and body.can_hit:
						target["tipe"] = "main_tower"
					elif body.is_in_group('tower'):
						target["tipe"] = 'tower'
#						Global.potHit[ID]["tower"] = body.MaxHP / ATK
					elif body.is_in_group('house'):
						target["tipe"] = 'house'
#						Global.potHit[ID]['house'] = body.MaxHP / ATK
				
	#			print("V",body.state)
		
		if target["tipe"] != "kosong":
			attackTime.start()
			state = "tembak"
			

func _on_shoot_area_body_exited(body):
	state = "jalan"
	target["tipe"] = "kosong"
	
	if body.is_in_group('player'):
		kabur = false

func _on_LifeTime_timeout():
	lifetimer += 1
		

func _on_ShootDelay_timeout():
	attacking_timer += 1
	if state != "tembak" or target["tipe"] == "kosong":
		attackTime.stop()
