extends Panel


onready var contrasenha = $ParteCentral/Datos/LineEditContrasenha
onready var enter = $ParteCentral/Datos/ButtonIS


func _on_LineEditContrasenha_text_changed(new_text):
	Globals.password = contrasenha.text


func _on_LineEditContrasenha_text_entered(new_text):
	enter.emit_signal("pressed")
