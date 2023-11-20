extends Control


var desplegado : bool
var paneles : Array


onready var animation_player : AnimationPlayer = $AnimationPlayer
onready var panel_bienvenida : Panel = $Bienvenida/PanelBienvenida
onready var panel_horarios : Panel = $TablaHorarios/PanelHorarios
onready var panel_cursos : Panel = $TablaCursos/PanelCursos
onready var panel_carga_notas : Panel = $CargarNotas/PanelCargaNotas


func _ready() -> void:
	
	desplegado = false
	
	paneles = [panel_bienvenida, panel_horarios, panel_carga_notas, panel_cursos]


func activar_panel(panel_a_visibilizar : Panel):
	for panel in paneles:
		if panel != panel_a_visibilizar:
			panel.visible = false
		else:
			panel.visible = true
	animation_player.play("replegar")
	desplegado = not desplegado


func _on_ButtonMenuLateral_pressed() -> void:
	
	if not desplegado:
		animation_player.play("desplegar")
	else:
		animation_player.play("replegar")
	
	desplegado = !desplegado


func _on_ButtonHorarios_pressed() -> void:
	
	activar_panel(panel_horarios)


func _on_ButtonCargarNotas_pressed() -> void:
	
	activar_panel(panel_carga_notas)


func _on_ButtonCursos_pressed() -> void:
	
	activar_panel(panel_cursos)


func _on_ButtonCombinado_pressed() -> void:
	pass # Replace with function body.


func _on_ButtonCN_pressed() -> void:
	pass # Replace with function body.






