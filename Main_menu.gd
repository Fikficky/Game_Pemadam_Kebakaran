extends CanvasLayer

onready var play = get_node("Bg/CenterContainer/VBoxContainer/play_btn")
onready var quit = get_node("Bg/CenterContainer/VBoxContainer/quit_btn")

func _ready():
	play.connect("pressed", self, "_play_game")
	quit.connect("pressed", self, "_quit_game")

func _play_game():
	get_tree().change_scene("res://Narration.tscn")

func _quit_game():
	get_tree().quit()
