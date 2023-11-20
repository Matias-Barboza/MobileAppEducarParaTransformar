extends Panel


onready var contrasenha = $ParteCentral/Datos/LineEditContrasenha
onready var enter = $ParteCentral/Datos/ButtonIS


func _on_LineEditContrasenha_text_changed(new_text):
	Globals.password = contrasenha.text


func _on_LineEditContrasenha_text_entered(new_text):
	enter.emit_signal("pressed")


func _on_AnimationPlayer_animation_started(anim_name):
	print(anim_name)
