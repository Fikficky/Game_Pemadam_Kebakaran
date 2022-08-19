extends TextureRect

func _animasi():
	if $TextureProgress.value <= 30:
		$AnimationPlayer.play("danger")
	else:
		$AnimationPlayer.play("normal")

func update_value_bar(nilai):
	$TextureProgress.value = nilai
	_animasi()
