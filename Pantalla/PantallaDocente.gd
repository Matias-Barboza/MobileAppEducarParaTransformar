extends Control


# Atributos
var header : = [ "content-type: application/json"]
var endpointMaterias : String = Globals.URL + "/api/teachers/classes/" + str(Globals.userId)
var endpointAlumnos: String = Globals.URL + "/api/classes/"
var endpointNota : String = Globals.URL + "/api/notes/student/"
var endpointModificarNota : String = Globals.URL + "/api/notes"
var endpointAlumnosId : String = Globals.URL + "/api/divisions/students/"

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
var alumnos_por_materia_id : = []
var materia_seleccionada 
var nota_Seleccionada
var alumno


# Atributos Onready
onready var animation_player : AnimationPlayer = $AnimationPlayer
onready var panel_bienvenida : Panel = $Bienvenida/PanelBienvenida


# Onready relacionados a la traduccion
onready var animation_player_toggle : AnimationPlayer = $MenuLateral/PanelLateral/VBoxContainer/Control/AnimationPlayer
onready var sprite_arg : Sprite = $MenuLateral/PanelLateral/VBoxContainer/Control/SpriteARG
onready var sprite_usa : Sprite = $MenuLateral/PanelLateral/VBoxContainer/Control/SpriteUSA


# Onready relacionado a las request
onready var request_materias : HTTPRequest = $GetMaterias


# Onready relacionados a la tabla de horarios por materia que tiene un profesor
onready var boton_mostrar_horariosML : Button = $MenuLateral/PanelLateral/VBoxContainer/ButtonHorarios
onready var panel_horarios : Panel = $Horarios/PanelHorarios
onready var tabla_horarios_de_materias : = $Horarios/PanelHorarios/ScrollContainer/TablaHorariosDocente


# Onready relacionados a la carga de notas por alumno
onready var boton_cargar_notasML : Button = $MenuLateral/PanelLateral/VBoxContainer/ButtonCargarNotas
onready var panel_carga_notas : Panel = $CargarNotas/PanelCargaNotas
onready var panel_seleccion_alumno = $CargarNotas/PanelSeleccionAlumno

onready var boton_buscar_alumno : Button = $CargarNotas/PanelSeleccionAlumno/SeleccionAlumno/ParteCentral/AlumnoSeleccion/ButtonBA
onready var label_mensaje_estado_cargar_notas : Label = $CargarNotas/PanelCargaNotas/CargaNotas/ParteCentral/LabelMensaje
onready var seleccion_materia_cargar_notas : OptionButton = $CargarNotas/PanelSeleccionAlumno/SeleccionAlumno/ParteCentral/AlumnoSeleccion/OptionButtonMateria
onready var seleccion_alumno_cargar_notas : OptionButton = $CargarNotas/PanelSeleccionAlumno/SeleccionAlumno/ParteCentral/AlumnoSeleccion/OptionButtonAlumno

onready var nota_1 = $CargarNotas/PanelCargaNotas/CargaNotas/ParteCentral/Notas/Nota1erTri2
onready var nota_2 = $CargarNotas/PanelCargaNotas/CargaNotas/ParteCentral/Notas/Nota2doTri2
onready var nota_3 = $CargarNotas/PanelCargaNotas/CargaNotas/ParteCentral/Notas/Nota3erTri2

# Onready relacionados a la tabla de alumnos por curso
onready var boton_buscar_cursoML : Button = $MenuLateral/PanelLateral/VBoxContainer/ButtonCursos
onready var panel_seleccion_curso = $Cursos/PanelSeleccionCurso
onready var panel_cursos : Panel = $Cursos/PanelCursos

onready var label_nombre_materia : Label = $Cursos/PanelCursos/LabelNombre
onready var label_mensaje_cursos : Label = $Cursos/PanelSeleccionCurso/SeleccionMateria/ParteCentral/LabelMensaje
onready var seleccion_materia_alumnos_por_curso : OptionButton = $Cursos/PanelSeleccionCurso/SeleccionMateria/ParteCentral/MateriaSeleccion/OptionButton
onready var boton_buscar_materia : Button = $Cursos/PanelSeleccionCurso/SeleccionMateria/ParteCentral/MateriaSeleccion/ButtonSM
onready var tabla_alumnos_por_curso : = $Cursos/PanelCursos/ScrollContainer/TablaAlumnos


# Falta implementar
onready var boton_combinadoML : Button = $MenuLateral/PanelLateral/VBoxContainer/ButtonCombinado
onready var panel_cursos_horarios : Panel = $CursosHorarios/PanelCursosHorarios


# Metodos
func _ready() -> void:
	
	
	boton_mostrar_horariosML.set_deferred("disabled", true)
	boton_cargar_notasML.set_deferred("disabled", true)
	boton_buscar_cursoML.set_deferred("disabled", true)
	boton_combinadoML.set_deferred("disabled", true)
	
	
	seleccion_alumno_cargar_notas.set_deferred("disabled", true)
	boton_buscar_alumno.set_deferred("disabled", true)
	
	
	$AnimationPlayerSpinner.play("girar")
	boton_buscar_materia.set_deferred("disabled", true)
	
	desplegado = false
	paneles = [panel_bienvenida, panel_horarios,
	panel_seleccion_alumno, panel_carga_notas, 
	panel_seleccion_curso, panel_cursos,
	panel_cursos_horarios]
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
	
	if desplegado:
		animation_player.play("replegar")
		desplegado = not desplegado


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
	
	activar_panel(panel_horarios)


func _on_ButtonCargarNotas_pressed() -> void:
	
	activar_panel(panel_seleccion_alumno)


func _on_ButtonCursos_pressed() -> void:
	
	activar_panel(panel_seleccion_curso)


func _on_ButtonCombinado_pressed() -> void:
	
	activar_panel(panel_cursos_horarios)


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
		
		tabla_horarios_de_materias.reiniciar_tabla()
		yield(get_tree().create_timer(0.5), "timeout")
		
		for materia in json.result:
			listaMaterias.append(materia)
			
			var request = HTTPRequest.new()
			request.connect("request_completed", self, "_on_request_alumnos_completed", [materia])
			add_child(request)
			request.request('{URL}{id}/students'.format({"URL" : endpointAlumnos, "id" : materia["id"]}))
			
			var request2 = HTTPRequest.new()
			request2.connect("request_completed", self, "_on_request_alumnosId_completed", [materia])
			add_child(request2)
			request2.request('{URL}{id}'.format({"URL" : endpointAlumnosId, "id" : materia.division.id}))
			
			seleccion_materia_alumnos_por_curso.get_popup().add_item(materia["class_name"] + " ("+ materia.division.division_name + ")")
			seleccion_materia_cargar_notas.get_popup().add_item(materia["class_name"] + " ("+ materia.division.division_name + ")")
			
			for horario in materia.schedules:
				
				datos_materia.insert(0, materia["class_name"])
				datos_materia.insert(1, materia["division"]["division_name"])
				datos_materia.insert(2, materia["classroom"]["room_type"])
				datos_materia.insert(3, convertir_dia_a_espanol(horario["day"]))
				datos_materia.insert(4, horario["startingTime"] + " - " + horario["endTime"])
				arreglo_materias.append(datos_materia)
				datos_materia = []
				
		tabla_horarios_de_materias.set_data(arreglo_materias)
		
		boton_mostrar_horariosML.set_deferred("disabled", false)
		boton_cargar_notasML.set_deferred("disabled", false)
		boton_buscar_cursoML.set_deferred("disabled", false)
		boton_combinadoML.set_deferred("disabled", false)
	else:
		print("Error al obtener los horarios")

func _on_request_alumnos_completed(_result, response_code, _headers, body, params):
	
	var materia = params["class_name"] + params["division"]["division_name"]
	
	if response_code == 200:
		var json = JSON.parse(body.get_string_from_utf8())
		var datos_materia = {"materia": materia, "alumnos": json.result}
		alumnos_por_materia.append(datos_materia)
		$AnimationPlayerSpinner.play("ocultar")
		boton_buscar_materia.set_deferred("disabled", false)
	else:
		print("Error al obtener los alumnos sin id", materia, ". Código de respuesta:", response_code)

func _on_request_alumnosId_completed(_result, response_code, _headers, body, params):
	var materia = params["class_name"] + params["division"]["division_name"]
	
	if response_code == 200:
		var json = JSON.parse(body.get_string_from_utf8())
		var datos_materia = {"materia": materia, "alumnos": json.result}
		alumnos_por_materia_id.append(datos_materia)
	else:
		print("Error al obtener los alumnos con id. Código de respuesta:", response_code)

func _on_OptionButton_item_selected(index: int) -> void:
	
	materia_seleccionada = listaMaterias[index]

func obtener_alumnos_de_materia_id(materia):
	
	for datos_materia in alumnos_por_materia_id:
		if datos_materia["materia"] == materia:
			return datos_materia["alumnos"]
	return []

func obtener_alumnos_de_materia(materia):
	
	for datos_materia in alumnos_por_materia:
		if datos_materia["materia"] == materia:
			return datos_materia["alumnos"]
	return []


func _on_ButtonSM_pressed() -> void:
	
	if materia_seleccionada["class_name"] != null:
		
		var alumnos_de_la_materia = obtener_alumnos_de_materia(materia_seleccionada["class_name"] + materia_seleccionada["division"]["division_name"])
		
		if alumnos_de_la_materia.empty():
			seleccion_materia_alumnos_por_curso.selected = -1
			label_mensaje_cursos.text = "La lista está vacía. Intente nuevamente."
			label_mensaje_cursos.visible = true
			return
		
		tabla_alumnos_por_curso.reiniciar_tabla()
		arreglo_alumnos = []
		
		yield(get_tree().create_timer(0.2), "timeout")
		for alumno in alumnos_de_la_materia:
			datos_alumno.insert(0,alumno.dni)
			datos_alumno.insert(1,alumno.lastname)
			datos_alumno.insert(2,alumno.firstname)
			datos_alumno.insert(3, alumno.username)
			arreglo_alumnos.append(datos_alumno)
			datos_alumno = []
		tabla_alumnos_por_curso.set_data(arreglo_alumnos)
		
		label_nombre_materia.text = materia_seleccionada["class_name"] + " " + materia_seleccionada["division"]["division_name"]
		
		activar_panel(panel_cursos)
		
		seleccion_materia_alumnos_por_curso.selected = -1


func _on_OptionButtonMateriaCN_item_selected(index: int) -> void:
	materia_seleccionada = listaMaterias[index]
	
	if materia_seleccionada["class_name"] != null:
		
		seleccion_alumno_cargar_notas.set_deferred("disabled",true)
		
		var alumnos_de_la_materia = obtener_alumnos_de_materia_id(materia_seleccionada["class_name"] + materia_seleccionada["division"]["division_name"])
		
		for alumno in alumnos_de_la_materia:
			seleccion_alumno_cargar_notas.get_popup().add_item(str(alumno.lastname) + " " + str(alumno.firstname))
		
		seleccion_alumno_cargar_notas.set_deferred("disabled",false)

func _on_OptionButtonAlumnoCN_item_selected(index: int) -> void:
	var alumnos_de_la_materia = obtener_alumnos_de_materia_id(materia_seleccionada["class_name"] + materia_seleccionada["division"]["division_name"])
	
	if alumnos_de_la_materia.empty():
		#seleccion_materia_alumnos_por_curso.selected = -1
		#label_mensaje_cursos.text = "La lista está vacía. Intente nuevamente."
		#label_mensaje_cursos.visible = true
		return
	
	alumno = alumnos_de_la_materia[index]

func _on_ButtonCN_pressed() -> void:
	
	var nota_1_numero = nota_1.text.to_int()
	var nota_2_numero = nota_2.text.to_int()
	var nota_3_numero = nota_3.text.to_int()
	
	if nota_1_numero < 0 or nota_2_numero < 0  or nota_3_numero < 0:
		$CargarNotas/PanelCargaNotas/CargaNotas/AnimationPlayer.play("Error")
		label_mensaje_estado_cargar_notas.text = "Las notas tiene que ser mayor a 0"
		label_mensaje_estado_cargar_notas.visible = true
		return
	if nota_1_numero > 10 or nota_2_numero > 10 or nota_3_numero > 10:
		$CargarNotas/PanelCargaNotas/CargaNotas/AnimationPlayer.play("Error")
		label_mensaje_estado_cargar_notas.text = "Las notas tiene que ser menor a 10"
		label_mensaje_estado_cargar_notas.visible = true
		return
	
	var json_data = {
		"id" : nota_Seleccionada["id"],
		"numeric_note_1" : nota_1.text,
		"numeric_note_2" : nota_2.text,
		"numeric_note_3" : nota_3.text
	}
	$ModificarNota.request(endpointModificarNota, header, true, HTTPClient.METHOD_PUT, JSON.print(json_data))

func _on_ModificarNota_request_completed(_result: int, response_code: int, _headers: PoolStringArray, _body: PoolByteArray) -> void:
	if response_code == 200:
		$CargarNotas/PanelCargaNotas/CargaNotas/AnimationPlayer.play("Exito")
		label_mensaje_estado_cargar_notas.text = "Notas modificadas con exito"
		label_mensaje_estado_cargar_notas.visible = true
	else:
		$CargarNotas/PanelCargaNotas/CargaNotas/AnimationPlayer.play("Error")
		label_mensaje_estado_cargar_notas.text = "Las notas no han sido modificadas"
		label_mensaje_estado_cargar_notas.visible = true
		return
	
	label_mensaje_estado_cargar_notas.visible = true
	yield(get_tree().create_timer(0.6),"timeout")
	activar_panel(panel_seleccion_alumno)
	label_mensaje_estado_cargar_notas.visible = false


func _on_GetNota_request_completed(_result: int, response_code: int, _headers: PoolStringArray, body: PoolByteArray) -> void:
	
	if response_code == 200:
		var json = JSON.parse(body.get_string_from_utf8())
		
		for nota in json.result:
			
			if nota["class_name"] == materia_seleccionada["class_name"]:
				nota_Seleccionada = nota
				nota_1.text = str(nota["numeric_note_1"])
				nota_2.text = str(nota["numeric_note_2"])
				nota_3.text = str(nota["numeric_note_3"])


func _on_ButtonBA_pressed():
	$GetNota.request('{URL}{id}'.format({"URL" : endpointNota, "id" : alumno["id"]}))
	
	#label_nota_nombre.text = "Notas de " + alumno["lastname"] + ", " + alumno["firstname"]
	#label_nota_materia.text = str(materia_seleccionada["class_name"] + " ("+ str(materia_seleccionada["division"]["division_name"]) + ")") 
	
	activar_panel(panel_carga_notas)
	
	seleccion_alumno_cargar_notas.clear()
	seleccion_alumno_cargar_notas.selected = -1
	seleccion_materia_cargar_notas.selected = -1
