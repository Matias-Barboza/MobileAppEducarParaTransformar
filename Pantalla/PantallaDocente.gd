extends Control


var desplegado : bool


onready var animation_player : AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	
	desplegado = false


func _on_ButtonMenuLateral_pressed() -> void:
	
	if not desplegado:
		animation_player.play("desplegar")
	else:
		animation_player.play("replegar")
	
	desplegado = !desplegado
