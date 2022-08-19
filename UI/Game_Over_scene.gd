extends CanvasLayer

onready var play_again = get_node("Bg/HBoxContainer/play_btn")
onready var back = get_node("Bg/HBoxContainer/back_btn")
onready var point = get_node("Bg/point")

func _ready():
	play_again.connect("pressed", self, "_play_game")
	back.connect("pressed", self, "_to_main_menu")
	result_point()

func result_point():
	point.text = str(Global.point)
	
func _play_game():
	get_tree().change_scene("res://Map/world.tscn")

func _to_main_menu():
	get_tree().change_scene("res://Main_menu.tscn")
