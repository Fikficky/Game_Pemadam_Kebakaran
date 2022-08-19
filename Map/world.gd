extends Node2D

var Enemy = load("res://NPC/Slime.tscn")
var win = preload("res://UI/Win_scene.tscn")
var lose = preload("res://UI/Game_Over_scene.tscn")

onready var navigation = $Navigation2D
onready var player = get_node("Map/player")
onready var fire_station = get_node("Map/FireStation")
onready var fire_lab = get_node("Map/FireLab")
onready var GUI = $GUI
onready var spawnTime = $spawn
var iterasi = 0


var towers = []
var houses = []
var enemys = []
var countdown = 10

func _ready():
	Global.reset()
	player.connect("update_HP", GUI, "update_HP")
	player.connect("update_Water", GUI, "update_Water")
	player.connect("refill", GUI, "anim_refill_water")
	player.connect("mati", self, "game_over")
	player.connect("update_point", GUI, "update_point")
	var HPpersen = float(player.HP) / player.MaxHP * 100
	player.emit_signal("update_HP", HPpersen)
	
	var WTRpersen = float(player.Water) / player.MaxWater * 100
	player.emit_signal("update_Water", WTRpersen)
	
	spawn_npc()
	
	set_connection_point()
	ambil_bangunan()
	update_icon()
	
	cek_mission()
	

func _process(_delta):
	var tower_terbakar = cek_tower()
	var tower_aman = towers.size() - tower_terbakar 
	
	update_icon()
	cek_mission()
	
	if tower_terbakar == towers.size():
		fire_station.can_hit = true
		if fire_station.state == "terbakar":
			game_over()
	else:
		fire_station.can_hit = false
		
	if tower_aman == towers.size():
		fire_lab.can_hit = true
		if fire_lab.state == "aman" and cek_enemy() == 0:
			game_win()
	else:
		fire_lab.can_hit = false
		
	if cek_enemy() == 0 and spawnTime.is_stopped() and fire_lab.state == "terbakar":
		print("Total Dmg :\n", Global.npcDmg)
		print("Liftime : ", Global.npcLifetime)
		spawnTime.set_wait_time(1)
		spawnTime.start()

func set_connection_point():
	var kump_objek = $Map.get_children()
	
	for bangunan in kump_objek:
		if bangunan.is_in_group("main_tower") or bangunan.is_in_group("tower") or bangunan.is_in_group("house"):
			bangunan.connect("get_point", GUI, "update_point")
			bangunan.connect("can_refill", GUI, "_refillBtn")
		if bangunan.is_in_group("tower") or bangunan.is_in_group("house"):
			bangunan.connect("main_tower_recovery", fire_station, "_recovery")
			bangunan.connect("main_tower_recovery", fire_lab, "_recovery")
			
func ambil_bangunan():
	var kump_objek = $Map.get_children()
	for bangunan in kump_objek:
		if bangunan.is_in_group("tower"):
			towers.push_back(bangunan)
		elif bangunan.is_in_group("house"):
			houses.push_back(bangunan)

func cek_tower():
	var hasil : int = 0
	for tower in towers:
		if tower.state == "terbakar":
			hasil += 1
	return hasil
	
func cek_house():
	var hasil : int = 0
	for house in houses:
		if house.state == "terbakar":
			hasil += 1
	return hasil

func cek_enemy():
	var kump_objek = $Map.get_children()
	var jumlah = 0
	for enemy in kump_objek:
		if enemy.is_in_group("musuh"):
			jumlah +=1
#	print(jumlah)
	return jumlah
	
func update_icon():
	var tower_terbakar = cek_tower()
	var rumah_terbakar = cek_house()
	var slime = cek_enemy()
	
	GUI.update_icon(slime, rumah_terbakar, tower_terbakar)
	
func spawn_npc():
	var iterasiMax = 10
	var pos = get_node("SlimeSpawn").position
	var GA = load("res://Algoritma_Genetika.gd").new()
	var stat = {}
	if iterasi <= 0:
		iterasi = 1
		stat = GA.bangkit_populasi()
		Global.npcStat = stat
	else:
		if iterasi > iterasiMax:
			Global.best = true
			Global.write_files("\n++BEST INDIVIDU++\nFitness = "+str(Global.bestIndividu["fitness"])+"\nStatus = "+str(Global.bestIndividu["stat"]))
			print("Best Individu = ", Global.bestIndividu)
			for idx in range(4):
				var ID = idx + 1
				stat[ID] = Global.bestIndividu["stat"]
		else:
			Global.write_files("Iterasi : " + str(iterasi))
			iterasi += 1
			catat_hasil(Global.npcLifetime, Global.npcDmg)
			stat = GA.AlgoritmaGenetika(Global.npcLifetime, Global.npcDmg, Global.npcStat, Global.HP_FL, Global.HP_FS, Global.HP_player)
		
	
	for individu in stat:
		Global.write_files(str(individu) + " : " + str(stat[individu]))
	Global.write_files("\n")
	print(stat)
	
	for npc in stat:
		var slime = Enemy.instance()
		player.connect("refill", slime, "kejar_off")
		slime.connect("mati", GUI, "update_point")
		slime.position = pos
		slime.nav = navigation
		slime.ID = npc
		slime.HP = stat[npc]["HP"]
		slime.ATK = stat[npc]["ATK"]
		slime.ATK_spd = stat[npc]["ASPD"]
		slime.speed += stat[npc]["SPD"]
		get_node("Map").add_child(slime)
		npc += 1
		yield(get_tree().create_timer(0.5), "timeout")

func catat_hasil(lifetime, tDMg):
	Global.write_files("Hasil (dmg, waktu, dan jumlah bangunan yang dilewati):")
	for individu in lifetime:
		Global.write_files(str(individu) + " : " + str(tDMg[individu]) + str(lifetime[individu]))
	Global.write_files("\n")

func cek_mission():
	var mission_code = []
	
	if player.Water <= 0:
		mission_code.push_back(1)
	if cek_tower() >= 1:
		mission_code.push_back(2)
	if fire_lab.state == "terbakar":
		mission_code.push_back(3)
	if cek_enemy() >= 1:
		mission_code.push_back(4)
	if cek_house() >= 1:
		mission_code.push_back(5)
	
	GUI.mission(mission_code)

func game_win():
	get_tree().change_scene("res://UI/Win_scene.tscn")

func game_over():
	get_tree().change_scene("res://UI/Game_Over_scene.tscn")


func _on_spawn_timeout():
	countdown -= 1
	GUI.countdown_spawn(countdown)
	if countdown == 0:
		spawnTime.stop()
		countdown = 10
		spawn_npc()


func _on_Timer_timeout():
	if cek_enemy() != 0 and player.Water == 0:
		get_tree().call_group("musuh", "get_target_path", player.position)
	pass
