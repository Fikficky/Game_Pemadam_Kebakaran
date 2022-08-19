extends CanvasLayer

var missionPanel = load("res://UI/mission_panel.tscn")

onready var pauseMenu = $PauseMenu
onready var pauseBtn = $Pause_btn
onready var slime = get_node("slime_icon")
onready var house = get_node("house_icon")
onready var tower = get_node("tower_icon")
onready var refill = get_node("touchscreen/Refill")
onready var spawn = get_node("spawn_alert")
onready var mission_list = get_node_or_null("VBoxContainer/bottom/ScrollContainer/List")
onready var mission_panel_list = get_node("VBoxContainer/bottom")
onready var mission_btn = get_node("VBoxContainer/mission")
onready var mission_btn_label = get_node("VBoxContainer/head/mission/Label")
var normal = preload("res://UI/refill_active.png")
var pressed = preload("res://UI/refill_pressed.png")
var disable = preload("res://UI/refill_disable.png")

func _ready():
	update_point(0)
	pauseBtn.connect("pressed", self, "_paused")
	pauseMenu.connect("resume", self, "_resumeGame")
	pauseMenu.connect("back", self, "_to_main_menu")
	_refillBtn(false)
	spawn.visible = false
	pass # Replace with function body.

func update_HP(persen):
	$HP_Bar.update_value_bar("player", persen)
	pass # Replace with function body.

func update_Water(persen):
	$Water_Bar.update_value_bar(persen)
	if persen <= 0:
		$AnimationPlayer.play("danger")
	pass # Replace with function body.

func update_point(value):
	var point = get_node("point/value")
	var current_value = int(point.get_text())
	var new_value
	
#	new_value = current_value + value
#	if new_value < 3:
#		new_value = 0
#	point.text = str(new_value)
	
	new_value = current_value
	if value > 0:
		for _i in range(value):
			new_value += 1
			point.text = str(new_value)
			yield(get_tree().create_timer(0.05), "timeout")
	else:
		value *= -1
		for _i in range(value):
			new_value -= 1
			if new_value < 0:
				new_value = 0
			point.text = str(new_value)
			yield(get_tree().create_timer(0.05), "timeout")
	Global.point = new_value

func anim_refill_water(persen, state):
	$AnimationPlayer.play("refill")
	if persen >= 100 or !state:
		$AnimationPlayer.play("normal")
	if state:
		_refillBtn(!state)

func _refillBtn(state):
	if state:
		refill.set_action("refill")
		refill.set_texture(normal)
		refill.set_texture_pressed(pressed)
	else:
		refill.set_action("")
		refill.set_texture(disable)
		refill.set_texture_pressed(null)

func _paused():
	pauseBtn.visible = false
	pauseMenu.visible = true
	get_tree().paused = true

func _resumeGame():
	pauseMenu.visible = false
	pauseBtn.visible = true
	get_tree().paused = false

func update_icon(s, h, t):
	var jml_slime = slime.get_node("pin/jml")
	var jml_house = house.get_node("pin/jml")
	var jml_tower = tower.get_node("pin/jml")
	if s == 0:
		slime.visible = false
	else:
		slime.visible = true
		jml_slime.text = str(s)
	
	if h == 0:
		house.visible = false
	else:
		house.visible = true
		jml_house.text = str(h)
	
	if t == 0:
		tower.visible = false
	else:
		tower.visible = true
		jml_tower.text = str(t)

func countdown_spawn(second):
	var sec = spawn.get_node("second")
	if second <= 0:
		spawn.visible = false
	else:
		spawn.visible = true
		sec.text = str(second)

func mission(list_code):
	delete_mission(list_code)
	for m_code in list_code:
		var input_status = true
		var pesan
		var prioritas
		if mission_list == null:
			input_status = true
		else:
			var c_list = mission_list.get_children()
			for current_mission in c_list:
				var current_code = current_mission.code
				if current_code == m_code:
					input_status = false
		
		if input_status:
			match m_code:
				1 :
					pesan = "Isi tas air ke tower terdekat!"
				2 :
					pesan = "Padamkan semua tower! Untuk mengahancurkan pertahanan Fire Lab"
				3 :
					pesan = "Padamkan Fire Lab! Untuk mecegah munculnya monster api kembali"
				4 :
					pesan = "Kalahkan semua monster api!"
				5 :
					pesan = "Padamkan semua api di sekitar!"
			
			prioritas = position_mission(m_code)
			
			var panel = missionPanel.instance()
			panel.input_mission(pesan, m_code)
			mission_list.add_child(panel)
			mission_list.move_child(panel, prioritas)

func delete_mission(new_list):
	var current_list = mission_list.get_children()
	var temp
	
	for i in range (current_list.size()):
		var c_code = current_list[i].code
		temp = i
		
		for j in range (new_list.size()):
			var n_code = new_list[j]
			
			if c_code == n_code:
				temp = null
			
			if j == (new_list.size() - 1) and temp != null:
				var selected_mission = mission_list.get_child(temp)
				mission_list.remove_child(selected_mission)
				selected_mission.queue_free()

func position_mission(code_mission):
	var pos = 0
	var current_list = mission_list.get_children()
	for i in range (current_list.size()):
		var current_code = current_list[i].code
		if code_mission > current_code:
			pos = i + 1
	return pos

func _to_main_menu():
	get_tree().change_scene("res://Main_menu.tscn")
	get_tree().paused = false


func _on_mission_toggled(button_pressed):
	if button_pressed:
		mission_panel_list.visible = false
		mission_btn_label.text = "SHOW"
	else:
		mission_panel_list.visible = true
		mission_btn_label.text = "HIDE"
