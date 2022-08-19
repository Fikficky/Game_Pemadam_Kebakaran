extends VBoxContainer

var code 

func input_mission(isi, mission_code):
	code = mission_code
	$Label.text = str(isi)
