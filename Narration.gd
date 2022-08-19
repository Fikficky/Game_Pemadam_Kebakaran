extends Node2D

onready var main_animation = get_node("AnimationPlayer")
onready var firelab_animation = get_node("Map/firelab/AnimationPlayer")
onready var fireworks_animation = get_node("kembang api/AnimationPlayer")
onready var slime_animation = get_node("Map/Slime/AnimationPlayer")
onready var camera = $Camera2D
onready var kid = $kid
onready var dialogBox = $dialog_box

var lokasi_1 = Vector2(1576.967, 927.451)
var lokasi_2 = Vector2(1656.13, 37.182)
var lokasi_3 = Vector2(-1690.22, 77.499)
var total_main_scene = range(1, 6+1)
var current_dialogs = []
var current_scenes = []
var effect_scene = []
var have_dialoge_scene

func _ready():
	dialogBox.connect("continue_scene", self, "play_scene")
	dialogBox.connect("skiped", self, "to_gameplay_scene")
	firelab_animation.play("normal")
	fireworks_animation.play("normal")
	
	play_scene()

func main_scene_1():
	
	kid.visible = false
	current_dialogs = [
		["ANAK A :", "Wah, Hari ini cerah! Hari yang sempurna untuk menyalakan petasan."],
		["ANAK A :", "Tapi aku harus menyalakannya di mana ya?"],
		["ANAK A :", "Aku harus mencari tempat yang sempurna untuk menyalakannya."]
		]
	current_scenes = [
		["transition_start", false], ["scene_1", true], ["scene_2", false], ["transition_end", false]
	]
	
	play_scene()

func main_scene_2():
	current_dialogs = [
		["ANAK A :", "Sepertinya ini tempat yang sempurna untuk menyalakan petasan."],
		["ANAK A :", "Waktunya menyalakannya!"]
		]
	current_scenes = [
		["transition_start", false], ["scene_3", true], ["scene_4", false, "firework", "meledak"],
	]
	
	
	play_scene()

func main_scene_3():
	current_dialogs = [
		["ANAK A :", "Waah... Indah sekali petasannya"],
		["ANAK A :", "Pilihanku memang tidak salah untuk menyalakan petasan ini hari ini, di tempat ini."]
		]
	current_scenes = [
		["scene_5", true], ["scene_5", false, "firelab", "meledak"], 
	]
	
	play_scene()

func main_scene_4():
	current_dialogs = [
		["ANAK A :", "Huh??!!"],
		["ANAK A :", "Apa yang terjadi?"]
		]
	current_scenes = [
		["scene_7", true], ["scene_5", false, "firework", "normal", "firelab", "terbakar"]
	]
	
	play_scene()

func main_scene_5():
	current_dialogs = [
		["ANAK A :", "Oh tidak, aku telah membakar laboratorium ini"],
		["ANAK A :", "Apa yang harus ku lakukan?"],
		["ANAK A :", "Aku harus meminta tolong pemadam kebakran FIRE FORCE!"]
		]
	current_scenes = [
		["scene_8", true], ["scene_9", false], ["transition_end", false]
	]
	
	play_scene()

func main_scene_6():
	current_dialogs = [
		["ANAK A :", "FIRE FORCE!! Tolong!!"],
		["FIRE FORCE :", "Ada apa? Apa yang terjadi?"],
		["ANAK A :", "Ada kebakaran di laboratorium di ujung desa, muncul monster api dari sana!"],
		["ANAK A :", "Ini salahku karena bermain petasan di tempat rawan terbakar seperti itu."],
		["FIRE FORCE :", "Lain kali jangan bermain api lagi di tempat rawan terbakar ya."],
		["FIRE FORCE :", "Sekarang tolong kamu evakuasi seluruh warga untuk pergi dari sini. Aku akan memadamkan api wilayah ini."],
		["ANAK A :", "Baik FIRE FORCE!"]
		]
	current_scenes = [
		["transition_start", false], ["scene_10", true], ["transition_end", false]
	]
	
	play_scene()

func dialog(naskah):
	dialogBox.dialog_scene = naskah
	

func play_scene():
	if !current_scenes.empty():
		var next_scene = current_scenes.pop_front()
		print(next_scene)
		var name_scene = next_scene[0]
		have_dialoge_scene = next_scene[1]
		
		if next_scene.size() > 2:
			for i in range(2, next_scene.size()):
				effect_scene.push_back(next_scene[i])
		
		main_animation.play(name_scene)
	else:
		if !total_main_scene.empty():
			var new_main_scene = total_main_scene.pop_front()
			match new_main_scene:
				1 : 
					camera.position = lokasi_1
					main_scene_1()
				2 : 
					camera.position = lokasi_2
					yield(get_tree().create_timer(1), "timeout")
					main_scene_2()
				3 : main_scene_3()
				4 : main_scene_4()
				5 : main_scene_5()
				6 : 
					camera.position = lokasi_3
					yield(get_tree().create_timer(1.3), "timeout")
					main_scene_6()
		else:
			to_gameplay_scene(false)

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "transition_end":
		yield(get_tree().create_timer(1), "timeout")
	if !effect_scene.empty():
		var i = 0
		print(effect_scene)
		for efek in effect_scene:
			if efek == "firework":
				fireworks_animation.play(effect_scene[i+1])
			if efek == "firelab":
				firelab_animation.play(effect_scene[i+1])
			i = i+1
		
	if have_dialoge_scene:
			main_animation.stop()
			dialog(current_dialogs)
	else:
		play_scene()

func to_gameplay_scene(skiped):
	main_animation.play("transition_end")
	if skiped:
		yield(get_tree().create_timer(1), "timeout")
	get_tree().change_scene("res://Map/world.tscn")
