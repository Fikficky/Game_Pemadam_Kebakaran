extends CanvasLayer

const CHAR_READ_RATE = 0.05

onready var textbox_container = $TextboxContainer
onready var name_char = get_node("TextboxContainer/MarginContainer/VBoxContainer/Name")
onready var dialog = get_node("TextboxContainer/MarginContainer/VBoxContainer/HBoxContainer/Text")
onready var next_btn = get_node("TextboxContainer/MarginContainer/VBoxContainer/HBoxContainer/MarginContainer/Next")

enum State {
	READY,
	READING,
	FINISED
}

var current_state = State.READY
var dialog_scene = []
var finised = false

signal continue_scene
signal skiped

func _ready():
	hide_textbox()

func _process(delta):
	match current_state:
		State.READY :
			if !dialog_scene.empty():
				display_text()
		State.READING :
			if next_btn.is_pressed() and current_state == State.READING:
				dialog.percent_visible = 1.0
				$Tween.stop_all()
				next_btn.set_disabled(true)
				change_state(State.FINISED)
			
		State.FINISED :
			if next_btn.is_pressed()  and current_state == State.FINISED:
				change_state(State.READY)
				hide_textbox()
				if dialog_scene.empty():
					emit_signal("continue_scene")
			else:
				next_btn.set_disabled(false)

func hide_textbox():
	name_char.text = ""
	dialog.text = ""
	next_btn.visible = false
	textbox_container.hide()

func show_textbox():
	textbox_container.show()

func display_text():
	var kalimat = dialog_scene.pop_front()
	name_char.text = kalimat[0]
	dialog.text = kalimat[1]
	dialog.percent_visible = 0.0
	show_textbox()
	change_state(State.READING)
	$Tween.interpolate_property(dialog, "percent_visible", 0.0, 1.0, len(dialog.text) * CHAR_READ_RATE, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.start()
	next_btn.set_disabled(false)
	next_btn.visible = true

func change_state(next_stage):
	current_state = next_stage
	

func _on_Tween_tween_all_completed():
	change_state(State.FINISED)


func _on_TextureButton_pressed():
	hide_textbox()
	emit_signal("skiped", true)
