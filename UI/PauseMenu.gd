extends Control

signal resume
signal back

func _on_resume_btn_pressed():
	emit_signal("resume")

func _on_back_btn_pressed():
	emit_signal("back")
