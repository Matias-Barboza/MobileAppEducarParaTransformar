extends Control

# Atributos Export
#export var escena_login : PackedScene


# Atributos
var header : = [ "content-type: application/json"]
var endpointMaterias : String = Globals.URL + "/api/teachers/classes/" + str(Globals.userId)
var endpointAlumnos: String = Globals.URL + "/api/classes/"
var endpointNota : String = Globals.URL + "/api/notes/student/"
var endpointModificarNota : String = Globals.URL + "/api/notes"

var desplegado : bool
var estado_traducir : bool
var paneles : Array
var escena_login : PackedScene

var listaMaterias : = []
var listaAlumnos : = []
var arreglo_alumnos : = []
var datos_alumno : = []
var arreglo_materias : = []
var datos_materia : = []
var alumnos_por_materia : = []
var alumnos
var materia_seleccionada 
var nota_Seleccionada


# Atributos Onready
onready var animation_player : AnimationPlayer = $AnimationPlayer
onready var panel_bienvenida : Panel = $Bienvenida/PanelBienvenida
onready var panel_horarios : Panel = $Horarios/PanelHorarios
onready var panel_cursos : Panel = $Cursos/PanelCursos
onready var panel_carga_notas : Panel = $CargarNotas/PanelCargaNotas
onready var panel_cursos_horarios : Panel = $CursosHorarios/PanelCursosHorarios

onready var panel_seleccion_materia = $Horarios/PanelSeleccionMateria
onready var panel_seleccion_alumno = $CargarNotas/PanelSeleccionAlumno
onready var panel_seleccion_curso = $Cursos/PanelSeleccionCurso

onready var animation_player_toggle : AnimationPlayer = $MenuLateral/PanelLateral/VBoxContainer/Control/AnimationPlayer
onready var sprite_arg : Sprite = $MenuLateral/PanelLateral/VBoxContainer/Control/SpriteARG
onready var sprite_usa : Sprite = $MenuLateral/PanelLateral/VBoxContainer/Control/SpriteUSA

onready var seleccion_materia_horarios : OptionButton = $Horarios/PanelSeleccionMateria/SeleccionMateria/ParteCentral/MateriaSeleccion/OptionButton
onready var seleccion_materia_alumnos : OptionButton = $Cursos/PanelSeleccionCurso/SeleccionMateria/ParteCentral/MateriaSeleccion/OptionButton
onready var seleccion_materia_cargar_notas : OptionButton = $CargarNotas/PanelSeleccionAlumno/SeleccionAlumno/ParteCentral/AlumnoSeleccion/OptionButtonMateria

onready var tabla_alumno : = $Cursos/PanelCursos/ScrollContainer/TablaAlumnos
onready var tabla_materias : = $Horarios/PanelHorarios/ScrollContainer/TablaHorariosDocente
onready var label_mensaje : Label = $CargarNotas/PanelCargaNotas/CargaNotas/ParteCentral/LabelMensaje
onready var label_mensaje_cursos : Label = $Cursos/PanelSeleccionCurso/SeleccionMateria/ParteCentral/LabelMensaje
onready var boton_buscar_materia : Button = $Cursos/PanelSeleccionCurso/SeleccionMateria/ParteCentral/MateriaSeleccion/ButtonSM
onready var request_materias : HTTPRequest = $GetMaterias


# Metodos
func _ready() -> void:
	
	boton_buscar_materia.set_deferred("disabled", true)
	
	desplegado = false
	paneles = [panel_bienvenida, panel_seleccion_materia, panel_seleccion_alumno, panel_seleccion_curso, panel_cursos_horarios, panel_cursos]
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
	
	request_materias.request(endpointMaterias)


func activar_panel(panel_a_visibilizar : Panel):
	for panel in paneles:
		if panel != panel_a_visibilizar:
			panel.visible = false
		else:
			panel.visible = true
	
	#animation_player.play("replegar")
	#desplegado = not desplegado


func convertir_dia_a_espanol(dia_en_ingles: String) -> String:
	var dias = {
		"MONDAY": "Lunes",
		"TUESDAY": "Martes",
		"WEDNESDAY": "Miércoles",
		"THURSDAY": "Jueves",
		"FRIDAY": "Viernes",
		"SATURDAY": "Sábado",
		"SUNDAY": "Domingo"
	}
	
	if dias.has(dia_en_ingles):
		return dias[dia_en_ingles]
	else:
		return "Día no válido"


# Señales internas
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
func _on_GetMaterias_request_completed(_result: int, response_code: int, _headers: PoolStringArray, body: PoolByteArray) -> void:

	if response_code == 200:
		var json = JSON.parse(body.get_string_from_utf8())
		
		tabla_materias.reiniciar_tabla()
		yield(get_tree().create_timer(0.5), "timeout")
		
		for materia in json.result:
			listaMaterias.append(materia)
			
			var request = HTTPRequest.new()
			request.connect("request_completed", self, "_on_request_alumnos_completed", [materia])
			add_child(request)
			request.request('{URL}{id}/students'.format({"URL" : endpointAlumnos, "id" : materia["id"]}))
			
			seleccion_materia_horarios.get_popup().add_item(materia["class_name"] + " ("+ materia.division.division_name + ")")
			seleccion_materia_alumnos.get_popup().add_item(materia["class_name"] + " ("+ materia.division.division_name + ")")
			seleccion_materia_cargar_notas.get_popup().add_item(materia["class_name"] + " ("+ materia.division.division_name + ")")
			
			for horario in materia.schedules:
				
				datos_materia.insert(0, materia["class_name"])
				datos_materia.insert(1, materia["division"]["division_name"])
				datos_materia.insert(2, materia["classroom"]["room_type"])
				datos_materia.insert(3, convertir_dia_a_espanol(horario["day"]))
				datos_materia.insert(4, horario["startingTime"] + " - " + horario["endTime"])
				arreglo_materias.append(datos_materia)
				datos_materia = []
				
		tabla_materias.set_data(arreglo_materias)
	else:
		print("Error al obtener los horarios")


func _on_GetNota_request_completed(_result: int, response_code: int, _headers: PoolStringArray, body: PoolByteArray) -> void:
	
	if response_code == 200:
		var json = JSON.parse(body.get_string_from_utf8())
		
		for nota in json.result:
			
			if nota["class_name"] == materia_seleccionada["class_name"]:
				nota_Seleccionada = nota
				$PanelNota/Nota_1.text = str(nota["numeric_note_1"])
				$PanelNota/Nota_2.text = str(nota["numeric_note_2"])
				$PanelNota/Nota_3.text = str(nota["numeric_note_3"])


func _on_ModificarNota_request_completed(_result: int, response_code: int, _headers: PoolStringArray, _body: PoolByteArray) -> void:

	if response_code == 200:
		label_mensaje.text = "Notas modificadas con exito"
	else:
		label_mensaje.text = "Las notas no han sido modificadas"
	
	label_mensaje.visible = true


func _on_request_alumnos_completed(_result, response_code, _headers, body, params):
	
	var materia = params["class_name"] + params["division"]["division_name"]
	
	if response_code == 200:
		var json = JSON.parse(body.get_string_from_utf8())
		var datos_materia = {"materia": materia, "alumnos": json.result}
		alumnos_por_materia.append(datos_materia)
		boton_buscar_materia.set_deferred("disabled", false)
	else:
		print("Error al obtener los alumnos de la materia", materia, ". Código de respuesta:", response_code)


func _on_OptionButton_item_selected(index: int) -> void:
	
	materia_seleccionada = listaMaterias[index]
	
	#label_nombre_materia.text = materia_seleccionada["class_name"]


func obtener_alumnos_de_materia(materia):
	
	for datos_materia in alumnos_por_materia:
		if datos_materia["materia"] == materia:
			return datos_materia["alumnos"]
	return []


func _on_ButtonSM_pressed() -> void:
	
	if materia_seleccionada["class_name"] != null:
		
		var alumnos_de_la_materia = obtener_alumnos_de_materia(materia_seleccionada["class_name"] + materia_seleccionada["division"]["division_name"])
		
		if alumnos_de_la_materia.empty():
			seleccion_materia_alumnos.selected = -1
			label_mensaje_cursos.text = "La lista está vacía. Intente nuevamente."
			label_mensaje_cursos.visible = true
			return
		
		alumnos = alumnos_de_la_materia
		tabla_alumno.reiniciar_tabla()
		arreglo_alumnos = []
		
		yield(get_tree().create_timer(0.2), "timeout")
		for alumno in alumnos_de_la_materia:
			datos_alumno.insert(0,alumno.dni)
			datos_alumno.insert(1,alumno.lastname)
			datos_alumno.insert(2,alumno.firstname)
			datos_alumno.insert(3, alumno.username)
			arreglo_alumnos.append(datos_alumno)
			datos_alumno = []
		tabla_alumno.set_data(arreglo_alumnos)
		
		activar_panel(panel_cursos)
		
		seleccion_materia_alumnos.selected = -1
