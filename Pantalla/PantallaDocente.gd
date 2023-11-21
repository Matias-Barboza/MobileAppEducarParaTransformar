extends Control

# Atributos Export
#export var escena_login : PackedScene


# Atributos Onready
onready var animation_player : AnimationPlayer = $AnimationPlayer
onready var panel_bienvenida : Panel = $Bienvenida/PanelBienvenida
onready var panel_horarios : Panel = $Horarios/PanelHorarios
onready var panel_cursos : Panel = $Cursos/PanelCursos
onready var panel_carga_notas : Panel = $CargarNotas/PanelCargaNotas
onready var panel_cursos_horarios : Panel = $TablaCursosHorarios/PanelCursosHorarios

onready var panel_seleccion_materia = $Horarios/PanelSeleccionMateria
onready var panel_seleccion_alumno = $CargarNotas/PanelSeleccionAlumno
onready var panel_seleccion_curso = $Cursos/PanelSeleccionCurso

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
	paneles = [panel_bienvenida, panel_seleccion_materia, panel_seleccion_alumno, panel_seleccion_curso, panel_cursos_horarios]
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
	
	activar_panel(panel_seleccion_materia)


func _on_ButtonCargarNotas_pressed() -> void:
	
	activar_panel(panel_seleccion_alumno)


func _on_ButtonCursos_pressed() -> void:
	
	activar_panel(panel_seleccion_curso)


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


# Request
#func _on_GetMaterias_request_completed(result: int, response_code: int, headers: PoolStringArray, body: PoolByteArray) -> void:
#
#	if response_code == 200:
#		var json = JSON.parse(body.get_string_from_utf8())
#
#		tabla_materias.reiniciar_tabla()
#		yield(get_tree().create_timer(0.5), "timeout")
#
#		for materia in json.result:
#			listaMaterias.append(materia)
#
#			seleccion_materia.get_popup().add_item(materia["class_name"] + " ("+ materia.division.division_name + ")")
#			seleccion_materia_nota.get_popup().add_item(materia["class_name"] + " ("+ materia.division.division_name + ")")
#
#			for horario in materia.schedules:
#
#				datos_materia.insert(0, materia["class_name"])
#				datos_materia.insert(1, materia["division"]["division_name"])
#				datos_materia.insert(2, materia["classroom"]["room_type"])
#				datos_materia.insert(3, convertir_dia_a_espanol(horario["day"]))
#				datos_materia.insert(4, horario["startingTime"] + " - " + horario["endTime"])
#				arreglo_materias.append(datos_materia)
#				datos_materia = []
#
#		tabla_materias.set_data(arreglo_materias)
#	else:
#		print("Error al obtener los horarios")
#
#
#func _on_GetAlumnos_request_completed(result: int, response_code: int, headers: PoolStringArray, body: PoolByteArray) -> void:
#
#	if response_code == 200:
#		var json = JSON.parse(body.get_string_from_utf8())
#		alumnos = json
#		tabla_alumno.reiniciar_tabla()
#		arreglo_alumnos = []
#		yield(get_tree().create_timer(0.5), "timeout")
#		for alumno in json.result:
#			datos_alumno.insert(0,alumno.file_number)
#			datos_alumno.insert(1,alumno.lastname)
#			datos_alumno.insert(2,alumno.firstname)
#			arreglo_alumnos.append(datos_alumno)
#			datos_alumno = []
#		tabla_alumno.set_data(arreglo_alumnos)
#
#	else:
#		print("Error en la request alumnos")
#
#
#func _on_GetAlumnosNota_request_completed(result: int, response_code: int, headers: PoolStringArray, body: PoolByteArray) -> void:
#
#	if response_code == 200:
#		var json = JSON.parse(body.get_string_from_utf8())
#
#		for alumno in json.result:
#			listaAlumnos.append(alumno)
#			seleccion_alumno_nota.get_popup().add_item(alumno["firstname"] + " " + alumno["lastname"])
#
#
#func _on_GetNota_request_completed(result: int, response_code: int, headers: PoolStringArray, body: PoolByteArray) -> void:
#
#	if response_code == 200:
#		var json = JSON.parse(body.get_string_from_utf8())
#
#		for nota in json.result:
#
#			if nota["class_name"] == materia_seleccionada["class_name"]:
#				nota_Seleccionada = nota
#
#				$PanelNota/Nota_1.text = str(nota["numeric_note_1"])
#				$PanelNota/Nota_2.text = str(nota["numeric_note_2"])
#				$PanelNota/Nota_3.text = str(nota["numeric_note_3"])
#
#
#func _on_ModificarNota_request_completed(result: int, response_code: int, headers: PoolStringArray, body: PoolByteArray) -> void:
#
#	if response_code == 200:
#		panel_nota_exitoso.visible = true
#		panel_nota_fallido.visible = false
#	else:
#		panel_nota_exitoso.visible = false
#		panel_nota_fallido.visible = true
