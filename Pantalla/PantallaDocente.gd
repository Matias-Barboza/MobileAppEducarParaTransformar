extends Control

# Atributos Export
#export var escena_login : PackedScene


# Atributos Onready
onready var animation_player : AnimationPlayer = $AnimationPlayer
onready var panel_bienvenida : Panel = $Bienvenida/PanelBienvenida
onready var panel_horarios : Panel = $TablaHorarios/PanelHorarios
onready var panel_cursos : Panel = $TablaCursos/PanelCursos
onready var panel_carga_notas : Panel = $CargarNotas/PanelCargaNotas
onready var panel_cursos_horarios : Panel = $TablaCursosHorarios/PanelCursosHorarios
onready var animation_player_toggle : AnimationPlayer = $MenuLateral/PanelLateral/VBoxContainer/Control/AnimationPlayer
onready var sprite_arg : Sprite = $MenuLateral/PanelLateral/VBoxContainer/Control/SpriteARG
onready var sprite_usa : Sprite = $MenuLateral/PanelLateral/VBoxContainer/Control/SpriteUSA

# Atributos
var desplegado : bool
var estado_traducir : bool
var paneles : Array
var escena_login : PackedScene


func _ready() -> void:
	
	desplegado = false
	paneles = [panel_bienvenida, panel_horarios, panel_carga_notas, panel_cursos, panel_cursos_horarios]
	escena_login = load("res://Pantalla/PantallaInicioSesion.tscn")
	if TranslationServer.get_locale() == "es":
		animation_player_toggle.play("on")
		estado_traducir = false
		sprite_arg.visible = true
		sprite_usa.visible = false
	else: 
		animation_player_toggle.play("off")
		estado_traducir = true
		sprite_arg.visible = false
		sprite_usa.visible = true
	


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
	print("ButtonHP")
	activar_panel(panel_horarios)


func _on_ButtonCargarNotas_pressed() -> void:
	
	activar_panel(panel_carga_notas)


func _on_ButtonCursos_pressed() -> void:
	
	activar_panel(panel_cursos)


func _on_ButtonCombinado_pressed() -> void:
	pass # Replace with function body.


func _on_ButtonCN_pressed() -> void:
	pass # Replace with function body.



func _on_ButtonSalir_pressed():
	get_tree().change_scene_to(escena_login)



func _on_ButtonTraduccion_pressed():
	estado_traducir = !estado_traducir
	
	if !estado_traducir:
		animation_player_toggle.play("on")
		TranslationServer.set_locale("es")
		sprite_arg.visible = true
		sprite_usa.visible = false
	else:
		animation_player_toggle.play("off")
		TranslationServer.set_locale("en")
		sprite_arg.visible = false
		sprite_usa.visible = true

