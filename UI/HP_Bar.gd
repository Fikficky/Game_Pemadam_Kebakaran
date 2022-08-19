extends TextureRect

var aman = preload ("res://UI/BarV8_Blue_ProgressBar.png")
var terbakar = preload("res://UI/BarV8_Red_ProgressBar.png")
var player = preload("res://UI/BarV8_Green_ProgressBar.png")


func animasi(status):
	if status == "player":
		if $TextureProgress.value == 100:
			$AnimationPlayer.play("normal")
	else:
		if $TextureProgress.value == 100 and $AnimationPlayer.get_current_animation() != "hilang":
			$AnimationPlayer.play("hilang")
	
	if $TextureProgress.value >= 25 and $TextureProgress.value < 100:
		$AnimationPlayer.play("normal")
	
	elif $TextureProgress.value < 25:
		$AnimationPlayer.play("danger")

func update_value_bar(st, nilai):
	if st == "aman":
		$TextureProgress.set_progress_texture(aman)
	elif st == "player":
		$TextureProgress.set_progress_texture(player)
	else:
		$TextureProgress.set_progress_texture(terbakar)
	$TextureProgress.value = nilai
	animasi(st)



